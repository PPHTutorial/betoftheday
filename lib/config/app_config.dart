class AppConfig {
  // Data Source base URL
  static const String baseUrl = 'https://www.predicd.com';

  // Paths
  static const String footballPath = '/en/football/';
  static const String matchSchedulePath = '/en/football/match-schedule/';
  static const String leaguePath = '/en/football/league/';

  // App Settings
  static const String appName = 'Bet Of The Day';
  static const String appId = 'btd';

  // Backend / Codeink Technologies Blueprint endpoints
  static const String campaignBaseUrl =
      'https://codeinktechnologies.com/api/promo/campaign';
  static const String campaignSlug = 'btd';
  static const String promoClaimUrl =
      'https://codeinktechnologies.com/api/promo/claim';
  static const String parentBackendBaseUrl =
      'https://serviceworker-two.vercel.app/api/promo';
  static const String fcmTopic = 'btd_all';

  // Legal & Support Links
  static const String privacyPolicyUrl =
      'https://serviceworker-two.vercel.app/privacies/btd/';
  static const String termsOfServiceUrl =
      'https://serviceworker-two.vercel.app/privacies/btd/tos/';
  static const String eulaUrl =
      'https://serviceworker-two.vercel.app/privacies/btd/eula/';
  static const String supportEmail = 'support@codeinktechnologies.com';

  // Free Unlock Configuration
  static const int maxDailyFreeUnlocks = 2;

  // Premium Pricing & RevenueCat Configuration
  // Credentials for RevenueCat Google Play project
  static const String revenueCatAndroidApiKey =
      'goog_sICAGTnFEbSxlMHkguMqPfFVUYG';
  static const String revenueCatIosApiKey = '';
  static const String revenueCatEntitlementId = 'btd_pro';
  static const String revenueCatOfferingId = 'default';

  // Package & Product identifiers
  static const String premiumMonthlyId = 'btd_monthly';
  static const String premiumYearlyId = 'btd_yearly';
  static const String premiumLifetimeId = 'btd_lifetime';

  static const String monthlyPrice = '\$9.99/month';
  static const String yearlyPrice = '\$59.99/year';
  static const String lifetimePrice = '\$99.99 lifetime';
  static const String premiumBenefit =
      'Unlock all expert picks, xG stats, probability models & ad-free access.';

  // Popular league IDs for quick access
  static const Map<String, String> popularLeagues = {
    '4328': 'Premier League',
    '4331': 'Bundesliga', // Normalized from 1. Bundesliga
    '4332': 'Serie A',
    '4334': 'Ligue 1',
    '4335': 'LaLiga', // Normalized from Primera División
    '4480': 'Champions League',
    '4481': 'Europa League',
    '5071': 'Europa Conference League',
    '4329': 'Championship', // Normalized from EFL Championship
    '4351': 'Brasileirão', // Normalized from Série A
  };

  // Mapping from Scraper names to Canonical names
  static const Map<String, String> leagueNameMapping = {
    'Primera División': 'LaLiga',
    '1. Bundesliga': 'Bundesliga',
    'Série A': 'Brasileirão',
    'EFL Championship': 'Championship',
    'Ligue 1 Uber Eats': 'Ligue 1',
    'Premier League (2023/24)': 'Premier League',
    'Seria A': 'Serie A',
    'Dutch Eredivisie': 'Eredivisie',
  };

  // Colors from actual app design (orange-based)
  // Primary: Orange shades
  static const int primary50 = 0xFFFFF7ED;
  static const int primary100 = 0xFFFFEDD5;
  static const int primary200 = 0xFFFED7AA;
  static const int primary300 = 0xFFFDBA74;
  static const int primary400 = 0xFFFB923C;
  static const int primary500 = 0xFFF97316;
  static const int primary600 = 0xFFEA580C;
  static const int primary700 = 0xFFC2410C;
  static const int primary800 = 0xFF9A3412;
  static const int primary900 = 0xFF7C2D12;

  // Secondary: Gray/Neutral shades
  static const int neutral50 = 0xFFFAFAFA;
  static const int neutral100 = 0xFFF5F5F5;
  static const int neutral200 = 0xFFE5E5E5;
  static const int neutral300 = 0xFFD4D4D4;
  static const int neutral400 = 0xFFA3A3A3;
  static const int neutral500 = 0xFF737373;
  static const int neutral600 = 0xFF525252;
  static const int neutral700 = 0xFF404040;
  static const int neutral800 = 0xFF262626;
  static const int neutral900 = 0xFF171717;

  // Success: Green shades
  static const int success50 = 0xFFF0FDF4;
  static const int success100 = 0xFFDCFCE7;
  static const int success200 = 0xFFBBF7D0;
  static const int success500 = 0xFF22C55E;
  static const int success800 = 0xFF166534;

  // Error: Red shades
  static const int error50 = 0xFFFEF2F2;
  static const int error100 = 0xFFFEE2E2;
  static const int error200 = 0xFFFECACA;
  static const int error500 = 0xFFEF4444;
  static const int error800 = 0xFF991B1B;

  // Warning: Yellow shades
  static const int warning50 = 0xFFFEFCE8;
  static const int warning100 = 0xFFFEF9C3;
  static const int warning200 = 0xFFFEF08A;
  static const int warning500 = 0xFFEAB308;
  static const int warning800 = 0xFF854D0E;

  // Gradient Colors
  static const int gradientBlue1 = 0xFF60A5FA;
  static const int gradientBlue2 = 0xFF3B82F6;
  static const int gradientPurple1 = 0xFFA78BFA;
  static const int gradientPurple2 = 0xFF7C3AED;
  static const int gradientBlueDark = 0xFF1E40AF;
  static const int gradientPurpleDark = 0xFF6D28D9;

  // Legacy color values (backward compat)
  static const int primaryColorValue = primary600;
  static const int secondaryColorValue = neutral800;
  static const int accentColorValue = primary500;
}
