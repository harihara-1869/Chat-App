/**
 * ResetPassword Page Tests
 * Tests for password reset page rendering and functionality
 */

import { describe, it, expect, vi, beforeEach } from 'vitest';
import { render, screen, fireEvent, waitFor } from '@testing-library/react';
import { MemoryRouter } from 'react-router-dom';
import { ResetPassword } from '../../pages/ResetPassword';

// Mock the auth store
const mockRequestPasswordReset = vi.fn();
const mockUpdatePassword = vi.fn();
vi.mock('../../store/useAuthStore', () => ({
    useAuthStore: vi.fn(() => ({
        requestPasswordReset: mockRequestPasswordReset,
        updatePassword: mockUpdatePassword,
        isResettingPassword: false
    }))
}));

// Mock AuthImagePattern
vi.mock('../../components/AuthImagePattern', () => ({
    default: ({ title, subtitle }) => (
        <div data-testid="auth-pattern">
            <h2>{title}</h2>
            <p>{subtitle}</p>
        </div>
    )
}));

// Mock useNavigate
const mockNavigate = vi.fn();
vi.mock('react-router-dom', async () => {
    const actual = await vi.importActual('react-router-dom');
    return {
        ...actual,
        useNavigate: () => mockNavigate,
    };
});

import { useAuthStore } from '../../store/useAuthStore';

const renderResetPasswordPage = (initialRoute = '/reset-password') => {
    return render(
        <MemoryRouter initialEntries={[initialRoute]}>
            <ResetPassword />
        </MemoryRouter>
    );
};

