/**
 * socketService Tests
 * Tests for centralized socket event listener management
 */

import { describe, it, expect, vi, beforeEach } from 'vitest';
import { initSocketListeners, cleanupSocketListeners } from '../../lib/socketService';

// Create mock socket
const mockSocket = {
    on: vi.fn(),
    off: vi.fn(),
};

// Mock stores
vi.mock('../../store/useAuthStore', () => ({
    useAuthStore: {
        getState: vi.fn(() => ({
            socket: mockSocket,
            authUser: { _id: 'current-user' },
        })),
        setState: vi.fn(),
    },
}));

vi.mock('../../store/useChatStore', () => ({
    useChatStore: {
        getState: vi.fn(() => ({
            selectedUser: null,
            isChatOpen: false,
            addMessage: vi.fn(),
        })),
        setState: vi.fn(),
    },
}));

vi.mock('../../store/useFriendStore', () => ({
    useFriendStore: {
        getState: vi.fn(() => ({
            friends: [
                { _id: 'user-1', fullName: 'Alice', profilePic: '/alice.png' },
            ],
            pendingRequests: [],
        })),
        setState: vi.fn(),
    },
}));

vi.mock('../../store/useNotificationStore', () => ({
    useNotificationStore: {
        getState: vi.fn(() => ({
            notifyIfNeeded: vi.fn(),
            showNotification: vi.fn(),
        })),
    },
}));

vi.mock('react-hot-toast', () => {
    const toastFn = vi.fn();
    toastFn.success = vi.fn();
    toastFn.error = vi.fn();
    return { default: toastFn };
});

import { useAuthStore } from '../../store/useAuthStore';
import { useChatStore } from '../../store/useChatStore';
import { useFriendStore } from '../../store/useFriendStore';
import { useNotificationStore } from '../../store/useNotificationStore';
import toast from 'react-hot-toast';

