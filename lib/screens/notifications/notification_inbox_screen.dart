import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import '../../models/notification_model.dart';
import '../../services/storage_service.dart';
import '../../utils/responsive.dart';
import '../../providers/predictions_provider.dart';
import '../../widgets/match_analysis_view.dart';

class NotificationInboxScreen extends StatefulWidget {
  const NotificationInboxScreen({super.key});

  @override
  State<NotificationInboxScreen> createState() =>
      _NotificationInboxScreenState();
}

class _NotificationInboxScreenState extends State<NotificationInboxScreen>
    with SingleTickerProviderStateMixin {
  List<AppNotification> _notifications = [];
  bool _isLoading = true;
  int _selectedTabIndex = 0;

  static const _tabs = ['All', 'Live', 'Favorites', 'Bookmarks'];
  static const _tabFilters = ['all', 'live', 'favorite', 'bookmark'];

  static const List<IconData> _tabIcons = [
    FontAwesomeIcons.solidBell,
    FontAwesomeIcons.bolt,
    FontAwesomeIcons.solidStar,
    FontAwesomeIcons.solidBookmark,
  ];

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    setState(() => _isLoading = true);
    final list = await StorageService().getNotificationHistory();
    if (mounted) {
      setState(() {
        _notifications = list;
        _isLoading = false;
      });
    }
  }

  List<AppNotification> _filteredNotifications(String filter) {
    if (filter == 'all') return _notifications;
    return _notifications.where((n) => n.type.contains(filter)).toList();
  }

  int get _unreadCount => _notifications.where((n) => !n.isRead).length;

  Future<void> _markAllRead() async {
    final updated =
        _notifications.map((n) => n.copyWith(isRead: true)).toList();
    await StorageService().saveNotificationHistory(updated);
    setState(() => _notifications = updated);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('All notifications marked as read'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  Future<void> _toggleRead(AppNotification notification) async {
    final idx = _notifications.indexWhere((n) => n.id == notification.id);
    if (idx == -1) return;
    final updated = notification.copyWith(isRead: !notification.isRead);
    _notifications[idx] = updated;
    await StorageService().saveNotificationHistory(_notifications);
    setState(() {});
  }

  Future<void> _markAsRead(AppNotification notification) async {
    if (notification.isRead) return;
    final idx = _notifications.indexWhere((n) => n.id == notification.id);
    if (idx == -1) return;
    final updated = notification.copyWith(isRead: true);
    _notifications[idx] = updated;
    await StorageService().saveNotificationHistory(_notifications);
    setState(() {});
  }

  Future<void> _deleteNotification(String id) async {
    _notifications.removeWhere((n) => n.id == id);
    await StorageService().saveNotificationHistory(_notifications);
    setState(() {});
  }

  Future<void> _deleteAll() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Clear All Notifications',
            style: TextStyle(fontWeight: FontWeight.w900)),
        content:
            const Text('This will permanently delete all saved notifications.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red, foregroundColor: Colors.white),
            child: const Text('Delete All'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await StorageService().clearNotificationHistory();
      setState(() => _notifications = []);
    }
  }

  void _showNotificationDetailModal(AppNotification notif) {
    _markAsRead(notif);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final accent = theme.colorScheme.primary;

    // Clean any residual emojis or AI bullets from text
    final cleanBody = notif.body
        .replaceAll(RegExp(r'[⚽📊🎲🎯💰🏟️👉🏆🔔🚨]'), '')
        .trim();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF0F172A) : Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.35),
                blurRadius: 25,
                offset: const Offset(0, -5),
              ),
            ],
          ),
          padding: EdgeInsets.only(
            top: Responsive.spacing(12),
            left: Responsive.spacing(20),
            right: Responsive.spacing(20),
            bottom: MediaQuery.of(ctx).padding.bottom + Responsive.spacing(20),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Modal drag handle
              Center(
                child: Container(
                  width: 44,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 18),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),

              // Header: Icon + Category + Time + Close
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: accent.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Center(
                      child: FaIcon(
                        _typeIcon(notif.type),
                        size: 18,
                        color: accent,
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          notif.type.toUpperCase(),
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1.2,
                            color: accent,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          _formatTimestamp(notif.timestamp),
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: theme.colorScheme.onSurface
                                .withValues(alpha: 0.5),
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.close_rounded,
                        color: theme.colorScheme.onSurface
                            .withValues(alpha: 0.6)),
                    onPressed: () => Navigator.pop(ctx),
                  ),
                ],
              ),

              const SizedBox(height: 18),

              // Title
              Text(
                notif.title,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w900,
                  fontSize: 17,
                  height: 1.3,
                ),
              ),

              const SizedBox(height: 12),

              // Body content
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDark
                      ? const Color(0xFF1E293B)
                      : const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  cleanBody.isNotEmpty ? cleanBody : notif.title,
                  style: TextStyle(
                    fontSize: 14,
                    height: 1.55,
                    color: theme.colorScheme.onSurface
                        .withValues(alpha: 0.85),
                  ),
                ),
              ),

              // Match Intelligence Stats (if match data present)
              if (_hasMatchDetails(notif)) ...[
                const SizedBox(height: 14),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: isDark
                        ? const Color(0xFF162032)
                        : const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    children: [
                      if (notif.homeTeam != null && notif.awayTeam != null) ...[
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                '${notif.homeTeam} vs ${notif.awayTeam}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w800,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                            if (notif.score != null)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: accent,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  notif.score!,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w900,
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 10),
                      ],
                      Wrap(
                        spacing: 10,
                        runSpacing: 8,
                        children: [
                          if (notif.league != null)
                            _buildInfoChip(
                              icon: FontAwesomeIcons.trophy,
                              label: notif.league!,
                              accent: accent,
                              isDark: isDark,
                            ),
                          if (notif.xg != null)
                            _buildInfoChip(
                              icon: FontAwesomeIcons.chartLine,
                              label: 'xG: ${notif.xg!}',
                              accent: accent,
                              isDark: isDark,
                            ),
                          if (notif.prediction != null)
                            _buildInfoChip(
                              icon: FontAwesomeIcons.bullseye,
                              label: 'Pick: ${notif.prediction!}',
                              accent: accent,
                              isDark: isDark,
                            ),
                          if (notif.odds != null)
                            _buildInfoChip(
                              icon: FontAwesomeIcons.coins,
                              label: 'Odds: ${notif.odds!}',
                              accent: accent,
                              isDark: isDark,
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: 22),

              // Management Action Buttons
              Row(
                children: [
                  // Mark as Unread
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        _toggleRead(notif);
                        Navigator.pop(ctx);
                      },
                      icon: FaIcon(
                        notif.isRead
                            ? FontAwesomeIcons.envelope
                            : FontAwesomeIcons.envelopeOpen,
                        size: 15,
                        color: theme.colorScheme.onSurface,
                      ),
                      label: Text(
                        notif.isRead ? 'Mark Unread' : 'Mark Read',
                        style: TextStyle(
                          color: theme.colorScheme.onSurface,
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        side: BorderSide(
                          color: theme.colorScheme.onSurface
                              .withValues(alpha: 0.18),
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),

                  // Copy message
                  IconButton.filledTonal(
                    onPressed: () {
                      Clipboard.setData(ClipboardData(
                          text: '${notif.title}\n\n$cleanBody'));
                      Navigator.pop(ctx);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Copied notification text to clipboard'),
                          duration: Duration(seconds: 2),
                        ),
                      );
                    },
                    icon: const FaIcon(FontAwesomeIcons.copy, size: 16),
                    style: IconButton.styleFrom(
                      padding: const EdgeInsets.all(14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),

                  // Delete
                  IconButton.filled(
                    onPressed: () {
                      _deleteNotification(notif.id);
                      Navigator.pop(ctx);
                    },
                    icon: const FaIcon(FontAwesomeIcons.trashCan,
                        size: 16, color: Colors.white),
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.red.shade600,
                      padding: const EdgeInsets.all(14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),
                ],
              ),

              // Match detail direct navigate button if match exists
              if (notif.matchId != null) ...[
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(ctx);
                      _navigateToMatch(notif.matchId!);
                    },
                    icon: const FaIcon(FontAwesomeIcons.chartPie,
                        size: 15, color: Colors.white),
                    label: const Text(
                      'View Match Analytics',
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: accent,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  void _navigateToMatch(String matchId) {
    final provider = Provider.of<PredictionsProvider>(context, listen: false);
    final match = provider.matches.where((m) => m.id == matchId).firstOrNull ??
        provider.liveMatches.where((m) => m.id == matchId).firstOrNull;
    if (match != null) {
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (ctx) => Container(
          height: MediaQuery.of(ctx).size.height * 0.85,
          decoration: const BoxDecoration(
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: MatchAnalysisView(prediction: match),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    Responsive.init(context);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final accent = theme.colorScheme.primary;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'NOTIFICATIONS',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w900,
                letterSpacing: 2,
                fontSize: Responsive.fontSize(16),
              ),
            ),
            if (_unreadCount > 0) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: accent,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '$_unreadCount',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ],
        ),
        centerTitle: true,
        actions: [
          PopupMenuButton<String>(
            icon: Icon(Icons.more_vert_rounded,
                color: theme.colorScheme.onSurface),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16)),
            onSelected: (val) {
              if (val == 'read') _markAllRead();
              if (val == 'delete') _deleteAll();
            },
            itemBuilder: (_) => [
              const PopupMenuItem(
                value: 'read',
                child: Row(
                  children: [
                    FaIcon(FontAwesomeIcons.checkDouble, size: 16),
                    SizedBox(width: 12),
                    Text('Mark all as read'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    FaIcon(FontAwesomeIcons.trashCan,
                        size: 16, color: Colors.red.shade500),
                    const SizedBox(width: 12),
                    Text('Delete all',
                        style: TextStyle(color: Colors.red.shade500)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          // Redesigned modern segmented pill menu
          _buildSegmentedTabMenu(theme, isDark, accent),

          // Notification List
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : Builder(
                    builder: (context) {
                      final currentFilter = _tabFilters[_selectedTabIndex];
                      final filtered = _filteredNotifications(currentFilter);

                      if (filtered.isEmpty) {
                        return _buildEmptyState(
                            theme, isDark, currentFilter, accent);
                      }

                      return RefreshIndicator(
                        onRefresh: _loadNotifications,
                        child: ListView.builder(
                          padding: EdgeInsets.symmetric(
                            horizontal: Responsive.spacing(16),
                            vertical: Responsive.spacing(12),
                          ),
                          itemCount: filtered.length,
                          itemBuilder: (context, index) {
                            final notif = filtered[index];
                            return _buildNotificationCard(
                                theme, isDark, accent, notif);
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

  // Redesigned modern horizontal segmented pill menu
  Widget _buildSegmentedTabMenu(ThemeData theme, bool isDark, Color accent) {
    return Container(
      height: 56,
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        itemCount: _tabs.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final isSelected = _selectedTabIndex == index;
          final tabFilter = _tabFilters[index];
          final count = _filteredNotifications(tabFilter).length;
          final unreadTabCount = _filteredNotifications(tabFilter)
              .where((n) => !n.isRead)
              .length;

          return GestureDetector(
            onTap: () => setState(() => _selectedTabIndex = index),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected
                    ? accent
                    : (isDark
                        ? const Color(0xFF1E293B)
                        : const Color(0xFFE2E8F0)),
                borderRadius: BorderRadius.circular(16),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: accent.withValues(alpha: 0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        )
                      ]
                    : null,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  FaIcon(
                    _tabIcons[index],
                    size: 13,
                    color: isSelected
                        ? Colors.white
                        : theme.colorScheme.onSurface
                            .withValues(alpha: 0.65),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _tabs[index],
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: isSelected
                          ? FontWeight.w900
                          : FontWeight.w700,
                      color: isSelected
                          ? Colors.white
                          : theme.colorScheme.onSurface
                              .withValues(alpha: 0.8),
                    ),
                  ),
                  if (count > 0) ...[
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 1),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? Colors.white.withValues(alpha: 0.25)
                            : (unreadTabCount > 0
                                ? accent.withValues(alpha: 0.15)
                                : theme.colorScheme.onSurface
                                    .withValues(alpha: 0.1)),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '$count',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w900,
                          color: isSelected
                              ? Colors.white
                              : (unreadTabCount > 0
                                  ? accent
                                  : theme.colorScheme.onSurface
                                      .withValues(alpha: 0.6)),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // Upgraded Card with solid deep container (no border, no AI emojis)
  Widget _buildNotificationCard(ThemeData theme, bool isDark, Color accent,
      AppNotification notif) {
    final typeIcon = _typeIcon(notif.type);
    final timeStr = _formatTimestamp(notif.timestamp);

    // Deep rich solid surface color (NO pale translucent opacity, NO border)
    final cardBg = isDark
        ? (notif.isRead
            ? const Color(0xFF162032)
            : const Color(0xFF1E293B))
        : (notif.isRead
            ? const Color(0xFFF8FAFC)
            : Colors.white);

    // Clean body text (strip any legacy emojis)
    final cleanBody = notif.body
        .replaceAll(RegExp(r'[⚽📊🎲🎯💰🏟️👉🏆🔔🚨]'), '')
        .trim();

    return Dismissible(
      key: Key(notif.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        margin: EdgeInsets.symmetric(vertical: Responsive.spacing(5)),
        padding: EdgeInsets.only(right: Responsive.spacing(24)),
        decoration: BoxDecoration(
          color: Colors.red.shade600,
          borderRadius: BorderRadius.circular(Responsive.radius(18)),
        ),
        child: const FaIcon(FontAwesomeIcons.trashCan,
            color: Colors.white, size: 20),
      ),
      onDismissed: (_) => _deleteNotification(notif.id),
      child: GestureDetector(
        onTap: () => _showNotificationDetailModal(notif),
        child: Container(
          margin: EdgeInsets.symmetric(vertical: Responsive.spacing(5)),
          decoration: BoxDecoration(
            color: cardBg,
            borderRadius: BorderRadius.circular(Responsive.radius(18)),
            boxShadow: [
              BoxShadow(
                color: isDark
                    ? Colors.black.withValues(alpha: notif.isRead ? 0.2 : 0.4)
                    : Colors.black.withValues(alpha: notif.isRead ? 0.03 : 0.07),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(Responsive.radius(18)),
            child: IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Left accent indicator for unread notifications
                  Container(
                    width: 4.5,
                    color: notif.isRead ? Colors.transparent : accent,
                  ),

                  // Main card body
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.all(Responsive.spacing(16)),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Header: Real FA Icon + Title + Timestamp
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: 34,
                                height: 34,
                                decoration: BoxDecoration(
                                  color: accent.withValues(alpha: 0.14),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Center(
                                  child: FaIcon(
                                    typeIcon,
                                    size: 15,
                                    color: accent,
                                  ),
                                ),
                              ),
                              SizedBox(width: Responsive.spacing(12)),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      notif.title,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: theme.textTheme.titleSmall
                                          ?.copyWith(
                                        fontWeight: notif.isRead
                                            ? FontWeight.w700
                                            : FontWeight.w900,
                                        fontSize: Responsive.fontSize(14),
                                        height: 1.25,
                                      ),
                                    ),
                                    SizedBox(height: Responsive.spacing(3)),
                                    Text(
                                      timeStr,
                                      style: theme.textTheme.labelSmall
                                          ?.copyWith(
                                        color: theme.colorScheme.onSurface
                                            .withValues(alpha: 0.45),
                                        fontSize: Responsive.fontSize(11),
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              // Quick action indicator icon
                              Icon(
                                Icons.chevron_right_rounded,
                                size: 18,
                                color: theme.colorScheme.onSurface
                                    .withValues(alpha: 0.3),
                              ),
                            ],
                          ),

                          // Clean body text
                          if (cleanBody.isNotEmpty) ...[
                            SizedBox(height: Responsive.spacing(10)),
                            Text(
                              cleanBody,
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurface
                                    .withValues(alpha: 0.72),
                                fontSize: Responsive.fontSize(12.5),
                                height: 1.45,
                              ),
                            ),
                          ],

                          // Match intelligence pills using real FA icons
                          if (_hasMatchDetails(notif)) ...[
                            SizedBox(height: Responsive.spacing(12)),
                            Wrap(
                              spacing: 8,
                              runSpacing: 6,
                              children: [
                                if (notif.score != null)
                                  _buildCardPill(
                                    icon: FontAwesomeIcons.futbol,
                                    label: notif.score!,
                                    accent: accent,
                                    isDark: isDark,
                                  ),
                                if (notif.xg != null)
                                  _buildCardPill(
                                    icon: FontAwesomeIcons.chartLine,
                                    label: 'xG ${notif.xg!}',
                                    accent: accent,
                                    isDark: isDark,
                                  ),
                                if (notif.prediction != null)
                                  _buildCardPill(
                                    icon: FontAwesomeIcons.bullseye,
                                    label: notif.prediction!,
                                    accent: accent,
                                    isDark: isDark,
                                  ),
                                if (notif.odds != null)
                                  _buildCardPill(
                                    icon: FontAwesomeIcons.coins,
                                    label: notif.odds!,
                                    accent: accent,
                                    isDark: isDark,
                                  ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCardPill({
    required IconData icon,
    required String label,
    required Color accent,
    required bool isDark,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isDark
            ? const Color(0xFF0F172A)
            : const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          FaIcon(icon, size: 10, color: accent),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 11,
              color: isDark
                  ? Colors.white.withValues(alpha: 0.9)
                  : const Color(0xFF334155),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoChip({
    required IconData icon,
    required String label,
    required Color accent,
    required bool isDark,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: isDark
            ? const Color(0xFF1E293B)
            : const Color(0xFFE2E8F0),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          FaIcon(icon, size: 11, color: accent),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: isDark ? Colors.white : const Color(0xFF1E293B),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(
      ThemeData theme, bool isDark, String filter, Color accent) {
    final icon = switch (filter) {
      'live' => FontAwesomeIcons.bolt,
      'favorite' => FontAwesomeIcons.solidStar,
      'bookmark' => FontAwesomeIcons.solidBookmark,
      _ => FontAwesomeIcons.bellSlash,
    };
    final msg = switch (filter) {
      'live' => 'No live match alerts',
      'favorite' => 'No favorite team alerts',
      'bookmark' => 'No bookmarked match alerts',
      _ => 'No notifications yet',
    };
    final sub = switch (filter) {
      'live' =>
        'Live match alerts will appear here when your tracked fixtures begin.',
      'favorite' =>
        'Add clubs to your favorites in Settings to receive team matchday alerts.',
      'bookmark' =>
        'Bookmark matches to receive kickoff, live score, and full-time alerts.',
      _ =>
        'Match analysis alerts, recommendations, and broadcast notifications will appear here.',
    };

    return Center(
      child: Padding(
        padding: EdgeInsets.all(Responsive.spacing(36)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 76,
              height: 76,
              decoration: BoxDecoration(
                color: accent.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: FaIcon(
                  icon,
                  size: 32,
                  color: accent.withValues(alpha: 0.7),
                ),
              ),
            ),
            SizedBox(height: Responsive.spacing(20)),
            Text(
              msg,
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w800,
                fontSize: 16,
              ),
            ),
            SizedBox(height: Responsive.spacing(8)),
            Text(
              sub,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.45),
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  bool _hasMatchDetails(AppNotification n) =>
      n.league != null ||
      n.score != null ||
      n.xg != null ||
      n.prediction != null ||
      n.odds != null ||
      (n.homeTeam != null && n.awayTeam != null);

  IconData _typeIcon(String type) {
    return switch (type) {
      'live' => FontAwesomeIcons.bolt,
      'kickoff' => FontAwesomeIcons.clock,
      'finished' => FontAwesomeIcons.futbol,
      'bookmark' => FontAwesomeIcons.solidBookmark,
      'favorite' => FontAwesomeIcons.solidStar,
      'server' => FontAwesomeIcons.solidBell,
      _ => FontAwesomeIcons.solidBell,
    };
  }

  String _formatTimestamp(DateTime ts) {
    final now = DateTime.now();
    final diff = now.difference(ts);

    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays == 1) return 'Yesterday';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return DateFormat('MMM d, y').format(ts);
  }
}
