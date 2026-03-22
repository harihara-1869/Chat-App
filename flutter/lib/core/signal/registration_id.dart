import 'dart:math';

const int kMaxRegistrationId = 16380;

int generateSecureRegistrationId({Random? random}) {
  final rng = random ?? Random.secure();
  return rng.nextInt(kMaxRegistrationId) + 1;
}
