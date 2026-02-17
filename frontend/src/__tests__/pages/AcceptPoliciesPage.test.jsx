/**
 * AcceptPoliciesPage Tests
 * Tests for the Accept Policies page with both Terms and Privacy Policy
 */

import React from 'react';
import { render, screen, fireEvent, waitFor } from '@testing-library/react';
import userEvent from '@testing-library/user-event';
import { BrowserRouter } from 'react-router-dom';
import { vi } from 'vitest';

// Mock the auth store
const mockAcceptPolicies = vi.fn();
const mockNavigate = vi.fn();

vi.mock('../../store/useAuthStore', () => ({
    useAuthStore: () => ({
        acceptPolicies: mockAcceptPolicies,
        isLoggingIn: false
    })
}));

vi.mock('react-router-dom', async () => {
    const actual = await vi.importActual('react-router-dom');
    return {
        ...actual,
        useNavigate: () => mockNavigate,
        useSearchParams: () => [
            new URLSearchParams({ email: 'test@example.com', token: 'temp-token-123' }),
            vi.fn()
        ]
    };
});

vi.mock('react-hot-toast', () => ({
    default: {
        error: vi.fn(),
        success: vi.fn()
    }
}));

import { AcceptPoliciesPage } from '../../pages/AcceptPoliciesPage';
import toast from 'react-hot-toast';

describe('AcceptPoliciesPage', () => {
    beforeEach(() => {
        vi.clearAllMocks();
    });

    describe('Page Rendering', () => {
        it('should render the page with required elements', () => {
            render(
                <BrowserRouter>
                    <AcceptPoliciesPage />
                </BrowserRouter>
            );

            expect(screen.getByText('Policy Update Required')).toBeInTheDocument();
            expect(screen.getByText(/Before you can continue using your account/i)).toBeInTheDocument();
            // Email appears as "Account: test@example.com"
            expect(screen.getByText(/Account: test@example.com/)).toBeInTheDocument();
        });

        it('should render Privacy Policy tab buttons', () => {
            render(
                <BrowserRouter>
                    <AcceptPoliciesPage />
                </BrowserRouter>
            );

            // Find by role to distinguish between tabs and links
            const tabs = screen.getAllByRole('button');
            const tabTexts = tabs.map(tab => tab.textContent);
            
            expect(tabTexts.some(text => text?.includes('Privacy Policy'))).toBe(true);
            expect(tabTexts.some(text => text?.includes('Terms and Conditions'))).toBe(true);
        });

        it('should render back to login button', () => {
            render(
                <BrowserRouter>
                    <AcceptPoliciesPage />
                </BrowserRouter>
            );

            expect(screen.getByText('Back to Login')).toBeInTheDocument();
        });

        it('should render acceptance checkbox', () => {
            render(
                <BrowserRouter>
                    <AcceptPoliciesPage />
                </BrowserRouter>
            );

            const checkbox = screen.getByRole('checkbox');
            expect(checkbox).toBeInTheDocument();
            expect(checkbox).not.toBeChecked();
        });

        it('should render accept and decline buttons', () => {
            render(
                <BrowserRouter>
                    <AcceptPoliciesPage />
                </BrowserRouter>
            );

            expect(screen.getByText('Accept and Continue')).toBeInTheDocument();
            expect(screen.getByText('Decline')).toBeInTheDocument();
        });
    });

    describe('Tab Navigation', () => {
        it('should have policy links with correct hrefs', () => {
            render(
                <BrowserRouter>
                    <AcceptPoliciesPage />
                </BrowserRouter>
            );

            // Find links by their href attributes
            const privacyLink = screen.getByRole('link', { name: /Privacy Policy/i });
            const termsLink = screen.getByRole('link', { name: /Terms and Conditions/i });

            expect(privacyLink).toHaveAttribute('href', '/privacy-policy');
            expect(termsLink).toHaveAttribute('href', '/terms-and-conditions');
        });
    });

    describe('Form Interactions', () => {
        it('should check checkbox when clicked', async () => {
            render(
                <BrowserRouter>
                    <AcceptPoliciesPage />
                </BrowserRouter>
            );

            const checkbox = screen.getByRole('checkbox');
            expect(checkbox).not.toBeChecked();

            await userEvent.click(checkbox);
            expect(checkbox).toBeChecked();
        });

        it('should show error when accepting without checking checkbox', async () => {
            render(
                <BrowserRouter>
                    <AcceptPoliciesPage />
                </BrowserRouter>
            );

            const acceptButton = screen.getByText('Accept and Continue');
            await userEvent.click(acceptButton);

            expect(toast.error).toHaveBeenCalledWith(
                'You must accept the privacy policy and terms and conditions to continue'
            );
        });

        it('should navigate to login when declining', async () => {
            render(
                <BrowserRouter>
                    <AcceptPoliciesPage />
                </BrowserRouter>
            );

            const declineButton = screen.getByText('Decline');
            await userEvent.click(declineButton);

            expect(toast.error).toHaveBeenCalledWith(
                'You must accept the policies to use this application'
            );
            expect(mockNavigate).toHaveBeenCalledWith('/login');
        });
    });

    describe('Accept Policies Submission', () => {
        it('should call acceptPolicies with correct data when checkbox is checked', async () => {
            mockAcceptPolicies.mockResolvedValue({ success: true });

            render(
                <BrowserRouter>
                    <AcceptPoliciesPage />
                </BrowserRouter>
            );

            const checkbox = screen.getByRole('checkbox');
            await userEvent.click(checkbox);

            const acceptButton = screen.getByText('Accept and Continue');
            await userEvent.click(acceptButton);

            await waitFor(() => {
                expect(mockAcceptPolicies).toHaveBeenCalledWith({
                    token: 'temp-token-123',
                    privacyPolicy: true,
                    termsAndConditions: true
                });
            });
        });

        it('should navigate to home on successful acceptance', async () => {
            mockAcceptPolicies.mockResolvedValue({ success: true });

            render(
                <BrowserRouter>
                    <AcceptPoliciesPage />
                </BrowserRouter>
            );

            const checkbox = screen.getByRole('checkbox');
            await userEvent.click(checkbox);

            const acceptButton = screen.getByText('Accept and Continue');
            await userEvent.click(acceptButton);

            await waitFor(() => {
                expect(mockNavigate).toHaveBeenCalledWith('/');
            });
        });
    });
});
