import 'package:flutter/material.dart';

class AppColors {
  static const Color primary = Color(0xFF9945FF);
  static const Color secondary = Color(0xFF14F195);
  static const Color background = Color(0xFF000212);
  static const Color surface = Color(0xFF1A1B23);
  static const Color error = Color(0xFFFF6B6B);
  static const Color success = Color(0xFF51CF66);
  static const Color warning = Color(0xFFFFD43B);

  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF9945FF), Color(0xFF14F195)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}

class AppConstants {
  // Solana Network URLs
  static const String mainnetUrl = 'https://api.mainnet-beta.solana.com';
  static const String devnetUrl = 'https://api.devnet.solana.com';
  static const String testnetUrl = 'https://api.testnet.solana.com';

  // Storage Keys
  static const String walletKey = 'wallet_data';
  static const String multisigKey = 'multisig_accounts';
  static const String settingsKey = 'app_settings';

  // Multi-signature
  static const int maxSigners = 11;
  static const int minSigners = 2;
  static const int defaultThreshold = 2;

  // Transaction
  static const int maxRetries = 3;
  static const Duration timeoutDuration = Duration(seconds: 30);

  // Solana
  static const int lamportsPerSol = 1000000000;
}

class AppStrings {
  static const String appName = 'Solana Multisig Wallet';
  static const String tagline = 'Secure Multi-Signature Wallet for Solana';

  // Onboarding
  static const String welcomeTitle = 'Welcome to Solana Multisig';
  static const String welcomeSubtitle =
      'Create or import your secure multi-signature wallet';

  // Wallet
  static const String createWallet = 'Create New Wallet';
  static const String importWallet = 'Import Existing Wallet';
  static const String walletBalance = 'Wallet Balance';

  // Multi-signature
  static const String createMultisig = 'Create Multisig Account';
  static const String pendingTransactions = 'Pending Transactions';
  static const String signTransaction = 'Sign Transaction';
}
