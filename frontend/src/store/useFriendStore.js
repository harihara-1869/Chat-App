import { create } from "zustand";
import toast from "react-hot-toast";
import { axiosInstance } from "../lib/axios";

export const useFriendStore = create((set, get) => ({
    friends: [],
    searchResults: [],
    pendingRequests: [],
    isLoading: false,
    isSearching: false,

    getFriends: async () => {
        set({ isLoading: true });
        try {
            const res = await axiosInstance.get("/user/get-friends");
            set({ friends: res.data });
        } catch (error) {
            toast.error(error.response?.data?.error || "Failed to fetch friends");
        } finally {
            set({ isLoading: false });
        }
    },

    searchUsers: async (query) => {
        if (!query || query.trim().length < 3) {
            set({ searchResults: [] });
            return;
        }
        set({ isSearching: true });
        try {
            const res = await axiosInstance.get(`/search?q=${encodeURIComponent(query)}`);
            set({ searchResults: res.data });
        } catch (error) {
            toast.error(error.response?.data?.error || "Search failed");
            set({ searchResults: [] });
        } finally {
            set({ isSearching: false });
        }
    },

    clearSearch: () => {
        set({ searchResults: [] });
    },

    sendFriendRequest: async (userId) => {
        try {
            await axiosInstance.post(`/friend/request/${userId}`);
            toast.success("Friend request sent!");
            // Remove from search results
            set({ searchResults: get().searchResults.filter(u => u._id !== userId) });
        } catch (error) {
            toast.error(error.response?.data?.error || "Failed to send request");
        }
    },

    getPendingRequests: async () => {
        try {
            const res = await axiosInstance.get("/friend/requests/pending");
            set({ pendingRequests: res.data });
        } catch (error) {
            toast.error(error.response?.data?.error || "Failed to fetch requests");
        }
    },

    acceptRequest: async (requestId) => {
        try {
            await axiosInstance.post(`/friend/accept/${requestId}`);
            toast.success("Friend request accepted!");
            // Remove from pending and refresh friends
            set({ pendingRequests: get().pendingRequests.filter(r => r._id !== requestId) });
            get().getFriends();
        } catch (error) {
            toast.error(error.response?.data?.error || "Failed to accept request");
        }
    },

    rejectRequest: async (requestId) => {
        try {
            await axiosInstance.post(`/friend/reject/${requestId}`);
            toast.success("Friend request rejected");
            set({ pendingRequests: get().pendingRequests.filter(r => r._id !== requestId) });
        } catch (error) {
            toast.error(error.response?.data?.error || "Failed to reject request");
        }
    },
}));
