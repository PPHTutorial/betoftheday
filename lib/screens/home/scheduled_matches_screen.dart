import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/predictions_provider.dart';
import '../../widgets/match_card.dart';

class ScheduledMatchesScreen extends StatefulWidget {
  const ScheduledMatchesScreen({super.key});

  @override
  State<ScheduledMatchesScreen> createState() => _ScheduledMatchesScreenState();
}

class _ScheduledMatchesScreenState extends State<ScheduledMatchesScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadMatches();
    });
  }

  void _loadMatches() {
    Provider.of<PredictionsProvider>(context, listen: false).loadMatches();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Schedule'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () =>
                Provider.of<PredictionsProvider>(context, listen: false)
                    .refreshMatches(),
          ),
        ],
      ),
      body: Column(
        children: [
          // Day Selector
          const _DaySelector(),

          // Match List
          Expanded(
            child: Consumer<PredictionsProvider>(
              builder: (context, provider, child) {
                if (provider.isLoading && provider.matches.isEmpty) {
                  return const Center(child: CircularProgressIndicator());
                }

                final upcoming = provider.upcomingMatches;

                if (upcoming.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.calendar_month,
                            size: 64, color: theme.colorScheme.outline),
                        const SizedBox(height: 16),
                        const Text('No matches scheduled for this day'),
                      ],
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: provider.refreshMatches,
                  child: ListView.builder(
                    padding: const EdgeInsets.only(bottom: 16),
                    itemCount: upcoming.length,
                    itemBuilder: (context, index) {
                      final match = upcoming[index];
                      return MatchCard(
                        prediction: match,
                        showDate: true,
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _DaySelector extends StatelessWidget {
  const _DaySelector();

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<PredictionsProvider>(context);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      height: 100,
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: 14, // Show 2 weeks
        itemBuilder: (context, index) {
          final date = DateTime.now().add(Duration(days: index));
          final isSelected = provider.selectedDayOffset == index;

          final dayName = DateFormat('EEE').format(date).toUpperCase();
          final dayNum = DateFormat('d').format(date);

          return Padding(
            padding: const EdgeInsets.only(right: 12),
            child: InkWell(
              onTap: () => provider.setDayOffset(index),
              borderRadius: BorderRadius.circular(20),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 60,
                decoration: BoxDecoration(
                  color: isSelected
                      ? theme.colorScheme.primary
                      : theme.colorScheme.surfaceContainerHighest
                          .withValues(alpha: isDark ? 0.4 : 0.3),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: theme.colorScheme.primary
                                .withValues(alpha: 0.2),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          )
                        ]
                      : null,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      dayName,
                      style: TextStyle(
                        color: isSelected
                            ? Colors.white.withValues(alpha: 0.8)
                            : theme.colorScheme.onSurface
                                .withValues(alpha: 0.5),
                        fontWeight: FontWeight.w900,
                        fontSize: 10,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      dayNum,
                      style: TextStyle(
                        color: isSelected
                            ? Colors.white
                            : theme.colorScheme.onSurface,
                        fontWeight: FontWeight.w900,
                        fontSize: 20,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
