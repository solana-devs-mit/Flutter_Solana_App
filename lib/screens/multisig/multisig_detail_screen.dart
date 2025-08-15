import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../models/multisig_account_model.dart';
import '../../providers/multisig_provider.dart';
import '../../providers/wallet_provider.dart';
import '../../utils/constants.dart';
import '../../widgets/transaction_card.dart';
import 'create_transaction_screen.dart';

class MultisigDetailScreen extends StatefulWidget {
  final MultisigAccountModel account;

  const MultisigDetailScreen({super.key, required this.account});

  @override
  State<MultisigDetailScreen> createState() => _MultisigDetailScreenState();
}

class _MultisigDetailScreenState extends State<MultisigDetailScreen> {
  @override
  void initState() {
    super.initState();
    _refreshData();
  }

  Future<void> _refreshData() async {
    final multisigProvider = context.read<MultisigProvider>();
    await multisigProvider.updateMultisigBalance(widget.account.address);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.account.name),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _refreshData),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refreshData,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Account Info Card
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Account Balance',
                            style: TextStyle(fontSize: 16, color: Colors.grey),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: widget.account.isOwner
                                  ? AppColors.primary
                                  : Colors.grey,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              widget.account.isOwner ? 'OWNER' : 'MEMBER',
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${widget.account.balance.toStringAsFixed(4)} SOL',
                        style: const TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Divider(),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          const Icon(
                            Icons.people,
                            size: 20,
                            color: Colors.grey,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '${widget.account.threshold} of ${widget.account.signers.length} signatures required',
                            style: const TextStyle(fontSize: 16),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          const Icon(
                            Icons.account_balance_wallet,
                            size: 20,
                            color: Colors.grey,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: GestureDetector(
                              onTap: () {
                                Clipboard.setData(
                                  ClipboardData(text: widget.account.address),
                                );
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'Address copied to clipboard',
                                    ),
                                  ),
                                );
                              },
                              child: Text(
                                widget.account.address,
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontFamily: 'monospace',
                                  color: AppColors.primary,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      if (widget.account.description != null) ...[
                        const SizedBox(height: 12),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(
                              Icons.description,
                              size: 20,
                              color: Colors.grey,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                widget.account.description!,
                                style: const TextStyle(fontSize: 14),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Signers Section
              const Text(
                'Signers',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),

              Card(
                child: Column(
                  children: widget.account.signers.asMap().entries.map((entry) {
                    final index = entry.key;
                    final signer = entry.value;
                    final isLast = index == widget.account.signers.length - 1;

                    return Column(
                      children: [
                        ListTile(
                          leading: CircleAvatar(
                            backgroundColor: AppColors.primary,
                            child: Text(
                              '${index + 1}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          title: Text(
                            '${signer.substring(0, 8)}...${signer.substring(signer.length - 8)}',
                            style: const TextStyle(fontFamily: 'monospace'),
                          ),
                          subtitle: index == 0 ? const Text('Owner') : null,
                          trailing: IconButton(
                            icon: const Icon(Icons.copy, size: 20),
                            onPressed: () {
                              Clipboard.setData(ClipboardData(text: signer));
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Address copied to clipboard'),
                                ),
                              );
                            },
                          ),
                        ),
                        if (!isLast) const Divider(height: 1),
                      ],
                    );
                  }).toList(),
                ),
              ),

              const SizedBox(height: 24),

              // Actions Section
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => CreateTransactionScreen(
                              multisigAccount: widget.account,
                            ),
                          ),
                        );
                      },
                      icon: const Icon(Icons.send),
                      label: const Text('Send Transaction'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Transactions Section
              const Text(
                'Recent Transactions',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),

              Consumer2<MultisigProvider, WalletProvider>(
                builder: (context, multisigProvider, walletProvider, child) {
                  final transactions = multisigProvider
                      .getTransactionsForMultisig(widget.account.address);
                  final currentWallet = walletProvider.currentWallet;

                  if (transactions.isEmpty) {
                    return Card(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          children: [
                            Icon(
                              Icons.receipt_long,
                              size: 48,
                              color: Colors.grey[400],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No Transactions',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: Colors.grey[600],
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Transactions for this multisig account will appear here',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[500],
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  return Column(
                    children: transactions
                        .map(
                          (transaction) => Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: TransactionCard(
                              transaction: transaction,
                              currentUserPublicKey:
                                  currentWallet?.publicKey ?? '',
                            ),
                          ),
                        )
                        .toList(),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
