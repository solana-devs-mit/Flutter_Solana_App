import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/multisig_provider.dart';
import '../../providers/wallet_provider.dart';
import '../../utils/constants.dart';
import '../../services/solana_service.dart';

class CreateMultisigScreen extends StatefulWidget {
  const CreateMultisigScreen({super.key});

  @override
  State<CreateMultisigScreen> createState() => _CreateMultisigScreenState();
}

class _CreateMultisigScreenState extends State<CreateMultisigScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final List<TextEditingController> _signerControllers = [];
  int _threshold = 2;
  bool _isCreating = false;

  @override
  void initState() {
    super.initState();
    // Add current wallet as first signer
    final currentWallet = context.read<WalletProvider>().currentWallet;
    if (currentWallet != null) {
      _signerControllers.add(
        TextEditingController(text: currentWallet.publicKey),
      );
    }
    // Add one empty signer field
    _signerControllers.add(TextEditingController());
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    for (final controller in _signerControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _addSignerField() {
    if (_signerControllers.length < AppConstants.maxSigners) {
      setState(() {
        _signerControllers.add(TextEditingController());
      });
    }
  }

  void _removeSignerField(int index) {
    if (_signerControllers.length > AppConstants.minSigners && index > 0) {
      setState(() {
        _signerControllers[index].dispose();
        _signerControllers.removeAt(index);
        if (_threshold > _signerControllers.length) {
          _threshold = _signerControllers.length;
        }
      });
    }
  }

  Future<void> _createMultisig() async {
    if (!_formKey.currentState!.validate()) return;

    // Get non-empty signers
    final signers = _signerControllers
        .map((controller) => controller.text.trim())
        .where((signer) => signer.isNotEmpty)
        .toList();

    if (signers.length < AppConstants.minSigners) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Minimum ${AppConstants.minSigners} signers required'),
        ),
      );
      return;
    }

    // Check for duplicate signers
    final uniqueSigners = signers.toSet();
    if (uniqueSigners.length != signers.length) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Duplicate signers are not allowed')),
      );
      return;
    }

    setState(() {
      _isCreating = true;
    });

    try {
      final multisigProvider = context.read<MultisigProvider>();
      final account = await multisigProvider.createMultisigAccount(
        name: _nameController.text.trim(),
        signers: signers,
        threshold: _threshold,
        description: _descriptionController.text.trim().isEmpty
            ? null
            : _descriptionController.text.trim(),
      );

      if (account != null && mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Multisig account created successfully!'),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to create multisig: $e')),
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
        title: const Text('Create Multisig Account'),
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
              // Basic Information
              const Text(
                'Basic Information',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Account Name',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter an account name';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description (Optional)',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),

              const SizedBox(height: 32),

              // Signers Section
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Signers',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  TextButton.icon(
                    onPressed:
                        _signerControllers.length < AppConstants.maxSigners
                        ? _addSignerField
                        : null,
                    icon: const Icon(Icons.add),
                    label: const Text('Add Signer'),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Signer Fields
              ...List.generate(_signerControllers.length, (index) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _signerControllers[index],
                          decoration: InputDecoration(
                            labelText: index == 0
                                ? 'Your Address (Owner)'
                                : 'Signer ${index + 1}',
                            border: const OutlineInputBorder(),
                            suffixIcon:
                                index > 0 &&
                                    _signerControllers.length >
                                        AppConstants.minSigners
                                ? IconButton(
                                    icon: const Icon(
                                      Icons.remove_circle_outline,
                                    ),
                                    onPressed: () => _removeSignerField(index),
                                  )
                                : null,
                          ),
                          readOnly:
                              index == 0, // First signer (owner) is read-only
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return index == 0
                                  ? null
                                  : 'Please enter a signer address';
                            }
                            if (!SolanaService.isValidSolanaAddress(
                              value.trim(),
                            )) {
                              return 'Invalid Solana address';
                            }
                            return null;
                          },
                        ),
                      ),
                    ],
                  ),
                );
              }),

              const SizedBox(height: 32),

              // Threshold Section
              const Text(
                'Approval Threshold',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),

              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Required Approvals: $_threshold of ${_signerControllers.where((c) => c.text.trim().isNotEmpty).length}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Slider(
                        value: _threshold.toDouble(),
                        min: 1,
                        max: _signerControllers
                            .where((c) => c.text.trim().isNotEmpty)
                            .length
                            .toDouble(),
                        divisions:
                            _signerControllers
                                .where((c) => c.text.trim().isNotEmpty)
                                .length -
                            1,
                        label: _threshold.toString(),
                        onChanged: (value) {
                          setState(() {
                            _threshold = value.round();
                          });
                        },
                      ),
                      Text(
                        'This multisig account will require $_threshold signature(s) to approve transactions.',
                        style: TextStyle(fontSize: 14, color: Colors.grey[600]),
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
                  onPressed: _isCreating ? null : _createMultisig,
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
                          'Create Multisig Account',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
