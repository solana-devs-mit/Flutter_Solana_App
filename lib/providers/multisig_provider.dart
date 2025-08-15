import 'package:flutter/foundation.dart';
import '../models/multisig_account_model.dart';
import '../models/transaction_model.dart';
import '../services/storage_service.dart';
import '../services/multisig_service.dart';

class MultisigProvider extends ChangeNotifier {
  List<MultisigAccountModel> _multisigAccounts = [];
  List<TransactionModel> _transactions = [];
  List<TransactionModel> _pendingTransactions = [];
  bool _isLoading = false;
  String? _error;

  List<MultisigAccountModel> get multisigAccounts => _multisigAccounts;
  List<TransactionModel> get transactions => _transactions;
  List<TransactionModel> get pendingTransactions => _pendingTransactions;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasMultisigAccounts => _multisigAccounts.isNotEmpty;

  // Initialize Provider
  Future<void> initialize() async {
    _setLoading(true);
    try {
      await _loadMultisigAccounts();
      await _loadTransactions();
      await _loadPendingTransactions();
      _clearError();
    } catch (e) {
      _setError('Failed to initialize multisig data: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Create Multisig Account
  Future<MultisigAccountModel?> createMultisigAccount({
    required String name,
    required List<String> signers,
    required int threshold,
    String? description,
  }) async {
    _setLoading(true);
    try {
      final account = await MultisigService.createMultisigAccount(
        name: name,
        signers: signers,
        threshold: threshold,
        description: description,
      );

      _multisigAccounts.add(account);
      _clearError();
      notifyListeners();
      return account;
    } catch (e) {
      _setError('Failed to create multisig account: $e');
      return null;
    } finally {
      _setLoading(false);
    }
  }

  // Create Transfer Transaction
  Future<TransactionModel?> createTransferTransaction({
    required String multisigAddress,
    required String recipient,
    required double amount,
    required String createdBy,
    String? memo,
  }) async {
    _setLoading(true);
    try {
      final transaction = await MultisigService.createTransferTransaction(
        multisigAddress: multisigAddress,
        recipient: recipient,
        amount: amount,
        createdBy: createdBy,
        memo: memo,
      );

      _transactions.add(transaction);
      await _loadPendingTransactions();
      _clearError();
      notifyListeners();
      return transaction;
    } catch (e) {
      _setError('Failed to create transaction: $e');
      return null;
    } finally {
      _setLoading(false);
    }
  }

  // Approve Transaction
  Future<bool> approveTransaction({
    required String transactionId,
    required String signerPublicKey,
    required String privateKey,
  }) async {
    _setLoading(true);
    try {
      final updatedTransaction = await MultisigService.approveTransaction(
        transactionId: transactionId,
        signerPublicKey: signerPublicKey,
        privateKey: privateKey,
      );

      // Update local transaction
      final index = _transactions.indexWhere((tx) => tx.id == transactionId);
      if (index != -1) {
        _transactions[index] = updatedTransaction;
      }

      await _loadPendingTransactions();
      _clearError();
      notifyListeners();
      return true;
    } catch (e) {
      _setError('Failed to approve transaction: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Reject Transaction
  Future<bool> rejectTransaction({
    required String transactionId,
    required String signerPublicKey,
  }) async {
    _setLoading(true);
    try {
      final updatedTransaction = await MultisigService.rejectTransaction(
        transactionId: transactionId,
        signerPublicKey: signerPublicKey,
      );

      // Update local transaction
      final index = _transactions.indexWhere((tx) => tx.id == transactionId);
      if (index != -1) {
        _transactions[index] = updatedTransaction;
      }

      await _loadPendingTransactions();
      _clearError();
      notifyListeners();
      return true;
    } catch (e) {
      _setError('Failed to reject transaction: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Get Transactions for Multisig
  List<TransactionModel> getTransactionsForMultisig(String multisigAddress) {
    return _transactions
        .where((tx) => tx.multisigAddress == multisigAddress)
        .toList();
  }

  // Get Pending Transactions for Signer
  List<TransactionModel> getPendingTransactionsForSigner(
    String signerPublicKey,
  ) {
    return MultisigService.getPendingTransactionsForSigner(signerPublicKey);
  }

  // Update Multisig Balance
  Future<void> updateMultisigBalance(String address) async {
    try {
      await MultisigService.updateMultisigBalance(address);

      // Reload accounts to get updated balance
      await _loadMultisigAccounts();
      notifyListeners();
    } catch (e) {
      print('Failed to update multisig balance: $e');
    }
  }

  // Update All Multisig Balances
  Future<void> updateAllMultisigBalances() async {
    for (final account in _multisigAccounts) {
      await updateMultisigBalance(account.address);
    }
  }

  // Delete Multisig Account
  Future<void> deleteMultisigAccount(String address) async {
    _setLoading(true);
    try {
      await StorageService.deleteMultisigAccount(address);
      _multisigAccounts.removeWhere((account) => account.address == address);

      // Also remove related transactions
      _transactions.removeWhere((tx) => tx.multisigAddress == address);

      _clearError();
      notifyListeners();
    } catch (e) {
      _setError('Failed to delete multisig account: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Refresh Data
  Future<void> refresh() async {
    await initialize();
    await updateAllMultisigBalances();
  }

  // Private Methods
  Future<void> _loadMultisigAccounts() async {
    _multisigAccounts = StorageService.getAllMultisigAccounts();
  }

  Future<void> _loadTransactions() async {
    _transactions = StorageService.getAllTransactions();
  }

  Future<void> _loadPendingTransactions() async {
    _pendingTransactions = StorageService.getPendingTransactions();
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _error = error;
    notifyListeners();
  }

  void _clearError() {
    _error = null;
    notifyListeners();
  }
}
