import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/predictions_provider.dart';
import '../home/widgets/vip_predictions_section.dart';

class VipScreen extends StatelessWidget {
  const VipScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final authProvider = Provider.of<AuthProvider>(context);
    final predictionsProvider = Provider.of<PredictionsProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('VIP Predictions'),
      ),
      body: authProvider.isVip
          ? _buildVipContent(context, theme, predictionsProvider)
          : _buildUpgradePrompt(context, theme),
    );
  }

  Widget _buildVipContent(
      BuildContext context, ThemeData theme, PredictionsProvider provider) {
    return RefreshIndicator(
      onRefresh: () => provider.refreshPredictions(),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          children: [
            if (provider.isLoading)
              const Padding(
                padding: EdgeInsets.all(24),
                child: CircularProgressIndicator(),
              )
            else if (provider.getVipGames().isEmpty)
              Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  'No VIP predictions available at the moment.',
                  style: theme.textTheme.bodyLarge,
                  textAlign: TextAlign.center,
                ),
              )
            else
              VipPredictionsSection(
                title: 'VIP Predictions',
                predictions: provider.getVipGames(),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildUpgradePrompt(BuildContext context, ThemeData theme) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.star_outline,
              size: 80,
              color: theme.colorScheme.secondary,
            ),
            const SizedBox(height: 24),
            Text(
              'Upgrade to VIP',
              style: theme.textTheme.headlineMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              'Get access to exclusive VIP predictions and expert analysis.',
              style: theme.textTheme.bodyLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () {
                // TODO: Navigate to pricing/subscription screen
              },
              child: const Text('View Plans'),
            ),
          ],
        ),
      ),
    );
  }
}

