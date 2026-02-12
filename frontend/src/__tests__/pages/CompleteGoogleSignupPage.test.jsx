/**
 * CompleteGoogleSignupPage Tests
 * Tests for the Google OAuth completion page with privacy policy acceptance
 */

import { describe, it, expect, vi, beforeEach, afterEach } from 'vitest';
import { render, screen, fireEvent, waitFor } from '@testing-library/react';
import { MemoryRouter, Routes, Route } from 'react-router-dom';

// Mock hooks before importing components
const mockNavigate = vi.fn();
const mockVerifyGoogleToken = vi.fn();
const mockCompleteGoogleSignup = vi.fn();

vi.mock('../../store/useAuthStore', () => ({
    useAuthStore: vi.fn(() => ({
        verifyGoogleToken: mockVerifyGoogleToken,
        completeGoogleSignup: mockCompleteGoogleSignup,
        isSigningUp: false
    }))
}));

vi.mock('react-hot-toast', () => ({
    default: {
        error: vi.fn(),
        success: vi.fn()
    }
}));

// Mock react-router-dom hooks
vi.mock('react-router-dom', async () => {
    const actual = await vi.importActual('react-router-dom');
    return {
        ...actual,
        useNavigate: () => mockNavigate,
        useSearchParams: () => [new URLSearchParams('?token=valid-token-123')]
    };
});

import { CompleteGoogleSignupPage } from '../../pages/CompleteGoogleSignupPage';
import { useAuthStore } from '../../store/useAuthStore';
import toast from 'react-hot-toast';