describe('ResetPassword Page', () => {
    beforeEach(() => {
        vi.clearAllMocks();
        useAuthStore.mockReturnValue({
            requestPasswordReset: mockRequestPasswordReset,
            updatePassword: mockUpdatePassword,
            isResettingPassword: false
        });
    });

    describe('Request Mode (no token)', () => {
        it('should render request mode when no token in URL', () => {
            renderResetPasswordPage();

            expect(screen.getByText(/forgot password/i)).toBeInTheDocument();
            expect(screen.getByPlaceholderText(/you@example.com/i)).toBeInTheDocument();
        });

        it('should render auth pattern sidebar', () => {
            renderResetPasswordPage();

            expect(screen.getByTestId('auth-pattern')).toBeInTheDocument();
        });

        it('should show email input field', () => {
            renderResetPasswordPage();

            const emailInput = screen.getByPlaceholderText(/you@example.com/i);
            expect(emailInput).toBeInTheDocument();
            expect(emailInput).toHaveAttribute('type', 'email');
        });

        it('should have send reset link button', () => {
            renderResetPasswordPage();

            expect(screen.getByRole('button', { name: /send reset link/i })).toBeInTheDocument();
        });

        it('should call requestPasswordReset when form submitted', async () => {
            mockRequestPasswordReset.mockResolvedValueOnce({});
            renderResetPasswordPage();

            const emailInput = screen.getByPlaceholderText(/you@example.com/i);
            fireEvent.change(emailInput, { target: { value: 'test@example.com' } });

            const submitButton = screen.getByRole('button', { name: /send reset link/i });
            fireEvent.click(submitButton);

            await waitFor(() => {
                expect(mockRequestPasswordReset).toHaveBeenCalledWith('test@example.com');
            });
        });

        it('should show success message after sending reset link', async () => {
            mockRequestPasswordReset.mockResolvedValueOnce({});
            renderResetPasswordPage();

            const emailInput = screen.getByPlaceholderText(/you@example.com/i);
            fireEvent.change(emailInput, { target: { value: 'test@example.com' } });

            const submitButton = screen.getByRole('button', { name: /send reset link/i });
            fireEvent.click(submitButton);

            await waitFor(() => {
                expect(screen.getByText(/reset link sent/i)).toBeInTheDocument();
            });
        });

        it('should show error message on failure', async () => {
            mockRequestPasswordReset.mockRejectedValueOnce({
                response: { data: { message: 'User not found' } }
            });
            renderResetPasswordPage();

            const emailInput = screen.getByPlaceholderText(/you@example.com/i);
            fireEvent.change(emailInput, { target: { value: 'notfound@example.com' } });

            const submitButton = screen.getByRole('button', { name: /send reset link/i });
            fireEvent.click(submitButton);

            await waitFor(() => {
                expect(screen.getByText(/user not found/i)).toBeInTheDocument();
            });
        });

        it('should have back to login link', () => {
            renderResetPasswordPage();

            expect(screen.getByText(/sign in/i)).toBeInTheDocument();
        });
    });

    describe('Reset Mode (with token)', () => {
        it('should render reset mode when token in URL', () => {
            renderResetPasswordPage('/reset-password?token=test-token');

            // Use role selector since "Reset Password" appears in multiple places (heading + button)
            expect(screen.getByRole('heading', { name: /reset password/i })).toBeInTheDocument();
            expect(screen.getAllByPlaceholderText('••••••••').length).toBeGreaterThan(0);
        });

        it('should show password and confirm password fields', () => {
            renderResetPasswordPage('/reset-password?token=test-token');

            // Use getAllByText since the text may appear in multiple places (label + pattern)
            const newPasswordLabels = screen.getAllByText(/new password/i);
            const confirmPasswordLabels = screen.getAllByText(/confirm password/i);
            expect(newPasswordLabels.length).toBeGreaterThan(0);
            expect(confirmPasswordLabels.length).toBeGreaterThan(0);
        });

        it('should have reset password button', () => {
            renderResetPasswordPage('/reset-password?token=test-token');

            expect(screen.getByRole('button', { name: /reset password/i })).toBeInTheDocument();
        });

        it('should show error when passwords do not match', async () => {
            renderResetPasswordPage('/reset-password?token=test-token');

            const passwordInputs = screen.getAllByPlaceholderText('••••••••');
            fireEvent.change(passwordInputs[0], { target: { value: 'password123' } });
            fireEvent.change(passwordInputs[1], { target: { value: 'different456' } });

            const submitButton = screen.getByRole('button', { name: /reset password/i });
            fireEvent.click(submitButton);

            await waitFor(() => {
                expect(screen.getByText(/passwords do not match/i)).toBeInTheDocument();
            });
        });

        it('should show error when password is too short', async () => {
            renderResetPasswordPage('/reset-password?token=test-token');

            const passwordInputs = screen.getAllByPlaceholderText('••••••••');
            fireEvent.change(passwordInputs[0], { target: { value: '123' } });
            fireEvent.change(passwordInputs[1], { target: { value: '123' } });

            const submitButton = screen.getByRole('button', { name: /reset password/i });
            fireEvent.click(submitButton);

            await waitFor(() => {
                expect(screen.getByText(/at least 6 characters/i)).toBeInTheDocument();
            });
        });

        it('should call updatePassword with token and new password', async () => {
            mockUpdatePassword.mockResolvedValueOnce({});
            renderResetPasswordPage('/reset-password?token=my-reset-token');

            const passwordInputs = screen.getAllByPlaceholderText('••••••••');
            fireEvent.change(passwordInputs[0], { target: { value: 'newpassword123' } });
            fireEvent.change(passwordInputs[1], { target: { value: 'newpassword123' } });

            const submitButton = screen.getByRole('button', { name: /reset password/i });
            fireEvent.click(submitButton);

            await waitFor(() => {
                expect(mockUpdatePassword).toHaveBeenCalledWith('my-reset-token', 'newpassword123');
            });
        });

        it('should show success message after password reset', async () => {
            mockUpdatePassword.mockResolvedValueOnce({});
            renderResetPasswordPage('/reset-password?token=test-token');

            const passwordInputs = screen.getAllByPlaceholderText('••••••••');
            fireEvent.change(passwordInputs[0], { target: { value: 'newpassword123' } });
            fireEvent.change(passwordInputs[1], { target: { value: 'newpassword123' } });

            const submitButton = screen.getByRole('button', { name: /reset password/i });
            fireEvent.click(submitButton);

            await waitFor(() => {
                expect(screen.getByText(/password reset successful/i)).toBeInTheDocument();
            });
        });

        it('should show error on reset failure', async () => {
            mockUpdatePassword.mockRejectedValueOnce({
                response: { data: { message: 'Invalid or expired token' } }
            });
            renderResetPasswordPage('/reset-password?token=invalid-token');

            const passwordInputs = screen.getAllByPlaceholderText('••••••••');
            fireEvent.change(passwordInputs[0], { target: { value: 'newpassword123' } });
            fireEvent.change(passwordInputs[1], { target: { value: 'newpassword123' } });

            const submitButton = screen.getByRole('button', { name: /reset password/i });
            fireEvent.click(submitButton);

            await waitFor(() => {
                expect(screen.getByText(/invalid or expired token/i)).toBeInTheDocument();
            });
        });
    });

    describe('Password Visibility Toggle', () => {
        it('should toggle password visibility', async () => {
            renderResetPasswordPage('/reset-password?token=test-token');

            const passwordInput = screen.getAllByPlaceholderText('••••••••')[0];
            expect(passwordInput).toHaveAttribute('type', 'password');

            // Find the toggle button (first eye button)
            const toggleButtons = screen.getAllByRole('button').filter(
                btn => !btn.textContent.includes('Reset')
            );

            if (toggleButtons.length > 0) {
                fireEvent.click(toggleButtons[0]);
                expect(passwordInput).toHaveAttribute('type', 'text');
            }
        });
    });
});
