import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lottie/lottie.dart';
import '../../providers/multisig_provider.dart';
import '../../providers/wallet_provider.dart';
import '../../services/solana_service.dart';
import '../../utils/constants.dart';
import '../../widgets/transaction_card.dart';

class TransactionsTab extends StatefulWidget {
  const TransactionsTab({super.key});

  @override
  State<TransactionsTab> createState() => _TransactionsTabState();
}

class _TransactionsTabState extends State<TransactionsTab> {
  List<SolanaTransaction> _solanaTransactions = [];
  bool _isLoadingTransactions = false;

  @override
  void initState() {
    super.initState();
    _loadSolanaTransactions();
  }

  Future<void> _loadSolanaTransactions() async {
    final walletProvider = context.read<WalletProvider>();
    final currentWallet = walletProvider.currentWallet;

    if (currentWallet == null) return;

    setState(() {
      _isLoadingTransactions = true;
    });

    try {
      final transactions = await SolanaService.getTransactionHistory(
        currentWallet.publicKey,
      );
      if (mounted) {
        setState(() {
          _solanaTransactions = transactions;
        });
      }
    } catch (e) {
      print('Error loading Solana transactions: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingTransactions = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<MultisigProvider, WalletProvider>(
      builder: (context, multisigProvider, walletProvider, child) {
        if (multisigProvider.isLoading || _isLoadingTransactions) {
          return Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF0F0F23), Color(0xFF1A1B2E)],
              ),
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Your corrected Lottie URL
                  SizedBox(
                    width: 200,
                    height: 200,
                    child: Lottie.network(
                      'https://lottie.host/6d126966-0dab-4b92-beca-a9e2db8ea215/wEHChNGjAN.json',
                      fit: BoxFit.contain,
                      repeat: true,
                      animate: true,
                      onLoaded: (composition) {
                        print('Your Lottie animation loaded successfully!');
                      },
                      errorBuilder: (context, error, stackTrace) {
                        print(
                          'Your Lottie failed, trying alternative format...',
                        );
                        // Try alternative lottie.host format
                        return Lottie.network(
                          'https://lottie.host/api/6d126966-0dab-4b92-beca-a9e2db8ea215/wEHChNGjAN.json',
                          fit: BoxFit.contain,
                          repeat: true,
                          animate: true,
                          errorBuilder: (context, error2, stackTrace2) {
                            print('Alternative format failed, using fallback');
                            // Fallback to a working animation
                            return Lottie.network(
                              'https://assets2.lottiefiles.com/packages/lf20_p8bfn5to.json',
                              fit: BoxFit.contain,
                              repeat: true,
                              animate: true,
                            );
                          },
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Loading Transactions...',
                    style: TextStyle(
                      color: Color(0xFF94A3B8),
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        final currentWallet = walletProvider.currentWallet;
        if (currentWallet == null) {
          return Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF0F0F23), Color(0xFF1A1B2E)],
              ),
            ),
            child: const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.account_balance_wallet_outlined,
                    size: 64,
                    color: Color(0xFF64748B),
                  ),
                  SizedBox(height: 20),
                  Text(
                    'No wallet selected',
                    style: TextStyle(
                      color: Color(0xFF94A3B8),
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Please select a wallet to view transactions',
                    style: TextStyle(color: Color(0xFF64748B), fontSize: 14),
                  ),
                ],
              ),
            ),
          );
        }

        final pendingTransactions = multisigProvider
            .getPendingTransactionsForSigner(currentWallet.publicKey);

        return Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF0F0F23), Color(0xFF1A1B2E)],
            ),
          ),
          child: RefreshIndicator(
            onRefresh: () async {
              await multisigProvider.refresh();
              await _loadSolanaTransactions();
            },
            backgroundColor: const Color(0xFF1E293B),
            color: const Color(0xFF00D4FF),
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Pending Multisig Transactions Section
                  _buildSectionHeader(
                    'Pending Multisig',
                    Icons.pending_actions_rounded,
                    pendingTransactions.length,
                  ),
                  const SizedBox(height: 16),

                  if (pendingTransactions.isNotEmpty) ...[
                    ...pendingTransactions.map(
                      (transaction) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _buildPremiumTransactionCard(
                          transaction: transaction,
                          currentUserPublicKey: currentWallet.publicKey,
                        ),
                      ),
                    ),
                  ] else ...[
                    _buildEmptyState(
                      'No Pending Transactions',
                      'All multisig transactions are up to date',
                      Icons.check_circle_outline_rounded,
                    ),
                  ],

                  const SizedBox(height: 32),

                  // Solana Transaction History Section
                  _buildSectionHeader(
                    'Solana History',
                    Icons.history_rounded,
                    _solanaTransactions.length,
                  ),
                  const SizedBox(height: 16),

                  if (_solanaTransactions.isNotEmpty) ...[
                    ..._solanaTransactions.map(
                      (transaction) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _buildSolanaTransactionCard(transaction),
                      ),
                    ),
                  ] else ...[
                    _buildEmptyState(
                      'No Transaction History',
                      'Your Solana transaction history will appear here',
                      Icons.receipt_long_rounded,
                    ),
                  ],

                  const SizedBox(height: 32),

                  // Multisig Transaction History Section
                  _buildSectionHeader(
                    'Multisig History',
                    Icons.group_work_rounded,
                    multisigProvider.transactions
                        .where((tx) => !tx.isPending)
                        .length,
                  ),
                  const SizedBox(height: 16),

                  if (multisigProvider.transactions
                      .where((tx) => !tx.isPending)
                      .isNotEmpty) ...[
                    ...multisigProvider.transactions
                        .where((tx) => !tx.isPending)
                        .map(
                          (transaction) => Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: _buildPremiumTransactionCard(
                              transaction: transaction,
                              currentUserPublicKey: currentWallet.publicKey,
                            ),
                          ),
                        ),
                  ] else ...[
                    _buildEmptyState(
                      'No Multisig History',
                      'Your multisig transaction history will appear here',
                      Icons.group_work_rounded,
                    ),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSectionHeader(String title, IconData icon, int count) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF00D4FF), Color(0xFF5B73FF)],
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: Colors.white, size: 18),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              letterSpacing: 0.5,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        if (count > 0)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF00D4FF), Color(0xFF5B73FF)],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              count.toString(),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildPremiumTransactionCard({
    required transaction,
    required String currentUserPublicKey,
  }) {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF1E293B), Color(0xFF334155)],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFF00D4FF).withOpacity(0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: TransactionCard(
          transaction: transaction,
          currentUserPublicKey: currentUserPublicKey,
        ),
      ),
    );
  }

  Widget _buildSolanaTransactionCard(SolanaTransaction transaction) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF1E293B), Color(0xFF334155)],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFF5B73FF).withOpacity(0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: transaction.type == 'incoming'
                            ? [const Color(0xFF10B981), const Color(0xFF059669)]
                            : [
                                const Color(0xFFEF4444),
                                const Color(0xFFDC2626),
                              ],
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      transaction.type == 'incoming'
                          ? Icons.call_received_rounded
                          : Icons.call_made_rounded,
                      color: Colors.white,
                      size: 16,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    transaction.type == 'incoming' ? 'Received' : 'Sent',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: transaction.status == 'confirmed'
                      ? const Color(0xFF10B981).withOpacity(0.2)
                      : const Color(0xFFEF4444).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  transaction.status.toUpperCase(),
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: transaction.status == 'confirmed'
                        ? const Color(0xFF10B981)
                        : const Color(0xFFEF4444),
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            '${transaction.amount.toStringAsFixed(4)} SOL',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: transaction.type == 'incoming'
                  ? const Color(0xFF10B981)
                  : const Color(0xFFEF4444),
            ),
          ),
          const SizedBox(height: 8),
          if (transaction.counterparty != null) ...[
            Row(
              children: [
                const Icon(
                  Icons.person_rounded,
                  color: Color(0xFF94A3B8),
                  size: 14,
                ),
                const SizedBox(width: 6),
                Text(
                  transaction.type == 'incoming' ? 'From:' : 'To:',
                  style: const TextStyle(
                    color: Color(0xFF94A3B8),
                    fontSize: 12,
                  ),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    '${transaction.counterparty!.substring(0, 8)}...${transaction.counterparty!.substring(transaction.counterparty!.length - 8)}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontFamily: 'monospace',
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
          ],
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFF0F172A),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.tag_rounded,
                  color: Color(0xFF94A3B8),
                  size: 14,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    transaction.signature,
                    style: const TextStyle(
                      color: Color(0xFF94A3B8),
                      fontSize: 10,
                      fontFamily: 'monospace',
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _formatDate(transaction.timestamp),
            style: const TextStyle(color: Color(0xFF64748B), fontSize: 11),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(String title, String subtitle, IconData icon) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1E293B), Color(0xFF334155)],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF64748B).withOpacity(0.2),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, size: 40, color: const Color(0xFF64748B)),
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xFF94A3B8),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            subtitle,
            style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }
}
