/// A single link returned by the Codeink campaign backend —
/// functional link (support, terms, privacy) or community/social channel (discord, telegram, etc.)
class CampaignLink {
  const CampaignLink({
    required this.kind,
    required this.label,
    required this.url,
  });

  final String kind;
  final String label;
  final String url;

  factory CampaignLink.fromJson(Map<String, dynamic> json) => CampaignLink(
        kind: (json['kind'] as String?)?.toLowerCase() ?? 'generic',
        label: (json['label'] as String?) ?? '',
        url: (json['url'] as String?) ?? '',
      );

  Map<String, dynamic> toJson() => {
        'kind': kind,
        'label': label,
        'url': url,
      };
}

/// The Codeink campaign response (Section 14.1 of Blueprint) —
/// community links, offers gating, promo-window state.
class Campaign {
  const Campaign({
    required this.id,
    required this.active,
    this.links = const [],
  });

  final String id;
  final bool active;
  final List<CampaignLink> links;

  /// Returns all community, social, and custom links with non-empty URLs
  List<CampaignLink> get communityLinks => links
      .where((l) =>
          l.url.trim().isNotEmpty &&
          l.kind != 'support' &&
          l.kind != 'terms' &&
          l.kind != 'privacy')
      .toList();

  CampaignLink? link(String kind) {
    for (final l in links) {
      if (l.kind.toLowerCase() == kind.toLowerCase()) return l;
    }
    return null;
  }

  /// Whether code claiming window is available
  bool get canClaimCodes => active && id.isNotEmpty;

  factory Campaign.fromJson(Map<String, dynamic> json) {
    final rawLinks = <Map<String, dynamic>>[];
    if (json['links'] is List) {
      rawLinks.addAll(
          (json['links'] as List).whereType<Map<String, dynamic>>());
    }
    if (json['communityLinks'] is List) {
      rawLinks.addAll(
          (json['communityLinks'] as List).whereType<Map<String, dynamic>>());
    }
    if (json['customLinks'] is List) {
      rawLinks.addAll(
          (json['customLinks'] as List).whereType<Map<String, dynamic>>());
    }

    return Campaign(
      id: json['id'] as String? ?? json['slug'] as String? ?? '',
      active: json['active'] as bool? ?? true,
      links: rawLinks.map(CampaignLink.fromJson).toList(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'active': active,
        'links': links.map((l) => l.toJson()).toList(),
      };
}
