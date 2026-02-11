/**
 * useNotificationStore Tests
 * Tests for browser notification state management
 */

import { describe, it, expect, vi, beforeEach } from 'vitest';
import { useNotificationStore } from '../../store/useNotificationStore';

// Mock useChatStore
vi.mock('../../store/useChatStore', () => ({
    useChatStore: {
        getState: vi.fn(() => ({
            setSelectedUser: vi.fn(),
        })),
    },
}));

// Mock useFriendStore
vi.mock('../../store/useFriendStore', () => ({
    useFriendStore: {
        getState: vi.fn(() => ({
            friends: [
                { _id: 'user-1', fullName: 'Alice', profilePic: '/alice.png' },
                { _id: 'user-2', fullName: 'Bob', profilePic: null },
            ],
        })),
    },
}));

// Mock Notification API
const mockNotificationInstance = { close: vi.fn(), onclick: null };
const MockNotification = vi.fn(() => mockNotificationInstance);
MockNotification.permission = 'granted';
MockNotification.requestPermission = vi.fn(() => Promise.resolve('granted'));

vi.stubGlobal('Notification', MockNotification);

describe('useNotificationStore', () => {
    beforeEach(() => {
        useNotificationStore.setState({ permission: 'granted' });
        vi.clearAllMocks();
        MockNotification.permission = 'granted';
    });

    describe('initial state', () => {
        it('should have permission from Notification API', () => {
            expect(useNotificationStore.getState().permission).toBe('granted');
        });
    });

    describe('requestPermission', () => {
        it('should request permission if not granted', async () => {
            MockNotification.permission = 'default';
            MockNotification.requestPermission.mockResolvedValue('granted');

            await useNotificationStore.getState().requestPermission();

            expect(MockNotification.requestPermission).toHaveBeenCalled();
            expect(useNotificationStore.getState().permission).toBe('granted');
        });

        it('should not request permission if already granted', async () => {
            MockNotification.permission = 'granted';

            await useNotificationStore.getState().requestPermission();

            expect(MockNotification.requestPermission).not.toHaveBeenCalled();
        });

        it('should handle denied permission', async () => {
            MockNotification.permission = 'default';
            MockNotification.requestPermission.mockResolvedValue('denied');

            await useNotificationStore.getState().requestPermission();

            expect(useNotificationStore.getState().permission).toBe('denied');
        });
    });

    describe('notifyIfNeeded', () => {
        it('should create notification when permission is granted', () => {
            const message = { senderId: 'user-1', text: 'Hello!' };

            useNotificationStore.getState().notifyIfNeeded(message);

            expect(MockNotification).toHaveBeenCalledWith('Alice', {
                body: 'Hello!',
                icon: '/alice.png',
                tag: 'user-1',
            });
        });

        it('should use fallback name when sender is not in friends list', () => {
            const message = { senderId: 'unknown-user', text: 'Hey' };

            useNotificationStore.getState().notifyIfNeeded(message);

            expect(MockNotification).toHaveBeenCalledWith('New message', {
                body: 'Hey',
                icon: '/avatar.png',
                tag: 'unknown-user',
            });
        });

        it('should show "Sent an image" when message has no text', () => {
            const message = { senderId: 'user-1', text: '' };

            useNotificationStore.getState().notifyIfNeeded(message);

            expect(MockNotification).toHaveBeenCalledWith('Alice', {
                body: 'Sent an image',
                icon: '/alice.png',
                tag: 'user-1',
            });
        });

        it('should not notify when permission is denied', () => {
            useNotificationStore.setState({ permission: 'denied' });
            const message = { senderId: 'user-1', text: 'Hello!' };

            useNotificationStore.getState().notifyIfNeeded(message);

            expect(MockNotification).not.toHaveBeenCalled();
        });

        it('should not notify when permission is default', () => {
            useNotificationStore.setState({ permission: 'default' });
            const message = { senderId: 'user-1', text: 'Hello!' };

            useNotificationStore.getState().notifyIfNeeded(message);

            expect(MockNotification).not.toHaveBeenCalled();
        });
    });

    describe('showNotification', () => {
        it('should create notification with provided title and body', () => {
            useNotificationStore.getState().showNotification({
                title: 'Friend Request',
                body: 'Alice sent you a friend request!',
                icon: '/alice.png',
                tag: 'friend-request-123',
            });

            expect(MockNotification).toHaveBeenCalledWith('Friend Request', {
                body: 'Alice sent you a friend request!',
                icon: '/alice.png',
                tag: 'friend-request-123',
            });
        });

        it('should use default icon when none provided', () => {
            useNotificationStore.getState().showNotification({
                title: 'Test',
                body: 'Test body',
            });

            expect(MockNotification).toHaveBeenCalledWith('Test', {
                body: 'Test body',
                icon: '/avatar.png',
                tag: undefined,
            });
        });

        it('should not create notification when permission is denied', () => {
            useNotificationStore.setState({ permission: 'denied' });

            useNotificationStore.getState().showNotification({
                title: 'Test',
                body: 'Test body',
            });

            expect(MockNotification).not.toHaveBeenCalled();
        });

        it('should call onClick callback when notification is clicked', () => {
            const onClick = vi.fn();
            const mockFocus = vi.spyOn(window, 'focus').mockImplementation(() => { });

            useNotificationStore.getState().showNotification({
                title: 'Test',
                body: 'Test body',
                onClick,
            });

            // Simulate click
            mockNotificationInstance.onclick();

            expect(mockFocus).toHaveBeenCalled();
            expect(onClick).toHaveBeenCalled();
            expect(mockNotificationInstance.close).toHaveBeenCalled();

            mockFocus.mockRestore();
        });
    });
});
