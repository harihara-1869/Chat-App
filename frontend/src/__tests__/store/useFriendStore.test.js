/**
 * useFriendStore Tests
 * Tests for friend system store actions and state management
 */

import { describe, it, expect, vi, beforeEach } from 'vitest';

// Mock axios instance - define mock inside factory to avoid hoisting issues
vi.mock('../../lib/axios', () => ({
    axiosInstance: {
        get: vi.fn(),
        post: vi.fn(),
    }
}));

// Mock react-hot-toast
vi.mock('react-hot-toast', () => ({
    default: {
        success: vi.fn(),
        error: vi.fn()
    }
}));

import { useFriendStore } from '../../store/useFriendStore';
import { axiosInstance } from '../../lib/axios';
import toast from 'react-hot-toast';

describe('useFriendStore', () => {
    beforeEach(() => {
        vi.clearAllMocks();
        // Reset store state
        useFriendStore.setState({
            friends: [],
            searchResults: [],
            pendingRequests: [],
            isLoading: false,
            isSearching: false,
        });
    });

    describe('Initial State', () => {
        it('should have correct initial state', () => {
            const state = useFriendStore.getState();

            expect(state.friends).toEqual([]);
            expect(state.searchResults).toEqual([]);
            expect(state.pendingRequests).toEqual([]);
            expect(state.isLoading).toBe(false);
            expect(state.isSearching).toBe(false);
        });
    });

    describe('getFriends', () => {
        it('should set isLoading to true while fetching', async () => {
            axiosInstance.get.mockResolvedValueOnce({ data: [] });

            const promise = useFriendStore.getState().getFriends();
            expect(useFriendStore.getState().isLoading).toBe(true);

            await promise;
        });

        it('should update friends on successful fetch', async () => {
            const mockFriends = [
                { _id: '1', fullName: 'Friend 1' },
                { _id: '2', fullName: 'Friend 2' }
            ];
            axiosInstance.get.mockResolvedValueOnce({ data: mockFriends });

            await useFriendStore.getState().getFriends();

            expect(useFriendStore.getState().friends).toEqual(mockFriends);
            expect(useFriendStore.getState().isLoading).toBe(false);
        });

        it('should show error toast on fetch failure', async () => {
            axiosInstance.get.mockRejectedValueOnce({
                response: { data: { error: 'Network error' } }
            });

            await useFriendStore.getState().getFriends();

            expect(toast.error).toHaveBeenCalledWith('Network error');
            expect(useFriendStore.getState().isLoading).toBe(false);
        });
    });

    describe('searchUsers', () => {
        it('should not search if query is less than 3 characters', async () => {
            await useFriendStore.getState().searchUsers('ab');

            expect(axiosInstance.get).not.toHaveBeenCalled();
            expect(useFriendStore.getState().searchResults).toEqual([]);
        });

        it('should search users with valid query', async () => {
            const mockResults = [{ _id: '1', fullName: 'Test User' }];
            axiosInstance.get.mockResolvedValueOnce({ data: mockResults });

            await useFriendStore.getState().searchUsers('test');

            expect(axiosInstance.get).toHaveBeenCalledWith('/search?q=test');
            expect(useFriendStore.getState().searchResults).toEqual(mockResults);
        });

        it('should set isSearching during search', async () => {
            axiosInstance.get.mockResolvedValueOnce({ data: [] });

            const promise = useFriendStore.getState().searchUsers('test user');
            expect(useFriendStore.getState().isSearching).toBe(true);

            await promise;
            expect(useFriendStore.getState().isSearching).toBe(false);
        });
    });

    describe('clearSearch', () => {
        it('should clear search results', () => {
            useFriendStore.setState({ searchResults: [{ _id: '1' }] });

            useFriendStore.getState().clearSearch();

            expect(useFriendStore.getState().searchResults).toEqual([]);
        });
    });

    describe('sendFriendRequest', () => {
        it('should call API and show success toast', async () => {
            axiosInstance.post.mockResolvedValueOnce({ data: { success: true } });
            useFriendStore.setState({
                searchResults: [
                    { _id: 'user-1' },
                    { _id: 'user-2' }
                ]
            });

            await useFriendStore.getState().sendFriendRequest('user-1');

            expect(axiosInstance.post).toHaveBeenCalledWith('/friend/request/user-1');
            expect(toast.success).toHaveBeenCalledWith('Friend request sent!');
        });

        it('should remove user from search results after sending request', async () => {
            axiosInstance.post.mockResolvedValueOnce({ data: { success: true } });
            useFriendStore.setState({
                searchResults: [
                    { _id: 'user-1', fullName: 'User 1' },
                    { _id: 'user-2', fullName: 'User 2' }
                ]
            });

            await useFriendStore.getState().sendFriendRequest('user-1');

            const results = useFriendStore.getState().searchResults;
            expect(results).toHaveLength(1);
            expect(results[0]._id).toBe('user-2');
        });

        it('should show error toast on failure', async () => {
            axiosInstance.post.mockRejectedValueOnce({
                response: { data: { error: 'Already friends' } }
            });

            await useFriendStore.getState().sendFriendRequest('user-1');

            expect(toast.error).toHaveBeenCalledWith('Already friends');
        });
    });

    describe('getPendingRequests', () => {
        it('should fetch and store pending requests', async () => {
            const mockRequests = [
                { _id: 'req-1', senderId: { fullName: 'User 1' } }
            ];
            axiosInstance.get.mockResolvedValueOnce({ data: mockRequests });

            await useFriendStore.getState().getPendingRequests();

            expect(axiosInstance.get).toHaveBeenCalledWith('/friend/requests/pending');
            expect(useFriendStore.getState().pendingRequests).toEqual(mockRequests);
        });
    });

    describe('acceptRequest', () => {
        it('should call API to accept request', async () => {
            axiosInstance.post.mockResolvedValueOnce({ data: { success: true } });
            axiosInstance.get.mockResolvedValueOnce({ data: [] }); // getFriends call
            useFriendStore.setState({
                pendingRequests: [{ _id: 'req-1' }, { _id: 'req-2' }]
            });

            await useFriendStore.getState().acceptRequest('req-1');

            expect(axiosInstance.post).toHaveBeenCalledWith('/friend/accept/req-1');
            expect(toast.success).toHaveBeenCalledWith('Friend request accepted!');
        });

        it('should remove request from pending after accepting', async () => {
            axiosInstance.post.mockResolvedValueOnce({ data: { success: true } });
            axiosInstance.get.mockResolvedValueOnce({ data: [] });
            useFriendStore.setState({
                pendingRequests: [
                    { _id: 'req-1' },
                    { _id: 'req-2' }
                ]
            });

            await useFriendStore.getState().acceptRequest('req-1');

            const pending = useFriendStore.getState().pendingRequests;
            expect(pending).toHaveLength(1);
            expect(pending[0]._id).toBe('req-2');
        });
    });

    describe('rejectRequest', () => {
        it('should call API to reject request', async () => {
            axiosInstance.post.mockResolvedValueOnce({ data: { success: true } });
            useFriendStore.setState({
                pendingRequests: [{ _id: 'req-1' }]
            });

            await useFriendStore.getState().rejectRequest('req-1');

            expect(axiosInstance.post).toHaveBeenCalledWith('/friend/reject/req-1');
            expect(toast.success).toHaveBeenCalledWith('Friend request rejected');
        });

        it('should remove request from pending after rejecting', async () => {
            axiosInstance.post.mockResolvedValueOnce({ data: { success: true } });
            useFriendStore.setState({
                pendingRequests: [
                    { _id: 'req-1' },
                    { _id: 'req-2' }
                ]
            });

            await useFriendStore.getState().rejectRequest('req-1');

            const pending = useFriendStore.getState().pendingRequests;
            expect(pending).toHaveLength(1);
            expect(pending[0]._id).toBe('req-2');
        });
    });
});
