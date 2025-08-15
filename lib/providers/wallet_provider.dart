import 'package:flutter/widgets.dart';
import '../models/wallet_model.dart';
import '../services/storage_service.dart';
import '../services/solana_service.dart';
import '../services/crypto_service.dart';

class WalletProvider extends ChangeNotifier {
  List<WalletModel> _wallets = [];
  WalletModel? _currentWallet;
  bool _isLoading = false;
  String? _error;
  bool _isInitialized = false; // Added initialization flag

  List<WalletModel> get wallets => _wallets;
  WalletModel? get currentWallet => _currentWallet;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasWallets => _wallets.isNotEmpty;
  bool get isInitialized => _isInitialized; // Added getter

  // Safe notify listeners method
  void _safeNotifyListeners() {
    if (_isInitialized) {
      try {
        notifyListeners();
      } catch (e) {
        print('Error notifying listeners: $e');
      }
    }
  }

  // Initialize Provider
  Future<void> initialize() async {
    _setLoading(true);
    try {
      await _loadWallets();
      if (_wallets.isNotEmpty) {
        _currentWallet = _wallets.first;
      }
      _clearError();
      _isInitialized = true; // Mark as initialized
    } catch (e) {
      _setError('Failed to initialize wallets: $e');
      _isInitialized = true; // Still mark as initialized even on error
    } finally {
      _setLoading(false);
    }
  }

  // Create New Wallet
  Future<WalletModel?> createWallet(String name) async {
    _setLoading(true);
    try {
      // Generate mnemonic and keypair
      final mnemonic = CryptoService.generateMnemonic();
      final keypair = await CryptoService.deriveKeypairFromMnemonic(mnemonic);

      // Create wallet model
      final wallet = WalletModel(
        publicKey: keypair['publicKey']!,
        name: name,
        createdAt: DateTime.now(),
        lastUpdated: DateTime.now(),
        isImported: false,
      );

      // Store wallet and private key
      await StorageService.saveWallet(wallet);
      await StorageService.storePrivateKey(
        wallet.publicKey,
        keypair['privateKey']!,
      );
      await StorageService.storeMnemonic(mnemonic);

      // Update local state
      _wallets.add(wallet);
      _currentWallet = wallet;

      _clearError();
      _safeNotifyListeners();

      // Update balance after notification
      _updateWalletBalanceAsync(wallet.publicKey);

      return wallet;
    } catch (e) {
      _setError('Failed to create wallet: $e');
      return null;
    } finally {
      _setLoading(false);
    }
  }

  // Import Wallet from Mnemonic
  Future<WalletModel?> importWallet(String name, String mnemonic) async {
    _setLoading(true);
    try {
      if (!CryptoService.validateMnemonic(mnemonic)) {
        throw Exception('Invalid mnemonic phrase');
      }

      final keypair = await CryptoService.deriveKeypairFromMnemonic(mnemonic);

      // Check if wallet already exists
      if (_wallets.any((w) => w.publicKey == keypair['publicKey'])) {
        throw Exception('Wallet already exists');
      }

      final wallet = WalletModel(
        publicKey: keypair['publicKey']!,
        name: name,
        createdAt: DateTime.now(),
        lastUpdated: DateTime.now(),
        isImported: true,
      );

      // Store wallet and private key
      await StorageService.saveWallet(wallet);
      await StorageService.storePrivateKey(
        wallet.publicKey,
        keypair['privateKey']!,
      );

      // Update local state
      _wallets.add(wallet);
      _currentWallet = wallet;

      _clearError();
      _safeNotifyListeners();

      // Update balance after notification
      _updateWalletBalanceAsync(wallet.publicKey);

      return wallet;
    } catch (e) {
      _setError('Failed to import wallet: $e');
      return null;
    } finally {
      _setLoading(false);
    }
  }

  // Switch Current Wallet
  void switchWallet(String publicKey) {
    final wallet = _wallets.firstWhere(
      (w) => w.publicKey == publicKey,
      orElse: () => throw Exception('Wallet not found'),
    );
    _currentWallet = wallet;
    _safeNotifyListeners();
  }

  // Async balance update without immediate notification
  void _updateWalletBalanceAsync(String publicKey) {
    Future.microtask(() async {
      await updateWalletBalance(publicKey);
    });
  }

  // Update Wallet Balance
  Future<void> updateWalletBalance(String publicKey) async {
    try {
      final balance = await SolanaService.getBalance(publicKey);
      final walletIndex = _wallets.indexWhere((w) => w.publicKey == publicKey);

      if (walletIndex != -1) {
        final updatedWallet = _wallets[walletIndex].copyWith(
          balance: balance,
          lastUpdated: DateTime.now(),
        );

        _wallets[walletIndex] = updatedWallet;
        await StorageService.saveWallet(updatedWallet);

        if (_currentWallet?.publicKey == publicKey) {
          _currentWallet = updatedWallet;
        }

        // Safe notification with post-frame callback
        if (_isInitialized) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _safeNotifyListeners();
          });
        }
      }
    } catch (e) {
      print('Failed to update balance for $publicKey: $e');
    }
  }

  // Update All Wallet Balances
  Future<void> updateAllBalances() async {
    if (!_isInitialized) return; // Don't update if not initialized

    final futures = _wallets.map((wallet) async {
      try {
        final balance = await SolanaService.getBalance(wallet.publicKey);
        final walletIndex = _wallets.indexWhere(
          (w) => w.publicKey == wallet.publicKey,
        );

        if (walletIndex != -1) {
          final updatedWallet = _wallets[walletIndex].copyWith(
            balance: balance,
            lastUpdated: DateTime.now(),
          );

          _wallets[walletIndex] = updatedWallet;
          await StorageService.saveWallet(updatedWallet);

          if (_currentWallet?.publicKey == wallet.publicKey) {
            _currentWallet = updatedWallet;
          }
        }
      } catch (e) {
        print('Failed to update balance for ${wallet.publicKey}: $e');
      }
    });

    await Future.wait(futures);

    // Safe notification with post-frame callback
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _safeNotifyListeners();
    });
  }

  // Delete Wallet
  Future<void> deleteWallet(String publicKey) async {
    _setLoading(true);
    try {
      await StorageService.deleteWallet(publicKey);

      _wallets.removeWhere((w) => w.publicKey == publicKey);

      if (_currentWallet?.publicKey == publicKey) {
        _currentWallet = _wallets.isNotEmpty ? _wallets.first : null;
      }

      _clearError();
      _safeNotifyListeners();
    } catch (e) {
      _setError('Failed to delete wallet: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Get Private Key
  Future<String?> getPrivateKey(String publicKey) async {
    return await StorageService.getPrivateKey(publicKey);
  }

  // Request Airdrop (Devnet only)
  Future<bool> requestAirdrop(String publicKey, double amount) async {
    _setLoading(true);
    try {
      final signature = await SolanaService.requestAirdrop(publicKey, amount);
      if (signature != null) {
        // Wait a bit and update balance
        await Future.delayed(const Duration(seconds: 3));
        await updateWalletBalance(publicKey);
        _clearError();
        return true;
      }
      return false;
    } catch (e) {
      _setError('Failed to request airdrop: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Private Methods
  Future<void> _loadWallets() async {
    _wallets = StorageService.getAllWallets();
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    _safeNotifyListeners();
  }

  void _setError(String error) {
    _error = error;
    _safeNotifyListeners();
  }

  void _clearError() {
    _error = null;
    _safeNotifyListeners();
  }
}
