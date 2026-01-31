/**
 * Utils Tests
 * Tests for frontend utility functions
 */

import { describe, it, expect } from 'vitest';
import { formatMessageTime } from '../../lib/utils';

describe('formatMessageTime', () => {
    it('should format date to HH:MM format', () => {
        // Arrange
        const date = new Date('2024-01-15T14:30:00');

        // Act
        const result = formatMessageTime(date);

        // Assert
        expect(result).toMatch(/^\d{2}:\d{2}$/);
    });

    it('should format morning time correctly', () => {
        // Arrange
        const date = new Date('2024-01-15T09:05:00');

        // Act
        const result = formatMessageTime(date);

        // Assert
        expect(result).toBe('09:05');
    });

    it('should format afternoon time correctly', () => {
        // Arrange
        const date = new Date('2024-01-15T15:45:00');

        // Act
        const result = formatMessageTime(date);

        // Assert
        expect(result).toBe('15:45');
    });

    it('should handle midnight', () => {
        // Arrange
        const date = new Date('2024-01-15T00:00:00');

        // Act
        const result = formatMessageTime(date);

        // Assert
        expect(result).toBe('00:00');
    });

    it('should handle string date input', () => {
        // Arrange
        const dateString = '2024-06-20T18:30:00.000Z';

        // Act
        const result = formatMessageTime(dateString);

        // Assert
        expect(result).toMatch(/^\d{2}:\d{2}$/);
    });

    it('should handle ISO date string from MongoDB', () => {
        // Arrange - typical MongoDB timestamp
        const mongoDate = '2024-01-15T12:00:00.000Z';

        // Act
        const result = formatMessageTime(mongoDate);

        // Assert - exact time depends on timezone, but format should be correct
        expect(result).toMatch(/^\d{2}:\d{2}$/);
    });
});
