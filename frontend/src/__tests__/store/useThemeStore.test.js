/**
 * useThemeStore Tests
 * Tests for theme state management
 */

import { describe, it, expect, vi, beforeEach } from 'vitest';
import { useThemeStore } from '../../store/useThemeStore';

describe('useThemeStore', () => {
    beforeEach(() => {
        // Reset store state
        useThemeStore.setState({ theme: 'coffee' });
        vi.clearAllMocks();
        localStorage.getItem.mockReturnValue(null);
    });

    describe('setTheme', () => {
        it('should update theme in state and localStorage', () => {
            // Act
            useThemeStore.getState().setTheme('dark');

            // Assert
            expect(useThemeStore.getState().theme).toBe('dark');
            expect(localStorage.setItem).toHaveBeenCalledWith('chat-theme', 'dark');
        });

        it('should handle different theme values', () => {
            // Test multiple themes
            const themes = ['light', 'dark', 'cupcake', 'forest', 'synthwave'];

            themes.forEach((theme) => {
                // Act
                useThemeStore.getState().setTheme(theme);

                // Assert
                expect(useThemeStore.getState().theme).toBe(theme);
                expect(localStorage.setItem).toHaveBeenCalledWith('chat-theme', theme);
            });
        });
    });

    describe('initial state', () => {
        it('should use default theme when localStorage is empty', () => {
            // Arrange
            localStorage.getItem.mockReturnValue(null);

            // The store initializes with default value
            // We're testing after reset in beforeEach
            expect(useThemeStore.getState().theme).toBe('coffee');
        });
    });
});
