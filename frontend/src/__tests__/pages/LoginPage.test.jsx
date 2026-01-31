/**
 * LoginPage Tests
 * Tests for login page rendering and user interactions
 */

import { describe, it, expect, vi, beforeEach } from 'vitest';
import { render, screen, fireEvent, waitFor } from '@testing-library/react';
import userEvent from '@testing-library/user-event';
import { BrowserRouter } from 'react-router-dom';
import { LoginPage } from '../../pages/LoginPage';

// Mock the auth store
const mockLogin = vi.fn();
const mockGoogleLogin = vi.fn();
vi.mock('../../store/useAuthStore', () => ({
    useAuthStore: vi.fn(() => ({
        login: mockLogin,
        isLoggingIn: false,
        googleLogin: mockGoogleLogin
    }))
}));

// Mock AuthImagePattern for simplicity
vi.mock('../../components/AuthImagePattern', () => ({
    default: ({ title, subtitle }) => (
        <div data-testid="auth-pattern">
            <h2>{title}</h2>
            <p>{subtitle}</p>
        </div>
    )
}));

import { useAuthStore } from '../../store/useAuthStore';

const renderLoginPage = () => {
    return render(
        <BrowserRouter>
            <LoginPage />
        </BrowserRouter>
    );
};

describe('LoginPage', () => {
    beforeEach(() => {
        vi.clearAllMocks();
        useAuthStore.mockReturnValue({
            login: mockLogin,
            isLoggingIn: false,
            googleLogin: mockGoogleLogin
        });
    });

    describe('Rendering', () => {
        it('should render login form with email and password fields', () => {
            // Act
            renderLoginPage();

            // Assert
            expect(screen.getByText('Welcome Back')).toBeInTheDocument();
            expect(screen.getByPlaceholderText('you@example.com')).toBeInTheDocument();
            expect(screen.getByPlaceholderText('••••••••')).toBeInTheDocument();
            expect(screen.getByRole('button', { name: /^sign in$/i })).toBeInTheDocument();
        });

        it('should render link to signup page', () => {
            // Act
            renderLoginPage();

            // Assert
            expect(screen.getByText(/don't have an account/i)).toBeInTheDocument();
            expect(screen.getByText('Create account')).toHaveAttribute('href', '/signup');
        });
    });

    describe('Loading State', () => {
        it('should show loading state during login', () => {
            // Arrange
            useAuthStore.mockReturnValue({
                login: mockLogin,
                isLoggingIn: true,
                googleLogin: mockGoogleLogin
            });

            // Act
            renderLoginPage();

            // Assert
            expect(screen.getByText('Loading...')).toBeInTheDocument();
            expect(screen.getByRole('button', { name: /loading/i })).toBeDisabled();
        });
    });

    describe('User Interactions', () => {
        it('should call login with form data on submit', async () => {
            // Arrange
            const user = userEvent.setup();
            renderLoginPage();

            // Act
            await user.type(screen.getByPlaceholderText('you@example.com'), 'test@example.com');
            await user.type(screen.getByPlaceholderText('••••••••'), 'password123');
            await user.click(screen.getByRole('button', { name: /^sign in$/i }));

            // Assert
            expect(mockLogin).toHaveBeenCalledWith({
                email: 'test@example.com',
                password: 'password123'
            });
        });

        it('should toggle password visibility', async () => {
            // Arrange
            const user = userEvent.setup();
            renderLoginPage();
            const passwordInput = screen.getByPlaceholderText('••••••••');

            // Assert initial state
            expect(passwordInput).toHaveAttribute('type', 'password');

            // Act - click toggle button
            const toggleButtons = screen.getAllByRole('button');
            const toggleButton = toggleButtons.find(btn =>
                btn.querySelector('svg') && !btn.textContent.includes('Sign in')
            );
            await user.click(toggleButton);

            // Assert - password visible
            expect(passwordInput).toHaveAttribute('type', 'text');

            // Act - click again
            await user.click(toggleButton);

            // Assert - password hidden
            expect(passwordInput).toHaveAttribute('type', 'password');
        });
    });

    describe('Form State', () => {
        it('should update form data on input change', async () => {
            // Arrange
            const user = userEvent.setup();
            renderLoginPage();

            // Act
            const emailInput = screen.getByPlaceholderText('you@example.com');
            const passwordInput = screen.getByPlaceholderText('••••••••');

            await user.type(emailInput, 'user@test.com');
            await user.type(passwordInput, 'secret123');

            // Assert
            expect(emailInput).toHaveValue('user@test.com');
            expect(passwordInput).toHaveValue('secret123');
        });
    });
});
