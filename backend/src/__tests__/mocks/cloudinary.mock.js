/**
 * Mock for Cloudinary
 */

const cloudinary = {
    uploader: {
        upload: jest.fn().mockResolvedValue({
            secure_url: 'https://res.cloudinary.com/test/image/upload/v123/test-image.jpg',
            public_id: 'test-image'
        }),
        destroy: jest.fn().mockResolvedValue({ result: 'ok' })
    },
    config: jest.fn()
};

export const resetCloudinaryMocks = () => {
    cloudinary.uploader.upload.mockReset();
    cloudinary.uploader.destroy.mockReset();
    cloudinary.config.mockReset();

    // Restore default behavior
    cloudinary.uploader.upload.mockResolvedValue({
        secure_url: 'https://res.cloudinary.com/test/image/upload/v123/test-image.jpg',
        public_id: 'test-image'
    });
};

export default cloudinary;
