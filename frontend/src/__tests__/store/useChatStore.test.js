/**
 * useChatStore Tests
 * Tests for chat state management
 */

import { describe, it, expect, vi, beforeEach } from 'vitest';
import { useChatStore } from '../../store/useChatStore';

// Mock axios
vi.mock('../../lib/axios', () => ({
    axiosInstance: {
        get: vi.fn(),
        post: vi.fn()
    }
}));

// Mock useAuthStore
vi.mock('../../store/useAuthStore', () => ({
    useAuthStore: {
        getState: vi.fn(() => ({
            socket: {
                on: vi.fn(),
                off: vi.fn()
            }
        }))
    }
}));

// Mock react-hot-toast
vi.mock('react-hot-toast', () => ({
    default: {
        error: vi.fn()
    }
}));

import { axiosInstance } from '../../lib/axios';
import toast from 'react-hot-toast';

describe('useChatStore', () => {
    beforeEach(() => {
        // Reset store state
        useChatStore.setState({
            messages: [],
            users: [],
            selectedUser: null,
            isUsersLoading: false,
            isMessagesLoading: false
        });

        vi.clearAllMocks();
    });

    describe('getUsers', () => {
        it('should fetch and set users', async () => {
            // Arrange
            const mockUsers = [
                { _id: 'user-1', fullName: 'User 1' },
                { _id: 'user-2', fullName: 'User 2' }
            ];
            axiosInstance.get.mockResolvedValue({ data: mockUsers });

            // Act
            await useChatStore.getState().getUsers();

            // Assert
            expect(axiosInstance.get).toHaveBeenCalledWith('/message/users');
            expect(useChatStore.getState().users).toEqual(mockUsers);
            expect(useChatStore.getState().isUsersLoading).toBe(false);
        });

        it('should show error toast on failure', async () => {
            // Arrange
            const error = { response: { data: { message: 'Failed to load users' } } };
            axiosInstance.get.mockRejectedValue(error);

            // Act
            await useChatStore.getState().getUsers();

            // Assert
            expect(toast.error).toHaveBeenCalledWith('Failed to load users');
            expect(useChatStore.getState().isUsersLoading).toBe(false);
        });
    });

    describe('getMessages', () => {
        it('should fetch messages for a user', async () => {
            // Arrange
            const mockMessages = [
                { _id: 'msg-1', text: 'Hello', senderId: 'user-1' },
                { _id: 'msg-2', text: 'Hi!', senderId: 'user-2' }
            ];
            axiosInstance.get.mockResolvedValue({ data: mockMessages });

            // Act
            await useChatStore.getState().getMessages('user-2');

            // Assert
            expect(axiosInstance.get).toHaveBeenCalledWith('/message/user-2');
            expect(useChatStore.getState().messages).toEqual(mockMessages);
            expect(useChatStore.getState().isMessagesLoading).toBe(false);
        });

        it('should show error toast on failure', async () => {
            // Arrange
            const error = { response: { data: { message: 'Failed to load messages' } } };
            axiosInstance.get.mockRejectedValue(error);

            // Act
            await useChatStore.getState().getMessages('user-2');

            // Assert
            expect(toast.error).toHaveBeenCalledWith('Failed to load messages');
            expect(useChatStore.getState().isMessagesLoading).toBe(false);
        });
    });

    describe('sendMessage', () => {
        it('should send message and add to list', async () => {
            // Arrange
            const selectedUser = { _id: 'user-2' };
            const existingMessages = [{ _id: 'msg-1', text: 'Hello' }];
            useChatStore.setState({ selectedUser, messages: existingMessages });

            const newMessage = { _id: 'msg-2', text: 'New message!' };
            axiosInstance.post.mockResolvedValue({ data: newMessage });

            // Act
            await useChatStore.getState().sendMessage({ text: 'New message!' });

            // Assert
            expect(axiosInstance.post).toHaveBeenCalledWith('/message/send/user-2', { text: 'New message!' });
            expect(useChatStore.getState().messages).toHaveLength(2);
            expect(useChatStore.getState().messages[1]).toEqual(newMessage);
        });

        it('should show error toast on failure', async () => {
            // Arrange
            const selectedUser = { _id: 'user-2' };
            useChatStore.setState({ selectedUser });
            const error = { response: { data: { message: 'Failed to send' } } };
            axiosInstance.post.mockRejectedValue(error);

            // Act
            await useChatStore.getState().sendMessage({ text: 'Hello' });

            // Assert
            expect(toast.error).toHaveBeenCalledWith('Failed to send');
        });
    });

    describe('setSelectedUser', () => {
        it('should update selectedUser', () => {
            // Arrange
            const user = { _id: 'user-123', fullName: 'Selected User' };

            // Act
            useChatStore.getState().setSelectedUser(user);

            // Assert
            expect(useChatStore.getState().selectedUser).toEqual(user);
        });

        it('should clear selectedUser when null passed', () => {
            // Arrange
            useChatStore.setState({ selectedUser: { _id: 'user-123' } });

            // Act
            useChatStore.getState().setSelectedUser(null);

            // Assert
            expect(useChatStore.getState().selectedUser).toBeNull();
        });
    });
});
