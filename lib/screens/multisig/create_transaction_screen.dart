import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/multisig_account_model.dart';
import '../../providers/multisig_provider.dart';
import '../../providers/wallet_provider.dart';
import '../../services/solana_service.dart';
import '../../utils/constants.dart';

class CreateTransactionScreen extends StatefulWidget {
  final MultisigAccountModel multisigAccount;

  const CreateTransactionScreen({super.key, required this.multisigAccount});

  @override
  State<CreateTransactionScreen> createState() =>
      _CreateTransactionScreenState();
}

class _CreateTransactionScreenState extends State<CreateTransactionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _recipientController = TextEditingController();
  final _amountController = TextEditingController();
  final _memoController = TextEditingController();
  bool _isCreating = false;

  @override
  void dispose() {
    _recipientController.dispose();
    _amountController.dispose();
    _memoController.dispose();
    super.dispose();
  }

  Future<void> _createTransaction() async {
    if (!_formKey.currentState!.validate()) return;

    final currentWallet = context.read<WalletProvider>().currentWallet;
    if (currentWallet == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('No wallet selected')));
      return;
    }

    setState(() {
      _isCreating = true;
    });

    try {
      final multisigProvider = context.read<MultisigProvider>();
      final transaction = await multisigProvider.createTransferTransaction(
        multisigAddress: widget.multisigAccount.address,
        recipient: _recipientController.text.trim(),
        amount: double.parse(_amountController.text.trim()),
        createdBy: currentWallet.publicKey,
        memo: _memoController.text.trim().isEmpty
            ? null
            : _memoController.text.trim(),
      );

      if (transaction != null && mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Transaction created successfully!'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to create transaction: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isCreating = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Transaction'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Multisig Account Info
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'From Multisig Account',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        widget.multisigAccount.name,
                        style: const TextStyle(fontSize: 18),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Balance: ${widget.multisigAccount.balance.toStringAsFixed(4)} SOL',
                        style: const TextStyle(
                          fontSize: 16,
                          color: AppColors.primary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Transaction Form
              const Text(
                'Transaction Details',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _recipientController,
                decoration: const InputDecoration(
                  labelText: 'Recipient Address',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.account_balance_wallet),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter recipient address';
                  }
                  if (!SolanaService.isValidSolanaAddress(value.trim())) {
                    return 'Invalid Solana address';
                  }
                  if (value.trim() == widget.multisigAccount.address) {
                    return 'Cannot send to the same account';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              TextFormField(
                controller: _amountController,
                decoration: const InputDecoration(
                  labelText: 'Amount (SOL)',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.monetization_on),
                ),
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter amount';
                  }
                  final amount = double.tryParse(value.trim());
                  if (amount == null || amount <= 0) {
                    return 'Please enter a valid amount';
                  }
                  if (amount > widget.multisigAccount.balance) {
                    return 'Insufficient balance';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              TextFormField(
                controller: _memoController,
                decoration: const InputDecoration(
                  labelText: 'Memo (Optional)',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.note),
                ),
                maxLines: 3,
              ),

              const SizedBox(height: 24),

              // Transaction Summary
              Card(
                color: Colors.grey[50],
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Transaction Summary',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Required Signatures:'),
                          Text(
                            '${widget.multisigAccount.threshold} of ${widget.multisigAccount.signers.length}',
                            style: const TextStyle(fontWeight: FontWeight.w500),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      const Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Transaction Fee:'),
                          Text(
                            '~0.000005 SOL',
                            style: TextStyle(fontWeight: FontWeight.w500),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 32),

              // Create Button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _isCreating ? null : _createTransaction,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isCreating
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          'Create Transaction',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ),

              const SizedBox(height: 16),

              // Info Text
              Text(
                'This transaction will be created and require ${widget.multisigAccount.threshold} signature(s) before it can be executed.',
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
