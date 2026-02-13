/**
 * SignUpPage Tests
 * Tests for signup page rendering, validation, and user interactions
 * Including email verification success flow
 */

import { describe, it, expect, vi, beforeEach } from 'vitest';
import { render, screen, waitFor } from '@testing-library/react';
import userEvent from '@testing-library/user-event';
import { BrowserRouter } from 'react-router-dom';
import { SignUpPage } from '../../pages/SignUpPage';

// Mock useNavigate
const mockNavigate = vi.fn();

// Mock the auth store
const mockSignup = vi.fn();
const mockGoogleLogin = vi.fn();
vi.mock('../../store/useAuthStore', () => ({
    useAuthStore: vi.fn(() => ({
        signup: mockSignup,
        isSigningUp: false,
        googleLogin: mockGoogleLogin
    }))
}));

vi.mock('react-router-dom', async () => {
    const actual = await vi.importActual('react-router-dom');
    return {
        ...actual,
        useNavigate: () => mockNavigate
    };
});

// Mock react-hot-toast
vi.mock('react-hot-toast', () => ({
    default: { error: vi.fn(), success: vi.fn() }
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

import { useAuthStore } from '../../store/useAuthStore';

const renderSignUpPage = () => {
    return render(
        <BrowserRouter>
            <SignUpPage />
        </BrowserRouter>
    );
};

describe('SignUpPage', () => {
    beforeEach(() => {
        vi.clearAllMocks();
        mockNavigate.mockClear();
        useAuthStore.mockReturnValue({
            signup: mockSignup,
            isSigningUp: false,
            googleLogin: mockGoogleLogin
        });
    });

    describe('Rendering', () => {
        it('should render signup form with all fields', () => {
            // Act
            renderSignUpPage();

            // Assert - use more specific selectors due to multiple matching elements
            expect(screen.getByRole('heading', { name: 'Create Account' })).toBeInTheDocument();
            expect(screen.getByPlaceholderText('John Doe')).toBeInTheDocument();
            expect(screen.getByPlaceholderText('you@example.com')).toBeInTheDocument();
            expect(screen.getByPlaceholderText('••••••••')).toBeInTheDocument();
        });

        it('should render link to login page', () => {
            // Act
            renderSignUpPage();

            // Assert
            expect(screen.getByText(/already have an account/i)).toBeInTheDocument();
            expect(screen.getByText('Sign in')).toHaveAttribute('href', '/login');
        });

        it('should render auth pattern sidebar', () => {
            // Act
            renderSignUpPage();

            // Assert
            expect(screen.getByTestId('auth-pattern')).toBeInTheDocument();
        });

        it('should render Google signup button', () => {
            renderSignUpPage();

            expect(screen.getByText(/sign up with google/i)).toBeInTheDocument();
        });
    });

    describe('Loading State', () => {
        it('should show loading state during signup', () => {
            // Arrange
            useAuthStore.mockReturnValue({
                signup: mockSignup,
                isSigningUp: true,
                googleLogin: mockGoogleLogin
            });

            // Act
            renderSignUpPage();

            // Assert
            expect(screen.getByText('Loading...')).toBeInTheDocument();
        });

        it('should disable button during loading', () => {
            // Arrange
            useAuthStore.mockReturnValue({
                signup: mockSignup,
                isSigningUp: true,
                googleLogin: mockGoogleLogin
            });

            // Act
            renderSignUpPage();

            // Assert
            const submitButton = document.querySelector('button[type="submit"]');
            expect(submitButton).toBeDisabled();
        });
    });

    describe('Password Toggle', () => {
        it('should toggle password visibility', async () => {
            // Arrange
            const user = userEvent.setup();
            renderSignUpPage();
            const passwordInput = screen.getByPlaceholderText('••••••••');

            // Assert initial state
            expect(passwordInput).toHaveAttribute('type', 'password');

            // Find and click toggle button (the one with type="button")
            const allButtons = screen.getAllByRole('button');
            const toggleButton = allButtons.find(btn =>
                btn.getAttribute('type') === 'button' &&
                !btn.textContent.includes('Loading') &&
                !btn.textContent.includes('Google')
            );

            await user.click(toggleButton);

            // Assert - password visible
            expect(passwordInput).toHaveAttribute('type', 'text');

            // Click again to hide
            await user.click(toggleButton);
            expect(passwordInput).toHaveAttribute('type', 'password');
        });
    });

    describe('Form Inputs', () => {
        it('should update input values when typing', async () => {
            // Arrange
            const user = userEvent.setup();
            renderSignUpPage();

            // Act & Assert - Full name
            const nameInput = screen.getByPlaceholderText('John Doe');
            await user.type(nameInput, 'Test User');
            expect(nameInput).toHaveValue('Test User');

            // Act & Assert - Email
            const emailInput = screen.getByPlaceholderText('you@example.com');
            await user.type(emailInput, 'test@example.com');
            expect(emailInput).toHaveValue('test@example.com');

            // Act & Assert - Password
            const passwordInput = screen.getByPlaceholderText('••••••••');
            await user.type(passwordInput, 'password123');
            expect(passwordInput).toHaveValue('password123');
        });
    });

    describe('Email Verification Flow', () => {
        it('should navigate to login after successful signup', async () => {
            // Arrange
            mockSignup.mockResolvedValueOnce({ success: true }); // Simulate success
            const user = userEvent.setup();
            renderSignUpPage();

            // Fill form
            await user.type(screen.getByPlaceholderText('John Doe'), 'Test User');
            await user.type(screen.getByPlaceholderText('you@example.com'), 'test@example.com');
            await user.type(screen.getByPlaceholderText('••••••••'), 'password123');

            // Check privacy policy checkbox
            const privacyCheckbox = screen.getByLabelText(/I agree to the/i);
            await user.click(privacyCheckbox);

            // Submit
            const submitButton = document.querySelector('button[type="submit"]');
            await user.click(submitButton);

            // Assert - should navigate to login
            await waitFor(() => {
                expect(mockNavigate).toHaveBeenCalledWith('/login');
            });
        });

        it('should call signup with form data including both policies', async () => {
            mockSignup.mockResolvedValueOnce({ success: true });
            const user = userEvent.setup();
            renderSignUpPage();

            await user.type(screen.getByPlaceholderText('John Doe'), 'Test User');
            await user.type(screen.getByPlaceholderText('you@example.com'), 'myemail@test.com');
            await user.type(screen.getByPlaceholderText('••••••••'), 'password123');

            // Check policies checkbox
            const policiesCheckbox = screen.getByLabelText(/I agree to the/i);
            await user.click(policiesCheckbox);

            const submitButton = document.querySelector('button[type="submit"]');
            await user.click(submitButton);

            await waitFor(() => {
                expect(mockSignup).toHaveBeenCalledWith({
                    fullName: 'Test User',
                    email: 'myemail@test.com',
                    password: 'password123',
                    privacyPolicy: true,
                    termsAndConditions: true
                });
            });
        });

        it('should NOT navigate on failed signup', async () => {
            mockSignup.mockResolvedValueOnce({ success: false }); // Simulate failure
            const user = userEvent.setup();
            renderSignUpPage();

            await user.type(screen.getByPlaceholderText('John Doe'), 'Test User');
            await user.type(screen.getByPlaceholderText('you@example.com'), 'test@example.com');
            await user.type(screen.getByPlaceholderText('••••••••'), 'password123');

            // Check privacy policy checkbox
            const privacyCheckbox = screen.getByLabelText(/I agree to the/i);
            await user.click(privacyCheckbox);

            const submitButton = document.querySelector('button[type="submit"]');
            await user.click(submitButton);

            // Should NOT navigate
            await waitFor(() => {
                expect(mockNavigate).not.toHaveBeenCalled();
            });

            // Should still show signup form
            expect(screen.getByRole('heading', { name: 'Create Account' })).toBeInTheDocument();
        });
    });

    describe('Google OAuth', () => {
        it('should call googleLogin when Google button clicked', async () => {
            const user = userEvent.setup();
            renderSignUpPage();

            const googleButton = screen.getByText(/sign up with google/i);
            await user.click(googleButton);

            expect(mockGoogleLogin).toHaveBeenCalled();
        });
    });
});
