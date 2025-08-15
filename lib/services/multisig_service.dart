import 'dart:convert';
import 'package:uuid/uuid.dart';
import '../models/multisig_account_model.dart';
import '../models/transaction_model.dart';
import '../services/solana_service.dart';
import '../services/crypto_service.dart';
import '../services/storage_service.dart';

class MultisigService {
  static const _uuid = Uuid();

  // Create Multisig Account
  static Future<MultisigAccountModel> createMultisigAccount({
    required String name,
    required List<String> signers,
    required int threshold,
    String? description,
  }) async {
    if (signers.length < 2) {
      throw Exception('Minimum 2 signers required');
    }

    if (threshold < 1 || threshold > signers.length) {
      throw Exception('Invalid threshold value');
    }

    // Generate multisig account address (simplified)
    final multisigKeypair = CryptoService.generateKeypair();
    final multisigAddress = multisigKeypair['publicKey']!;

    final account = MultisigAccountModel(
      address: multisigAddress,
      name: name,
      signers: signers,
      threshold: threshold,
      createdAt: DateTime.now(),
      lastUpdated: DateTime.now(),
      isOwner: true,
      description: description,
    );

    await StorageService.saveMultisigAccount(account);
    return account;
  }

  // Create Transfer Transaction
  static Future<TransactionModel> createTransferTransaction({
    required String multisigAddress,
    required String recipient,
    required double amount,
    required String createdBy,
    String? memo,
  }) async {
    final multisigAccount = StorageService.getMultisigAccount(multisigAddress);
    if (multisigAccount == null) {
      throw Exception('Multisig account not found');
    }

    if (!SolanaService.isValidSolanaAddress(recipient)) {
      throw Exception('Invalid recipient address');
    }

    if (amount <= 0) {
      throw Exception('Amount must be greater than 0');
    }

    // Check if multisig has sufficient balance
    final balance = await SolanaService.getBalance(multisigAddress);
    if (balance < amount) {
      throw Exception('Insufficient balance');
    }

    final transaction = TransactionModel(
      id: _uuid.v4(),
      multisigAddress: multisigAddress,
      recipient: recipient,
      amount: amount,
      memo: memo,
      approvedBy: [],
      rejectedBy: [],
      requiredApprovals: multisigAccount.threshold,
      createdAt: DateTime.now(),
      expiresAt: DateTime.now().add(const Duration(days: 7)), // 7 days expiry
      status: 'pending',
      type: 'transfer',
      createdBy: createdBy,
    );

    await StorageService.saveTransaction(transaction);
    return transaction;
  }

  // Approve Transaction
  static Future<TransactionModel> approveTransaction({
    required String transactionId,
    required String signerPublicKey,
    required String privateKey,
  }) async {
    final transaction = StorageService.getTransaction(transactionId);
    if (transaction == null) {
      throw Exception('Transaction not found');
    }

    final multisigAccount = StorageService.getMultisigAccount(
      transaction.multisigAddress,
    );
    if (multisigAccount == null) {
      throw Exception('Multisig account not found');
    }

    // Check if signer is authorized
    if (!multisigAccount.signers.contains(signerPublicKey)) {
      throw Exception('Unauthorized signer');
    }

    // Check if already approved or rejected
    if (transaction.approvedBy.contains(signerPublicKey)) {
      throw Exception('Already approved by this signer');
    }

    if (transaction.rejectedBy.contains(signerPublicKey)) {
      throw Exception('Already rejected by this signer');
    }

    // Check if transaction is expired
    if (transaction.isExpired) {
      throw Exception('Transaction has expired');
    }

    // Sign the transaction
    final signature = _signTransaction(transaction, privateKey);

    // Update transaction
    final updatedApprovedBy = [...transaction.approvedBy, signerPublicKey];
    final newStatus = updatedApprovedBy.length >= transaction.requiredApprovals
        ? 'approved'
        : 'partiallyApproved';

    final updatedTransaction = TransactionModel(
      id: transaction.id,
      multisigAddress: transaction.multisigAddress,
      recipient: transaction.recipient,
      amount: transaction.amount,
      memo: transaction.memo,
      approvedBy: updatedApprovedBy,
      rejectedBy: transaction.rejectedBy,
      requiredApprovals: transaction.requiredApprovals,
      createdAt: transaction.createdAt,
      executedAt: transaction.executedAt,
      expiresAt: transaction.expiresAt,
      status: newStatus,
      type: transaction.type,
      transactionHash: transaction.transactionHash,
      rawTransaction: transaction.rawTransaction,
      createdBy: transaction.createdBy,
    );

    await StorageService.saveTransaction(updatedTransaction);

    // Auto-execute if threshold reached
    if (updatedTransaction.canBeExecuted) {
      return await executeTransaction(updatedTransaction.id);
    }

    return updatedTransaction;
  }

  // Reject Transaction
  static Future<TransactionModel> rejectTransaction({
    required String transactionId,
    required String signerPublicKey,
  }) async {
    final transaction = StorageService.getTransaction(transactionId);
    if (transaction == null) {
      throw Exception('Transaction not found');
    }

    final multisigAccount = StorageService.getMultisigAccount(
      transaction.multisigAddress,
    );
    if (multisigAccount == null) {
      throw Exception('Multisig account not found');
    }

    // Check if signer is authorized
    if (!multisigAccount.signers.contains(signerPublicKey)) {
      throw Exception('Unauthorized signer');
    }

    // Check if already approved or rejected
    if (transaction.rejectedBy.contains(signerPublicKey)) {
      throw Exception('Already rejected by this signer');
    }

    if (transaction.approvedBy.contains(signerPublicKey)) {
      throw Exception('Already approved by this signer');
    }

    // Update transaction
    final updatedRejectedBy = [...transaction.rejectedBy, signerPublicKey];

    final updatedTransaction = TransactionModel(
      id: transaction.id,
      multisigAddress: transaction.multisigAddress,
      recipient: transaction.recipient,
      amount: transaction.amount,
      memo: transaction.memo,
      approvedBy: transaction.approvedBy,
      rejectedBy: updatedRejectedBy,
      requiredApprovals: transaction.requiredApprovals,
      createdAt: transaction.createdAt,
      executedAt: transaction.executedAt,
      expiresAt: transaction.expiresAt,
      status: 'rejected',
      type: transaction.type,
      transactionHash: transaction.transactionHash,
      rawTransaction: transaction.rawTransaction,
      createdBy: transaction.createdBy,
    );

    await StorageService.saveTransaction(updatedTransaction);
    return updatedTransaction;
  }

