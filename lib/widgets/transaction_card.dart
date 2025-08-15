import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/transaction_model.dart';
import '../providers/multisig_provider.dart';
import '../providers/wallet_provider.dart';
import '../utils/constants.dart';

class TransactionCard extends StatelessWidget {
  final TransactionModel transaction;
  final String currentUserPublicKey;

  const TransactionCard({
    super.key,
    required this.transaction,
    required this.currentUserPublicKey,
  });

  @override
  Widget build(BuildContext context) {
    final hasApproved = transaction.approvedBy.contains(currentUserPublicKey);
    final hasRejected = transaction.rejectedBy.contains(currentUserPublicKey);

    // Only require signatures for actual multisig transactions
    // Regular wallet transactions don't need multisig approval
    final isMultisigTransaction =
        transaction.multisigAddress.isNotEmpty &&
        transaction.type == 'transfer' &&
        transaction.createdBy != currentUserPublicKey;

    final canSign =
        isMultisigTransaction &&
        !hasApproved &&
        !hasRejected &&
        transaction.isPending &&
        !transaction.isExpired;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _getTransactionTitle(),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                _buildStatusChip(),
              ],
            ),

            const SizedBox(height: 12),

            // Transaction Details
            if (transaction.recipient != null &&
                transaction.amount != null) ...[
              Row(
                children: [
                  const Icon(Icons.send, size: 16, color: Colors.grey),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'To: ${transaction.recipient!.substring(0, 8)}...${transaction.recipient!.substring(transaction.recipient!.length - 8)}',
                      style: const TextStyle(
                        fontSize: 14,
                        fontFamily: 'monospace',
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(
                    Icons.account_balance_wallet,
                    size: 16,
                    color: Colors.grey,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Amount: ${transaction.amount!.toStringAsFixed(4)} SOL',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],

            if (transaction.memo != null) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.note, size: 16, color: Colors.grey),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Memo: ${transaction.memo!}',
                      style: const TextStyle(fontSize: 14),
                    ),
                  ),
                ],
              ),
            ],

            const SizedBox(height: 12),

            // Approval Progress - Only show for multisig transactions
            if (isMultisigTransaction) ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  Text(
                    'Approvals: ${transaction.approvedBy.length}/${transaction.requiredApprovals}',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: LinearProgressIndicator(
                      value:
                          transaction.approvedBy.length /
                          transaction.requiredApprovals,
                      backgroundColor: Colors.grey[300],
                      valueColor: const AlwaysStoppedAnimation<Color>(
                        AppColors.primary,
                      ),
                    ),
                  ),
                ],
              ),
            ],

            const SizedBox(height: 12),

            // Action Buttons - Only show for actual multisig transactions
            if (canSign && isMultisigTransaction) ...[
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _approveTransaction(context),
                      icon: const Icon(Icons.check, size: 16),
                      label: const Text('Approve'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.success,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _rejectTransaction(context),
                      icon: const Icon(Icons.close, size: 16),
                      label: const Text('Reject'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.error,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ] else if (hasApproved && isMultisigTransaction) ...[
              // Show approved status only for multisig transactions
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: AppColors.success.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.success),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.check_circle,
                      color: AppColors.success,
                      size: 16,
                    ),
                    SizedBox(width: 8),
                    Text(
                      'You have approved this transaction',
                      style: TextStyle(
                        color: AppColors.success,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ] else if (hasRejected && isMultisigTransaction) ...[
              // Show rejected status only for multisig transactions
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: AppColors.error.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.error),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.cancel, color: AppColors.error, size: 16),
                    SizedBox(width: 8),
                    Text(
                      'You have rejected this transaction',
                      style: TextStyle(
                        color: AppColors.error,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],

            // Transaction Info
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Created: ${_formatDate(transaction.createdAt)}',
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
                if (transaction.expiresAt != null)
                  Text(
                    'Expires: ${_formatDate(transaction.expiresAt!)}',
                    style: TextStyle(
                      fontSize: 12,
                      color: transaction.isExpired
                          ? AppColors.error
                          : Colors.grey[600],
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _getTransactionTitle() {
    switch (transaction.transactionType) {
      case TransactionType.transfer:
        return 'Transfer Transaction';
      case TransactionType.multisigCreate:
        return 'Create Multisig';
      case TransactionType.multisigApprove:
        return 'Approve Transaction';
      case TransactionType.multisigExecute:
        return 'Execute Transaction';
      default:
        return 'Transaction';
    }
  }

  Widget _buildStatusChip() {
    Color color;
    String text;

    switch (transaction.transactionStatus) {
      case TransactionStatus.pending:
        color = AppColors.warning;
        text = 'PENDING';
        break;
      case TransactionStatus.partiallyApproved:
        color = AppColors.primary;
        text = 'PARTIAL';
        break;
      case TransactionStatus.approved:
        color = AppColors.success;
        text = 'APPROVED';
        break;
      case TransactionStatus.executed:
        color = AppColors.success;
        text = 'EXECUTED';
        break;
      case TransactionStatus.rejected:
        color = AppColors.error;
        text = 'REJECTED';
        break;
      case TransactionStatus.expired:
        color = Colors.grey;
        text = 'EXPIRED';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  Future<void> _approveTransaction(BuildContext context) async {
    try {
      final walletProvider = context.read<WalletProvider>();
      final multisigProvider = context.read<MultisigProvider>();

      final privateKey = await walletProvider.getPrivateKey(
        currentUserPublicKey,
      );
      if (privateKey == null) {
        throw Exception('Private key not found');
      }

      final success = await multisigProvider.approveTransaction(
        transactionId: transaction.id,
        signerPublicKey: currentUserPublicKey,
        privateKey: privateKey,
      );

      if (success && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Transaction approved successfully!'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to approve transaction: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Future<void> _rejectTransaction(BuildContext context) async {
    try {
      final multisigProvider = context.read<MultisigProvider>();

      final success = await multisigProvider.rejectTransaction(
        transactionId: transaction.id,
        signerPublicKey: currentUserPublicKey,
      );

      if (success && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Transaction rejected successfully!'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to reject transaction: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }
}
