import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/iap_service.dart';
import '../screens/settings/subscription_screen.dart';

/// A utility class for enforcing paywall gates across the app.
class PaywallGuard {
  /// Returns true if the user is subscribed (premium).
  static bool isSubscribed(BuildContext context) {
    return Provider.of<IAPService>(context, listen: false).isSubscribed;
  }

  /// Opens the Subscription screen as a modal bottom-sheet paywall prompt.
  /// Call this when a gated feature is accessed without a subscription.
  static void showPaywall(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const SubscriptionScreen()),
    );
  }

  /// Executes [action] only when user is subscribed; otherwise shows paywall.
  static void guard(BuildContext context, VoidCallback action) {
    if (isSubscribed(context)) {
      action();
    } else {
      showPaywall(context);
    }
  }
}
