class AppConfig {
  // Update this with your Next.js backend URL
  static const String baseUrl =
      'https://bigboystips.com'; // Works with or without www.
  static const String apiBaseUrl = '$baseUrl/api';

  // API Endpoints
  static const String signupEndpoint = '/auth/signup';
  static const String signinEndpoint = '/auth/signin';
  static const String signoutEndpoint = '/auth/signout';
  static const String verifyEmailEndpoint = '/auth/verify-email';
  static const String resetPasswordEndpoint = '/auth/reset-password';
  static const String resendVerificationEndpoint = '/auth/resend-verification';
  static const String authCheckEndpoint = '/auth/check';
  static const String paymentVerifyEndpoint = '/payment/verify';

  // Generic CRUD Endpoints (following Next.js pattern)
  // Note: Endpoint uses singular 'prediction' to match Prisma model name
  static const String predictionsEndpoint = '/prediction';
  static const String subscriptionsEndpoint = '/subscription';
  static const String paymentsEndpoint = '/payment';
  static const String pricingEndpoint = '/pricing';
  static const String blogsEndpoint = '/blogPost';
  static const String notificationsEndpoint = '/notification';

  // Storage Keys
  static const String authTokenKey = 'auth_token';
  static const String userDataKey = 'user_data';
  static const String themeModeKey = 'theme_mode';
  static const String pendingPaymentsKey = 'pending_payments';

  // App Settings
  static const String appName = 'Bet Of The Day';
  static const int paymentRetryLimit = 5;
  static const int paymentPollInterval = 60000; // 60 seconds

  // Colors from actual Next.js app usage (orange-based design)
  // Primary: Orange shades (orange-400/500/600/700)
  static const int primary50 = 0xFFFFF7ED;
  static const int primary100 = 0xFFFFEDD5;
  static const int primary200 = 0xFFFED7AA;
  static const int primary300 = 0xFFFDBA74;
  static const int primary400 = 0xFFFB923C; // orange-400
  static const int primary500 = 0xFFF97316; // orange-500 (main primary)
  static const int primary600 = 0xFFEA580C; // orange-600 (main CTA buttons)
  static const int primary700 = 0xFFC2410C; // orange-700
  static const int primary800 = 0xFF9A3412;
  static const int primary900 = 0xFF7C2D12;

  // Secondary: Gray/Neutral shades (for backgrounds and text)
  static const int neutral50 = 0xFFFAFAFA;
  static const int neutral100 = 0xFFF5F5F5;
  static const int neutral200 = 0xFFE5E5E5;
  static const int neutral300 = 0xFFD4D4D4;
  static const int neutral400 = 0xFFA3A3A3;
  static const int neutral500 = 0xFF737373;
  static const int neutral600 = 0xFF525252;
  static const int neutral700 = 0xFF404040;
  static const int neutral800 = 0xFF262626; // Dark backgrounds
  static const int neutral900 = 0xFF171717; // Darkest (navbar bg)

  // Success: Green shades (for WON predictions)
  static const int success50 = 0xFFF0FDF4;
  static const int success100 = 0xFFDCFCE7;
  static const int success200 = 0xFFBBF7D0;
  static const int success500 = 0xFF22C55E;
  static const int success800 = 0xFF166534; // green-800

  // Error: Red shades (for LOST predictions)
  static const int error50 = 0xFFFEF2F2;
  static const int error100 = 0xFFFEE2E2;
  static const int error200 = 0xFFFECACA;
  static const int error500 = 0xFFEF4444;
  static const int error800 = 0xFF991B1B; // red-800

  // Warning: Yellow shades (for PENDING predictions)
  static const int warning50 = 0xFFFEFCE8;
  static const int warning100 = 0xFFFEF9C3;
  static const int warning200 = 0xFFFEF08A;
  static const int warning500 = 0xFFEAB308;
  static const int warning800 = 0xFF854D0E; // yellow-800

  // Gradient Colors for Modern UI (matching betting app design)
  static const int gradientBlue1 = 0xFF60A5FA; // Light blue
  static const int gradientBlue2 = 0xFF3B82F6; // Medium blue
  static const int gradientPurple1 = 0xFFA78BFA; // Light purple
  static const int gradientPurple2 = 0xFF7C3AED; // Medium purple
  static const int gradientBlueDark = 0xFF1E40AF; // Dark blue
  static const int gradientPurpleDark = 0xFF6D28D9; // Dark purple

  // Legacy color values (for backward compatibility)
  static const int primaryColorValue = primary600; // Use orange-600 as main
  static const int secondaryColorValue = neutral800; // Use neutral as secondary
  static const int accentColorValue = primary500;
}
