enum SubscriptionPlan {
  daily('DAILY'),
  weekly('WEEKLY'),
  monthly('MONTHLY'),
  yearly('YEARLY');

  const SubscriptionPlan(this.value);
  final String value;

  static SubscriptionPlan fromString(String value) {
    return SubscriptionPlan.values.firstWhere(
      (e) => e.value == value,
      orElse: () => SubscriptionPlan.daily,
    );
  }

  String get displayName {
    switch (this) {
      case SubscriptionPlan.daily:
        return 'Daily';
      case SubscriptionPlan.weekly:
        return 'Weekly';
      case SubscriptionPlan.monthly:
        return 'Monthly';
      case SubscriptionPlan.yearly:
        return 'Yearly';
    }
  }
}

enum SubscriptionStatus {
  active('ACTIVE'),
  expired('EXPIRED'),
  cancelled('CANCELLED');

  const SubscriptionStatus(this.value);
  final String value;

  static SubscriptionStatus fromString(String value) {
    return SubscriptionStatus.values.firstWhere(
      (e) => e.value == value,
      orElse: () => SubscriptionStatus.expired,
    );
  }
}

class SubscriptionModel {
  final String id;
  final String userId;
  final SubscriptionPlan plan;
  final SubscriptionStatus status;
  final DateTime startedAt;
  final DateTime expiresAt;
  final String? flutterwavePaymentId;
  final DateTime createdAt;
  final DateTime updatedAt;

  SubscriptionModel({
    required this.id,
    required this.userId,
    required this.plan,
    required this.status,
    required this.startedAt,
    required this.expiresAt,
    this.flutterwavePaymentId,
    required this.createdAt,
    required this.updatedAt,
  });

  factory SubscriptionModel.fromJson(Map<String, dynamic> json) {
    return SubscriptionModel(
      id: json['id'] as String,
      userId: json['userId'] as String,
      plan: SubscriptionPlan.fromString(json['plan'] as String),
      status: SubscriptionStatus.fromString(json['status'] as String),
      startedAt: DateTime.parse(json['startedAt'] as String),
      expiresAt: DateTime.parse(json['expiresAt'] as String),
      flutterwavePaymentId: json['flutterwavePaymentId'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'plan': plan.value,
      'status': status.value,
      'startedAt': startedAt.toIso8601String(),
      'expiresAt': expiresAt.toIso8601String(),
      'flutterwavePaymentId': flutterwavePaymentId,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  bool get isActive {
    return status == SubscriptionStatus.active && 
           DateTime.now().isBefore(expiresAt);
  }

  Duration get timeRemaining {
    if (!isActive) return const Duration();
    return expiresAt.difference(DateTime.now());
  }
}

