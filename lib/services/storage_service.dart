import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/wallet_model.dart';
import '../models/multisig_account_model.dart';
import '../models/transaction_model.dart';

class StorageService {
  static const FlutterSecureStorage _secureStorage = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility.first_unlock_this_device,
    ),
  );

  static late Box _walletBox;
  static late Box _multisigBox;
  static late Box _transactionBox;
  static late Box _settingsBox;

  static Future<void> initialize() async {
    // Open boxes
    _walletBox = await Hive.openBox('wallets');
    _multisigBox = await Hive.openBox('multisig_accounts');
    _transactionBox = await Hive.openBox('transactions');
    _settingsBox = await Hive.openBox('settings');
  }

  // Secure Storage Methods
  static Future<void> storeSecureData(String key, String value) async {
    await _secureStorage.write(key: key, value: value);
  }

  static Future<String?> getSecureData(String key) async {
    return await _secureStorage.read(key: key);
  }

  static Future<void> deleteSecureData(String key) async {
    await _secureStorage.delete(key: key);
  }

  // Wallet Storage Methods
  static Future<void> saveWallet(WalletModel wallet) async {
    await _walletBox.put(wallet.publicKey, wallet.toJson());
  }

  static WalletModel? getWallet(String publicKey) {
    final data = _walletBox.get(publicKey);
    return data != null
        ? WalletModel.fromJson(Map<String, dynamic>.from(data))
        : null;
  }

  static List<WalletModel> getAllWallets() {
    return _walletBox.values
        .map((data) => WalletModel.fromJson(Map<String, dynamic>.from(data)))
        .toList();
  }

  static Future<void> deleteWallet(String publicKey) async {
    await _walletBox.delete(publicKey);
    await deleteSecureData('private_key_$publicKey');
  }

  // Multisig Account Storage Methods
  static Future<void> saveMultisigAccount(MultisigAccountModel account) async {
    await _multisigBox.put(account.address, account.toJson());
  }

  static MultisigAccountModel? getMultisigAccount(String address) {
    final data = _multisigBox.get(address);
    return data != null
        ? MultisigAccountModel.fromJson(Map<String, dynamic>.from(data))
        : null;
  }

  static List<MultisigAccountModel> getAllMultisigAccounts() {
    return _multisigBox.values
        .map(
          (data) =>
              MultisigAccountModel.fromJson(Map<String, dynamic>.from(data)),
        )
        .toList();
  }

  static Future<void> deleteMultisigAccount(String address) async {
    await _multisigBox.delete(address);
  }

  // Transaction Storage Methods
  static Future<void> saveTransaction(TransactionModel transaction) async {
    await _transactionBox.put(transaction.id, transaction.toJson());
  }

  static TransactionModel? getTransaction(String id) {
    final data = _transactionBox.get(id);
    return data != null
        ? TransactionModel.fromJson(Map<String, dynamic>.from(data))
        : null;
  }

  static List<TransactionModel> getAllTransactions() {
    return _transactionBox.values
        .map(
          (data) => TransactionModel.fromJson(Map<String, dynamic>.from(data)),
        )
        .toList();
  }

  static List<TransactionModel> getTransactionsByMultisig(
    String multisigAddress,
  ) {
    return getAllTransactions()
        .where((tx) => tx.multisigAddress == multisigAddress)
        .toList();
  }

  static List<TransactionModel> getPendingTransactions() {
    return getAllTransactions()
        .where((tx) => tx.isPending && !tx.isExpired)
        .toList();
  }

  // Private Key Management
  static Future<void> storePrivateKey(
    String publicKey,
    String privateKey,
  ) async {
    await storeSecureData('private_key_$publicKey', privateKey);
  }

  static Future<String?> getPrivateKey(String publicKey) async {
    return await getSecureData('private_key_$publicKey');
  }

  // Mnemonic Management
  static Future<void> storeMnemonic(String mnemonic) async {
    await storeSecureData('mnemonic', mnemonic);
  }

  static Future<String?> getMnemonic() async {
    return await getSecureData('mnemonic');
  }
}
