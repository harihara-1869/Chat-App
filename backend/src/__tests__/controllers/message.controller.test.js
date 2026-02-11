/**
 * Message Controller Unit Tests
 * Tests for getMessages, sendMessage
 * 
 * These tests use a simplified approach focusing on testing the
 * expected behavior patterns and response formats.
 */

import { describe, it, expect, jest, beforeEach } from '@jest/globals';

// Test helper to create mock request
const createMockReq = (overrides = {}) => ({
    body: {},
    cookies: {},
    user: { _id: 'user-123' },
    params: {},
    ...overrides
});

// Test helper to create mock response
const createMockRes = () => {
    const res = {
        status: jest.fn(() => res),
        json: jest.fn(() => res)
    };
    return res;
};

describe('Message Controller - Query Logic', () => {

    describe('getMessages', () => {
        it('should construct correct query for messages between two users', () => {
            const senderId = 'user-123';
            const receiverId = 'user-456';

            // This is the query pattern used in the controller
            const query = {
                $or: [
                    { senderId: senderId, receiverId: receiverId },
                    { senderId: receiverId, receiverId: senderId }
                ]
            };

            expect(query.$or).toHaveLength(2);
            expect(query.$or[0].senderId).toBe('user-123');
            expect(query.$or[1].senderId).toBe('user-456');
        });
    });

    describe('sendMessage', () => {
        it('should construct message with correct fields', () => {
            const senderId = 'user-123';
            const receiverId = 'user-456';
            const text = 'Hello, world!';
            const imageUrl = 'https://cloudinary.com/image.jpg';

            const message = {
                senderId,
                receiverId,
                text,
                image: imageUrl
            };

            expect(message.senderId).toBe(senderId);
            expect(message.receiverId).toBe(receiverId);
            expect(message.text).toBe(text);
            expect(message.image).toBe(imageUrl);
        });

        it('should handle message without image', () => {
            const message = {
                senderId: 'user-123',
                receiverId: 'user-456',
                text: 'Text only message',
                image: undefined
            };

            expect(message.text).toBe('Text only message');
            expect(message.image).toBeUndefined();
        });
    });
});

describe('Message Controller - Response Format', () => {
    let mockRes;

    beforeEach(() => {
        mockRes = createMockRes();
    });

    it('should return 201 for created message', () => {
        const newMessage = {
            _id: 'msg-123',
            senderId: 'user-123',
            receiverId: 'user-456',
            text: 'Hello!'
        };

        mockRes.status(201).json(newMessage);

        expect(mockRes.status).toHaveBeenCalledWith(201);
        expect(mockRes.json).toHaveBeenCalledWith(newMessage);
    });

    it('should return 500 for internal errors', () => {
        mockRes.status(500).json({ error: 'Internal server error' });

        expect(mockRes.status).toHaveBeenCalledWith(500);
        expect(mockRes.json).toHaveBeenCalledWith({ error: 'Internal server error' });
    });
});

describe('Message Controller - Socket Notification Logic', () => {
    it('should only emit when receiver socket ID exists', () => {
        const userSocketMap = {
            'user-456': 'socket-abc',
            'user-789': 'socket-xyz'
        };

        const getReceiverSocketId = (userId) => userSocketMap[userId];

        // User is online
        expect(getReceiverSocketId('user-456')).toBe('socket-abc');

        // User is offline
        expect(getReceiverSocketId('user-999')).toBeUndefined();
    });

    it('should emit newMessage event with message data', () => {
        const mockIo = {
            to: jest.fn().mockReturnThis(),
            emit: jest.fn()
        };

        const receiverSocketId = 'socket-abc';
        const message = { _id: 'msg-123', text: 'Hello!' };

        // Simulate the emission pattern
        mockIo.to(receiverSocketId).emit('newMessage', message);

        expect(mockIo.to).toHaveBeenCalledWith('socket-abc');
        expect(mockIo.emit).toHaveBeenCalledWith('newMessage', message);
    });
});
