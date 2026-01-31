/**
 * Mock for Mongoose User model
 * Provides mock implementations for database operations
 */

// Default mock user data
export const mockUser = {
    _id: '507f1f77bcf86cd799439011',
    email: 'test@example.com',
    fullName: 'Test User',
    password: '$2a$10$hashedpassword',
    profilePic: '',
    createdAt: new Date(),
    updatedAt: new Date(),
    save: jest.fn().mockResolvedValue(this),
    toObject: jest.fn().mockReturnValue({
        _id: '507f1f77bcf86cd799439011',
        email: 'test@example.com',
        fullName: 'Test User',
        profilePic: ''
    })
};

// Create mock User model
const User = {
    findOne: jest.fn(),
    findById: jest.fn(),
    find: jest.fn(),
    findByIdAndUpdate: jest.fn(),
    create: jest.fn(),
    deleteOne: jest.fn(),
    deleteMany: jest.fn()
};

// Helper to reset all mocks
export const resetUserMocks = () => {
    User.findOne.mockReset();
    User.findById.mockReset();
    User.find.mockReset();
    User.findByIdAndUpdate.mockReset();
    User.create.mockReset();
};

// Helper to setup mock User constructor
export const createMockUserInstance = (data = {}) => {
    const instance = {
        ...mockUser,
        ...data,
        save: jest.fn().mockResolvedValue({ ...mockUser, ...data })
    };
    return instance;
};

export default User;
