abstract class StorageFailure {
  final String message;
  const StorageFailure(this.message);
  
  @override
  String toString() => message;
}

class SessionNotFoundFailure extends StorageFailure {
  const SessionNotFoundFailure(String recipientId) 
      : super('Session not found for recipient: $recipientId');
}

class SessionUpdateFailure extends StorageFailure {
  const SessionUpdateFailure(String recipientId, String cause) 
      : super('Failed to update session for $recipientId: $cause');
}

class KeyNotFoundFailure extends StorageFailure {
  const KeyNotFoundFailure(String keyName) 
      : super('Key not found in secure storage: $keyName');
}

class DbOpenFailure extends StorageFailure {
  const DbOpenFailure(String cause) 
      : super('Failed to open encrypted database: $cause');
}

class IdentityKeyNotFoundFailure extends StorageFailure {
  const IdentityKeyNotFoundFailure() 
      : super('Identity key pair not found in secure storage');
}

class DbEncryptionKeyFailure extends StorageFailure {
  const DbEncryptionKeyFailure(String cause) 
      : super('Database encryption key error: $cause');
}