describe('CompleteGoogleSignupPage', () => {
    beforeEach(() => {
        vi.clearAllMocks();
        
        // Reset mock implementations
        useAuthStore.mockReturnValue({
            verifyGoogleToken: mockVerifyGoogleToken,
            completeGoogleSignup: mockCompleteGoogleSignup,
            isSigningUp: false
        });
    });

    afterEach(() => {
        vi.useRealTimers();
    });

    describe('Initial Load', () => {
        it('should verify token on mount', async () => {
            // Arrange
            const mockUserData = {
                googleId: 'google-123',
                email: 'test@example.com',
                fullName: 'Test User',
                profilePic: 'https://example.com/pic.jpg',
                emailVerified: true
            };
            mockVerifyGoogleToken.mockResolvedValue({
                success: true,
                data: mockUserData
            });

            // Act
            render(
                <MemoryRouter initialEntries={['/complete-google-signup?token=valid-token-123']}>
                    <Routes>
                        <Route path="/complete-google-signup" element={<CompleteGoogleSignupPage />} />
                    </Routes>
                </MemoryRouter>
            );

            // Assert
            await waitFor(() => {
                expect(mockVerifyGoogleToken).toHaveBeenCalledWith('valid-token-123');
            });
        });
    });

    describe('Form Display', () => {
        beforeEach(() => {
            const mockUserData = {
                googleId: 'google-123',
                email: 'test@example.com',
                fullName: 'Test User',
                profilePic: 'https://example.com/pic.jpg',
                emailVerified: true
            };
            mockVerifyGoogleToken.mockResolvedValue({
                success: true,
                data: mockUserData
            });
        });

        it('should display page title and subtitle', async () => {
            // Act
            render(
                <MemoryRouter initialEntries={['/complete-google-signup?token=valid-token-123']}>
                    <Routes>
                        <Route path="/complete-google-signup" element={<CompleteGoogleSignupPage />} />
                    </Routes>
                </MemoryRouter>
            );

            // Assert
            await waitFor(() => {
                expect(screen.getByText('Complete Your Profile')).toBeInTheDocument();
                expect(screen.getByText('One more step to get started')).toBeInTheDocument();
            });
        });

        it('should display privacy warning alert', async () => {
            // Act
            render(
                <MemoryRouter initialEntries={['/complete-google-signup?token=valid-token-123']}>
                    <Routes>
                        <Route path="/complete-google-signup" element={<CompleteGoogleSignupPage />} />
                    </Routes>
                </MemoryRouter>
            );

            // Assert
            await waitFor(() => {
                expect(screen.getByText(/Messages are stored in plain text/i)).toBeInTheDocument();
            });
        });

        it('should pre-fill email from Google data and make it read-only', async () => {
            // Act
            render(
                <MemoryRouter initialEntries={['/complete-google-signup?token=valid-token-123']}>
                    <Routes>
                        <Route path="/complete-google-signup" element={<CompleteGoogleSignupPage />} />
                    </Routes>
                </MemoryRouter>
            );

            // Assert
            await waitFor(() => {
                const emailInput = screen.getByDisplayValue('test@example.com');
                expect(emailInput).toBeInTheDocument();
                expect(emailInput).toHaveAttribute('readonly');
            });
        });

        it('should pre-fill full name from Google data and allow editing', async () => {
            // Act
            render(
                <MemoryRouter initialEntries={['/complete-google-signup?token=valid-token-123']}>
                    <Routes>
                        <Route path="/complete-google-signup" element={<CompleteGoogleSignupPage />} />
                    </Routes>
                </MemoryRouter>
            );

            // Assert
            await waitFor(() => {
                const nameInput = screen.getByDisplayValue('Test User');
                expect(nameInput).toBeInTheDocument();
                expect(nameInput).not.toHaveAttribute('readonly');
            });
        });

        it('should display privacy policy checkbox', async () => {
            // Act
            render(
                <MemoryRouter initialEntries={['/complete-google-signup?token=valid-token-123']}>
                    <Routes>
                        <Route path="/complete-google-signup" element={<CompleteGoogleSignupPage />} />
                    </Routes>
                </MemoryRouter>
            );

            // Assert
            await waitFor(() => {
                expect(screen.getByLabelText(/I agree to the/i)).toBeInTheDocument();
                expect(screen.getByText('Privacy Policy')).toBeInTheDocument();
            });
        });

        it('should have privacy policy link that opens in new tab', async () => {
            // Act
            render(
                <MemoryRouter initialEntries={['/complete-google-signup?token=valid-token-123']}>
                    <Routes>
                        <Route path="/complete-google-signup" element={<CompleteGoogleSignupPage />} />
                    </Routes>
                </MemoryRouter>
            );

            // Assert
            await waitFor(() => {
                const privacyLink = screen.getByText('Privacy Policy');
                expect(privacyLink).toHaveAttribute('href', '/privacy-policy');
                expect(privacyLink).toHaveAttribute('target', '_blank');
                expect(privacyLink).toHaveAttribute('rel', 'noopener noreferrer');
            });
        });
    });

    describe('Form Submission', () => {
        beforeEach(() => {
            const mockUserData = {
                googleId: 'google-123',
                email: 'test@example.com',
                fullName: 'Test User',
                profilePic: 'https://example.com/pic.jpg',
                emailVerified: true
            };
            mockVerifyGoogleToken.mockResolvedValue({
                success: true,
                data: mockUserData
            });
        });

        it('should show error if privacy policy is not accepted', async () => {
            // Act
            render(
                <MemoryRouter initialEntries={['/complete-google-signup?token=valid-token-123']}>
                    <Routes>
                        <Route path="/complete-google-signup" element={<CompleteGoogleSignupPage />} />
                    </Routes>
                </MemoryRouter>
            );

            // Wait for form to load
            await waitFor(() => {
                expect(screen.getByText('Complete Your Profile')).toBeInTheDocument();
            });

            // Submit without checking privacy policy
            const submitButton = screen.getByRole('button', { name: /Create Account/i });
            fireEvent.click(submitButton);

            // Assert
            expect(toast.error).toHaveBeenCalledWith('You must accept the privacy policy to continue');
            expect(mockCompleteGoogleSignup).not.toHaveBeenCalled();
        });

        it('should call completeGoogleSignup with correct data on valid submission', async () => {
            // Arrange
            mockCompleteGoogleSignup.mockResolvedValue({ success: true });

            // Act
            render(
                <MemoryRouter initialEntries={['/complete-google-signup?token=valid-token-123']}>
                    <Routes>
                        <Route path="/complete-google-signup" element={<CompleteGoogleSignupPage />} />
                    </Routes>
                </MemoryRouter>
            );

            // Wait for form to load
            await waitFor(() => {
                expect(screen.getByText('Complete Your Profile')).toBeInTheDocument();
            });

            // Check privacy policy
            const privacyCheckbox = screen.getByLabelText(/I agree to the/i);
            fireEvent.click(privacyCheckbox);

            // Change full name
            const nameInput = screen.getByDisplayValue('Test User');
            fireEvent.change(nameInput, { target: { value: 'Custom Name' } });

            // Submit form
            const submitButton = screen.getByRole('button', { name: /Create Account/i });
            fireEvent.click(submitButton);

            // Assert
            await waitFor(() => {
                expect(mockCompleteGoogleSignup).toHaveBeenCalledWith({
                    tempToken: 'valid-token-123',
                    privacyPolicy: true,
                    fullName: 'Custom Name'
                });
            });
        });

        it('should navigate to home on successful signup', async () => {
            // Arrange
            mockCompleteGoogleSignup.mockResolvedValue({ success: true });

            // Act
            render(
                <MemoryRouter initialEntries={['/complete-google-signup?token=valid-token-123']}>
                    <Routes>
                        <Route path="/complete-google-signup" element={<CompleteGoogleSignupPage />} />
                    </Routes>
                </MemoryRouter>
            );

            // Wait for form to load and submit
            await waitFor(() => {
                expect(screen.getByText('Complete Your Profile')).toBeInTheDocument();
            });

            const privacyCheckbox = screen.getByLabelText(/I agree to the/i);
            fireEvent.click(privacyCheckbox);

            const submitButton = screen.getByRole('button', { name: /Create Account/i });
            fireEvent.click(submitButton);

            // Assert
            await waitFor(() => {
                expect(mockNavigate).toHaveBeenCalledWith('/');
            });
        });
    });

    describe('Token Expiration', () => {
        it('should show error and redirect when token is invalid', async () => {
            // Arrange
            mockVerifyGoogleToken.mockResolvedValue({
                success: false,
                error: 'Invalid or expired signup token'
            });

            // Act
            render(
                <MemoryRouter initialEntries={['/complete-google-signup?token=expired-token']}>
                    <Routes>
                        <Route path="/complete-google-signup" element={<CompleteGoogleSignupPage />} />
                    </Routes>
                </MemoryRouter>
            );

            // Assert
            await waitFor(() => {
                expect(screen.getByText('Signup Expired')).toBeInTheDocument();
                expect(screen.getByText('Invalid or expired signup token')).toBeInTheDocument();
            });
        });
    });

    describe('Navigation', () => {
        beforeEach(() => {
            const mockUserData = {
                googleId: 'google-123',
                email: 'test@example.com',
                fullName: 'Test User',
                profilePic: 'https://example.com/pic.jpg',
                emailVerified: true
            };
            mockVerifyGoogleToken.mockResolvedValue({
                success: true,
                data: mockUserData
            });
        });

        it('should navigate back to login when back button is clicked', async () => {
            // Act
            render(
                <MemoryRouter initialEntries={['/complete-google-signup?token=valid-token-123']}>
                    <Routes>
                        <Route path="/complete-google-signup" element={<CompleteGoogleSignupPage />} />
                    </Routes>
                </MemoryRouter>
            );

            // Wait for form to load
            await waitFor(() => {
                expect(screen.getByText('Complete Your Profile')).toBeInTheDocument();
            });

            // Click back button
            const backButton = screen.getByRole('button', { name: /Back to Login/i });
            fireEvent.click(backButton);

            // Assert
            expect(mockNavigate).toHaveBeenCalledWith('/login');
        });
    });
});