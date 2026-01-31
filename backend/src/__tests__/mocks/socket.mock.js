/**
 * Mock for Socket.io
 */

// Store for tracking socket emissions
export const socketEmissions = [];

// Mock socket instance
export const mockSocket = {
    id: 'test-socket-id',
    emit: jest.fn((event, data) => {
        socketEmissions.push({ event, data });
    }),
    on: jest.fn(),
    join: jest.fn(),
    leave: jest.fn(),
    disconnect: jest.fn(),
    handshake: {
        query: {
            userId: '507f1f77bcf86cd799439011'
        }
    }
};

// Mock io instance
export const io = {
    emit: jest.fn((event, data) => {
        socketEmissions.push({ event, data });
    }),
    to: jest.fn().mockReturnThis(),
    on: jest.fn()
};

// User socket map mock
const userSocketMap = {};

export const getReciverSocketId = jest.fn((userId) => {
    return userSocketMap[userId];
});

export const setUserSocket = (userId, socketId) => {
    userSocketMap[userId] = socketId;
};

export const clearUserSockets = () => {
    Object.keys(userSocketMap).forEach(key => delete userSocketMap[key]);
};

export const resetSocketMocks = () => {
    socketEmissions.length = 0;
    io.emit.mockClear();
    io.to.mockClear();
    getReciverSocketId.mockClear();
    clearUserSockets();
};

export default { io, getReciverSocketId, mockSocket };
