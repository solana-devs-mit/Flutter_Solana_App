class MultisigAccountModel {
  final String address;
  final String name;
  final List<String> signers;
  final int threshold;
  final double balance;
  final DateTime createdAt;
  final DateTime lastUpdated;
  final bool isOwner;
  final String? description;

  MultisigAccountModel({
    required this.address,
    required this.name,
    required this.signers,
    required this.threshold,
    this.balance = 0.0,
    required this.createdAt,
    required this.lastUpdated,
    this.isOwner = false,
    this.description,
  });

  Map<String, dynamic> toJson() {
    return {
      'address': address,
      'name': name,
      'signers': signers,
      'threshold': threshold,
      'balance': balance,
      'createdAt': createdAt.toIso8601String(),
      'lastUpdated': lastUpdated.toIso8601String(),
      'isOwner': isOwner,
      'description': description,
    };
  }

  factory MultisigAccountModel.fromJson(Map<String, dynamic> json) {
    return MultisigAccountModel(
      address: json['address'],
      name: json['name'],
      signers: List<String>.from(json['signers']),
      threshold: json['threshold'],
      balance: json['balance']?.toDouble() ?? 0.0,
      createdAt: DateTime.parse(json['createdAt']),
      lastUpdated: DateTime.parse(json['lastUpdated']),
      isOwner: json['isOwner'] ?? false,
      description: json['description'],
    );
  }

  bool get isValidThreshold => threshold >= 1 && threshold <= signers.length;
  bool get hasMinimumSigners => signers.length >= 2;

  MultisigAccountModel copyWith({
    String? name,
    double? balance,
    DateTime? lastUpdated,
    String? description,
  }) {
    return MultisigAccountModel(
      address: address,
      name: name ?? this.name,
      signers: signers,
      threshold: threshold,
      balance: balance ?? this.balance,
      createdAt: createdAt,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      isOwner: isOwner,
      description: description ?? this.description,
    );
  }
}
