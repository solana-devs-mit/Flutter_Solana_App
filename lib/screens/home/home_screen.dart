import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/wallet_provider.dart';
import '../../providers/multisig_provider.dart';
import 'wallet_tab.dart';
import 'multisig_tab.dart';
import 'transactions_tab.dart';
import 'settings_tab.dart';
import '../../utils/constants.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  late TabController _tabController;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _tabController.addListener(() {
      setState(() {
        _currentIndex = _tabController.index;
      });
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _refreshData() async {
    final walletProvider = context.read<WalletProvider>();
    final multisigProvider = context.read<MultisigProvider>();

    await Future.wait([
      walletProvider.updateAllBalances(),
      multisigProvider.refresh(),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F23),
      body: Column(
        children: [
          // Custom App Bar with Gradient
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF00D4FF),
                  Color(0xFF5B73FF),
                  Color(0xFF9C27B0),
                ],
              ),
            ),
            child: SafeArea(
              child: Column(
                children: [
                  // App Bar Content
                  Container(
                    height: 56,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Expanded(
                          child: Text(
                            AppStrings.appName,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              letterSpacing: 0.5,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: IconButton(
                            icon: const Icon(
                              Icons.refresh_rounded,
                              color: Colors.white,
                              size: 20,
                            ),
                            onPressed: _refreshData,
                            padding: const EdgeInsets.all(8),
                            constraints: const BoxConstraints(
                              minWidth: 40,
                              minHeight: 40,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Tab Bar
                  Container(
                    margin: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: TabBar(
                        controller: _tabController,
                        indicator: BoxDecoration(
                          color: Colors.white.withOpacity(0.25),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        indicatorPadding: const EdgeInsets.all(4),
                        labelColor: Colors.white,
                        unselectedLabelColor: Colors.white70,
                        labelStyle: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                        ),
                        unselectedLabelStyle: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                        ),
                        dividerColor: Colors.transparent,
                        overlayColor: WidgetStateProperty.all(
                          Colors.transparent,
                        ),
                        splashFactory: NoSplash.splashFactory,
                        tabs: const [
                          Tab(
                            height: 40,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.account_balance_wallet_rounded,
                                  size: 16,
                                ),
                                SizedBox(height: 2),
                                Text('Wallet', overflow: TextOverflow.ellipsis),
                              ],
                            ),
                          ),
                          Tab(
                            height: 40,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.group_rounded, size: 16),
                                SizedBox(height: 2),
                                Text(
                                  'Multisig',
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                          Tab(
                            height: 40,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.receipt_long_rounded, size: 16),
                                SizedBox(height: 2),
                                Text(
                                  'History',
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                          Tab(
                            height: 40,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.settings_rounded, size: 16),
                                SizedBox(height: 2),
                                Text(
                                  'Settings',
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Tab Content
          Expanded(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0xFF0F0F23), Color(0xFF1A1B2E)],
                ),
              ),
              child: TabBarView(
                controller: _tabController,
                children: const [
                  WalletTab(),
                  MultisigTab(),
                  TransactionsTab(),
                  SettingsTab(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
