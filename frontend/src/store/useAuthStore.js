import { create } from "zustand";
import { axiosInstance } from "../lib/axios";
import toast from "react-hot-toast";
import { io } from "socket.io-client"

const BASE_URL = import.meta.env.VITE_API_URL;
const SOCKET_URL = import.meta.env.VITE_SOCKET_URL || "http://localhost:5000";

export const useAuthStore = create((set, get) => ({
  authUser: null,
  isCheckingAuth: true,
  isSigningUp: false,
  isLoggingIn: false,
  isUpdatingProfile: false,
  isVerifyingEmail: false,
  isResettingPassword: false,
  onlineUsers: [],
  socket: null,

  checkAuth: async () => {
    try {
      const response = await axiosInstance.get("/auth/get-user");
      get().connectSocket();
      set({ authUser: response.data })
    } catch (err) {
      console.error("Auth check failed:", err);
      set({ authUser: null });
    } finally {
      set({ isCheckingAuth: false });
    }
  },

  signup: async (data) => {
    set({ isSigningUp: true });
    try {
      const res = await axiosInstance.post("/auth/signup", data);
      // Don't set authUser - user needs to verify email first
      toast.success(res.data.message || "Account created! Please check your email to verify.");
      return { success: true, message: res.data.message };
    } catch (error) {
      toast.error(error.response?.data?.message || "Signup failed");
      return { success: false };
    } finally {
      set({ isSigningUp: false });
    }
  },

  verifyEmail: async (token) => {
    set({ isVerifyingEmail: true });
    try {
      const res = await axiosInstance.post("/auth/verify-email", { token });
      set({ authUser: res.data });
      get().connectSocket();
      toast.success("Email verified successfully!");
    } catch (error) {
      toast.error(error.response?.data?.message || "Verification failed");
      throw error;
    } finally {
      set({ isVerifyingEmail: false });
    }
  },

  logout: async () => {
    try {
      await axiosInstance.post("/auth/logout");
      toast.success("Logged out successfully");
      get().disconnectSocket()
    } catch (err) {
      console.error("Logout failed:", err);
    } finally {
      set({ authUser: null });
    }
  },

  login: async (data) => {
    set({ isLoggingIn: true });
    try {
      const res = await axiosInstance.post("/auth/login", data);
      set({ authUser: res.data });
      toast.success("Login successful!");

      get().connectSocket();
    } catch (err) {
      toast.error(err.response?.data?.message || "Login failed");
    } finally {
      set({ isLoggingIn: false });
    }
  },

  updateProfile: async (data) => {
    set({ isUpdatingProfile: true });
    try {
      const res = await axiosInstance.put("/auth/update-profile", data);
      set({ authUser: res.data });
      toast.success("Profile updated successfully!");
    } catch (err) {
      console.error("Profile update failed:", err);
      toast.error(err.response?.data?.message || "Failed to update profile");
    } finally {
      set({ isUpdatingProfile: false });
    }
  },

  connectSocket: async () => {
    const { authUser } = get()
    if (!authUser || get().socket?.connected) return;

    const socket = io(SOCKET_URL, {
      withCredentials: true, // Send cookies with the handshake
    })
    socket.connect()
    set({ socket: socket });

    socket.on("getOnlineUsers", (userIds) => {
      set({ onlineUsers: userIds })
    })

    // Friend request socket events
    socket.on("newFriendRequest", (request) => {
      const { useFriendStore } = require("./useFriendStore");
      const store = useFriendStore.getState();
      store.pendingRequests = [...store.pendingRequests, request];
      useFriendStore.setState({ pendingRequests: store.pendingRequests });
      toast.success(`${request.senderId?.fullName || "Someone"} sent you a friend request!`);
    })

    socket.on("friendRequestAccepted", ({ friend }) => {
      const { useFriendStore } = require("./useFriendStore");
      useFriendStore.setState({
        friends: [...useFriendStore.getState().friends, friend]
      });
      toast.success(`${friend.fullName} is now your friend!`);
    })
  },

  disconnectSocket: async () => {
    if (get().socket?.connected) get().socket.disconnect();
  },

  // Email Verification
  verifyEmail: async (token) => {
    set({ isVerifyingEmail: true });
    try {
      const res = await axiosInstance.post("/auth/verify-email", { token });
      // Set authUser - user is now verified and logged in
      set({ authUser: res.data });
      toast.success("Email verified successfully!");
      get().connectSocket();
      return res.data;
    } catch (error) {
      toast.error(error.response?.data?.message || "Verification failed");
      throw error;
    } finally {
      set({ isVerifyingEmail: false });
    }
  },

  // Password Reset
  requestPasswordReset: async (email) => {
    set({ isResettingPassword: true });
    try {
      const res = await axiosInstance.post("/auth/reset-password", { email });
      toast.success("Reset link sent! Check your email.");
      return res.data;
    } catch (error) {
      toast.error(error.response?.data?.message || "Failed to send reset email");
      throw error;
    } finally {
      set({ isResettingPassword: false });
    }
  },

  updatePassword: async (token, newPassword) => {
    set({ isResettingPassword: true });
    try {
      const res = await axiosInstance.post("/auth/update-password", { token, newPassword });
      toast.success("Password reset successfully!");
      return res.data;
    } catch (error) {
      toast.error(error.response?.data?.message || "Failed to reset password");
      throw error;
    } finally {
      set({ isResettingPassword: false });
    }
  },

  // Google OAuth - redirect to backend Google auth endpoint
  googleLogin: () => {
    window.location.href = `${BASE_URL}/auth/google`;
  }
}));