describe('socketService', () => {
    beforeEach(() => {
        vi.clearAllMocks();
        mockSocket.on.mockClear();
        mockSocket.off.mockClear();
    });

    describe('initSocketListeners', () => {
        it('should register all socket event listeners', () => {
            initSocketListeners();

            expect(mockSocket.on).toHaveBeenCalledWith('getOnlineUsers', expect.any(Function));
            expect(mockSocket.on).toHaveBeenCalledWith('newMessage', expect.any(Function));
            expect(mockSocket.on).toHaveBeenCalledWith('newFriendRequest', expect.any(Function));
            expect(mockSocket.on).toHaveBeenCalledWith('friendRequestAccepted', expect.any(Function));
            expect(mockSocket.on).toHaveBeenCalledTimes(4);
        });

        it('should clean up listeners before registering new ones', () => {
            initSocketListeners();

            // Should call off before on
            expect(mockSocket.off).toHaveBeenCalledWith('getOnlineUsers');
            expect(mockSocket.off).toHaveBeenCalledWith('newMessage');
            expect(mockSocket.off).toHaveBeenCalledWith('newFriendRequest');
            expect(mockSocket.off).toHaveBeenCalledWith('friendRequestAccepted');
        });

        it('should not register listeners if socket is null', () => {
            useAuthStore.getState.mockReturnValueOnce({
                socket: null,
                authUser: { _id: 'current-user' },
            });

            initSocketListeners();

            expect(mockSocket.on).not.toHaveBeenCalled();
        });
    });

    describe('cleanupSocketListeners', () => {
        it('should remove all socket event listeners', () => {
            cleanupSocketListeners();

            expect(mockSocket.off).toHaveBeenCalledWith('getOnlineUsers');
            expect(mockSocket.off).toHaveBeenCalledWith('newMessage');
            expect(mockSocket.off).toHaveBeenCalledWith('newFriendRequest');
            expect(mockSocket.off).toHaveBeenCalledWith('friendRequestAccepted');
            expect(mockSocket.off).toHaveBeenCalledTimes(4);
        });
    });

    describe('getOnlineUsers handler', () => {
        it('should update online users in auth store', () => {
            initSocketListeners();

            const handler = mockSocket.on.mock.calls.find(c => c[0] === 'getOnlineUsers')[1];
            handler(['user-1', 'user-2']);

            expect(useAuthStore.setState).toHaveBeenCalledWith({ onlineUsers: ['user-1', 'user-2'] });
        });
    });

    describe('newMessage handler', () => {
        it('should add message to chat when chat is open and visible', () => {
            const mockAddMessage = vi.fn();
            useChatStore.getState.mockReturnValue({
                selectedUser: { _id: 'user-1' },
                isChatOpen: true,
                addMessage: mockAddMessage,
            });

            // Mock tab as visible
            Object.defineProperty(document, 'visibilityState', {
                value: 'visible',
                writable: true,
                configurable: true,
            });

            initSocketListeners();
            const handler = mockSocket.on.mock.calls.find(c => c[0] === 'newMessage')[1];

            const message = { senderId: 'user-1', receiverId: 'current-user', text: 'Hi!' };
            handler(message);

            expect(mockAddMessage).toHaveBeenCalledWith(message);
        });

        it('should show browser notification when tab is hidden and message from another user', () => {
            const mockNotify = vi.fn();
            useNotificationStore.getState.mockReturnValue({
                notifyIfNeeded: mockNotify,
                showNotification: vi.fn(),
            });
            useChatStore.getState.mockReturnValue({
                selectedUser: null,
                isChatOpen: false,
                addMessage: vi.fn(),
            });

            Object.defineProperty(document, 'visibilityState', {
                value: 'hidden',
                writable: true,
                configurable: true,
            });

            initSocketListeners();
            const handler = mockSocket.on.mock.calls.find(c => c[0] === 'newMessage')[1];

            const message = { senderId: 'user-1', receiverId: 'current-user', text: 'Hello!' };
            handler(message);

            expect(mockNotify).toHaveBeenCalledWith(message);
        });

        it('should show toast when tab is visible but different chat is open', () => {
            useChatStore.getState.mockReturnValue({
                selectedUser: { _id: 'user-2' },
                isChatOpen: true,
                addMessage: vi.fn(),
            });

            Object.defineProperty(document, 'visibilityState', {
                value: 'visible',
                writable: true,
                configurable: true,
            });

            initSocketListeners();
            const handler = mockSocket.on.mock.calls.find(c => c[0] === 'newMessage')[1];

            const message = { senderId: 'user-1', receiverId: 'current-user', text: 'Hey there' };
            handler(message);

            expect(toast).toHaveBeenCalledWith('Hey there', {
                icon: '💬',
                duration: 3000,
            });
        });

        it('should not notify for own messages', () => {
            useChatStore.getState.mockReturnValue({
                selectedUser: null,
                isChatOpen: false,
                addMessage: vi.fn(),
            });

            Object.defineProperty(document, 'visibilityState', {
                value: 'hidden',
                writable: true,
                configurable: true,
            });

            initSocketListeners();
            const handler = mockSocket.on.mock.calls.find(c => c[0] === 'newMessage')[1];

            // Own message
            const message = { senderId: 'current-user', receiverId: 'user-1', text: 'My message' };
            handler(message);

            const mockNotify = useNotificationStore.getState().notifyIfNeeded;
            expect(mockNotify).not.toHaveBeenCalled();
        });
    });

    describe('newFriendRequest handler', () => {
        it('should add to pending requests and show toast when tab is visible', () => {
            Object.defineProperty(document, 'visibilityState', {
                value: 'visible',
                writable: true,
                configurable: true,
            });

            initSocketListeners();
            const handler = mockSocket.on.mock.calls.find(c => c[0] === 'newFriendRequest')[1];

            const request = { _id: 'req-1', senderId: { _id: 'user-3', fullName: 'Charlie' } };
            handler(request);

            expect(useFriendStore.setState).toHaveBeenCalledWith({
                pendingRequests: [request],
            });
            expect(toast.success).toHaveBeenCalledWith('Charlie sent you a friend request!');
        });

        it('should show browser notification when tab is hidden', () => {
            const mockShowNotification = vi.fn();
            useNotificationStore.getState.mockReturnValue({
                notifyIfNeeded: vi.fn(),
                showNotification: mockShowNotification,
            });

            Object.defineProperty(document, 'visibilityState', {
                value: 'hidden',
                writable: true,
                configurable: true,
            });

            initSocketListeners();
            const handler = mockSocket.on.mock.calls.find(c => c[0] === 'newFriendRequest')[1];

            const request = { _id: 'req-1', senderId: { _id: 'user-3', fullName: 'Charlie', profilePic: '/charlie.png' } };
            handler(request);

            expect(mockShowNotification).toHaveBeenCalledWith({
                title: 'Friend Request',
                body: 'Charlie sent you a friend request!',
                icon: '/charlie.png',
                tag: 'friend-request-req-1',
            });
            expect(toast.success).not.toHaveBeenCalled();
        });
    });

    describe('friendRequestAccepted handler', () => {
        it('should add to friends list and show toast when tab is visible', () => {
            Object.defineProperty(document, 'visibilityState', {
                value: 'visible',
                writable: true,
                configurable: true,
            });

            initSocketListeners();
            const handler = mockSocket.on.mock.calls.find(c => c[0] === 'friendRequestAccepted')[1];

            const friend = { _id: 'user-4', fullName: 'Diana' };
            handler({ friend });

            expect(useFriendStore.setState).toHaveBeenCalledWith({
                friends: [{ _id: 'user-1', fullName: 'Alice', profilePic: '/alice.png' }, friend],
            });
            expect(toast.success).toHaveBeenCalledWith('Diana is now your friend!');
        });

        it('should show browser notification when tab is hidden', () => {
            const mockShowNotification = vi.fn();
            useNotificationStore.getState.mockReturnValue({
                notifyIfNeeded: vi.fn(),
                showNotification: mockShowNotification,
            });

            Object.defineProperty(document, 'visibilityState', {
                value: 'hidden',
                writable: true,
                configurable: true,
            });

            initSocketListeners();
            const handler = mockSocket.on.mock.calls.find(c => c[0] === 'friendRequestAccepted')[1];

            const friend = { _id: 'user-4', fullName: 'Diana', profilePic: '/diana.png' };
            handler({ friend });

            expect(mockShowNotification).toHaveBeenCalledWith({
                title: 'Friend Request Accepted',
                body: 'Diana is now your friend!',
                icon: '/diana.png',
                tag: 'friend-accepted-user-4',
            });
            expect(toast.success).not.toHaveBeenCalled();
        });
    });
});
