import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/multisig_provider.dart';
import '../multisig/create_multisig_screen.dart';

class MultisigTab extends StatelessWidget {
  const MultisigTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<MultisigProvider>(
      builder: (context, multisigProvider, child) {
        if (multisigProvider.isLoading) {
          return Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF1A1B2E), Color(0xFF16213E)],
              ),
            ),
            child: const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF00D4FF)),
                strokeWidth: 3,
              ),
            ),
          );
        }

        return Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF0F0F23), Color(0xFF1A1B2E)],
            ),
          ),
          child: RefreshIndicator(
            onRefresh: () => multisigProvider.refresh(),
            backgroundColor: const Color(0xFF1E293B),
            color: const Color(0xFF00D4FF),
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Premium Create Button
                  Container(
                    width: double.infinity,
                    height: 60,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF00D4FF), Color(0xFF5B73FF)],
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
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => const CreateMultisigScreen(),
                            ),
                          );
                        },
                        borderRadius: BorderRadius.circular(20),
                        child: const Center(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.add_rounded,
                                color: Colors.white,
                                size: 24,
                              ),
                              SizedBox(width: 12),
                              Text(
                                'Create Multisig Account',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Multisig Accounts List
                  if (multisigProvider.hasMultisigAccounts) ...[
                    const Text(
                      'Multisig Accounts',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 20),
                    ...multisigProvider.multisigAccounts.map(
                      (account) => Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: _buildPremiumMultisigCard(account),
                      ),
                    ),
                  ] else ...[
                    const SizedBox(height: 60),
                    _buildEmptyState(),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildPremiumMultisigCard(account) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF1E293B), Color(0xFF334155)],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFF00D4FF).withOpacity(0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  account.name,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  gradient: account.isOwner
                      ? const LinearGradient(
                          colors: [Color(0xFF00D4FF), Color(0xFF5B73FF)],
                        )
                      : const LinearGradient(
                          colors: [Color(0xFF64748B), Color(0xFF475569)],
                        ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  account.isOwner ? 'OWNER' : 'MEMBER',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                    letterSpacing: 1,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            '${account.balance.toStringAsFixed(4)} SOL',
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Color(0xFF00D4FF),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF00D4FF).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.people_rounded,
                  size: 20,
                  color: Color(0xFF00D4FF),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                '${account.threshold} of ${account.signers.length} signatures required',
                style: const TextStyle(
                  fontSize: 16,
                  color: Color(0xFF94A3B8),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          if (account.description != null) ...[
            const SizedBox(height: 12),
            Text(
              account.description!,
              style: const TextStyle(fontSize: 14, color: Color(0xFF64748B)),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF0F172A),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '${account.address.substring(0, 8)}...${account.address.substring(account.address.length - 8)}',
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF94A3B8),
                fontFamily: 'monospace',
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF1E293B), Color(0xFF334155)],
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Icon(
              Icons.group_off_rounded,
              size: 80,
              color: Color(0xFF64748B),
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'No Multisig Accounts',
            style: TextStyle(
              fontSize: 22,
              color: Color(0xFF94A3B8),
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'Create your first multisig account to get started\nwith secure multi-signature transactions',
            style: TextStyle(fontSize: 16, color: Color(0xFF64748B)),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
