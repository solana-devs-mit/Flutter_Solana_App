import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:solana_multisig_wallet/screens/home/wallet_tab.dart';
import '../../providers/wallet_provider.dart';
import '../../services/crypto_service.dart';
import '../../utils/constants.dart';

class ImportWalletScreen extends StatefulWidget {
  const ImportWalletScreen({super.key});

  @override
  State<ImportWalletScreen> createState() => _ImportWalletScreenState();
}

class _ImportWalletScreenState extends State<ImportWalletScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _mnemonicController = TextEditingController();
  bool _obscureMnemonic = true;
  bool _isImporting = false;
  String _importStatus = '';

  @override
  void dispose() {
    _nameController.dispose();
    _mnemonicController.dispose();
    super.dispose();
  }

  Future<void> _importWallet() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isImporting = true;
      _importStatus = 'Validating seed phrase...';
    });

    try {
      final walletProvider = context.read<WalletProvider>();
      final cleanMnemonic = _mnemonicController.text
          .trim()
          .split(RegExp(r'\s+'))
          .join(' ');

      // Update status
      setState(() {
        _importStatus = 'Generating wallet keys...';
      });

      final wallet = await walletProvider.importWallet(
        _nameController.text.trim(),
        cleanMnemonic,
      );

      if (wallet != null && mounted) {
        setState(() {
          _importStatus = 'Wallet imported successfully!';
        });

        // Small delay to show success message
        await Future.delayed(const Duration(milliseconds: 500));

        // Navigate to seed phrase display screen
        if (mounted) {
          Navigator.of(
            context,
          ).pushReplacement(MaterialPageRoute(builder: (_) => WalletTab()));
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _importStatus = '';
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to import wallet: $e'),
            backgroundColor: AppColors.error,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isImporting = false;
          _importStatus = '';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Import Wallet'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.white,
      ),
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.primaryGradient),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight:
                    MediaQuery.of(context).size.height -
                    MediaQuery.of(context).padding.top -
                    kToolbarHeight -
                    48,
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 16),
                    const Text(
                      'Import Existing Wallet',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Enter your seed phrase to restore your wallet',
                      style: TextStyle(fontSize: 16, color: Colors.white70),
                    ),
                    const SizedBox(height: 32),

                    // Security Notice
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.blue.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.blue.withOpacity(0.3)),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.info, color: Colors.blue, size: 20),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Import Notice',
                                  style: TextStyle(
                                    color: Colors.blue,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Only enter your seed phrase on trusted devices',
                                  style: TextStyle(
                                    color: Colors.blue.shade200,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    TextFormField(
                      controller: _nameController,
                      enabled: !_isImporting,
                      decoration: InputDecoration(
                        labelText: 'Wallet Name',
                        labelStyle: const TextStyle(color: Colors.white70),
                        filled: true,
                        fillColor: Colors.white.withOpacity(0.1),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Colors.white30),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Colors.white30),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Colors.white),
                        ),
                        disabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: Colors.white.withOpacity(0.3),
                          ),
                        ),
                        prefixIcon: const Icon(
                          Icons.account_balance_wallet,
                          color: Colors.white70,
                        ),
                      ),
                      style: const TextStyle(color: Colors.white),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter a wallet name';
                        }
                        if (value.trim().length < 3) {
                          return 'Wallet name must be at least 3 characters';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 16),

                    TextFormField(
                      controller: _mnemonicController,
                      enabled: !_isImporting,
                      maxLines: _obscureMnemonic ? 1 : 3,
                      minLines: 1,
                      obscureText: _obscureMnemonic,
                      decoration: InputDecoration(
                        labelText: 'Seed Phrase (12 or 24 words)',
                        labelStyle: const TextStyle(color: Colors.white70),
                        filled: true,
                        fillColor: Colors.white.withOpacity(0.1),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Colors.white30),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Colors.white30),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Colors.white),
                        ),
                        disabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: Colors.white.withOpacity(0.3),
                          ),
                        ),
                        prefixIcon: const Icon(
                          Icons.key,
                          color: Colors.white70,
                        ),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscureMnemonic
                                ? Icons.visibility
                                : Icons.visibility_off,
                            color: Colors.white70,
                          ),
                          onPressed: _isImporting
                              ? null
                              : () {
                                  setState(() {
                                    _obscureMnemonic = !_obscureMnemonic;
                                  });
                                },
                        ),
                      ),
                      style: const TextStyle(color: Colors.white),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter your seed phrase';
                        }
                        final words = value.trim().split(RegExp(r'\s+'));
                        if (words.length != 12 && words.length != 24) {
                          return 'Seed phrase must be 12 or 24 words';
                        }
                        if (words.any((word) => word.isEmpty)) {
                          return 'Invalid seed phrase format';
                        }
                        // Quick validation without heavy crypto operations
                        final cleanMnemonic = words.join(' ');
                        if (!CryptoService.validateMnemonic(cleanMnemonic)) {
                          return 'Invalid seed phrase';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 40),

                    // Import Status
                    if (_importStatus.isNotEmpty) ...[
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.blue.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: Colors.blue.withOpacity(0.3),
                          ),
                        ),
                        child: Row(
                          children: [
                            const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.blue,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                _importStatus,
                                style: const TextStyle(
                                  color: Colors.blue,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],

                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: _isImporting ? null : _importWallet,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _isImporting
                              ? Colors.grey
                              : Colors.white,
                          foregroundColor: _isImporting
                              ? Colors.grey.shade600
                              : AppColors.primary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 2,
                        ),
                        child: _isImporting
                            ? const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.white,
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: 12),
                                  Text(
                                    'Importing...',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              )
                            : const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.download, size: 20),
                                  SizedBox(width: 8),
                                  Text(
                                    'Import Wallet',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
