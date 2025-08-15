import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:crypto/crypto.dart';
import 'package:convert/convert.dart';
import '../utils/constants.dart';

// Solana Transaction Model
class SolanaTransaction {
  final String signature;
  final double amount;
  final String type; // 'incoming' or 'outgoing'
  final String status; // 'confirmed', 'failed', etc.
  final DateTime timestamp;
  final String? counterparty;
  final String? memo;

  SolanaTransaction({
    required this.signature,
    required this.amount,
    required this.type,
    required this.status,
    required this.timestamp,
    this.counterparty,
    this.memo,
  });

  factory SolanaTransaction.fromJson(
    Map<String, dynamic> json,
    String walletAddress,
  ) {
    final transaction = json['transaction'];
    final meta = json['meta'];

    // Determine transaction type and amount
    double amount = 0.0;
    String type = 'outgoing';
    String? counterparty;

    if (meta != null &&
        meta['preBalances'] != null &&
        meta['postBalances'] != null) {
      final preBalances = List<int>.from(meta['preBalances']);
      final postBalances = List<int>.from(meta['postBalances']);

      if (preBalances.isNotEmpty && postBalances.isNotEmpty) {
        final balanceChange =
            (postBalances[0] - preBalances[0]) / AppConstants.lamportsPerSol;
        amount = balanceChange.abs();
        type = balanceChange > 0 ? 'incoming' : 'outgoing';
      }
    }

    // Extract counterparty from account keys
    if (transaction != null && transaction['message'] != null) {
      final accountKeys = List<String>.from(
        transaction['message']['accountKeys'] ?? [],
      );
      if (accountKeys.length > 1) {
        counterparty = accountKeys.firstWhere(
          (key) => key != walletAddress,
          orElse: () => accountKeys.length > 1 ? accountKeys[1] : '',
        );
      }
    }

    return SolanaTransaction(
      signature: json['transaction']?['signatures']?[0] ?? '',
      amount: amount,
      type: type,
      status: meta?['err'] == null ? 'confirmed' : 'failed',
      timestamp: DateTime.fromMillisecondsSinceEpoch(
        (json['blockTime'] ?? 0) * 1000,
      ),
      counterparty: counterparty,
    );
  }
}

class SolanaService {
  static const String _rpcUrl = AppConstants.devnetUrl;
  static int _requestId = 1;

  // RPC Request Helper - now returns dynamic
  static Future<dynamic> _makeRpcRequest(
    String method,
    List<dynamic> params,
  ) async {
    final request = {
      'jsonrpc': '2.0',
      'id': _requestId++,
      'method': method,
      'params': params,
    };

    final response = await http.post(
      Uri.parse(_rpcUrl),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(request),
    );

    if (response.statusCode != 200) {
      throw Exception('HTTP ${response.statusCode}: ${response.body}');
    }

    final data = jsonDecode(response.body);
    if (data['error'] != null) {
      throw Exception('RPC Error: ${data['error']['message']}');
    }

    return data['result'];
  }

  // Get Transaction History
  static Future<List<SolanaTransaction>> getTransactionHistory(
    String publicKey, {
    int limit = 20,
  }) async {
    try {
      final result = await _makeRpcRequest('getSignaturesForAddress', [
        publicKey,
        {'limit': limit, 'commitment': 'confirmed'},
      ]);

      final signatures = List<Map<String, dynamic>>.from(result ?? []);
      final transactions = <SolanaTransaction>[];

      // Get detailed transaction info for each signature
      for (final sigInfo in signatures) {
        try {
          final signature = sigInfo['signature'];
          final txResult = await _makeRpcRequest('getTransaction', [
            signature,
            {'encoding': 'json', 'maxSupportedTransactionVersion': 0},
          ]);

          if (txResult != null) {
            final transaction = SolanaTransaction.fromJson(txResult, publicKey);
            transactions.add(transaction);
          }
        } catch (e) {
          print('Error fetching transaction details: $e');
          // Continue with other transactions even if one fails
        }
      }

      return transactions;
    } catch (e) {
      print('Error getting transaction history: $e');
      return [];
    }
  }

