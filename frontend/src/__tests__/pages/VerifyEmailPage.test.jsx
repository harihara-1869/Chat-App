/**
 * VerifyEmailPage Tests
 * Tests for email verification page rendering and token handling
 */

import { describe, it, expect, vi, beforeEach } from 'vitest';
import { render, screen, waitFor } from '@testing-library/react';
import { BrowserRouter, MemoryRouter } from 'react-router-dom';
import { VerifyEmailPage } from '../../pages/VerifyEmailPage';

// Mock the auth store
const mockVerifyEmail = vi.fn();
vi.mock('../../store/useAuthStore', () => ({
    useAuthStore: vi.fn(() => ({
        verifyEmail: mockVerifyEmail,
        isVerifyingEmail: false
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

const renderVerifyEmailPage = (initialRoute = '/verify-email?token=test-token') => {
    return render(
        <MemoryRouter initialEntries={[initialRoute]}>
            <VerifyEmailPage />
        </MemoryRouter>
    );
};

describe('VerifyEmailPage', () => {
    beforeEach(() => {
        vi.clearAllMocks();
        useAuthStore.mockReturnValue({
            verifyEmail: mockVerifyEmail,
            isVerifyingEmail: false
        });
    });

    describe('Rendering', () => {
        it('should render auth pattern sidebar', () => {
            renderVerifyEmailPage();

            expect(screen.getByTestId('auth-pattern')).toBeInTheDocument();
        });

        it('should show verifying state initially when token is present', () => {
            renderVerifyEmailPage();

            expect(screen.getByText(/verifying/i)).toBeInTheDocument();
        });
    });

    describe('Token Handling', () => {
        it('should show error state when no token is provided', async () => {
            renderVerifyEmailPage('/verify-email');

            await waitFor(() => {
                expect(screen.getByText(/verification failed/i)).toBeInTheDocument();
            });
        });

        it('should call verifyEmail with token from URL', async () => {
            mockVerifyEmail.mockResolvedValueOnce({});

            renderVerifyEmailPage('/verify-email?token=my-test-token');

            await waitFor(() => {
                expect(mockVerifyEmail).toHaveBeenCalledWith('my-test-token');
            });
        });

        it('should show success state after successful verification', async () => {
            mockVerifyEmail.mockResolvedValueOnce({});

            renderVerifyEmailPage();

            await waitFor(() => {
                expect(screen.getByText(/email verified/i)).toBeInTheDocument();
            });
        });

        it('should show error state on verification failure', async () => {
            mockVerifyEmail.mockRejectedValueOnce(new Error('Invalid token'));

            renderVerifyEmailPage();

            await waitFor(() => {
                expect(screen.getByText(/verification failed/i)).toBeInTheDocument();
            });
        });
    });

    describe('Navigation', () => {
        it('should show back to login link on error', async () => {
            mockVerifyEmail.mockRejectedValueOnce(new Error('Invalid token'));

            renderVerifyEmailPage();

            await waitFor(() => {
                expect(screen.getByText(/back to login/i)).toBeInTheDocument();
            });
        });
    });
});
