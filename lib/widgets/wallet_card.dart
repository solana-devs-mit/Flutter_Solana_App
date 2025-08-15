import 'package:flutter/material.dart';
import '../models/wallet_model.dart';
import '../utils/constants.dart';

class WalletCard extends StatelessWidget {
  final WalletModel wallet;

  const WalletCard({super.key, required this.wallet});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                wallet.name,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  wallet.isImported ? 'IMPORTED' : 'CREATED',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          const Text(
            'Balance',
            style: TextStyle(fontSize: 14, color: Colors.white70),
          ),
          const SizedBox(height: 4),
          Text(
            '${wallet.balance.toStringAsFixed(4)} SOL',
            style: const TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            '${wallet.publicKey.substring(0, 8)}...${wallet.publicKey.substring(wallet.publicKey.length - 8)}',
            style: const TextStyle(
              fontSize: 14,
              color: Colors.white70,
              fontFamily: 'monospace',
            ),
          ),
        ],
      ),
    );
  }
}
