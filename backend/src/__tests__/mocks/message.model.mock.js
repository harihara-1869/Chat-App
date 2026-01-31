/**
 * Mock for Mongoose Message model
 */

export const mockMessage = {
    _id: '507f1f77bcf86cd799439022',
    senderId: '507f1f77bcf86cd799439011',
    receiverId: '507f1f77bcf86cd799439012',
    text: 'Hello, this is a test message',
    image: null,
    createdAt: new Date(),
    updatedAt: new Date(),
    save: jest.fn().mockResolvedValue(this)
};

const Message = {
    find: jest.fn(),
    findOne: jest.fn(),
    findById: jest.fn(),
    create: jest.fn(),
    deleteOne: jest.fn(),
    deleteMany: jest.fn()
};

export const resetMessageMocks = () => {
    Message.find.mockReset();
    Message.findOne.mockReset();
    Message.findById.mockReset();
    Message.create.mockReset();
};

export const createMockMessageInstance = (data = {}) => {
    const instance = {
        ...mockMessage,
        ...data,
        save: jest.fn().mockResolvedValue({ ...mockMessage, ...data })
    };
    return instance;
};

export default Message;
