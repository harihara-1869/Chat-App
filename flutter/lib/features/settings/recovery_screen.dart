import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:go_router/go_router.dart';
import 'package:crypto/crypto.dart';

import '../../../core/storage/database/app_database.dart';

const _hasShownBackupPromptKey = 'has_shown_backup_prompt';
const _dbEncryptionKeyStorageKey = 'db_encryption_key';
const _recoveryPhraseKey = 'recovery_phrase';

final recoveryScreenViewModelProvider = StateNotifierProvider<RecoveryScreenViewModel, RecoveryScreenState>((ref) {
  return RecoveryScreenViewModel();
});

class RecoveryScreenState {
  final bool isLoading;
  final String? error;
  final bool isRecovered;

  const RecoveryScreenState({
    this.isLoading = false,
    this.error,
    this.isRecovered = false,
  });

  RecoveryScreenState copyWith({
    bool? isLoading,
    String? error,
    bool? isRecovered,
  }) {
    return RecoveryScreenState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      isRecovered: isRecovered ?? this.isRecovered,
    );
  }
}

class RecoveryScreenViewModel extends StateNotifier<RecoveryScreenState> {
  RecoveryScreenViewModel() : super(const RecoveryScreenState());

  final _secureStorage = const FlutterSecureStorage(
    aOptions: AndroidOptions(),
    iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock_this_device),
  );

  Future<bool> recoverWithPhrase(String phrase) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final words = phrase.trim().toLowerCase().split(RegExp(r'\s+'));
      
      if (words.length != 12) {
        state = state.copyWith(isLoading: false, error: 'Please enter all 12 words');
        return false;
      }

      final derivedKey = _deriveKeyFromMnemonic(words);
      final encodedKey = base64Encode(derivedKey);
      
      await _secureStorage.write(key: _dbEncryptionKeyStorageKey, value: encodedKey);
      await _secureStorage.write(key: _recoveryPhraseKey, value: words.join(' '));

      state = state.copyWith(isLoading: false, isRecovered: true);
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: 'Recovery failed: ${e.toString()}');
      return false;
    }
  }

  Uint8List _deriveKeyFromMnemonic(List<String> words) {
    final phrase = words.join(' ');
    final salt = 'chat_app_sqlcipher';
    
    // Simple key derivation using multiple rounds of SHA256
    List<int> data = utf8.encode(phrase + salt);
    for (int i = 0; i < 10000; i++) {
      data = sha256.convert(data).bytes;
    }
    
    return Uint8List.fromList(data.sublist(0, 32));
  }

  Future<void> startFresh() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final newKey = generateDbEncryptionKey();
      final encodedKey = base64Encode(newKey);
      await _secureStorage.write(key: _dbEncryptionKeyStorageKey, value: encodedKey);
      
      state = state.copyWith(isLoading: false, isRecovered: true);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }
}

class RecoveryScreen extends ConsumerStatefulWidget {
  const RecoveryScreen({super.key});

  @override
  ConsumerState<RecoveryScreen> createState() => _RecoveryScreenState();
}

class _RecoveryScreenState extends ConsumerState<RecoveryScreen> {
  final _phraseController = TextEditingController();

  @override
  void dispose() {
    _phraseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(recoveryScreenViewModelProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Recover Chat History'),
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.warning_amber_rounded, size: 64, color: Colors.orange),
            const SizedBox(height: 16),
            const Text(
              'Chat History Recovery',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Enter your 12-word recovery phrase to restore your chat history. This only works if you have a backup.',
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 24),
            TextField(
              controller: _phraseController,
              maxLines: 4,
              decoration: const InputDecoration(
                labelText: 'Recovery Phrase',
                hintText: 'Enter your 12 words separated by spaces',
                border: OutlineInputBorder(),
              ),
            ),
            if (state.error != null) ...[
              const SizedBox(height: 8),
              Text(state.error!, style: const TextStyle(color: Colors.red)),
            ],
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: state.isLoading
                    ? null
                    : () async {
                        final success = await ref
                            .read(recoveryScreenViewModelProvider.notifier)
                            .recoverWithPhrase(_phraseController.text);
                        if (success && context.mounted) {
                          context.go('/');
                        }
                      },
                child: state.isLoading
                    ? const CircularProgressIndicator()
                    : const Text('Recover'),
              ),
            ),
            const SizedBox(height: 32),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.red[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.red[200]!),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.dangerous, color: Colors.red),
                      SizedBox(width: 8),
                      Text(
                        'Start Fresh',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.red,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'If you don\'t have your recovery phrase, you can start fresh with a new encryption key. This will delete all your existing chat history permanently.',
                    style: TextStyle(color: Colors.red),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: state.isLoading
                          ? null
                          : () => _showStartFreshConfirmation(context),
                      style: OutlinedButton.styleFrom(foregroundColor: Colors.red),
                      child: const Text('Start Fresh - Delete Chat History'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showStartFreshConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Chat History?'),
        content: const Text(
          'This will permanently delete all your chat messages. This action cannot be undone. Are you sure?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await ref.read(recoveryScreenViewModelProvider.notifier).startFresh();
              if (context.mounted) {
                context.go('/');
              }
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
