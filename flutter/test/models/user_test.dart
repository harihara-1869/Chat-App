import 'package:flutter_test/flutter_test.dart';
import 'package:chat_app/features/auth/models/user.dart';

void main() {
  group('User Model', () {
    final testDateTime = DateTime(2024, 1, 1, 12, 0, 0);

    test('should create User with required fields', () {
      final user = User(
        id: '123',
        username: 'testuser',
        email: 'test@example.com',
        createdAt: testDateTime,
      );

      expect(user.id, '123');
      expect(user.username, 'testuser');
      expect(user.email, 'test@example.com');
      expect(user.profilePicture, isNull);
      expect(user.isVerified, false);
      expect(user.acceptedPrivacyPolicy, false);
      expect(user.acceptedTermsAndConditions, false);
      expect(user.createdAt, testDateTime);
    });

    test('should create User from JSON', () {
      final json = {
        '_id': '456',
        'username': 'jsonuser',
        'email': 'json@example.com',
        'profilePicture': 'https://example.com/pic.jpg',
        'isVerified': true,
        'acceptedPrivacyPolicy': true,
        'acceptedTermsAndConditions': true,
        'createdAt': '2024-01-01T12:00:00.000',
      };

      final user = User.fromJson(json);

      expect(user.id, '456');
      expect(user.username, 'jsonuser');
      expect(user.email, 'json@example.com');
      expect(user.profilePicture, 'https://example.com/pic.jpg');
      expect(user.isVerified, true);
      expect(user.acceptedPrivacyPolicy, true);
      expect(user.acceptedTermsAndConditions, true);
    });

    test('should handle missing optional fields in JSON', () {
      final json = {
        '_id': '789',
        'username': 'minimal',
        'email': 'minimal@example.com',
        'createdAt': '2024-01-01T12:00:00.000',
      };

      final user = User.fromJson(json);

      expect(user.profilePicture, isNull);
      expect(user.isVerified, false);
      expect(user.acceptedPrivacyPolicy, false);
      expect(user.acceptedTermsAndConditions, false);
    });

    test('should convert User to JSON', () {
      final user = User(
        id: '123',
        username: 'testuser',
        email: 'test@example.com',
        profilePicture: 'https://example.com/pic.jpg',
        isVerified: true,
        acceptedPrivacyPolicy: true,
        acceptedTermsAndConditions: true,
        createdAt: testDateTime,
      );

      final json = user.toJson();

      expect(json['_id'], '123');
      expect(json['username'], 'testuser');
      expect(json['email'], 'test@example.com');
      expect(json['profilePicture'], 'https://example.com/pic.jpg');
      expect(json['isVerified'], true);
      expect(json['acceptedPrivacyPolicy'], true);
      expect(json['acceptedTermsAndConditions'], true);
    });

    test('should copyWith User with new values', () {
      final user = User(
        id: '123',
        username: 'testuser',
        email: 'test@example.com',
        createdAt: testDateTime,
      );

      final updatedUser = user.copyWith(
        username: 'updateduser',
        acceptedPrivacyPolicy: true,
      );

      expect(updatedUser.id, '123'); // unchanged
      expect(updatedUser.username, 'updateduser');
      expect(updatedUser.email, 'test@example.com'); // unchanged
      expect(updatedUser.acceptedPrivacyPolicy, true);
    });

    test('should have correct props for equality', () {
      final user1 = User(
        id: '123',
        username: 'testuser',
        email: 'test@example.com',
        createdAt: testDateTime,
      );

      final user2 = User(
        id: '123',
        username: 'testuser',
        email: 'test@example.com',
        createdAt: testDateTime,
      );

      final user3 = User(
        id: '456',
        username: 'different',
        email: 'diff@example.com',
        createdAt: testDateTime,
      );

      expect(user1, equals(user2));
      expect(user1, isNot(equals(user3)));
    });
  });
}