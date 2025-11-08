import 'prediction_model.dart';
import 'subscription_model.dart';
import 'payment_model.dart';

/// Pricing model for sample data
class PricingModel {
  final String id;
  final String currency;
  final String name;
  final int price;
  final String plan;
  final bool isPopular;
  final List<String> features;
  final DateTime createdAt;
  final DateTime updatedAt;

  PricingModel({
    required this.id,
    required this.currency,
    required this.name,
    required this.price,
    required this.plan,
    required this.isPopular,
    required this.features,
    required this.createdAt,
    required this.updatedAt,
  });

  factory PricingModel.fromJson(Map<String, dynamic> json) {
    return PricingModel(
      id: json['id'] as String,
      currency: json['currency'] as String,
      name: json['name'] as String,
      price: json['price'] as int,
      plan: json['plan'] as String,
      isPopular: json['isPopular'] as bool? ?? false,
      features: List<String>.from(json['features'] as List? ?? []),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'currency': currency,
      'name': name,
      'price': price,
      'plan': plan,
      'isPopular': isPopular,
      'features': features,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}

/// Model for the complete sample.json data structure
class SampleDataModel {
  final List<PredictionModel> predictions;
  final List<PricingModel> pricing;
  final List<PaymentModel> payments;
  final List<SubscriptionModel> subscriptions;
  final List<TitleModel> titles;
  final List<BettingCodeModel> betslip;
  final CurrencyRateModel? currencyRate;
  final bool isSubscriptionActive;

  SampleDataModel({
    required this.predictions,
    required this.pricing,
    required this.payments,
    required this.subscriptions,
    required this.titles,
    required this.betslip,
    this.currencyRate,
    required this.isSubscriptionActive,
  });

  factory SampleDataModel.fromJson(Map<String, dynamic> json) {
    return SampleDataModel(
      predictions: (json['predictions'] as List<dynamic>?)
              ?.map((p) => PredictionModel.fromJson(p as Map<String, dynamic>))
              .toList() ??
          [],
      pricing: (json['pricing'] as List<dynamic>?)
              ?.map((p) => PricingModel.fromJson(p as Map<String, dynamic>))
              .toList() ??
          [],
      payments: (json['payments'] as List<dynamic>?)
              ?.map((p) => PaymentModel.fromJson(p as Map<String, dynamic>))
              .toList() ??
          [],
      subscriptions: (json['subscriptions'] as List<dynamic>?)
              ?.map(
                  (s) => SubscriptionModel.fromJson(s as Map<String, dynamic>))
              .toList() ??
          [],
      titles: (json['titles'] as List<dynamic>?)
              ?.map((t) => TitleModel.fromJson(t as Map<String, dynamic>))
              .toList() ??
          [],
      betslip: (json['betslip'] as List<dynamic>?)
              ?.map((b) => BettingCodeModel.fromJson(b as Map<String, dynamic>))
              .toList() ??
          [],
      currencyRate: json['currencyrate'] != null
          ? CurrencyRateModel.fromJson(
              json['currencyrate'] as Map<String, dynamic>)
          : null,
      isSubscriptionActive: json['isSubscriptionActive'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'predictions': predictions.map((p) => p.toJson()).toList(),
      'pricing': pricing.map((p) => p.toJson()).toList(),
      'payments': payments.map((p) => p.toJson()).toList(),
      'subscriptions': subscriptions.map((s) => s.toJson()).toList(),
      'titles': titles.map((t) => t.toJson()).toList(),
      'betslip': betslip.map((b) => b.toJson()).toList(),
      'currencyrate': currencyRate?.toJson(),
      'isSubscriptionActive': isSubscriptionActive,
    };
  }
}

/// Title model for prediction sections
class TitleModel {
  final String id;
  final String defaultTitle;
  final String customTitle;

  TitleModel({
    required this.id,
    required this.defaultTitle,
    required this.customTitle,
  });

  factory TitleModel.fromJson(Map<String, dynamic> json) {
    return TitleModel(
      id: json['id'] as String,
      defaultTitle: json['defaulttitle'] as String,
      customTitle: json['customtitle'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'defaulttitle': defaultTitle,
      'customtitle': customTitle,
    };
  }
}

/// Betting Code model
class BettingCodeModel {
  final String id;
  final String bettingPlatform;
  final String bettingCode;
  final DateTime createdAt;
  final DateTime updatedAt;

  BettingCodeModel({
    required this.id,
    required this.bettingPlatform,
    required this.bettingCode,
    required this.createdAt,
    required this.updatedAt,
  });

  factory BettingCodeModel.fromJson(Map<String, dynamic> json) {
    return BettingCodeModel(
      id: json['id'] as String,
      bettingPlatform: json['bettingPlatform'] as String,
      bettingCode: json['bettingCode'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'bettingPlatform': bettingPlatform,
      'bettingCode': bettingCode,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}

/// Currency Rate model
class CurrencyRateModel {
  final String baseCurrency;
  final String quoteCurrency;
  final DateTime closeTime;
  final double averageBid;
  final double averageAsk;
  final double highBid;
  final double highAsk;
  final double lowBid;
  final double lowAsk;

  CurrencyRateModel({
    required this.baseCurrency,
    required this.quoteCurrency,
    required this.closeTime,
    required this.averageBid,
    required this.averageAsk,
    required this.highBid,
    required this.highAsk,
    required this.lowBid,
    required this.lowAsk,
  });

  factory CurrencyRateModel.fromJson(Map<String, dynamic> json) {
    return CurrencyRateModel(
      baseCurrency: json['base_currency'] as String,
      quoteCurrency: json['quote_currency'] as String,
      closeTime: DateTime.parse(json['close_time'] as String),
      averageBid: (json['average_bid'] as num).toDouble(),
      averageAsk: (json['average_ask'] as num).toDouble(),
      highBid: (json['high_bid'] as num).toDouble(),
      highAsk: (json['high_ask'] as num).toDouble(),
      lowBid: (json['low_bid'] as num).toDouble(),
      lowAsk: (json['low_ask'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'base_currency': baseCurrency,
      'quote_currency': quoteCurrency,
      'close_time': closeTime.toIso8601String(),
      'average_bid': averageBid,
      'average_ask': averageAsk,
      'high_bid': highBid,
      'high_ask': highAsk,
      'low_bid': lowBid,
      'low_ask': lowAsk,
    };
  }
}
