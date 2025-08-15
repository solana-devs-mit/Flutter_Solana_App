import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:solana/encoder.dart';
import 'package:solana/solana.dart';
import '../../providers/wallet_provider.dart';
import '../../services/solana_service.dart';
import '../../utils/constants.dart';
import '../../widgets/wallet_card.dart';
import '../../widgets/action_button.dart';
import 'dart:convert';

class WalletTab extends StatelessWidget {
  const WalletTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<WalletProvider>(
      builder: (context, walletProvider, child) {
        if (walletProvider.isLoading) {
          return const Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF00D4FF)),
              strokeWidth: 3,
            ),
          );
        }

        if (!walletProvider.hasWallets) {
          return const Center(
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
                  'No wallets found',
                  style: TextStyle(
                    fontSize: 18,
                    color: Color(0xFF94A3B8),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Create your first wallet to get started',
                  style: TextStyle(fontSize: 14, color: Color(0xFF64748B)),
                ),
              ],
            ),
          );
        }

        final currentWallet = walletProvider.currentWallet!;

        return RefreshIndicator(
          onRefresh: () => walletProvider.updateAllBalances(),
          backgroundColor: const Color(0xFF1E293B),
          color: const Color(0xFF00D4FF),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Premium Wallet Card
                _buildPremiumWalletCard(currentWallet),

                const SizedBox(height: 24),

                // Premium Action Buttons
                _buildPremiumActionButtons(
                  context,
                  currentWallet,
                  walletProvider,
                ),

                const SizedBox(height: 24),

                // Wallet List
                if (walletProvider.wallets.length > 1) ...[
                  const Text(
                    'All Wallets',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ...walletProvider.wallets.map(
                    (wallet) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _buildPremiumWalletListItem(
                        wallet,
                        currentWallet,
                        walletProvider,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildPremiumWalletCard(wallet) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF00D4FF), Color(0xFF5B73FF), Color(0xFF9C27B0)],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF00D4FF).withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      wallet.name,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: 0.5,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        wallet.isImported ? 'IMPORTED' : 'CREATED',
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.account_balance_wallet,
                  color: Colors.white,
                  size: 24,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          const Text(
            'Balance',
            style: TextStyle(
              fontSize: 14,
              color: Colors.white70,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            '${wallet.balance.toStringAsFixed(4)} SOL',
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Icon(Icons.fingerprint, color: Colors.white70, size: 16),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '${wallet.publicKey.substring(0, 8)}...${wallet.publicKey.substring(wallet.publicKey.length - 8)}',
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.white70,
                      fontFamily: 'monospace',
                      letterSpacing: 0.5,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    Clipboard.setData(ClipboardData(text: wallet.publicKey));
                  },
                  child: const Icon(
                    Icons.copy,
                    color: Colors.white70,
                    size: 16,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPremiumActionButtons(
    BuildContext context,
    wallet,
    WalletProvider walletProvider,
  ) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Row(
          children: [
            Expanded(
              child: _buildActionButton(
                icon: Icons.send_rounded,
                label: 'Send',
                gradient: const LinearGradient(
                  colors: [Color(0xFF00D4FF), Color(0xFF5B73FF)],
                ),
                onPressed: () =>
                    _showSendDialog(context, wallet, walletProvider),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildActionButton(
                icon: Icons.call_received_rounded,
                label: 'Receive',
                gradient: const LinearGradient(
                  colors: [Color(0xFF5B73FF), Color(0xFF9C27B0)],
                ),
                onPressed: () => _showReceiveDialog(context, wallet.publicKey),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildActionButton(
                icon: Icons.water_drop_rounded,
                label: 'Airdrop',
                gradient: const LinearGradient(
                  colors: [Color(0xFF9C27B0), Color(0xFFE91E63)],
                ),
                onPressed: () => _requestAirdrop(context, walletProvider),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Gradient gradient,
    required VoidCallback onPressed,
  }) {
    return Container(
      height: 64,
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: Colors.white, size: 20),
              const SizedBox(height: 4),
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.3,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPremiumWalletListItem(
    wallet,
    currentWallet,
    WalletProvider walletProvider,
  ) {
    final isSelected = wallet.publicKey == currentWallet.publicKey;

    return Container(
      decoration: BoxDecoration(
        gradient: isSelected
            ? const LinearGradient(
                colors: [Color(0xFF1E293B), Color(0xFF334155)],
              )
            : null,
        color: isSelected ? null : const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(16),
        border: isSelected
            ? Border.all(color: const Color(0xFF00D4FF), width: 1)
            : null,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => walletProvider.switchWallet(wallet.publicKey),
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    gradient: isSelected
                        ? const LinearGradient(
                            colors: [Color(0xFF00D4FF), Color(0xFF5B73FF)],
                          )
                        : const LinearGradient(
                            colors: [Color(0xFF64748B), Color(0xFF475569)],
                          ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Text(
                      wallet.name[0].toUpperCase(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        wallet.name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${wallet.balance.toStringAsFixed(4)} SOL',
                        style: TextStyle(
                          color: isSelected
                              ? const Color(0xFF00D4FF)
                              : const Color(0xFF94A3B8),
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                if (isSelected)
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: const Color(0xFF00D4FF).withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.check_circle_rounded,
                      color: Color(0xFF00D4FF),
                      size: 16,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showSendDialog(
    BuildContext context,
    wallet,
    WalletProvider walletProvider,
  ) {
    showDialog(
      context: context,
      builder: (context) =>
          SendTransactionDialog(wallet: wallet, walletProvider: walletProvider),
    );
  }

  void _showReceiveDialog(BuildContext context, String publicKey) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF1E293B), Color(0xFF334155)],
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF00D4FF), Color(0xFF5B73FF)],
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.call_received_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'Receive SOL',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              const Text(
                'Share this address to receive SOL:',
                style: TextStyle(fontSize: 14, color: Color(0xFF94A3B8)),
              ),
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF0F172A),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFF334155)),
                ),
                child: Column(
                  children: [
                    SelectableText(
                      publicKey,
                      style: const TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 12,
                        color: Colors.white,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      width: double.infinity,
                      height: 44,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF00D4FF), Color(0xFF5B73FF)],
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () {
                            Clipboard.setData(ClipboardData(text: publicKey));
                            Navigator.of(context).pop();
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: const Text(
                                  'Address copied to clipboard',
                                ),
                                backgroundColor: const Color(0xFF00D4FF),
                                behavior: SnackBarBehavior.floating,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                margin: const EdgeInsets.all(16),
                              ),
                            );
                          },
                          borderRadius: BorderRadius.circular(8),
                          child: const Center(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.copy, color: Colors.white, size: 16),
                                SizedBox(width: 6),
                                Text(
                                  'Copy Address',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text(
                  'Close',
                  style: TextStyle(color: Color(0xFF94A3B8), fontSize: 14),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _requestAirdrop(
    BuildContext context,
    WalletProvider walletProvider,
  ) async {
    final currentWallet = walletProvider.currentWallet!;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF1E293B), Color(0xFF334155)],
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF00D4FF)),
              ),
              SizedBox(height: 16),
              Text(
                'Requesting airdrop...',
                style: TextStyle(color: Colors.white, fontSize: 14),
              ),
            ],
          ),
        ),
      ),
    );

    final success = await walletProvider.requestAirdrop(
      currentWallet.publicKey,
      1.0,
    );

    if (context.mounted) {
      Navigator.of(context).pop();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            success
                ? 'Airdrop successful! 1 SOL added to your wallet.'
                : 'Airdrop failed. Please try again later.',
          ),
          backgroundColor: success
              ? const Color(0xFF10B981)
              : const Color(0xFFEF4444),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          margin: const EdgeInsets.all(16),
        ),
      );
    }
  }
}