  // Execute Transaction
  static Future<TransactionModel> executeTransaction(
    String transactionId,
  ) async {
    final transaction = StorageService.getTransaction(transactionId);
    if (transaction == null) {
      throw Exception('Transaction not found');
    }

    if (!transaction.canBeExecuted) {
      throw Exception('Transaction cannot be executed');
    }

    try {
      String? txHash;

      if (transaction.transactionType == TransactionType.transfer) {
        txHash = await _executeTransfer(transaction);
      }

      final updatedTransaction = TransactionModel(
        id: transaction.id,
        multisigAddress: transaction.multisigAddress,
        recipient: transaction.recipient,
        amount: transaction.amount,
        memo: transaction.memo,
        approvedBy: transaction.approvedBy,
        rejectedBy: transaction.rejectedBy,
        requiredApprovals: transaction.requiredApprovals,
        createdAt: transaction.createdAt,
        executedAt: DateTime.now(),
        expiresAt: transaction.expiresAt,
        status: 'executed',
        type: transaction.type,
        transactionHash: txHash,
        rawTransaction: transaction.rawTransaction,
        createdBy: transaction.createdBy,
      );

      await StorageService.saveTransaction(updatedTransaction);
      return updatedTransaction;
    } catch (e) {
      throw Exception('Failed to execute transaction: $e');
    }
  }

  // Get Pending Transactions for Signer
  static List<TransactionModel> getPendingTransactionsForSigner(
    String signerPublicKey,
  ) {
    final allTransactions = StorageService.getAllTransactions();

    return allTransactions.where((tx) {
      if (!tx.isPending || tx.isExpired) return false;

      final multisigAccount = StorageService.getMultisigAccount(
        tx.multisigAddress,
      );
      if (multisigAccount == null) return false;

      // Check if signer is authorized and hasn't already signed
      return multisigAccount.signers.contains(signerPublicKey) &&
          !tx.approvedBy.contains(signerPublicKey) &&
          !tx.rejectedBy.contains(signerPublicKey);
    }).toList();
  }

  // Private Methods
  static String _signTransaction(
    TransactionModel transaction,
    String privateKey,
  ) {
    final transactionData = {
      'id': transaction.id,
      'multisigAddress': transaction.multisigAddress,
      'recipient': transaction.recipient,
      'amount': transaction.amount,
      'memo': transaction.memo,
      'createdAt': transaction.createdAt.toIso8601String(),
    };

    final message = jsonEncode(transactionData);
    return CryptoService.signMessage(message, privateKey);
  }

  static Future<String> _executeTransfer(TransactionModel transaction) async {
    if (transaction.recipient == null || transaction.amount == null) {
      throw Exception('Invalid transfer transaction');
    }

    // Create transfer instruction
    final lamports = (transaction.amount! * 1000000000)
        .toInt(); // Convert SOL to lamports
    final instruction = SolanaService.createTransferInstruction(
      fromPubkey: transaction.multisigAddress,
      toPubkey: transaction.recipient!,
      lamports: lamports,
    );

    // Get recent blockhash
    final blockhash = await SolanaService.getRecentBlockhash();

    // Create transaction (simplified)
    final solanaTransaction = {
      'recentBlockhash': blockhash,
      'instructions': [instruction],
      'feePayer': transaction.multisigAddress,
    };

    // Serialize and send transaction (simplified)
    final serializedTx = base64Encode(
      utf8.encode(jsonEncode(solanaTransaction)),
    );
    final txHash = await SolanaService.sendTransaction(serializedTx);

    return txHash;
  }

  // Update Multisig Account Balance
  static Future<void> updateMultisigBalance(String address) async {
    final account = StorageService.getMultisigAccount(address);
    if (account == null) return;

    final balance = await SolanaService.getBalance(address);
    final updatedAccount = account.copyWith(
      balance: balance,
      lastUpdated: DateTime.now(),
    );

    await StorageService.saveMultisigAccount(updatedAccount);
  }

  // Cleanup Expired Transactions
  static Future<void> cleanupExpiredTransactions() async {
    final allTransactions = StorageService.getAllTransactions();

    for (final transaction in allTransactions) {
      if (transaction.isExpired && transaction.status != 'executed') {
        final updatedTransaction = TransactionModel(
          id: transaction.id,
          multisigAddress: transaction.multisigAddress,
          recipient: transaction.recipient,
          amount: transaction.amount,
          memo: transaction.memo,
          approvedBy: transaction.approvedBy,
          rejectedBy: transaction.rejectedBy,
          requiredApprovals: transaction.requiredApprovals,
          createdAt: transaction.createdAt,
          executedAt: transaction.executedAt,
          expiresAt: transaction.expiresAt,
          status: 'expired',
          type: transaction.type,
          transactionHash: transaction.transactionHash,
          rawTransaction: transaction.rawTransaction,
          createdBy: transaction.createdBy,
        );

        await StorageService.saveTransaction(updatedTransaction);
      }
    }
  }
}