  // Get Account Balance
  static Future<double> getBalance(String publicKey) async {
    try {
      final result = await _makeRpcRequest('getBalance', [publicKey]);
      final lamports = result['value'] as int;
      return lamports / AppConstants.lamportsPerSol;
    } catch (e) {
      print('Error getting balance: $e');
      return 0.0;
    }
  }

  // Get Account Info
  static Future<Map<String, dynamic>?> getAccountInfo(String publicKey) async {
    try {
      final result = await _makeRpcRequest('getAccountInfo', [
        publicKey,
        {'encoding': 'base64'},
      ]);
      return result['value'] as Map<String, dynamic>?;
    } catch (e) {
      print('Error getting account info: $e');
      return null;
    }
  }

  // Get Recent Blockhash
  static Future<String> getRecentBlockhash() async {
    final result = await _makeRpcRequest('getRecentBlockhash', []);
    return result['value']['blockhash'] as String;
  }

  // Send Transaction
  static Future<String> sendTransaction(String signedTransaction) async {
    final result = await _makeRpcRequest('sendTransaction', [
      signedTransaction,
      {'encoding': 'base64'},
    ]);
    return result as String;
  }

  // Get Transaction Status
  static Future<Map<String, dynamic>?> getTransactionStatus(
    String signature,
  ) async {
    try {
      final result = await _makeRpcRequest('getSignatureStatus', [signature]);
      return result as Map<String, dynamic>?;
    } catch (e) {
      print('Error getting transaction status: $e');
      return null;
    }
  }

  // Get Minimum Rent Exemption
  static Future<int> getMinimumBalanceForRentExemption(int dataLength) async {
    final result = await _makeRpcRequest('getMinimumBalanceForRentExemption', [
      dataLength,
    ]);
    return result as int;
  }

  // Validate Address
  static bool isValidSolanaAddress(String address) {
    try {
      if (address.length < 32 || address.length > 44) return false;
      final validChars = RegExp(r'^[1-9A-HJ-NP-Za-km-z]+$');
      return validChars.hasMatch(address);
    } catch (e) {
      return false;
    }
  }

  // Create Transfer Instruction
  static Map<String, dynamic> createTransferInstruction({
    required String fromPubkey,
    required String toPubkey,
    required int lamports,
  }) {
    return {
      'programId': '11111111111111111111111111111112',
      'keys': [
        {'pubkey': fromPubkey, 'isSigner': true, 'isWritable': true},
        {'pubkey': toPubkey, 'isSigner': false, 'isWritable': true},
      ],
      'data': _encodeTransferInstruction(lamports),
    };
  }

  static String _encodeTransferInstruction(int lamports) {
    final buffer = ByteData(12);
    buffer.setUint32(0, 2, Endian.little);
    buffer.setUint64(4, lamports, Endian.little);
    return base64Encode(buffer.buffer.asUint8List());
  }

  // Get Token Accounts
  static Future<List<Map<String, dynamic>>> getTokenAccounts(
    String publicKey,
  ) async {
    try {
      final result = await _makeRpcRequest('getTokenAccountsByOwner', [
        publicKey,
        {'programId': 'TokenkegQfeZyiNwAJbNbGKPFXCWuBvf9Ss623VQ5DA'},
        {'encoding': 'jsonParsed'},
      ]);
      return List<Map<String, dynamic>>.from(result['value'] ?? []);
    } catch (e) {
      print('Error getting token accounts: $e');
      return [];
    }
  }

  // Airdrop SOL (Devnet only)
  static Future<String?> requestAirdrop(
    String publicKey,
    double solAmount,
  ) async {
    try {
      final lamports = (solAmount * AppConstants.lamportsPerSol).toInt();
      final result = await _makeRpcRequest('requestAirdrop', [
        publicKey,
        lamports,
      ]);
      return result as String;
    } catch (e) {
      print('Error requesting airdrop: $e');
      return null;
    }
  }
}
