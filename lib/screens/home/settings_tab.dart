import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/wallet_provider.dart';
import '../../providers/multisig_provider.dart';
import '../onboarding/welcome_screen.dart';

class SettingsTab extends StatelessWidget {
  const SettingsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF0F0F23), Color(0xFF1A1B2E)],
        ),
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Settings',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 32),

            // Wallet Settings
            _buildPremiumSettingsSection(
              title: 'Wallet',
              icon: Icons.account_balance_wallet_rounded,
              children: [
                _buildPremiumSettingsTile(
                  icon: Icons.add_circle_outline_rounded,
                  title: 'Create New Wallet',
                  subtitle: 'Add another wallet to your account',
                  onTap: () => _showCreateWalletDialog(context),
                ),
                _buildPremiumSettingsTile(
                  icon: Icons.download_rounded,
                  title: 'Import Wallet',
                  subtitle: 'Import wallet from seed phrase',
                  onTap: () => _showImportWalletDialog(context),
                ),
                _buildPremiumSettingsTile(
                  icon: Icons.backup_rounded,
                  title: 'Backup Wallet',
                  subtitle: 'View your seed phrase',
                  onTap: () => _showBackupDialog(context),
                ),
              ],
            ),

            const SizedBox(height: 32),

            // Security Settings
            _buildPremiumSettingsSection(
              title: 'Security',
              icon: Icons.security_rounded,
              children: [
                _buildPremiumSettingsTile(
                  icon: Icons.shield_rounded,
                  title: 'Security Settings',
                  subtitle: 'Manage your security preferences',
                  onTap: () => _showSecuritySettings(context),
                ),
                _buildPremiumSettingsTile(
                  icon: Icons.lock_reset_rounded,
                  title: 'Reset App',
                  subtitle: 'Clear all data and start fresh',
                  onTap: () => _showResetDialog(context),
                  isDestructive: true,
                ),
              ],
            ),

            const SizedBox(height: 32),

            // About Section
            _buildPremiumSettingsSection(
              title: 'About',
              icon: Icons.info_outline_rounded,
              children: [
                _buildPremiumSettingsTile(
                  icon: Icons.info_rounded,
                  title: 'App Version',
                  subtitle: '1.0.0',
                  onTap: null,
                ),
                _buildPremiumSettingsTile(
                  icon: Icons.help_outline_rounded,
                  title: 'Help & Support',
                  subtitle: 'Get help with using the app',
                  onTap: () => _showHelpDialog(context),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPremiumSettingsSection({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF00D4FF), Color(0xFF5B73FF)],
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(icon, color: Colors.white, size: 24),
            ),
            const SizedBox(width: 16),
            Text(
              title,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        Container(
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF1E293B), Color(0xFF334155)],
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 15,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(children: children),
        ),
      ],
    );
  }

  Widget _buildPremiumSettingsTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback? onTap,
    bool isDestructive = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: const Color(0xFF334155).withOpacity(0.5),
            width: 0.5,
          ),
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    gradient: isDestructive
                        ? const LinearGradient(
                            colors: [Color(0xFFEF4444), Color(0xFFDC2626)],
                          )
                        : const LinearGradient(
                            colors: [Color(0xFF00D4FF), Color(0xFF5B73FF)],
                          ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: Colors.white, size: 20),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          color: isDestructive
                              ? const Color(0xFFEF4444)
                              : Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: const TextStyle(
                          color: Color(0xFF94A3B8),
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                if (onTap != null)
                  const Icon(
                    Icons.chevron_right_rounded,
                    color: Color(0xFF64748B),
                    size: 24,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showCreateWalletDialog(BuildContext context) {
    _showPremiumSnackBar(context, 'Create wallet feature coming soon!', false);
  }

  void _showImportWalletDialog(BuildContext context) {
    _showPremiumSnackBar(context, 'Import wallet feature coming soon!', false);
  }

  void _showBackupDialog(BuildContext context) {
    _showPremiumSnackBar(context, 'Backup feature coming soon!', false);
  }

  void _showSecuritySettings(BuildContext context) {
    _showPremiumSnackBar(context, 'Security settings coming soon!', false);
  }

  void _showResetDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF1E293B), Color(0xFF334155)],
            ),
            borderRadius: BorderRadius.circular(24),
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
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFEF4444), Color(0xFFDC2626)],
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Icon(
                  Icons.warning_rounded,
                  color: Colors.white,
                  size: 32,
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Reset App',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'This will delete all your wallets and data. Make sure you have backed up your seed phrases. This action cannot be undone.',
                style: TextStyle(fontSize: 16, color: Color(0xFF94A3B8)),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text(
                        'Cancel',
                        style: TextStyle(
                          color: Color(0xFF94A3B8),
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Container(
                      height: 50,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFFEF4444), Color(0xFFDC2626)],
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () => _resetApp(context),
                          borderRadius: BorderRadius.circular(12),
                          child: const Center(
                            child: Text(
                              'Reset',
                              style: TextStyle(
                                color: Colors.white,
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
    );
  }

  void _showHelpDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF1E293B), Color(0xFF334155)],
            ),
            borderRadius: BorderRadius.circular(24),
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
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF00D4FF), Color(0xFF5B73FF)],
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Icon(
                  Icons.help_outline_rounded,
                  color: Colors.white,
                  size: 32,
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Help & Support',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Solana Multisig Wallet v1.0.0\n\nThis is a secure multi-signature wallet for the Solana blockchain. For support, please contact our team or visit our documentation.',
                style: TextStyle(fontSize: 16, color: Color(0xFF94A3B8)),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              Container(
                width: double.infinity,
                height: 50,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF00D4FF), Color(0xFF5B73FF)],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () => Navigator.of(context).pop(),
                    borderRadius: BorderRadius.circular(12),
                    child: const Center(
                      child: Text(
                        'Close',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
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

  void _resetApp(BuildContext context) async {
    try {
      await context.read<WalletProvider>().initialize();
      await context.read<MultisigProvider>().initialize();

      if (context.mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const WelcomeScreen()),
          (route) => false,
        );
      }
    } catch (e) {
      if (context.mounted) {
        _showPremiumSnackBar(context, 'Failed to reset app: $e', true);
      }
    }
  }

  void _showPremiumSnackBar(
    BuildContext context,
    String message,
    bool isError,
  ) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError
            ? const Color(0xFFEF4444)
            : const Color(0xFF00D4FF),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}