class SendTransactionDialog extends StatefulWidget {
  final wallet;
  final WalletProvider walletProvider;

  const SendTransactionDialog({
    super.key,
    required this.wallet,
    required this.walletProvider,
  });

  @override
  State<SendTransactionDialog> createState() => _SendTransactionDialogState();
}

class _SendTransactionDialogState extends State<SendTransactionDialog> {
  final _formKey = GlobalKey<FormState>();
  final _recipientController = TextEditingController();
  final _amountController = TextEditingController();
  final _memoController = TextEditingController();

  bool _isLoading = false;
  final double _estimatedFee = 0.000005;

  @override
  void dispose() {
    _recipientController.dispose();
    _amountController.dispose();
    _memoController.dispose();
    super.dispose();
  }

  Future<void> _sendTransaction() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final recipient = _recipientController.text.trim();
      final amount = double.parse(_amountController.text.trim());
      final memo = _memoController.text.trim();

      final privateKeyBase64 = await widget.walletProvider.getPrivateKey(
        widget.wallet.publicKey,
      );
      if (privateKeyBase64 == null) {
        throw Exception('Private key not found');
      }

      final txHash = await _createAndSendSolanaTransaction(
        fromPublicKey: widget.wallet.publicKey,
        toPublicKey: recipient,
        amount: amount,
        privateKeyBase64: privateKeyBase64,
        memo: memo.isEmpty ? null : memo,
      );

