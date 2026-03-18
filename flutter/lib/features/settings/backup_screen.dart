import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:go_router/go_router.dart';
import 'package:pointycastle/export.dart';

import '../../../core/constants/constants.dart';
import '../../../core/storage/database/database_provider.dart';

const _hasShownBackupPromptKey = 'has_shown_backup_prompt';
const _dbEncryptionKeyStorageKey = 'db_encryption_key';
const _recoveryPhraseKey = 'recovery_phrase';

final backupScreenViewModelProvider = StateNotifierProvider<BackupScreenViewModel, BackupScreenState>((ref) {
  return BackupScreenViewModel();
});

class BackupScreenState {
  final List<String> mnemonic;
  final bool isLoading;
  final bool isConfirmed;
  final String? error;

  const BackupScreenState({
    this.mnemonic = const [],
    this.isLoading = false,
    this.isConfirmed = false,
    this.error,
  });

  BackupScreenState copyWith({
    List<String>? mnemonic,
    bool? isLoading,
    bool? isConfirmed,
    String? error,
  }) {
    return BackupScreenState(
      mnemonic: mnemonic ?? this.mnemonic,
      isLoading: isLoading ?? this.isLoading,
      isConfirmed: isConfirmed ?? this.isConfirmed,
      error: error,
    );
  }
}

class BackupScreenViewModel extends StateNotifier<BackupScreenState> {
  BackupScreenViewModel() : super(const BackupScreenState());

  final _secureStorage = const FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
    iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock_this_device),
  );

  Future<void> generateMnemonic() async {
    state = state.copyWith(isLoading: true);

    try {
      final existingPhrase = await _secureStorage.read(key: _recoveryPhraseKey);
      List<String> words;
      
      if (existingPhrase != null) {
        words = existingPhrase.split(' ');
      } else {
        words = _generateBip39Mnemonic();
        await _secureStorage.write(key: _recoveryPhraseKey, value: words.join(' '));
      }

      state = state.copyWith(mnemonic: words, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  List<String> _generateBip39Mnemonic() {
    const wordList = [
      'abandon', 'ability', 'able', 'about', 'above', 'absent', 'absorb', 'abstract', 
      'absurd', 'abuse', 'access', 'accident', 'account', 'accuse', 'achieve', 'acid', 
      'acoustic', 'acquire', 'across', 'act', 'action', 'actor', 'actress', 'actual', 
      'adapt', 'add', 'addict', 'address', 'adjust', 'admit', 'adult', 'advance', 
      'advice', 'aerobic', 'affair', 'afford', 'afraid', 'again', 'age', 'agent', 
      'agree', 'ahead', 'aim', 'air', 'airport', 'aisle', 'alarm', 'album',
    ];
    
    final random = Random.secure();
    final words = <String>[];
    
    for (int i = 0; i < 12; i++) {
      words.add(wordList[random.nextInt(wordList.length)]);
    }
    
    return words;
  }

  Future<bool> confirmBackup(List<String> verifiedWords) async {
    if (verifiedWords.length != 3) return false;
    
    final correctIndices = <int>[];
    final random = Random();
    
    while (correctIndices.length < 3) {
      final idx = random.nextInt(12);
      if (!correctIndices.contains(idx)) {
        correctIndices.add(idx);
      }
    }
    correctIndices.sort();

    for (int i = 0; i < 3; i++) {
      if (verifiedWords[i] != state.mnemonic[correctIndices[i]]) {
        return false;
      }
    }

    await _secureStorage.write(key: _hasShownBackupPromptKey, value: 'true');
    state = state.copyWith(isConfirmed: true);
    return true;
  }
}

class BackupScreen extends ConsumerStatefulWidget {
  const BackupScreen({super.key});

  @override
  ConsumerState<BackupScreen> createState() => _BackupScreenState();
}

class _BackupScreenState extends ConsumerState<BackupScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(backupScreenViewModelProvider.notifier).generateMnemonic();
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(backupScreenViewModelProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Chat Backup'),
      ),
      body: state.isLoading
          ? const Center(child: CircularProgressIndicator())
          : state.mnemonic.isEmpty
              ? const Center(child: Text('Failed to load recovery phrase'))
              : _buildContent(state),
    );
  }

  Widget _buildContent(BackupScreenState state) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Recovery Phrase',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            'This phrase can be used to recover your chat history if you reinstall the app or switch devices.',
            style: TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                for (int i = 0; i < state.mnemonic.length; i += 4)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      children: [
                        _buildWordChip(i + 1, state.mnemonic[i]),
                        _buildWordChip(i + 2, state.mnemonic[i + 1]),
                        _buildWordChip(i + 3, state.mnemonic[i + 2]),
                        _buildWordChip(i + 4, state.mnemonic[i + 3]),
                      ].map((w) => Expanded(child: Padding(padding: const EdgeInsets.symmetric(horizontal: 2), child: w))).toList(),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Write down these words in order and store them safely. You will need them to recover your chat history.',
            style: TextStyle(color: Colors.orange, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => _showVerificationDialog(context),
              child: const Text('I\'ve Saved This'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWordChip(int index, String word) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('$index.', style: const TextStyle(color: Colors.grey, fontSize: 12)),
          const SizedBox(width: 4),
          Flexible(
            child: Text(word, style: const TextStyle(fontWeight: FontWeight.w500), overflow: TextOverflow.ellipsis),
          ),
        ],
      ),
    );
  }

  void _showVerificationDialog(BuildContext context) {
    final random = Random();
    final indices = <int>[];
    while (indices.length < 3) {
      final idx = random.nextInt(12);
      if (!indices.contains(idx)) indices.add(idx);
    }
    indices.sort();

    final controllers = List.generate(3, (_) => TextEditingController());

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          left: 16,
          right: 16,
          top: 16,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Verify your backup', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            for (int i = 0; i < 3; i++)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: TextField(
                  controller: controllers[i],
                  decoration: InputDecoration(
                    labelText: 'Word #${indices[i] + 1}',
                    border: const OutlineInputBorder(),
                  ),
                ),
              ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  final verified = await ref.read(backupScreenViewModelProvider.notifier).confirmBackup(
                    controllers.map((c) => c.text.trim().toLowerCase()).toList(),
                  );
                  if (context.mounted) {
                    Navigator.pop(context);
                    if (verified) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Backup confirmed!')),
                      );
                      context.pop();
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Verification failed. Please try again.')),
                      );
                    }
                  }
                },
                child: const Text('Confirm'),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
