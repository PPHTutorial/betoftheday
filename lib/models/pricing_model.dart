import 'subscription_model.dart';

class PricingPlanModel {
  final String id;
  final String name;
  final int price;
  final String currency;
  final SubscriptionPlan plan;
  final bool isPopular;
  final List<String> features;

  PricingPlanModel({
    required this.id,
    required this.name,
    required this.price,
    required this.currency,
    required this.plan,
    required this.isPopular,
    required this.features,
  });

  factory PricingPlanModel.fromJson(Map<String, dynamic> json) {
    return PricingPlanModel(
      id: json['id'] as String,
      name: json['name'] as String,
      price: json['price'] as int,
      currency: json['currency'] as String? ?? 'GHS',
      plan: SubscriptionPlan.fromString(json['plan'] as String),
      isPopular: json['isPopular'] as bool? ?? false,
      features: List<String>.from(json['features'] as List? ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'price': price,
      'currency': currency,
      'plan': plan.value,
      'isPopular': isPopular,
      'features': features,
    };
  }
}