      if (mounted) {
        Navigator.of(context).pop();
        _showTransactionSuccessDialog(txHash);
        await widget.walletProvider.updateWalletBalance(
          widget.wallet.publicKey,
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Transaction failed: $e'),
            backgroundColor: const Color(0xFFEF4444),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            margin: const EdgeInsets.all(16),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<String> _createAndSendSolanaTransaction({
    required String fromPublicKey,
    required String toPublicKey,
    required double amount,
    required String privateKeyBase64,
    String? memo,
  }) async {
    try {
      final client = SolanaClient(
        rpcUrl: Uri.parse(AppConstants.devnetUrl),
        websocketUrl: Uri.parse(
          AppConstants.devnetUrl.replaceFirst('https', 'wss'),
        ),
      );

      final privateKeyBytes = base64Decode(privateKeyBase64);
      final keyPair = await Ed25519HDKeyPair.fromPrivateKeyBytes(
        privateKey: privateKeyBytes,
      );

      final source = Ed25519HDPublicKey.fromBase58(fromPublicKey);
      final destination = Ed25519HDPublicKey.fromBase58(toPublicKey);
      final lamports = (amount * AppConstants.lamportsPerSol).toInt();

      final transferInstruction = SystemInstruction.transfer(
        fundingAccount: source,
        recipientAccount: destination,
        lamports: lamports,
      );

      final instructions = <Instruction>[transferInstruction];
      final message = Message(instructions: instructions);

      final signature = await client.sendAndConfirmTransaction(
        message: message,
        signers: [keyPair],
        commitment: Commitment.confirmed,
      );

      return signature.toString();
    } catch (e) {
      print('Detailed transaction error: $e');
      throw Exception('Failed to send transaction: $e');
    }
  }

  void _showTransactionSuccessDialog(String txHash) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF1E293B), Color(0xFF334155)],
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF10B981), Color(0xFF059669)],
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(
                  Icons.check_circle_rounded,
                  color: Colors.white,
                  size: 32,
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Transaction Sent!',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Your transaction has been successfully sent!',
                style: TextStyle(fontSize: 14, color: Color(0xFF94A3B8)),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF0F172A),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFF334155)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Transaction Hash:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 6),
                    SelectableText(
                      txHash,
                      style: const TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 10,
                        color: Color(0xFF94A3B8),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () {
                        Clipboard.setData(ClipboardData(text: txHash));
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: const Text('Transaction hash copied'),
                            backgroundColor: const Color(0xFF00D4FF),
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            margin: const EdgeInsets.all(16),
                          ),
                        );
                      },
                      child: const Text(
                        'Copy Hash',
                        style: TextStyle(
                          color: Color(0xFF00D4FF),
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Container(
                      height: 40,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF00D4FF), Color(0xFF5B73FF)],
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () => Navigator.of(context).pop(),
                          borderRadius: BorderRadius.circular(8),
                          child: const Center(
                            child: Text(
                              'Close',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        width: double.maxFinite,
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF1E293B), Color(0xFF334155)],
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF00D4FF), Color(0xFF5B73FF)],
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.send_rounded,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Text(
                        'Send SOL',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // From wallet info
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF00D4FF), Color(0xFF5B73FF)],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.account_balance_wallet,
                        color: Colors.white,
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'From: ${widget.wallet.name}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                fontSize: 14,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Balance: ${widget.wallet.balance.toStringAsFixed(4)} SOL',
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // Form fields with premium styling
                _buildPremiumTextField(
                  controller: _recipientController,
                  label: 'Recipient Address',
                  icon: Icons.person_rounded,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter recipient address';
                    }
                    if (!SolanaService.isValidSolanaAddress(value.trim())) {
                      return 'Invalid Solana address';
                    }
                    if (value.trim() == widget.wallet.publicKey) {
                      return 'Cannot send to yourself';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 16),

                _buildPremiumTextField(
                  controller: _amountController,
                  label: 'Amount (SOL)',
                  icon: Icons.monetization_on_rounded,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  onChanged: (value) => setState(() {}),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter amount';
                    }
                    final amount = double.tryParse(value.trim());
                    if (amount == null || amount <= 0) {
                      return 'Please enter a valid amount';
                    }
                    if (amount + _estimatedFee > widget.wallet.balance) {
                      return 'Insufficient balance (including fees)';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 16),

                _buildPremiumTextField(
                  controller: _memoController,
                  label: 'Memo (Optional)',
                  icon: Icons.note_rounded,
                  maxLines: 2,
                ),

                const SizedBox(height: 20),

                // Transaction summary
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0F172A),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFF334155)),
                  ),
                  child: Column(
                    children: [
                      _buildSummaryRow(
                        'Amount:',
                        '${_amountController.text.isEmpty ? '0.0000' : double.tryParse(_amountController.text)?.toStringAsFixed(4) ?? '0.0000'} SOL',
                      ),
                      const SizedBox(height: 8),
                      _buildSummaryRow(
                        'Network Fee:',
                        '${_estimatedFee.toStringAsFixed(6)} SOL',
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 8),
                        child: Divider(color: Color(0xFF334155), height: 1),
                      ),
                      _buildSummaryRow(
                        'Total:',
                        '${((double.tryParse(_amountController.text) ?? 0.0) + _estimatedFee).toStringAsFixed(6)} SOL',
                        isTotal: true,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Action buttons
                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: _isLoading
                            ? null
                            : () => Navigator.of(context).pop(),
                        child: const Text(
                          'Cancel',
                          style: TextStyle(
                            color: Color(0xFF94A3B8),
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 2,
                      child: Container(
                        height: 44,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF00D4FF), Color(0xFF5B73FF)],
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: _isLoading ? null : _sendTransaction,
                            borderRadius: BorderRadius.circular(8),
                            child: Center(
                              child: _isLoading
                                  ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                              Colors.white,
                                            ),
                                      ),
                                    )
                                  : const Text(
                                      'Send Transaction',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPremiumTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    int maxLines = 1,
    String? Function(String?)? validator,
    void Function(String)? onChanged,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      validator: validator,
      onChanged: onChanged,
      style: const TextStyle(color: Colors.white, fontSize: 14),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Color(0xFF94A3B8), fontSize: 12),
        prefixIcon: Icon(icon, color: const Color(0xFF00D4FF), size: 18),
        filled: true,
        fillColor: const Color(0xFF0F172A),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF334155)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF334155)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF00D4FF), width: 1),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFEF4444)),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 12,
        ),
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, {bool isTotal = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            color: isTotal ? Colors.white : const Color(0xFF94A3B8),
            fontSize: isTotal ? 14 : 12,
            fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            color: isTotal ? const Color(0xFF00D4FF) : Colors.white,
            fontSize: isTotal ? 14 : 12,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
