enum TransactionStatus {
  pending,
  partiallyApproved,
  approved,
  executed,
  rejected,
  expired,
}

enum TransactionType {
  transfer,
  multisigCreate,
  multisigApprove,
  multisigExecute,
  other,
}

class TransactionModel {
  final String id;
  final String multisigAddress;
  final String? recipient;
  final double? amount;
  final String? memo;
  final List<String> approvedBy;
  final List<String> rejectedBy;
  final int requiredApprovals;
  final DateTime createdAt;
  final DateTime? executedAt;
  final DateTime? expiresAt;
  final String status;
  final String type;
  final String? transactionHash;
  final String? rawTransaction;
  final String createdBy;

  TransactionModel({
    required this.id,
    required this.multisigAddress,
    this.recipient,
    this.amount,
    this.memo,
    required this.approvedBy,
    required this.rejectedBy,
    required this.requiredApprovals,
    required this.createdAt,
    this.executedAt,
    this.expiresAt,
    required this.status,
    required this.type,
    this.transactionHash,
    this.rawTransaction,
    required this.createdBy,
  });

  TransactionStatus get transactionStatus {
    switch (status) {
      case 'pending':
        return TransactionStatus.pending;
      case 'partiallyApproved':
        return TransactionStatus.partiallyApproved;
      case 'approved':
        return TransactionStatus.approved;
      case 'executed':
        return TransactionStatus.executed;
      case 'rejected':
        return TransactionStatus.rejected;
      case 'expired':
        return TransactionStatus.expired;
      default:
        return TransactionStatus.pending;
    }
  }

  TransactionType get transactionType {
    switch (type) {
      case 'transfer':
        return TransactionType.transfer;
      case 'multisigCreate':
        return TransactionType.multisigCreate;
      case 'multisigApprove':
        return TransactionType.multisigApprove;
      case 'multisigExecute':
        return TransactionType.multisigExecute;
      default:
        return TransactionType.other;
    }
  }

  bool get isExpired => expiresAt != null && DateTime.now().isAfter(expiresAt!);
  bool get canBeExecuted =>
      approvedBy.length >= requiredApprovals && !isExpired;
  bool get isPending =>
      transactionStatus == TransactionStatus.pending ||
      transactionStatus == TransactionStatus.partiallyApproved;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'multisigAddress': multisigAddress,
      'recipient': recipient,
      'amount': amount,
      'memo': memo,
      'approvedBy': approvedBy,
      'rejectedBy': rejectedBy,
      'requiredApprovals': requiredApprovals,
      'createdAt': createdAt.toIso8601String(),
      'executedAt': executedAt?.toIso8601String(),
      'expiresAt': expiresAt?.toIso8601String(),
      'status': status,
      'type': type,
      'transactionHash': transactionHash,
      'rawTransaction': rawTransaction,
      'createdBy': createdBy,
    };
  }

  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    return TransactionModel(
      id: json['id'],
      multisigAddress: json['multisigAddress'],
      recipient: json['recipient'],
      amount: json['amount']?.toDouble(),
      memo: json['memo'],
      approvedBy: List<String>.from(json['approvedBy'] ?? []),
      rejectedBy: List<String>.from(json['rejectedBy'] ?? []),
      requiredApprovals: json['requiredApprovals'],
      createdAt: DateTime.parse(json['createdAt']),
      executedAt: json['executedAt'] != null
          ? DateTime.parse(json['executedAt'])
          : null,
      expiresAt: json['expiresAt'] != null
          ? DateTime.parse(json['expiresAt'])
          : null,
      status: json['status'],
      type: json['type'],
      transactionHash: json['transactionHash'],
      rawTransaction: json['rawTransaction'],
      createdBy: json['createdBy'],
    );
  }
}
