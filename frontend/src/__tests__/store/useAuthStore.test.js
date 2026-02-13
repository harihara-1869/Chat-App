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
            expect(axiosInstance.get).toHaveBeenCalledWith('/user/get-user');
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
        it('should return success and NOT set authUser on signup (email verification required)', async () => {
            // Arrange
            const mockResponse = {
                message: 'Account created! Please check your email to verify.',
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
            expect(useAuthStore.getState().authUser).toBeNull(); // User not logged in yet
            expect(useAuthStore.getState().isSigningUp).toBe(false);
            expect(result.success).toBe(true);
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
            expect(result).toEqual({ success: false });
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
            expect(axiosInstance.put).toHaveBeenCalledWith('/user/update-profile', { profilePic: 'base64-image' });
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

    describe('requestPasswordReset', () => {
        it('should call reset-password endpoint and show success toast', async () => {
            // Arrange
            const mockResponse = { message: 'Reset password email sent' };
            axiosInstance.post.mockResolvedValue({ data: mockResponse });

            // Act
            const result = await useAuthStore.getState().requestPasswordReset('test@example.com');

            // Assert
            expect(axiosInstance.post).toHaveBeenCalledWith('/auth/reset-password', { email: 'test@example.com' });
            expect(toast.success).toHaveBeenCalledWith('Reset link sent! Check your email.');
            expect(result).toEqual(mockResponse);
            expect(useAuthStore.getState().isResettingPassword).toBe(false);
        });

        it('should show error toast on reset password failure', async () => {
            // Arrange
            const error = { response: { data: { message: 'User not found' } } };
            axiosInstance.post.mockRejectedValue(error);

            // Act & Assert
            await expect(useAuthStore.getState().requestPasswordReset('notfound@example.com'))
                .rejects.toEqual(error);
            expect(toast.error).toHaveBeenCalledWith('User not found');
            expect(useAuthStore.getState().isResettingPassword).toBe(false);
        });

        it('should set isResettingPassword to true during request', async () => {
            // Arrange
            let capturedState;
            axiosInstance.post.mockImplementation(() => {
                capturedState = useAuthStore.getState().isResettingPassword;
                return Promise.resolve({ data: {} });
            });

            // Act
            await useAuthStore.getState().requestPasswordReset('test@example.com');

            // Assert
            expect(capturedState).toBe(true);
            expect(useAuthStore.getState().isResettingPassword).toBe(false);
        });
    });

    describe('updatePassword', () => {
        it('should call update-password endpoint and show success toast', async () => {
            // Arrange
            const mockResponse = { message: 'Password updated successfully' };
            axiosInstance.post.mockResolvedValue({ data: mockResponse });

            // Act
            const result = await useAuthStore.getState().updatePassword('reset-token', 'newpass123');

            // Assert
            expect(axiosInstance.post).toHaveBeenCalledWith('/auth/update-password', {
                token: 'reset-token',
                newPassword: 'newpass123'
            });
            expect(toast.success).toHaveBeenCalledWith('Password reset successfully!');
            expect(result).toEqual(mockResponse);
            expect(useAuthStore.getState().isResettingPassword).toBe(false);
        });

        it('should show error toast on update password failure', async () => {
            // Arrange
            const error = { response: { data: { message: 'Invalid or expired token' } } };
            axiosInstance.post.mockRejectedValue(error);

            // Act & Assert
            await expect(useAuthStore.getState().updatePassword('bad-token', 'newpass123'))
                .rejects.toEqual(error);
            expect(toast.error).toHaveBeenCalledWith('Invalid or expired token');
            expect(useAuthStore.getState().isResettingPassword).toBe(false);
        });

        it('should set isResettingPassword to true during request', async () => {
            // Arrange
            let capturedState;
            axiosInstance.post.mockImplementation(() => {
                capturedState = useAuthStore.getState().isResettingPassword;
                return Promise.resolve({ data: {} });
            });

            // Act
            await useAuthStore.getState().updatePassword('token', 'password');

            // Assert
            expect(capturedState).toBe(true);
            expect(useAuthStore.getState().isResettingPassword).toBe(false);
        });
    });

    describe('verifyGoogleToken', () => {
        it('should verify Google OAuth temp token and return user data', async () => {
            // Arrange
            const mockUserData = {
                googleId: 'google-123',
                email: 'test@example.com',
                fullName: 'Test User',
                profilePic: 'https://example.com/pic.jpg',
                emailVerified: true
            };
            axiosInstance.get.mockResolvedValue({ data: mockUserData });

            // Act
            const result = await useAuthStore.getState().verifyGoogleToken('temp-token-123');

            // Assert
            expect(axiosInstance.get).toHaveBeenCalledWith('/auth/google/verify-token?token=temp-token-123');
            expect(result.success).toBe(true);
            expect(result.data).toEqual(mockUserData);
        });

        it('should show error toast and return failure on invalid token', async () => {
            // Arrange
            const error = { response: { data: { message: 'Invalid or expired token' } } };
            axiosInstance.get.mockRejectedValue(error);

            // Act
            const result = await useAuthStore.getState().verifyGoogleToken('invalid-token');

            // Assert
            expect(axiosInstance.get).toHaveBeenCalledWith('/auth/google/verify-token?token=invalid-token');
            expect(toast.error).toHaveBeenCalledWith('Invalid or expired token');
            expect(result.success).toBe(false);
            expect(result.error).toBe('Invalid or expired token');
        });
    });

    describe('completeGoogleSignup', () => {
        it('should complete Google signup and set authUser on success', async () => {
            // Arrange
            const mockUser = {
                _id: 'user-123',
                fullName: 'Test User',
                email: 'test@example.com',
                profilePic: null
            };
            const signupData = {
                tempToken: 'temp-token-123',
                privacyPolicy: true,
                fullName: 'Test User'
            };
            axiosInstance.post.mockResolvedValue({ data: mockUser });

            // Act
            const result = await useAuthStore.getState().completeGoogleSignup(signupData);

            // Assert
            expect(axiosInstance.post).toHaveBeenCalledWith('/auth/google/complete-signup', signupData);
            expect(useAuthStore.getState().authUser).toEqual(mockUser);
            expect(useAuthStore.getState().isSigningUp).toBe(false);
            expect(toast.success).toHaveBeenCalledWith('Account created successfully!');
            expect(result.success).toBe(true);
        });

        it('should show error toast on failure', async () => {
            // Arrange
            const error = { response: { data: { message: 'Token expired' } } };
            axiosInstance.post.mockRejectedValue(error);

            // Act
            const result = await useAuthStore.getState().completeGoogleSignup({
                tempToken: 'expired-token',
                privacyPolicy: true
            });

            // Assert
            expect(toast.error).toHaveBeenCalledWith('Token expired');
            expect(useAuthStore.getState().authUser).toBeNull();
            expect(useAuthStore.getState().isSigningUp).toBe(false);
            expect(result.success).toBe(false);
            expect(result.error).toBe('Token expired');
        });

        it('should set isSigningUp to true during request', async () => {
            // Arrange
            let capturedState;
            axiosInstance.post.mockImplementation(() => {
                capturedState = useAuthStore.getState().isSigningUp;
                return Promise.resolve({ data: {} });
            });

            // Act
            await useAuthStore.getState().completeGoogleSignup({
                tempToken: 'token',
                privacyPolicy: true
            });

            // Assert
            expect(capturedState).toBe(true);
            expect(useAuthStore.getState().isSigningUp).toBe(false);
        });
    });

    describe('acceptPolicies', () => {
        it('should accept policies and set authUser on success', async () => {
            // Arrange
            const mockUser = {
                _id: 'user-123',
                fullName: 'Test User',
                email: 'test@example.com',
                profilePic: null
            };
            const acceptData = {
                email: 'test@example.com',
                privacyPolicy: true,
                termsAndConditions: true
            };
            axiosInstance.post.mockResolvedValue({ data: mockUser });

            // Act
            const result = await useAuthStore.getState().acceptPolicies(acceptData);

            // Assert
            expect(axiosInstance.post).toHaveBeenCalledWith('/auth/google/accept-policies', acceptData);
            expect(useAuthStore.getState().authUser).toEqual(mockUser);
            expect(useAuthStore.getState().isLoggingIn).toBe(false);
            expect(toast.success).toHaveBeenCalledWith('Policies accepted successfully!');
            expect(result.success).toBe(true);
        });

        it('should show error toast on failure', async () => {
            // Arrange
            const error = { response: { data: { message: 'User not found' } } };
            axiosInstance.post.mockRejectedValue(error);

            // Act
            const result = await useAuthStore.getState().acceptPolicies({
                email: 'notfound@example.com',
                privacyPolicy: true,
                termsAndConditions: true
            });

            // Assert
            expect(toast.error).toHaveBeenCalledWith('User not found');
            expect(useAuthStore.getState().authUser).toBeNull();
            expect(useAuthStore.getState().isLoggingIn).toBe(false);
            expect(result.success).toBe(false);
            expect(result.error).toBe('User not found');
        });

        it('should set isLoggingIn to true during request', async () => {
            // Arrange
            let capturedState;
            axiosInstance.post.mockImplementation(() => {
                capturedState = useAuthStore.getState().isLoggingIn;
                return Promise.resolve({ data: {} });
            });

            // Act
            await useAuthStore.getState().acceptPolicies({
                email: 'test@example.com',
                privacyPolicy: true,
                termsAndConditions: true
            });

            // Assert
            expect(capturedState).toBe(true);
            expect(useAuthStore.getState().isLoggingIn).toBe(false);
        });
    });

    describe('googleLogin', () => {
        it('should redirect to Google OAuth endpoint', () => {
            // Arrange
            const originalLocation = window.location;
            delete window.location;
            window.location = { href: '' };

            // Act
            useAuthStore.getState().googleLogin();

            // Assert
            expect(window.location.href).toContain('/auth/google');

            // Cleanup
            window.location = originalLocation;
        });
    });
});
