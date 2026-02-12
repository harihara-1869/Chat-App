/**
 * PrivacyRequiredPage Tests
 * Tests for the privacy policy acceptance page for existing Google OAuth users
 */

import { describe, it, expect, vi, beforeEach, afterEach } from 'vitest';
import { render, screen, fireEvent, waitFor } from '@testing-library/react';
import { MemoryRouter, Routes, Route } from 'react-router-dom';

// Mock hooks before importing components
const mockNavigate = vi.fn();
const mockAcceptPrivacyPolicy = vi.fn();

vi.mock('../../store/useAuthStore', () => ({
    useAuthStore: vi.fn(() => ({
        acceptPrivacyPolicy: mockAcceptPrivacyPolicy,
        isLoggingIn: false
    }))
}));

// Mock the PrivacyPolicyContent component
vi.mock('../../components/PrivacyPolicyContent', () => ({
    PrivacyPolicyContent: () => <div data-testid="privacy-policy-content">Privacy Policy Content</div>
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
        useSearchParams: () => [new URLSearchParams('?email=test@example.com')]
    };
});

import { PrivacyRequiredPage } from '../../pages/PrivacyRequiredPage';
import { useAuthStore } from '../../store/useAuthStore';
import toast from 'react-hot-toast';

describe('PrivacyRequiredPage', () => {
    beforeEach(() => {
        vi.clearAllMocks();
        
        // Reset mock implementations
        useAuthStore.mockReturnValue({
            acceptPrivacyPolicy: mockAcceptPrivacyPolicy,
            isLoggingIn: false
        });
    });

    afterEach(() => {
        vi.useRealTimers();
    });

    describe('Page Layout', () => {
        it('should display header with title and description', async () => {
            // Act
            render(
                <MemoryRouter initialEntries={['/privacy-required?email=test@example.com']}>
                    <Routes>
                        <Route path="/privacy-required" element={<PrivacyRequiredPage />} />
                    </Routes>
                </MemoryRouter>
            );

            // Assert
            await waitFor(() => {
                expect(screen.getByText('Privacy Policy Update Required')).toBeInTheDocument();
                expect(screen.getByText(/Before you can continue using your account/i)).toBeInTheDocument();
            });
        });

        it('should display the email from URL params', async () => {
            // Act
            render(
                <MemoryRouter initialEntries={['/privacy-required?email=test@example.com']}>
                    <Routes>
                        <Route path="/privacy-required" element={<PrivacyRequiredPage />} />
                    </Routes>
                </MemoryRouter>
            );

            // Assert
            await waitFor(() => {
                expect(screen.getByText(/test@example.com/)).toBeInTheDocument();
            });
        });

        it('should display back to login button', async () => {
            // Act
            render(
                <MemoryRouter initialEntries={['/privacy-required?email=test@example.com']}>
                    <Routes>
                        <Route path="/privacy-required" element={<PrivacyRequiredPage />} />
                    </Routes>
                </MemoryRouter>
            );

            // Assert
            await waitFor(() => {
                expect(screen.getByRole('button', { name: /Back to Login/i })).toBeInTheDocument();
            });
        });

        it('should display privacy policy content', async () => {
            // Act
            render(
                <MemoryRouter initialEntries={['/privacy-required?email=test@example.com']}>
                    <Routes>
                        <Route path="/privacy-required" element={<PrivacyRequiredPage />} />
                    </Routes>
                </MemoryRouter>
            );

            // Assert
            await waitFor(() => {
                expect(screen.getByTestId('privacy-policy-content')).toBeInTheDocument();
            });
        });

        it('should display acceptance section with checkbox', async () => {
            // Act
            render(
                <MemoryRouter initialEntries={['/privacy-required?email=test@example.com']}>
                    <Routes>
                        <Route path="/privacy-required" element={<PrivacyRequiredPage />} />
                    </Routes>
                </MemoryRouter>
            );

            // Assert
            await waitFor(() => {
                expect(screen.getByText('Accept Privacy Policy')).toBeInTheDocument();
                expect(screen.getByLabelText(/I have read and agree to the Privacy Policy/i)).toBeInTheDocument();
            });
        });

        it('should display accept and decline buttons', async () => {
            // Act
            render(
                <MemoryRouter initialEntries={['/privacy-required?email=test@example.com']}>
                    <Routes>
                        <Route path="/privacy-required" element={<PrivacyRequiredPage />} />
                    </Routes>
                </MemoryRouter>
            );

            // Assert
            await waitFor(() => {
                expect(screen.getByRole('button', { name: /Accept and Continue/i })).toBeInTheDocument();
                expect(screen.getByRole('button', { name: /Decline/i })).toBeInTheDocument();
            });
        });

        it('should display acknowledgment text', async () => {
            // Act
            render(
                <MemoryRouter initialEntries={['/privacy-required?email=test@example.com']}>
                    <Routes>
                        <Route path="/privacy-required" element={<PrivacyRequiredPage />} />
                    </Routes>
                </MemoryRouter>
            );

            // Assert
            await waitFor(() => {
                expect(screen.getByText(/By clicking "Accept and Continue"/i)).toBeInTheDocument();
            });
        });
    });

    describe('Privacy Acceptance', () => {
        it('should show error if privacy policy is not checked', async () => {
            // Act
            render(
                <MemoryRouter initialEntries={['/privacy-required?email=test@example.com']}>
                    <Routes>
                        <Route path="/privacy-required" element={<PrivacyRequiredPage />} />
                    </Routes>
                </MemoryRouter>
            );

            // Wait for page to load
            await waitFor(() => {
                expect(screen.getByText('Privacy Policy Update Required')).toBeInTheDocument();
            });

            // Click accept without checking checkbox
            const acceptButton = screen.getByRole('button', { name: /Accept and Continue/i });
            fireEvent.click(acceptButton);

            // Assert
            expect(toast.error).toHaveBeenCalledWith('You must accept the privacy policy to continue');
            expect(mockAcceptPrivacyPolicy).not.toHaveBeenCalled();
        });

        it('should call acceptPrivacyPolicy with email and privacyPolicy true', async () => {
            // Arrange
            mockAcceptPrivacyPolicy.mockResolvedValue({ success: true });

            // Act
            render(
                <MemoryRouter initialEntries={['/privacy-required?email=test@example.com']}>
                    <Routes>
                        <Route path="/privacy-required" element={<PrivacyRequiredPage />} />
                    </Routes>
                </MemoryRouter>
            );

            // Wait for page to load
            await waitFor(() => {
                expect(screen.getByText('Privacy Policy Update Required')).toBeInTheDocument();
            });

            // Check privacy policy checkbox
            const privacyCheckbox = screen.getByLabelText(/I have read and agree to the Privacy Policy/i);
            fireEvent.click(privacyCheckbox);

            // Click accept
            const acceptButton = screen.getByRole('button', { name: /Accept and Continue/i });
            fireEvent.click(acceptButton);

            // Assert
            await waitFor(() => {
                expect(mockAcceptPrivacyPolicy).toHaveBeenCalledWith({
                    email: 'test@example.com',
                    privacyPolicy: true
                });
            });
        });

        it('should navigate to home on successful acceptance', async () => {
            // Arrange
            mockAcceptPrivacyPolicy.mockResolvedValue({ success: true });

            // Act
            render(
                <MemoryRouter initialEntries={['/privacy-required?email=test@example.com']}>
                    <Routes>
                        <Route path="/privacy-required" element={<PrivacyRequiredPage />} />
                    </Routes>
                </MemoryRouter>
            );

            // Wait for page to load
            await waitFor(() => {
                expect(screen.getByText('Privacy Policy Update Required')).toBeInTheDocument();
            });

            const privacyCheckbox = screen.getByLabelText(/I have read and agree to the Privacy Policy/i);
            fireEvent.click(privacyCheckbox);

            const acceptButton = screen.getByRole('button', { name: /Accept and Continue/i });
            fireEvent.click(acceptButton);

            // Assert
            await waitFor(() => {
                expect(mockNavigate).toHaveBeenCalledWith('/');
            });
        });
    });

    describe('Decline Action', () => {
        it('should show error and redirect to login on decline', async () => {
            // Act
            render(
                <MemoryRouter initialEntries={['/privacy-required?email=test@example.com']}>
                    <Routes>
                        <Route path="/privacy-required" element={<PrivacyRequiredPage />} />
                    </Routes>
                </MemoryRouter>
            );

            // Wait for page to load
            await waitFor(() => {
                expect(screen.getByText('Privacy Policy Update Required')).toBeInTheDocument();
            });

            // Click decline
            const declineButton = screen.getByRole('button', { name: /Decline/i });
            fireEvent.click(declineButton);

            // Assert
            expect(toast.error).toHaveBeenCalledWith('You must accept the privacy policy to use this application');
            expect(mockNavigate).toHaveBeenCalledWith('/login');
        });
    });

    describe('Navigation', () => {
        it('should navigate back to login when back button is clicked', async () => {
            // Act
            render(
                <MemoryRouter initialEntries={['/privacy-required?email=test@example.com']}>
                    <Routes>
                        <Route path="/privacy-required" element={<PrivacyRequiredPage />} />
                    </Routes>
                </MemoryRouter>
            );

            // Wait for page to load
            await waitFor(() => {
                expect(screen.getByText('Privacy Policy Update Required')).toBeInTheDocument();
            });

            // Click back button
            const backButton = screen.getByRole('button', { name: /Back to Login/i });
            fireEvent.click(backButton);

            // Assert
            expect(mockNavigate).toHaveBeenCalledWith('/login');
        });
    });

    describe('Error Handling', () => {
        it('should handle API failure gracefully', async () => {
            // Arrange
            mockAcceptPrivacyPolicy.mockResolvedValue({ 
                success: false, 
                error: 'Server error' 
            });

            // Act
            render(
                <MemoryRouter initialEntries={['/privacy-required?email=test@example.com']}>
                    <Routes>
                        <Route path="/privacy-required" element={<PrivacyRequiredPage />} />
                    </Routes>
                </MemoryRouter>
            );

            // Wait for page to load
            await waitFor(() => {
                expect(screen.getByText('Privacy Policy Update Required')).toBeInTheDocument();
            });

            const privacyCheckbox = screen.getByLabelText(/I have read and agree to the Privacy Policy/i);
            fireEvent.click(privacyCheckbox);

            const acceptButton = screen.getByRole('button', { name: /Accept and Continue/i });
            fireEvent.click(acceptButton);

            // Assert - should not navigate on failure
            await waitFor(() => {
                expect(mockAcceptPrivacyPolicy).toHaveBeenCalled();
            });
            expect(mockNavigate).not.toHaveBeenCalledWith('/');
        });
    });
});