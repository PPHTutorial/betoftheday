enum PaymentStatus {
  pending('PENDING'),
  success('SUCCESS'),
  failed('FAILED');

  const PaymentStatus(this.value);
  final String value;

  static PaymentStatus fromString(String value) {
    return PaymentStatus.values.firstWhere(
      (e) => e.value == value,
      orElse: () => PaymentStatus.pending,
    );
  }
}

class PaymentModel {
  final String id;
  final String userId;
  final double amount;
  final String currency;
  final String provider;
  final PaymentStatus status;
  final String reference;
  final DateTime createdAt;
  final DateTime updatedAt;

  PaymentModel({
    required this.id,
    required this.userId,
    required this.amount,
    required this.currency,
    required this.provider,
    required this.status,
    required this.reference,
    required this.createdAt,
    required this.updatedAt,
  });

  factory PaymentModel.fromJson(Map<String, dynamic> json) {
    return PaymentModel(
      id: json['id'] as String,
      userId: json['userId'] as String,
      amount: (json['amount'] as num).toDouble(),
      currency: json['currency'] as String,
      provider: json['provider'] as String? ?? 'Flutterwave',
      status: PaymentStatus.fromString(json['status'] as String),
      reference: json['reference'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'amount': amount,
      'currency': currency,
      'provider': provider,
      'status': status.value,
      'reference': reference,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}

