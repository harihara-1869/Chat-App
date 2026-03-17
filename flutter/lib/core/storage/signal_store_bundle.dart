import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:libsignal/libsignal.dart';

import 'identity_key_store.dart';
import 'kyber_pre_key_store.dart';
import 'pre_key_store.dart';
import 'session_store.dart';
import 'signed_pre_key_store.dart';

class SignalStoreBundle {
  final DriftSignalSessionStore sessionStore;
  final DriftIdentityKeyStore identityKeyStore;
  final DriftPreKeyStore preKeyStore;
  final DriftSignedPreKeyStore signedPreKeyStore;
  final DriftKyberPreKeyStore kyberPreKeyStore;

  SignalStoreBundle({
    required this.sessionStore,
    required this.identityKeyStore,
    required this.preKeyStore,
    required this.signedPreKeyStore,
    required this.kyberPreKeyStore,
  });

  SessionCipher getSessionCipher(ProtocolAddress address) {
    return SessionCipher(
      sessionStore: sessionStore,
      identityKeyStore: identityKeyStore,
      preKeyStore: preKeyStore,
      signedPreKeyStore: signedPreKeyStore,
      kyberPreKeyStore: kyberPreKeyStore,
    );
  }

  SessionBuilder getSessionBuilder(ProtocolAddress address) {
    return SessionBuilder(
      sessionStore: sessionStore,
      identityKeyStore: identityKeyStore,
    );
  }
}

final signalStoreBundleProvider = Provider<SignalStoreBundle>((ref) {
  final sessionStore = ref.watch(driftSessionStoreProvider);
  final identityKeyStore = ref.watch(driftIdentityKeyStoreProvider);
  final preKeyStore = ref.watch(driftPreKeyStoreProvider);
  final signedPreKeyStore = ref.watch(driftSignedPreKeyStoreProvider);
  final kyberPreKeyStore = ref.watch(driftKyberPreKeyStoreProvider);

  return SignalStoreBundle(
    sessionStore: sessionStore,
    identityKeyStore: identityKeyStore,
    preKeyStore: preKeyStore,
    signedPreKeyStore: signedPreKeyStore,
    kyberPreKeyStore: kyberPreKeyStore,
  );
});
