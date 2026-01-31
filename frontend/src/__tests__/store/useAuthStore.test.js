/**
 * useAuthStore Tests
 * Tests for authentication state management
 */

import { describe, it, expect, vi, beforeEach } from 'vitest';
import { useAuthStore } from '../../store/useAuthStore';

// Mock axios
vi.mock('../../lib/axios', () => ({
    axiosInstance: {
        get: vi.fn(),
        post: vi.fn(),
        put: vi.fn()
    }
}));

// Mock socket.io-client
vi.mock('socket.io-client', () => ({
    io: vi.fn(() => ({
        connect: vi.fn(),
        disconnect: vi.fn(),
        on: vi.fn(),
        off: vi.fn(),
        connected: false
    }))
}));

// Mock react-hot-toast
vi.mock('react-hot-toast', () => ({
    default: {
        success: vi.fn(),
        error: vi.fn()
    }
}));

import { axiosInstance } from '../../lib/axios';
import toast from 'react-hot-toast';

describe('useAuthStore', () => {
    beforeEach(() => {
        // Reset store state
        useAuthStore.setState({
            authUser: null,
            isCheckingAuth: true,
            isSigningUp: false,
            isLoggingIn: false,
            isUpdatingProfile: false,
            onlineUsers: [],
            socket: null
        });

        vi.clearAllMocks();
    });

    describe('checkAuth', () => {
        it('should set authUser when authenticated', async () => {
            // Arrange
            const mockUser = {
                _id: 'user-123',
                fullName: 'Test User',
                email: 'test@example.com'
            };
            axiosInstance.get.mockResolvedValue({ data: mockUser });

            // Act
            await useAuthStore.getState().checkAuth();

            // Assert
            expect(axiosInstance.get).toHaveBeenCalledWith('/auth/get-user');
            expect(useAuthStore.getState().authUser).toEqual(mockUser);
            expect(useAuthStore.getState().isCheckingAuth).toBe(false);
        });

        it('should set authUser to null on error', async () => {
            // Arrange
            axiosInstance.get.mockRejectedValue(new Error('Unauthorized'));

            // Act
            await useAuthStore.getState().checkAuth();

            // Assert
            expect(useAuthStore.getState().authUser).toBeNull();
            expect(useAuthStore.getState().isCheckingAuth).toBe(false);
        });
    });

    describe('signup', () => {
        it('should return true and NOT set authUser on successful signup (email verification required)', async () => {
            // Arrange
            const mockResponse = {
                message: "Account created! Please verify your email to log in.",
                _id: 'user-123',
                fullName: 'New User',
                email: 'new@example.com'
            };
            const signupData = {
                fullName: 'New User',
                email: 'new@example.com',
                password: 'password123'
            };
            axiosInstance.post.mockResolvedValue({ data: mockResponse });

            // Act
            const result = await useAuthStore.getState().signup(signupData);

            // Assert - With email verification, signup does NOT set authUser
            expect(axiosInstance.post).toHaveBeenCalledWith('/auth/signup', signupData);
            expect(result).toBe(true); // Returns success indicator
            expect(useAuthStore.getState().authUser).toBeNull(); // NOT logged in
            expect(useAuthStore.getState().isSigningUp).toBe(false);
            expect(toast.success).toHaveBeenCalled();
        });

        it('should show error toast on signup failure', async () => {
            // Arrange
            const error = { response: { data: { message: 'Email already exists' } } };
            axiosInstance.post.mockRejectedValue(error);

            // Act
            const result = await useAuthStore.getState().signup({ email: 'existing@example.com' });

            // Assert
            expect(toast.error).toHaveBeenCalledWith('Email already exists');
            expect(result).toBe(false);
            expect(useAuthStore.getState().authUser).toBeNull();
            expect(useAuthStore.getState().isSigningUp).toBe(false);
        });
    });

    describe('login', () => {
        it('should set authUser on successful login', async () => {
            // Arrange
            const mockUser = {
                _id: 'user-123',
                fullName: 'Test User',
                email: 'test@example.com'
            };
            const loginData = { email: 'test@example.com', password: 'password123' };
            axiosInstance.post.mockResolvedValue({ data: mockUser });

            // Act
            await useAuthStore.getState().login(loginData);

            // Assert
            expect(axiosInstance.post).toHaveBeenCalledWith('/auth/login', loginData);
            expect(useAuthStore.getState().authUser).toEqual(mockUser);
            expect(useAuthStore.getState().isLoggingIn).toBe(false);
            expect(toast.success).toHaveBeenCalledWith('Login successful!');
        });

        it('should show error toast on login failure', async () => {
            // Arrange
            const error = { response: { data: { message: 'Invalid credentials' } } };
            axiosInstance.post.mockRejectedValue(error);

            // Act
            await useAuthStore.getState().login({ email: 'test@example.com', password: 'wrong' });

            // Assert
            expect(toast.error).toHaveBeenCalledWith('Invalid credentials');
            expect(useAuthStore.getState().authUser).toBeNull();
            expect(useAuthStore.getState().isLoggingIn).toBe(false);
        });
    });

    describe('logout', () => {
        it('should clear authUser on logout', async () => {
            // Arrange
            useAuthStore.setState({ authUser: { _id: 'user-123' } });
            axiosInstance.post.mockResolvedValue({});

            // Act
            await useAuthStore.getState().logout();

            // Assert
            expect(axiosInstance.post).toHaveBeenCalledWith('/auth/logout');
            expect(useAuthStore.getState().authUser).toBeNull();
            expect(toast.success).toHaveBeenCalledWith('Logged out successfully');
        });
    });

    describe('updateProfile', () => {
        it('should update authUser on successful profile update', async () => {
            // Arrange
            useAuthStore.setState({ authUser: { _id: 'user-123', profilePic: '' } });
            const updatedUser = { _id: 'user-123', profilePic: 'https://new-pic.jpg' };
            axiosInstance.put.mockResolvedValue({ data: updatedUser });

            // Act
            await useAuthStore.getState().updateProfile({ profilePic: 'base64-image' });

            // Assert
            expect(axiosInstance.put).toHaveBeenCalledWith('/auth/update-profile', { profilePic: 'base64-image' });
            expect(useAuthStore.getState().authUser).toEqual(updatedUser);
            expect(useAuthStore.getState().isUpdatingProfile).toBe(false);
            expect(toast.success).toHaveBeenCalledWith('Profile updated successfully!');
        });

        it('should show error toast on update failure', async () => {
            // Arrange
            const error = { response: { data: { message: 'Update failed' } } };
            axiosInstance.put.mockRejectedValue(error);

            // Act
            await useAuthStore.getState().updateProfile({ profilePic: 'base64-image' });

            // Assert
            expect(toast.error).toHaveBeenCalledWith('Update failed');
            expect(useAuthStore.getState().isUpdatingProfile).toBe(false);
        });
    });
});
