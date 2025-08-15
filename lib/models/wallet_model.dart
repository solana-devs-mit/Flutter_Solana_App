class WalletModel {
  final String publicKey;
  final String name;
  final double balance;
  final DateTime createdAt;
  final DateTime lastUpdated;
  final bool isImported;
  final String? derivationPath;

  WalletModel({
    required this.publicKey,
    required this.name,
    this.balance = 0.0,
    required this.createdAt,
    required this.lastUpdated,
    this.isImported = false,
    this.derivationPath,
  });

  Map<String, dynamic> toJson() {
    return {
      'publicKey': publicKey,
      'name': name,
      'balance': balance,
      'createdAt': createdAt.toIso8601String(),
      'lastUpdated': lastUpdated.toIso8601String(),
      'isImported': isImported,
      'derivationPath': derivationPath,
    };
  }

  factory WalletModel.fromJson(Map<String, dynamic> json) {
    return WalletModel(
      publicKey: json['publicKey'],
      name: json['name'],
      balance: json['balance']?.toDouble() ?? 0.0,
      createdAt: DateTime.parse(json['createdAt']),
      lastUpdated: DateTime.parse(json['lastUpdated']),
      isImported: json['isImported'] ?? false,
      derivationPath: json['derivationPath'],
    );
  }

  WalletModel copyWith({
    String? publicKey,
    String? name,
    double? balance,
    DateTime? lastUpdated,
  }) {
    return WalletModel(
      publicKey: publicKey ?? this.publicKey,
      name: name ?? this.name,
      balance: balance ?? this.balance,
      createdAt: createdAt,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      isImported: isImported,
      derivationPath: derivationPath,
    );
  }
}
