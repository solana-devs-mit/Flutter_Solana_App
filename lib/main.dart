import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'providers/wallet_provider.dart';
import 'providers/multisig_provider.dart';
import 'services/storage_service.dart';
import 'screens/splash_screen.dart';
import 'utils/constants.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Hive
  await Hive.initFlutter();

  // Initialize services
  await StorageService.initialize();

  runApp(const SolanaMultisigWallet());
}

class SolanaMultisigWallet extends StatelessWidget {
  const SolanaMultisigWallet({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => WalletProvider()),
        ChangeNotifierProvider(create: (_) => MultisigProvider()),
      ],
      child: MaterialApp(
        title: 'Solana Multisig Wallet',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.purple,
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
            seedColor: AppColors.primary,
            brightness: Brightness.light,
          ),
        ),
        darkTheme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
            seedColor: AppColors.primary,
            brightness: Brightness.dark,
          ),
        ),
        home: const SplashScreen(),
      ),
    );
  }
}
