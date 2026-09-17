# Codeink Technologies — Universal Fullstack App Build Blueprint

> Covers: **Flutter mobile apps** + **Next.js web (landing pages, legal, support)** + **Server Side Backend business logics**
> Single source of truth for every Codeink project — mobile app + companion landing page.

---

## HOW TO USE THIS BLUEPRINT

This file is a **universal scaffold template**. It contains no project-specific data.
All `{{PLACEHOLDER}}` tokens remain empty until an agent is explicitly told to tag a copy.

### Workflow

```
UNIVERSAL TEMPLATE (this file)
  │
  │  Step 1: Copy this file into the new project's root directory.
  │           e.g.  E:\Projects\Flutter\MyNewApp\CODEINK_APP_BLUEPRINT.md
  │
  ▼
PROJECT COPY (lives inside the project folder)
  │
  │  Step 2: Agent reads the project description / mindmap from the developer.
  │           Agent fills Section 0 (Project Concept) from that description.
  │
  │  Step 3: Agent fills Section 1 (App Identity) from the values in Section 0.
  │
  │  Step 4: Agent generates all project files, using Section 1 tokens throughout.
  │
  ▼
WORKING PROJECT (fully wired, all placeholders resolved)
```

### Rules

- **Never edit this universal template** with project-specific data.
- **Never fill placeholders in this file** — only in a project copy.
- A project copy is "tagged" when Section 0 and Section 1 are fully populated.
- Until tagged, the agent treats every `{{PLACEHOLDER}}` as unresolved and stops to ask.
- The universal template lives at its own path; every project copy lives inside that project.

---

## SECTION 0 — Project Concept (Agent: fill this section first from the project description)

> **Agent instruction:** When you receive a project description, mindmap, or idea from the developer,
> populate every `{{PLACEHOLDER}}` in this section before touching Section 1 or writing any code.
> Everything downstream — Section 1 tokens, feature cards on the landing page, paywall copy,
> onboarding showcases, FAQ answers — is derived from what you write here.

### 0.1 Project Summary

```yaml
PROJECT_NAME:        "{{PROJECT_NAME}}"
ONE_LINER:           "{{ONE_LINER}}"        # ≤ 15 words. What the app does.
PROBLEM_STATEMENT:   "{{PROBLEM_STATEMENT}}" # The pain point it solves, 1–2 sentences.
SOLUTION_STATEMENT:  "{{SOLUTION_STATEMENT}}" # How the app solves it, 1–2 sentences.
APP_CATEGORY:        "{{APP_CATEGORY}}"     # e.g. Productivity / Utility / Entertainment
TARGET_PLATFORM:     "{{TARGET_PLATFORM}}"  # Android | iOS | Both
```

### 0.2 Target Users

```yaml
PRIMARY_USER:        "{{PRIMARY_USER}}"     # The core persona. e.g. "Students who need to digitize handwritten notes"
SECONDARY_USERS:
  - "{{SECONDARY_USER_1}}"
  - "{{SECONDARY_USER_2}}"
USE_CASES:
  - "{{USE_CASE_1}}"
  - "{{USE_CASE_2}}"
  - "{{USE_CASE_3}}"
```

### 0.3 Feature Inventory — Mobile App

List every feature the app will have. This table drives:
- Onboarding feature showcase pages
- Paywall feature checklist
- Landing page feature grid
- Settings screen structure

```yaml
FEATURES:
  - id: "{{FEATURE_ID_1}}"           # snake_case identifier
    title: "{{FEATURE_TITLE_1}}"     # Short display name
    desc: "{{FEATURE_DESC_1}}"       # 1–2 sentences for marketing copy
    tier: "{{free|pro}}"             # free = available to all, pro = behind paywall
    icon: "{{LUCIDE_ICON_NAME_1}}"   # lucide-react icon name used on web
    fa_icon: "{{FA_ICON_NAME_1}}"    # font_awesome_flutter icon used on mobile

  - id: "{{FEATURE_ID_2}}"
    title: "{{FEATURE_TITLE_2}}"
    desc: "{{FEATURE_DESC_2}}"
    tier: "{{free|pro}}"
    icon: "{{LUCIDE_ICON_NAME_2}}"
    fa_icon: "{{FA_ICON_NAME_2}}"

  # … add a row per feature
```

### 0.4 App Screens — Mobile

List every screen in the app, in navigation order. Drives router config and agent generation order.

```yaml
SCREENS:
  - route: "/splash"
    name: "SplashPage"
    purpose: "Init services, check onboarding state"
    tier: "all"

  - route: "/onboarding"
    name: "OnboardingPage"
    purpose: "{{ONBOARDING_PURPOSE}}"
    tier: "all"
    pages:
      - "{{ONBOARDING_PAGE_1}}"   # e.g. "Welcome — logo + tagline"
      - "{{ONBOARDING_PAGE_2}}"
      - "{{ONBOARDING_PAGE_3}}"

  - route: "/"
    name: "HomePage"
    purpose: "{{HOME_PURPOSE}}"
    tier: "all"

  - route: "/settings"
    name: "SettingsPage"
    purpose: "Account, preferences, legal links, support"
    tier: "all"

  - route: "/offers"
    name: "OffersPage"
    purpose: "Coupon redemption + where-to-get-codes links"
    tier: "all"

  - route: "/pro-upgrade"
    name: "ProUpgradePage"
    purpose: "RevenueCat paywall + watch-ads unlock"
    tier: "all"

  # Add app-specific screens below:
  - route: "{{CUSTOM_ROUTE_1}}"
    name: "{{CUSTOM_SCREEN_NAME_1}}"
    purpose: "{{CUSTOM_SCREEN_PURPOSE_1}}"
    tier: "{{free|pro}}"
```

### 0.5 Web Pages — Next.js Landing

List every page the landing site needs. Drives Section 21 (Web Agent Instructions).

```yaml
WEB_PAGES:
  # Standard pages (always present — do not remove):
  - path: "/{{APP_ID}}/"           route: "Landing / Hero" #12 - 20 pages
  - path: "/{{APP_ID}}/about/"     route: "About"
  - path: "/{{APP_ID}}/features/"  route: "Features"
  - path: "/{{APP_ID}}/contact/"   route: "Contact"
  - path: "/{{APP_ID}}/support/"   route: "Support / FAQ"
  - path: "/{{APP_ID}}/offers/"   route: "Offers"
  - path: "/{{APP_ID}}/download/"  route: "Download"

  # Legal pages (always present — URLs must match AppConstants exactly):
  # This must be very indepth based on the project details (Not less than 500 words each)
  - path: "/{{APP_ID}}/legal/privacy"  route: "Privacy Policy"
  - path: "/{{APP_ID}}/legal/tos"      route: "Terms of Service"
  - path: "/{{APP_ID}}/legal/eula"     route: "EULA"
  - path: "/{{APP_ID}}/legal/cookies"  route: "Cookie Policy"
  - path: "/{{APP_ID}}/legal/refund"   route: "Refund Policy"

  # App-specific extra pages (optional):
  # - path: "/{{APP_ID}}/{{EXTRA_PAGE_SLUG}}/" route: "{{EXTRA_PAGE_PURPOSE}}"
```

### 0.6 Monetisation Model

```yaml
MONETISATION:
  has_ads: "{{true|false}}"
  has_iap: "{{true|false}}"
  free_tier_limits:
    - "{{FREE_LIMIT_1}}"   # e.g. "Up to 5 documents"
    - "{{FREE_LIMIT_2}}"
  pro_benefits:
    - "{{PRO_BENEFIT_1}}"  # e.g. "Unlimited documents"
    - "{{PRO_BENEFIT_2}}"
    - "{{PRO_BENEFIT_3}}"
  iap_products:
    - monthly
    - yearly
    - lifetime
    # Remove any that don't apply; add three_month / six_month if needed
  watch_ads_unlock:
    enabled: "{{true|false}}"
    ad_count: "{{AD_COUNT}}"  # Number of ads to watch for 12h Pro
```

### 0.7 Design Mindmap

> **User-defined section.** The developer fills this — the agent does NOT choose design styles.
> Color and style decisions belong to the person who owns the product.

```yaml
DESIGN:
  # ── Colors (user picks all four; agent writes them as TS constants in page.tsx) ──
  ACCENT:       "{{HEX_COLOR}}"      # e.g. "#2979FF" — primary brand color (matches Flutter app_colors.dart)
  ACCENT_DARK:  "{{HEX_DARK}}"       # e.g. "#2962FF" — pressed/hover state
  ACCENT_LIGHT: "{{HEX_LIGHT}}"      # e.g. "#82B1FF" — icon tints, check marks, muted text highlights
  ACCENT_BG:    "{{HEX_BG}}"         # e.g. "#0D1F3C" — dark tinted section backgrounds, pricing card bg
  BG:           "{{HEX_PAGE_BG}}"    # e.g. "#08090D" — overall page background (near-black)
  accent_rationale: "{{WHY_THIS_COLOR}}"  # e.g. "Deep blue = tech, precision, trust"

  # ── Secondary style (user picks ONE — agent applies only to surfaces listed below) ──
  # Options: glassmorphism | claymorphism | minimalism | glass+clay | glass+minimal
  secondary_style: "{{SECONDARY_STYLE}}"

  # ── Surfaces where secondary style appears (user specifies; agent applies only here) ──
  mobile_accent_surfaces:
    - "{{MOBILE_SURFACE_1}}"   # e.g. "Paywall hero card — glassmorphism"
    - "{{MOBILE_SURFACE_2}}"   # e.g. "Watch-ads CTA button — claymorphism"
  web_accent_surfaces:
    - "{{WEB_SURFACE_1}}"      # e.g. "Navbar on scroll — glassmorphism"
    - "{{WEB_SURFACE_2}}"      # e.g. "Final download CTA section background"

  logo_style: "{{LOGO_STYLE}}"   # e.g. "Icon + wordmark, geometric"
  app_mood:   "{{APP_MOOD}}"     # e.g. "Productive, focused, professional"
```

**Secondary style quick reference** (agent applies to listed surfaces only):

| Choice | Mobile | Web |
|---|---|---|
| `glassmorphism` | `BackdropFilter blur(20)` + `white 5% fill` + `white 10% border` | `backdrop-blur-xl bg-white/5 border border-white/10` |
| `claymorphism` | Inner shadow light top-left + dark bottom-right + border-radius 24+ | `shadow-[inset_-4px_-4px_12px_rgba(255,255,255,0.12),inset_4px_4px_12px_rgba(0,0,0,0.15)] rounded-3xl` |
| `minimalism` | No secondary accents — pure flat only | No secondary accents — pure flat fills only |

Primary Flat Design 2.0 is **always-on** on every surface regardless of secondary choice.
Flat surface recipe: web → `rgba(255,255,255,0.04–0.08)` · mobile → `Color(0xFF1A1A1A)`.
Navbar always gets `backdrop-blur` glassmorphism regardless of secondary style choice.

### 0.8 Web Asset Manifest

> **User-defined section.** Developer lists every image asset by its intended filename and dimensions.
> Agent uses these exact names in placeholder comments and `ImgPlaceholder` labels.
> Developer drops real files into `public/{{APP_ID}}/` when ready — agent never invents filenames.

```yaml
WEB_ASSETS:
  base_path: "public/{{APP_ID}}/"

  images:
    - file: "{{FILENAME_1}}"          # e.g. "logo.svg"
      type: "{{svg|png|jpg|webp}}"
      usage: "{{USAGE_1}}"            # e.g. "Navbar logo + og:image"
      dimensions: "{{WxH|vector}}"   # e.g. "200×40" or "vector"

    - file: "{{FILENAME_2}}"          # e.g. "hero-phone.png"
      type: "{{png|jpg|webp}}"
      usage: "{{USAGE_2}}"            # e.g. "Hero section — phone mockup"
      dimensions: "{{WxH}}"          # e.g. "260×540"

    # Add one entry per asset the developer will provide
```

**Agent placeholder rule** — for each listed asset, render this pattern:
```tsx
{/* IMAGE PLACEHOLDER: {{USAGE}} — /{{APP_ID}}/{{FILENAME}} ({{DIMENSIONS}}) */}
<ImgPlaceholder label="[ {{USAGE}} — {{FILENAME}} ]" aspect="{{TAILWIND_ASPECT}}" />
{/* Uncomment when asset is ready:
<Image src="/{{APP_ID}}/{{FILENAME}}" width={W} height={H} alt="{{USAGE}}" className="..." />
*/}
```

### 0.9 Data Sources & External APIs

```yaml
DATA_SOURCES:
  - name: "{{DATA_SOURCE_NAME_1}}"
    type: "{{rest|graphql|local|firebase}}"
    base_url: "{{DATA_SOURCE_URL_1}}"
    auth: "{{api_key|oauth|none}}"
    notes: "{{DATA_SOURCE_NOTES_1}}"

  # Parent backend (always present — do not remove):
  - name: "Codeink Parent Backend"
    type: "rest"
    base_url: "https://serviceworker-two.vercel.app/api/promo"
    auth: "none"
    notes: "Coupon redemption, device ID, campaign offers"

  # Campaign API (always present — do not remove):
  - name: "Codeink Campaign API"
    type: "rest"
    base_url: "https://codeinktechnologies.com/api/promo/campaign"
    auth: "none"
    notes: "Community links, custom links, campaign metadata"
```

### 0.9 Agent Tag Confirmation

When all fields above are populated, the agent writes this block to confirm the blueprint is tagged:

```yaml
BLUEPRINT_STATUS:
  tagged:        true
  project:       "{{PROJECT_NAME}}"
  tagged_by:     "{{AGENT_MODEL}}"        # e.g. "claude-sonnet-4-6"
  tagged_date:   "{{ISO_DATE}}"           # e.g. "2026-06-24"
  project_path:  "{{PROJECT_ROOT_PATH}}"  # Absolute path to the project root
```

---

## SECTION 1 — App Identity Questionnaire

Fill every field before writing any code. Replace each `{{…}}` with the real value.

```yaml
# ── Core Identity ───────────────────────────────────────────────────────
APP_NAME:           "{{APP_NAME}}"           # Display name, e.g. "MyApp"
APP_ID:             "{{APP_ID}}"             # Lowercase slug, e.g. "myapp"
BUNDLE_ID:          "{{BUNDLE_ID}}"          # e.g. "com.company.myapp"
APP_TAGLINE:        "{{APP_TAGLINE}}"        # One-line value prop for hero sections

# ── Campaign ────────────────────────────────────────────────────────────
CAMPAIGN_SLUG:      "{{CAMPAIGN_SLUG}}"      # e.g. "myapp-feature-slug"
FCM_TOPIC:          "{{FCM_TOPIC}}"          # Default broadcast topic, e.g. "all"

# ── Monetisation ────────────────────────────────────────────────────────
REVENUECAT_ANDROID: "{{RC_ANDROID_KEY}}"    # goog_ prefixed — base64-encode in AppConstants
REVENUECAT_IOS:     "{{RC_IOS_KEY}}"        # appl_ prefixed — base64-encode in AppConstants
ENTITLEMENT_PRO:    "{{ENTITLEMENT_ID}}"    # RevenueCat entitlement name

# ── Links ────────────────────────────────────────────────────────────────
SUPPORT_EMAIL:      "{{SUPPORT_EMAIL}}"
PRIVACY_URL:        "https://serviceworker-two.vercel.app/privacies/{{APP_ID}}/"
TERMS_URL:          "https://serviceworker-two.vercel.app/privacies/{{APP_ID}}/tos/"
EULA_URL:           "https://serviceworker-two.vercel.app/privacies/{{APP_ID}}/eula/"
PLAY_STORE_URL:     "{{PLAY_STORE_URL}}"    # Fill after first publish
APP_STORE_URL:      "{{APP_STORE_URL}}"     # Fill after first publish

# ── App-Specific Branding ────────────────────────────────────────────────
APP_ACCENT_COLOR:   "{{HEX_COLOR}}"         # Per-app accent — chosen by developer
APP_ACCENT_DARK:    "{{HEX_DARK}}"          # Darker shade for hover/press states
LOGO_ASSET:         "{{PATH}}"              # e.g. "assets/images/logo.png"

# ── Defaults ─────────────────────────────────────────────────────────────
ONBOARDING_AD_COUNT: 3
DATA_SOURCE:        "{{DATA_SOURCE}}"       # tmdb | custom_api | local
DATA_SOURCE_URL:    "{{DATA_SOURCE_URL}}"
DATA_SOURCE_KEY:    "{{DATA_SOURCE_KEY}}"
```

---

## SECTION 2 — Flutter Project Setup

### 2.1 Flutter & Dart Versions

```
Flutter:   stable channel (latest)
Dart:      bundled with Flutter
Min SDK:   Android 21 / iOS 13
```

### 2.2 Android Release Build Configuration

All Codeink apps share the same upload keystore. Never create a per-app keystore.

**Shared keystore** (already exists — do not recreate):
```
Path:    E:\Projects\AAASigningkeys\upload-keystore.jks
Alias:   upload
Storepass / Keypass: 123456
```

**`android/key.properties`** (gitignored — create locally):
```properties
storePassword=123456
keyPassword=123456
keyAlias=upload
storeFile=E:\\Projects\\AAASigningkeys\\upload-keystore.jks
```

**`android/app/build.gradle.kts`** — standard Codeink config:
```kotlin
import java.util.Properties

val keystoreProperties = Properties().apply {
    load(rootProject.file("key.properties").inputStream())
}

android {
    namespace = "{{BUNDLE_ID}}"
    compileSdk = 36
    ndkVersion = "27.0.12077973"

    defaultConfig {
        applicationId = "{{BUNDLE_ID}}"
        minSdk = 23
        targetSdk = 36
        versionCode = 1
        versionName = "1.0.0"
    }

    signingConfigs {
        create("release") {
            keyAlias     = keystoreProperties["keyAlias"]     as String
            keyPassword  = keystoreProperties["keyPassword"]  as String
            storeFile    = file(keystoreProperties["storeFile"] as String)
            storePassword= keystoreProperties["storePassword"] as String
        }
    }

    buildTypes {
        release {
            signingConfig    = signingConfigs.getByName("release")
            isMinifyEnabled  = true
            isShrinkResources= true
            proguardFiles(getDefaultProguardFile("proguard-android-optimize.txt"), "proguard-rules.pro")
        }
    }
}
```

**`android/gradle.properties`** — Codeink JVM standard:
```properties
org.gradle.jvmargs=-Xmx8G -XX:MaxMetaspaceSize=2G
android.useAndroidX=true
android.enableJetifier=true
kotlin.code.style=official
```

**`android/build.gradle.kts`** — AGP version:
```kotlin
plugins {
    id("com.android.application") version "8.7.3" apply false
    id("org.jetbrains.kotlin.android") version "2.2.0" apply false
    id("com.google.gms.google-services") version "4.4.2" apply false
}
```

Build commands:
```bash
flutter build appbundle --release   # → build/app/outputs/bundle/release/app-release.aab
flutter build apk --release         # → build/app/outputs/apk/release/app-release.apk
```

> Note: `key.properties` is gitignored. Each developer creates it locally pointing to the shared keystore.
> Never commit `key.properties` or the `.jks` file.

### 2.2.1 Windows Cross-Drive Build Note

If your project lives on a different drive from the Flutter pub cache (e.g., project on `E:\` and pub cache on `C:\`), the Kotlin incremental compiler emits `"this and base files have different roots"` errors after a `flutter clean`. **These are non-fatal** — the APK is built and installed successfully. The errors come from the Kotlin daemon failing to persist incremental cache entries that span two drive letters; the next incremental build skips them cleanly.

When to run `flutter clean`:
- After adding, removing, or changing any package in `pubspec.yaml`
- After modifying `AndroidManifest.xml`
- After switching branches with different pubspec versions
- When `flutter run` shows "Error opening archive app-debug.apk: Invalid file"

### 2.3 Required Packages (`pubspec.yaml`)

```yaml
dependencies:
  # State management
  flutter_bloc: ^8.x

  # Navigation
  go_router: ^14.x

  # Networking
  dio: ^5.x

  # Storage
  shared_preferences: ^2.x
  hive: ^2.x
  hive_flutter: ^1.x

  # Firebase — REQUIRED for all apps (see Section 6.2)
  firebase_core: ^3.x
  firebase_messaging: ^15.x

  # Ads
  google_mobile_ads: ^5.x

  # IAP
  purchases_flutter: ^8.x          # RevenueCat

  # UI / Icons
  cached_network_image: ^3.x
  shimmer: ^3.x
  lottie: ^3.x
  font_awesome_flutter: ^10.x      # REQUIRED — real brand logos for community links

  # Localisation
  easy_localization: ^3.0.7        # REQUIRED — see Section 17
  intl: ^0.20.2

  # Utilities
  url_launcher: ^6.x
  share_plus: ^10.x
  package_info_plus: ^8.x
  app_review: ^5.x
  path_provider: ^2.x

dev_dependencies:
  build_runner: ^2.x
  hive_generator: ^2.x
  bloc_test: ^9.x

dependency_overrides:
  intl: ^0.20.2                    # Pin to resolve Syncfusion vs flutter_localizations conflict
```

### 2.4 Project Folder Structure (Feature-First)

```
lib/
├── core/
│   ├── constants/
│   │   └── app_constants.dart      ← all app-wide constants (Section 3)
│   ├── theme/
│   │   ├── app_colors.dart
│   │   ├── app_dimensions.dart
│   │   ├── app_text_styles.dart
│   │   └── app_theme.dart
│   ├── services/
│   │   ├── ads_service.dart
│   │   ├── app_actions.dart
│   │   ├── campaign_service.dart
│   │   ├── coupon_service.dart
│   │   ├── notification_service.dart  ← FCM (Section 6.2)
│   │   └── paywall_service.dart
│   └── utils/
│       └── logger.dart
├── data/
│   └── models/
│       ├── campaign_model.dart
│       └── …
└── features/
    ├── splash/
    ├── onboarding/
    ├── home/
    ├── settings/
    ├── offers/
    └── …

assets/
├── translations/
│   ├── en.json            ← ONLY file developers ever edit
│   ├── es.json            ← written by AI agent (Claude), committed
│   ├── … (22 more)
│   └── .fingerprint       ← change-detection cache
└── fonts/
    └── Inter/

tool/
└── translate.dart         ← change detector (Section 17)
```

---

## SECTION 3 — Core Constants

### `lib/core/constants/app_constants.dart`

```dart
import 'dart:convert';
import 'dart:io';

class AppConstants {
  static const String appName = '{{APP_NAME}}';
  static const String appId   = '{{APP_ID}}';

  static const String campaignBaseUrl = 'https://codeinktechnologies.com/api/promo/campaign';
  static const String campaignSlug    = '{{CAMPAIGN_SLUG}}'; // NEVER hardcode elsewhere

  static const String parentBackendBaseUrl = 'https://serviceworker-two.vercel.app/api/promo';

  static String get revenueCatApiKey {
    if (Platform.isAndroid) return _rcAndroid;
    if (Platform.isIOS)     return _rcIos;
    return '';
  }
  static String get _rcAndroid => utf8.decode(base64Decode('{{RC_ANDROID_B64}}'));
  static String get _rcIos     => utf8.decode(base64Decode('{{RC_IOS_B64}}'));
  static const String entitlementPro = '{{ENTITLEMENT_ID}}';

  static const String iapMonthly    = 'monthly';
  static const String iapYearly     = 'yearly';
  static const String iapLifetime   = 'lifetimepro';
  static const String iapThreeMonth = 'three_month';
  static const String iapSixMonth   = 'six_month';

  static const String supportEmail      = '{{SUPPORT_EMAIL}}';
  static const String privacyPolicyUrl  = 'https://serviceworker-two.vercel.app/privacies/{{APP_ID}}/';
  static const String termsOfServiceUrl = 'https://serviceworker-two.vercel.app/privacies/{{APP_ID}}/tos/';
  static const String eulaUrl           = 'https://serviceworker-two.vercel.app/privacies/{{APP_ID}}/eula/';

  static const String fcmTopic = '{{FCM_TOPIC}}';

  static const String keyOnboardingComplete = 'onboarding_complete';
  static const String keyProStatus          = 'pro_status';
  static const String keyThemeMode          = 'theme_mode';

  static const Duration requestTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 60);
  static const Duration debounceDelay  = Duration(milliseconds: 300);
}
```

---

## SECTION 4 — Flutter Theme System

All apps share the same theme contract. Only accent colour and surface shades change per app.

### 4.1 Colors (`app_colors.dart`)

```dart
import 'package:flutter/material.dart';

class AppColors {
  // ── App accent (override per app using Section 1 APP_ACCENT_COLOR) ───
  static const Color accent     = Color(0xFF{{HEX_NO_HASH}});
  static const Color accentDark = Color(0xFF{{HEX_DARK_NO_HASH}});

  // ── Dark mode surfaces ───────────────────────────────────────────────
  static const Color darkBackground = Color(0xFF0A0A0A);
  static const Color darkSurface    = Color(0xFF111111);
  static const Color darkCard       = Color(0xFF1A1A1A);
  static const Color darkBorder     = Color(0xFF2A2A2A);
  static const Color darkTextMuted  = Color(0xFF666666);

  // ── Light mode surfaces ──────────────────────────────────────────────
  static const Color surface    = Color(0xFFF5F5F5);
  static const Color white      = Color(0xFFFFFFFF);
  static const Color obsidian   = Color(0xFF1A1A1A);
  static const Color border     = Color(0xFFE0E0E0);
  static const Color textMuted  = Color(0xFF888888);

  // ── Semantic ─────────────────────────────────────────────────────────
  static const Color success = Color(0xFF22C55E);
  static const Color gold    = Color(0xFFFFD700);

  // ── Glass overlay (glassmorphism accents) ────────────────────────────
  static const Color glassLight = Color(0x0DFFFFFF); // white 5%
  static const Color glassDark  = Color(0x1A000000); // black 10%
  static const Color glassBorder = Color(0x1AFFFFFF); // white 10%
}
```

### 4.2 Text Styles (`app_text_styles.dart`)

Available styles — do not invent new ones:
`headline2`, `headline3`, `headline4`, `headline5`,
`bodyLarge`, `bodyMedium`, `caption`, `button`, `sectionTitle`

---

## SECTION 5 — Data Models

### 5.1 Campaign Model

`customLinks` (action links: support, privacy, terms, redemption) and `communityLinks`
(social platforms) are **separate arrays — never confuse them**.

```dart
import 'dart:convert';

class CampaignCustomLink {
  final String id, kind, label, url;
  const CampaignCustomLink({
    required this.id, required this.kind,
    required this.label, required this.url,
  });
  factory CampaignCustomLink.fromJson(Map<String, dynamic> j) => CampaignCustomLink(
    id: j['id'] as String? ?? '', kind: j['kind'] as String? ?? '',
    label: j['label'] as String? ?? '', url: j['url'] as String? ?? '',
  );
  Map<String, dynamic> toJson() =>
      {'id': id, 'kind': kind, 'label': label, 'url': url};
}

class Campaign {
  final String id, slug, appName, appDescription;
  final String? imageUrl, landingPageUrl, instructions;
  final bool active;
  final List<String> appLinks;
  final List<CampaignCustomLink> customLinks;    // action links
  final List<CampaignCustomLink> communityLinks; // social platforms

  const Campaign({
    required this.id, required this.slug, required this.appName,
    required this.appDescription, this.imageUrl, this.landingPageUrl,
    this.instructions, required this.active, required this.appLinks,
    required this.customLinks, required this.communityLinks,
  });

  factory Campaign.fromJson(Map<String, dynamic> j) => Campaign(
    id: j['id'] as String? ?? '', slug: j['slug'] as String? ?? '',
    appName: j['appName'] as String? ?? '',
    appDescription: j['appDescription'] as String? ?? '',
    imageUrl: j['imageUrl'] as String?,
    landingPageUrl: j['landingPageUrl'] as String?,
    instructions: j['instructions'] as String?,
    active: j['active'] as bool? ?? true,
    appLinks: (j['appLinks'] as List<dynamic>?)?.cast<String>() ?? [],
    customLinks: _parse(j['customLinks']),
    communityLinks: _parse(j['communityLinks']),
  );

  static List<CampaignCustomLink> _parse(dynamic raw) =>
      (raw as List<dynamic>?)
          ?.map((e) => CampaignCustomLink.fromJson(e as Map<String, dynamic>))
          .toList() ?? [];

  Map<String, dynamic> toJson() => {
    'id': id, 'slug': slug, 'appName': appName,
    'appDescription': appDescription, 'imageUrl': imageUrl,
    'landingPageUrl': landingPageUrl, 'instructions': instructions,
    'active': active, 'appLinks': appLinks,
    'customLinks': customLinks.map((l) => l.toJson()).toList(),
    'communityLinks': communityLinks.map((l) => l.toJson()).toList(),
  };

  CampaignCustomLink? link(String kind) =>
      customLinks.where((l) => l.kind == kind).firstOrNull;

  List<CampaignCustomLink> links(String kind) =>
      customLinks.where((l) => l.kind == kind).toList();
}
```

---

## SECTION 6 — Flutter Services

### 6.1 Campaign Service

Fetches `GET {{campaignBaseUrl}}/{{campaignSlug}}`, caches to SharedPreferences for **6 hours**.
Falls back to stale cache on network failure. Bump cache key version (`_v2` → `_v3`) whenever
Campaign model fields change.

```dart
import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:{{APP_ID}}/core/constants/app_constants.dart';
import 'package:{{APP_ID}}/data/models/campaign_model.dart';

class CampaignService {
  CampaignService._();
  static final CampaignService instance = CampaignService._();

  static const _cacheKey   = 'codeink_campaign_v2';
  static const _cacheTsKey = 'codeink_campaign_ts_v2';
  static const _ttl        = Duration(hours: 6);

  Campaign? _cached;
  Campaign? get cached => _cached;

  Future<Campaign?> fetch({bool forceRefresh = false}) async {
    if (!forceRefresh && _cached != null) return _cached;
    final prefs = await SharedPreferences.getInstance();
    if (!forceRefresh) {
      final ts = prefs.getInt(_cacheTsKey);
      if (ts != null) {
        final age = DateTime.now().difference(DateTime.fromMillisecondsSinceEpoch(ts));
        if (age < _ttl) {
          final hit = _fromPrefs(prefs);
          if (hit != null) { _cached = hit; return _cached; }
        }
      }
    }
    try {
      final res = await Dio().get<Map<String, dynamic>>(
        '${AppConstants.campaignBaseUrl}/${AppConstants.campaignSlug}',
        options: Options(sendTimeout: const Duration(seconds: 10),
                         receiveTimeout: const Duration(seconds: 10)),
      );
      if (res.statusCode == 200 && res.data != null) {
        _cached = Campaign.fromJson(res.data!);
        await prefs.setString(_cacheKey, jsonEncode(res.data));
        await prefs.setInt(_cacheTsKey, DateTime.now().millisecondsSinceEpoch);
        return _cached;
      }
    } catch (_) {}
    final stale = _fromPrefs(prefs);
    if (stale != null) { _cached = stale; return _cached; }
    return null;
  }

  Campaign? _fromPrefs(SharedPreferences prefs) {
    final raw = prefs.getString(_cacheKey);
    if (raw == null) return null;
    try { return Campaign.fromJson(jsonDecode(raw) as Map<String, dynamic>); }
    catch (_) { return null; }
  }
}
```

### 6.2 Notification Service — ⚠️ REQUIRED before first publish

```dart
// lib/core/services/notification_service.dart
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:{{APP_ID}}/core/constants/app_constants.dart';

class NotificationService {
  NotificationService._();
  static final NotificationService instance = NotificationService._();
  final _fcm = FirebaseMessaging.instance;

  Future<void> initialize() async {
    await _fcm.requestPermission(alert: true, badge: true, sound: true);
    await _fcm.subscribeToTopic(AppConstants.fcmTopic);
    if (AppConstants.fcmTopic != 'all') await _fcm.subscribeToTopic('all');
    FirebaseMessaging.onMessageOpenedApp.listen(_handleMessage);
    final initial = await _fcm.getInitialMessage();
    if (initial != null) _handleMessage(initial);
  }

  void _handleMessage(RemoteMessage message) {
    // Navigate based on message.data['route']
  }
}
```

Firebase setup checklist:
```
1. Create Firebase project: {{APP_NAME}}
2. Add Android app: {{BUNDLE_ID}} → download google-services.json → android/app/
3. Add iOS app:     {{BUNDLE_ID}} → download GoogleService-Info.plist → ios/Runner/
4. Enable Cloud Messaging.
5. NotificationService subscribes to '{{FCM_TOPIC}}' AND always 'all'.
6. Call NotificationService.instance.initialize() from main() after Firebase.initializeApp()
```

### 6.3 Ad Service

| Method | When |
|---|---|
| `showInterstitialAdThenDo(callback)` | Before opening external offer/link |
| `showRewardedAd(onRewarded)` | Single watch-ad flow |
| `showMultipleRewardedAds(count:N, onProgress:, onComplete:)` | N-ad onboarding/upgrade flow |

`showMultipleRewardedAds` increments `shown` **only on `onAdDismissedFullScreenContent`**.

### 6.4 Paywall Service

```dart
// Key API:
bool get isPro;
Future<void> grantProAccess({required String expiresAt});
Future<void> applyPromoToken(String token);
Future<void> addCredits(int amount);
Future<void> restorePurchases();

// 12h ad-unlock flow:
await PaywallService.instance.grantProAccess(
  expiresAt: DateTime.now().add(const Duration(hours: 12)).toIso8601String(),
);
```

### 6.5 Coupon Service

```dart
Future<CouponResult> redeem(String code);
// POST {parentBackendBaseUrl}/redeem  body: {code, deviceId, appId}
enum CouponError { alreadyRedeemed, invalid, expired, network }
```

### 6.6 App Actions

```dart
class AppActions {
  static Future<void> shareApp() async { /* Share.share(appLink + message) */ }
  static Future<void> rateApp()  async { /* AppReviewService().requestManualReview() */ }
  static Future<void> openSupport(Campaign? campaign) async {
    final raw = campaign?.link('support')?.url;
    if (raw != null && raw.isNotEmpty) {
      final uri = raw.contains('@') && !raw.startsWith('mailto:')
          ? Uri(scheme: 'mailto', path: raw,
                queryParameters: {'subject': '{{APP_NAME}} Support'})
          : Uri.parse(raw);
      await launchUrl(uri, mode: LaunchMode.externalApplication);
      return;
    }
    await launchUrl(Uri(scheme: 'mailto', path: AppConstants.supportEmail,
        queryParameters: {'subject': '{{APP_NAME}} Support'}));
  }
}
```

### 6.7 Parent Backend

Base URL: `https://serviceworker-two.vercel.app/api/promo`

| Endpoint | Purpose |
|---|---|
| `GET  /offers?appId={{APP_ID}}` | Offer cards for Offers screen |
| `POST /redeem` body `{code, deviceId, appId}` | Redeem coupon |
| `GET  /device-id` | Stable anonymous device identifier |

---

## SECTION 7 — Community Link Design System

Applies identically on all three mobile surfaces **and** on the web landing page.

### 7.1 Icon Rule — Non-Negotiable

**Always use `font_awesome_flutter` with the exact official brand icon.**
Never substitute generic Material icons.

```
✅ CORRECT                          ❌ WRONG
FontAwesomeIcons.discord            Icons.headset_mic_rounded
FontAwesomeIcons.telegram           Icons.send_rounded
FontAwesomeIcons.whatsapp           Icons.chat_rounded
FontAwesomeIcons.xTwitter           Icons.alternate_email_rounded
FontAwesomeIcons.youtube            Icons.play_circle_rounded
FontAwesomeIcons.facebook           Icons.thumb_up_rounded
FontAwesomeIcons.users (fallback)   Icons.group_rounded
```

### 7.2 Brand Colors & Icon Helpers

Add to every file that renders community links:

```dart
static Color _communityColor(String kind) => switch (kind) {
  'discord'  => const Color(0xFF5865F2),
  'telegram' => const Color(0xFF26A5E4),
  'whatsapp' => const Color(0xFF25D366),
  'twitter'  => Colors.white,   // #000000 is invisible on dark backgrounds; use white
  'youtube'  => const Color(0xFFFF0000),
  'facebook' => const Color(0xFF1877F2),
  _          => AppColors.accent,
};

static IconData _communityFaIcon(String kind) => switch (kind) {
  'discord'  => FontAwesomeIcons.discord,
  'telegram' => FontAwesomeIcons.telegram,
  'whatsapp' => FontAwesomeIcons.whatsapp,
  'twitter'  => FontAwesomeIcons.xTwitter,
  'youtube'  => FontAwesomeIcons.youtube,
  'facebook' => FontAwesomeIcons.facebook,
  _          => FontAwesomeIcons.users,
};
```

### 7.3 Home — Horizontal Scroll Pills

Coloured brand background, white FA icon + label. No borders.

```dart
class _CommunityPill extends StatelessWidget {
  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: () {
      HapticFeedback.selectionClick();
      launchUrl(Uri.parse(link.url), mode: LaunchMode.externalApplication);
    },
    child: Container(
      margin: const EdgeInsets.only(right: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: _communityColor(link.kind),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        FaIcon(_communityFaIcon(link.kind), size: 13, color: Colors.white),
        const SizedBox(width: 7),
        Text(link.label, style: const TextStyle(
          fontFamily: 'Inter', fontSize: 13,
          fontWeight: FontWeight.w600, color: Colors.white)),
      ]),
    ),
  );
}
```

### 7.4 Onboarding — List Rows

32×32 coloured badge + FA icon + title + chevron.

### 7.5 Settings — Tile Icon

Settings tiles must accept `Widget icon`, not `IconData`. Wrap leading in `IconTheme`:

```dart
leading: IconTheme(
  data: IconThemeData(size: 20, color: isDark ? darkTextSecondary : textSecondary),
  child: icon, // Widget — Icon(...) or FaIcon(...)
),
```

---

## SECTION 8 — Flutter Routing

```dart
final router = GoRouter(
  initialLocation: '/splash',
  routes: [
    GoRoute(path: '/splash',      builder: (_, __) => const SplashPage()),
    GoRoute(path: '/onboarding',  builder: (_, __) => const OnboardingPage()),
    GoRoute(path: '/',            builder: (_, __) => const HomePage()),
    GoRoute(path: '/settings',    builder: (_, __) => const SettingsPage()),
    GoRoute(path: '/offers',      builder: (_, __) => const OffersPage()),
    GoRoute(path: '/pro-upgrade', builder: (_, __) => const ProUpgradePage()),
    // App-specific routes below
  ],
);
```

---

## SECTION 9 — Flutter Screens

### 9.1 Splash

```
1. Logo centred on dark background.
2. Parallel init: Firebase, RevenueCat, Ads, Notifications, Campaign prefetch.
   Offline check → if offline: show snackbar 'splash_offline_warning'.
3. Read 'onboarding_complete' from SharedPreferences.
   false/null → context.go('/onboarding')
   true       → context.go('/')
4. debugPrint only — never print().
5. Guard every async with mounted check before context.go().
```

### 9.2 Onboarding

#### Standard (5-page)
```
0. Welcome       — logo, tagline, "Get Started"
1. Pro / Ads     — feature list + "Watch N Ads → 12h Pro"
2. Rate          — star graphic + AppActions.rateApp()
3. Share         — AppActions.shareApp() + community links (FA brand icons)
4. Offers        — promo code hint + "Get Started"
```

#### Extended (9-page — for feature-rich apps)
```
0. Welcome
1–5. Feature showcase (one feature per page)
6. Unlock — Watch {{ONBOARDING_AD_COUNT}} ads → redemption links + code input
7. Share
8. Rate
```

Watch-N-Ads flow:
```
State: _adsWatched, _totalAds=N, _watching, _adsComplete
Increment _adsWatched ONLY on onAdDismissedFullScreenContent.
On complete: grantProAccess(expiresAt: +12h.toIso8601String())
Auto-advance after 1.5s success state.
```

Layout rules — REQUIRED:
```dart
// Inside SingleChildScrollView: ALWAYS CrossAxisAlignment.stretch
Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [...])
// Center items explicitly: Center(child: ...), NOT column alignment.
// Buttons inside Row: explicit SizedBox(width:, height:)
SizedBox(height: 48, width: 90, child: ElevatedButton(...))
```

### 9.3 Home

App-specific content. Always append community section after main content.

**Critical: cache the Future in `initState` — never call `fetch()` inline in `build()`.**
Calling it inline recreates the Future on every rebuild, causing flicker and redundant network
calls even when the cache is warm.

```dart
// ✅ CORRECT — cache in initState
late final Future<Campaign?> _campaignFuture;

@override
void initState() {
  super.initState();
  _campaignFuture = CampaignService.instance.fetch();
}

// In build():
FutureBuilder<Campaign?>(
  future: _campaignFuture,         // ← use the cached future
  builder: (ctx, snap) {
    final links = snap.data?.communityLinks ?? [];
    if (links.isEmpty) return const SizedBox.shrink();
    return _CommunitySectionWidget(links: links);
  },
)
```

Community section layout options (choose one per app):

**A) Horizontal scroll pills** (≤3 platforms, quick scan):
```dart
SizedBox(
  height: 44,
  child: ListView.builder(
    scrollDirection: Axis.horizontal,
    itemCount: links.length,
    itemBuilder: (_, i) => _CommunityPill(link: links[i]),
  ),
)
```

**B) Vertical column tiles** (4+ platforms, better readability):
```dart
ClipRRect(
  borderRadius: BorderRadius.circular(14),
  child: Column(
    children: [
      for (int i = 0; i < links.length; i++) ...[
        _CommunityTile(link: links[i]),
        if (i < links.length - 1)
          Divider(height: 1, indent: 50, color: Colors.white.withValues(alpha: 0.05)),
      ],
    ],
  ),
)
```

### 9.4 Settings

```
ACCOUNT
  - Pro / Upgrade Pro     → /pro-upgrade
  - Redeem Coupon         → /offers
  - Silence Ads           → internet-check → showRewardedAd

GENERAL
  - Language              → locale picker dialog

OFFERS & COMMUNITY
  - [communityLinks tiles — FaIcon + brand color (Section 7.5)]
  - Terms of Service      → campaign.link('terms')?.url ?? AppConstants.termsOfServiceUrl
  - EULA                  → AppConstants.eulaUrl

SUPPORT
  - Help & Feedback       → AppActions.openSupport(campaign)
  - Privacy Policy        → campaign.link('privacy')?.url ?? AppConstants.privacyPolicyUrl
  - Share App             → AppActions.shareApp()
  - Rate App              → AppActions.rateApp()
  - About {{APP_NAME}}    → showAboutDialog(...)

Footer: version string from PackageInfo
```

### 9.5 Offers Screen

```
1. "REDEEM A CODE" — monospace input → CouponService.redeem() → coloured status banner
2. "WHERE TO GET CODES" — campaign.links('redemption') as ListTiles
   Fallback if no campaign links: hardcoded promo URL
Design: no gradients, flat. Status banner = coloured fill, no border.
```

**`_init()` pattern — fetch campaign alongside offers in the same `Future.wait`:**

```dart
Campaign? _campaign;

Future<void> _init() async {
  final results = await Future.wait([
    ParentBackendService.instance.fetchOffers(),
    ParentBackendService.instance.getDeviceId(),
    CampaignService.instance.fetch(),               // ← always include
  ]);
  if (!mounted) return;
  setState(() {
    _offers   = results[0] as List<ParentOffer>;
    _deviceId = results[1] as String;
    _campaign = results[2] as Campaign?;
    _loadingOffers = false;
  });
}
```

**"Where to get codes" rendering:**

```dart
Widget _buildGetCodesSection() {
  final links = _campaign?.links('redemption') ?? [];
  if (links.isEmpty) {
    return _FallbackRow(url: _fallbackPromoUrl);   // hardcoded fallback
  }
  return Column(
    children: links.map((l) => GestureDetector(
      onTap: () => launchUrl(Uri.parse(l.url), mode: LaunchMode.externalApplication),
      child: Row(children: [
        const Icon(Icons.open_in_new_rounded, size: 14, color: Colors.white24),
        const SizedBox(width: 8),
        Expanded(child: Text(l.label, style: const TextStyle(color: Colors.white38, fontSize: 12.5))),
        const Icon(Icons.chevron_right_rounded, size: 16, color: Colors.white12),
      ]),
    )).toList(),
  );
}
```

### 9.6 Pro Upgrade Screen

```
- WatchAdsCard (if not Pro): N progress dots + CTA
- Pro benefits list
- RevenueCat Offerings as package cards
- Restore Purchases link
```

---

## SECTION 10 — Localisation (en.json Key Registry)

All user-visible strings go in `assets/translations/en.json`. Never hardcode in widgets.
See Section 17 for the full multilanguage system.

Minimum required key groups:
`common_*`, `home_*`, `scanner_*`, `editor_*`, `search_*`,
`onboarding_*`, `settings_*`, `community`, `offers_*`,
`paywall_*`, `export_*`

---

## SECTION 11 — AdMob Setup

```
1. Create ad units: Interstitial, Rewarded, (optional) Banner.
2. Add AdMob App ID to AndroidManifest.xml and Info.plist.
3. Store IDs in AdsService:
   static const String adInterstitialId = '{{ADMOB_INTERSTITIAL_ID}}';
   static const String adRewardedId     = '{{ADMOB_REWARDED_ID}}';
4. Test IDs (development only):
   Interstitial: ca-app-pub-3940256099942544/1033173712
   Rewarded:     ca-app-pub-3940256099942544/5224354917
```

---

## SECTION 12 — RevenueCat Setup

```
1. Create app in RevenueCat dashboard.
2. Add Android (Google Play) + iOS (App Store) integrations.
3. Create entitlement: "{{ENTITLEMENT_ID}}"
4. Create products: monthly, yearly, three_month, six_month, lifetimepro
5. Create Offering containing these packages.
6. Base64-encode each key → AppConstants._rcAndroid / _rcIos.
7. main(): await Purchases.configure(PurchasesConfiguration(AppConstants.revenueCatApiKey));
```

---

## SECTION 13 — Backend Registration

```
1. Parent backend: https://serviceworker-two.vercel.app/admin/promo
   → Create app entry: APP_ID = "{{APP_ID}}"
2. Campaign backend: https://codeinktechnologies.com/api/promo/campaign
   → Create campaign: slug = "{{CAMPAIGN_SLUG}}"
3. Add customLinks:
   - kind: "redemption" → promo code source URL
   - kind: "support"    → help URL or bare email (app handles both)
   - kind: "privacy"    → privacy policy URL
   - kind: "terms"      → terms of service URL
4. Add communityLinks:
   - kind: discord | telegram | whatsapp | twitter | youtube | facebook
5. Add appLinks: [Play Store URL, App Store URL]
6. App picks up changes within 6h via CampaignService TTL.
   Force: CampaignService.instance.fetch(forceRefresh: true)
```

---

## SECTION 14 — Mobile Design Philosophy

> **Critical agent rule**: You bring zero design opinions to any Codeink project.
> All design decisions are pre-made by the developer in Section 0.7.
> Your job is to implement exactly what is specified — nothing more.

### 14.1 Primary Style: Flat Design 2.0 (Modern Flat UI)

Always-on foundation. Every screen starts here regardless of secondary style choice.

```
✅ DO:
  - Dark scaffold backgrounds: #000000 or #0A0A0A
  - Flat surface cards: Color(0xFF1A1A1A) fill, Colors.white10 border, radius 8–16
  - Single app accent color for CTAs and active states only
  - 0 elevation on all ElevatedButtons
  - Clean typographic hierarchy using size + weight contrast — no decorative text
  - Subtle dividers: Colors.white10
  - Minimal empty states: one icon + one short line of text
  - CrossAxisAlignment.stretch in all scrollable Columns
  - Explicit SizedBox(width:, height:) on buttons inside a Row
  - Widget (not IconData) for tile leading icons
  - font_awesome_flutter brand icons for ALL social platforms
  - Exact brand hex colors for community/social icons (Section 7.2)
  - Clamp ConstrainedBox minHeight: `(constraints.maxHeight - N).clamp(0.0, double.infinity)`
    NEVER `minHeight: constraints.maxHeight - N` — crashes with negative constraint during warm-up
```

```
❌ NEVER — these are banned by default. The agent does not add them even if they "look nice":
  - Neon or glowing effects of any kind (ColorFilters, glowRadius, neon-color shadows)
  - Colored card borders — borders are white/black at low opacity ONLY (e.g. Colors.white10)
  - Accent-colored borders on feature tiles or list items
  - Drop shadows on cards or containers (BoxShadow on non-CTA elements)
  - Gradient backgrounds — no LinearGradient / RadialGradient on surfaces or scaffolds
  - Gradient text (ShaderMask or similar)
  - Animated particle effects, sparkle effects, shimmer on loaded content
  - Multiple accent colors — one accent, one dark variant, that is all
  - More than two font weights on a single screen
  - Hardcoded hex colors outside app_colors.dart
  - Hardcoded strings in widget builds — everything in en.json
  - print() — use debugPrint()
  - Material icons for any social/community platform (Section 7 governs this)
  - CrossAxisAlignment.center in scrollable Columns (causes RenderBox crash)
  - Hardcoded campaign slug — always AppConstants.campaignSlug
  - `open_filex` package — it injects READ_MEDIA_VIDEO + READ_MEDIA_AUDIO into AndroidManifest
    even when never called from Dart. Use `share_plus` for file sharing. Remove if present.
```

### 14.2 Secondary: User-Chosen Style (applies ONLY to surfaces listed in Section 0.7)

The secondary style is specified by the developer in `DESIGN.secondary_style` and
`DESIGN.mobile_accent_surfaces`. The agent applies it **only to those listed surfaces**.
On every other surface the primary flat style applies. Agent adds nothing extra.

**If `secondary_style: glassmorphism`** — on listed surfaces only:
```dart
ClipRRect(
  borderRadius: BorderRadius.circular(20),
  child: BackdropFilter(
    filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
    child: Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.10)),
      ),
      child: child,
    ),
  ),
)
// ✅ Allowed on: bottom sheets, paywall hero card, overlay dialogs, promo card
// ❌ Not on: scrolling list items, full scaffold, standard buttons, nav bar
```

**If `secondary_style: claymorphism`** — on listed surfaces only:
```dart
Container(
  decoration: BoxDecoration(
    color: AppColors.accent,
    borderRadius: BorderRadius.circular(24),
    boxShadow: [
      BoxShadow(color: Colors.white.withOpacity(0.12),
                offset: const Offset(-4, -4), blurRadius: 12),
      BoxShadow(color: Colors.black.withOpacity(0.15),
                offset: const Offset(4, 4), blurRadius: 12),
    ],
  ),
  child: child,
)
// ✅ Allowed on: primary CTA button, "Go Pro" card, onboarding highlight badge
// ❌ Not on: standard list tiles, navigation, text containers
```

**If `secondary_style: minimalism`** — no secondary elements at all. Pure flat everywhere.

### 14.3 The Minimalism Principle (always-on regardless of secondary choice)

- One primary action per screen
- Every element must justify its presence — if removing it costs nothing, remove it
- Content over chrome
- Whitespace is a design element, not wasted space
- Secondary styles must clarify or focus attention — never decorate

---

## SECTION 15 — Flutter Pre-Launch Checklist

### Code
- [ ] All `{{PLACEHOLDER}}` tokens replaced
- [ ] No `print()` — only `debugPrint()`
- [ ] No hardcoded strings — all in `en.json`
- [ ] No hardcoded colors — all in `AppColors`
- [ ] `BuildContext` never used across `await` without `mounted` guard
- [ ] RevenueCat keys base64-encoded in `AppConstants`
- [ ] Test AdMob IDs replaced with production IDs
- [ ] `google-services.json` and `GoogleService-Info.plist` present
- [ ] Audit every package in `pubspec.yaml` against its Android plugin source for undeclared permissions
- [ ] Remove any package that is in `pubspec.yaml` but never imported or called from `lib/`
      (unused packages still merge their AndroidManifest permissions into your APK)

### Services
- [ ] ⚠️ FCM wired in `NotificationService.initialize()` — add before first publish
- [ ] Campaign slug returns valid JSON (verify via curl)
- [ ] `communityLinks` populated with correct platform kinds
- [ ] App registered on parent backend
- [ ] Coupon redemption tested end-to-end
- [ ] RevenueCat entitlement verified in sandbox
- [ ] `AppActions.openSupport()` handles bare email addresses
- [ ] No unused packages with Android permission plugins (grep lib/ for each package's import)

### Community & Onboarding
- [ ] Home banner: horizontal scroll pills with brand colors, no borders
- [ ] Onboarding share page: community section visible only when communityLinks.isNotEmpty
- [ ] Settings tiles: FaIcon with brand color (not Material icons)
- [ ] Watch-N-Ads grants Pro for exactly 12 hours
- [ ] Pro users skip ads step entirely

### Stores
- [ ] App icon (1024×1024)
- [ ] Screenshots for all required device sizes
- [ ] Privacy policy URL live and accessible
- [ ] Play Store data safety form completed
- [ ] App Store content rating completed

---

## SECTION 16 — Flutter Agent Instructions

When an AI agent reads this document, it must:

1. **Check blueprint status first.**
   - Read Section 0.9 (`BLUEPRINT_STATUS`).
   - If `tagged: false` or the block is missing → ask the developer for the project description.
     Do NOT proceed until Section 0 is fully populated and `BLUEPRINT_STATUS.tagged = true`.
   - If `tagged: true` → proceed.

2. **Populate Section 0 from the project description** (if not yet done):
   - Fill every `{{PLACEHOLDER}}` in Sections 0.1–0.8 from the developer's mindmap / description.
   - Derive `APP_NAME`, `APP_ID`, `BUNDLE_ID`, `APP_TAGLINE`, `APP_ACCENT_COLOR` etc. from Section 0.
   - Fill Section 1 from the derived values.
   - Write the Section 0.9 tag block.
   - Stop and confirm with the developer before generating any code.

3. **Stop at Section 1.** Confirm every `{{PLACEHOLDER}}` is resolved before writing code.
4. **Generate files in this order:**
   a. `pubspec.yaml` (include `font_awesome_flutter`, `easy_localization`, `assets/translations/`)
   b. `lib/core/constants/app_constants.dart`
   c. `lib/core/theme/` (4 files)
   d. `lib/data/models/campaign_model.dart`
   e. `lib/core/services/campaign_service.dart` (use `AppConstants.campaignSlug`)
   f. `lib/core/services/app_actions.dart`
   g. All remaining services
   h. `lib/router.dart`
   i. `lib/main.dart` with EasyLocalization (Section 17.4)
   j. Screens derived from Section 0.4 — standard first (splash → onboarding → home → settings → offers → pro_upgrade), then app-specific screens in order
   k. `assets/translations/en.json` (all Section 10 keys + app-specific keys for features in Section 0.3)
   l. **Write all 24 language files directly** (Section 17 — no API, agent writes them)
   m. `tool/translate.dart` (change detector only — Section 17.3)
   n. Wire `EasyLocalization` in `app.dart`
5. **Community links:** FA brand icons on all three surfaces (Sections 7.3, 7.4, 7.5).
6. **Settings tiles:** `Widget icon`, not `IconData` (Section 7.5).
7. **Scrollable Columns:** `CrossAxisAlignment.stretch` always.
8. **Buttons in Rows:** `SizedBox(width:…, height:…)` wrappers.
9. **Notifications:** wire `NotificationService.initialize()` in `main()`.
10. **Design:** Pull accent color and UI moments from Section 0.7. Glassmorphism/claymorphism are secondary accents (Section 14.2–14.3). Primary is always flat.
11. **Verify per screen:** no raw hex colors, no `print()`, no hardcoded strings.
12. **Run pre-launch checklist** (Section 15); report items requiring human action.

---

## SECTION 17 — Multilanguage System

All Codeink apps ship with **25 languages**. Developers **only ever edit `en.json`**.
The other 24 files are written directly by the AI coding agent — **no external API, no cost**.

### 17.1 Supported Languages

| # | Code | Language | Direction |
|---|------|----------|-----------|
| 1 | `en` | English *(source — humans edit this)* | LTR |
| 2 | `es` | Spanish | LTR |
| 3 | `pt` | Portuguese | LTR |
| 4 | `fr` | French | LTR |
| 5 | `de` | German | LTR |
| 6 | `it` | Italian | LTR |
| 7 | `ru` | Russian | LTR |
| 8 | `ja` | Japanese | LTR |
| 9 | `ko` | Korean | LTR |
| 10 | `zh` | Chinese Simplified | LTR |
| 11 | `ar` | Arabic | **RTL** |
| 12 | `hi` | Hindi | LTR |
| 13 | `tr` | Turkish | LTR |
| 14 | `pl` | Polish | LTR |
| 15 | `nl` | Dutch | LTR |
| 16 | `id` | Indonesian | LTR |
| 17 | `vi` | Vietnamese | LTR |
| 18 | `th` | Thai | LTR |
| 19 | `sv` | Swedish | LTR |
| 20 | `da` | Danish | LTR |
| 21 | `fi` | Finnish | LTR |
| 22 | `uk` | Ukrainian | LTR |
| 23 | `ms` | Malay | LTR |
| 24 | `ro` | Romanian | LTR |
| 25 | `cs` | Czech | LTR |

### 17.2 Developer Workflow

```
1. Edit ONLY assets/translations/en.json — add or update English strings.
2. Run the change detector:
     dart run tool/translate.dart
   If changes are detected, it prints the list of changed keys and says:
     "Ask the AI coding agent to update all 24 translation files."
3. Ask the AI agent to write updated translation files. Agent writes all 24 directly.
4. Build normally: flutter build apk --release
```

### 17.3 Change Detector (`tool/translate.dart`)

**Does NOT call any external API.** Pure Dart, zero cost, zero network.
It reads `en.json`, compares to `.fingerprint`, and tells the developer what changed.
The AI agent then writes the 24 language files from its own language knowledge.

```dart
// tool/translate.dart
// Change detector — no API, no network, no cost.
// Reads en.json, compares to .fingerprint, prints changed keys.
// Run: dart run tool/translate.dart

import 'dart:convert';
import 'dart:io';

void main() {
  const enPath = 'assets/translations/en.json';
  const fpPath = 'assets/translations/.fingerprint';

  final enContent = File(enPath).readAsStringSync();
  String? fingerprint;
  try { fingerprint = File(fpPath).readAsStringSync(); } catch (_) {}

  if (fingerprint == enContent) {
    print('✅ en.json unchanged — all 24 language files are up to date.');
    exit(0);
  }

  final Map<String, dynamic> current  = jsonDecode(enContent) as Map<String, dynamic>;
  final Map<String, dynamic> previous = fingerprint != null
      ? jsonDecode(fingerprint) as Map<String, dynamic>
      : {};

  final added   = current.keys.where((k) => !previous.containsKey(k)).toList();
  final removed = previous.keys.where((k) => !current.containsKey(k)).toList();
  final changed = current.keys.where((k) =>
      previous.containsKey(k) && previous[k] != current[k]).toList();

  if (added.isNotEmpty)   print('➕ Added keys:   ${added.join(', ')}');
  if (removed.isNotEmpty) print('➖ Removed keys: ${removed.join(', ')}');
  if (changed.isNotEmpty) print('✏️  Changed keys: ${changed.join(', ')}');

  print('');
  print('👉 Ask the AI coding agent:');
  print('   "Update all 24 language translation files in assets/translations/');
  print('    for the changed/added keys above. Preserve {0}, {1} placeholders exactly."');
  print('');
  print('   After the agent writes the files, update the fingerprint:');
  print('   cp assets/translations/en.json assets/translations/.fingerprint');

  exit(1);
}
```

After the agent updates all 24 files, update the fingerprint:
```bash
# Windows PowerShell:
Copy-Item assets\translations\en.json assets\translations\.fingerprint

# macOS / Linux:
cp assets/translations/en.json assets/translations/.fingerprint
```

### 17.4 App Setup

**`main.dart`:**
```dart
import 'package:easy_localization/easy_localization.dart';

const _supportedLocales = [
  Locale('en'), Locale('es'), Locale('pt'), Locale('fr'), Locale('de'),
  Locale('it'), Locale('ru'), Locale('ja'), Locale('ko'), Locale('zh'),
  Locale('ar'), Locale('hi'), Locale('tr'), Locale('pl'), Locale('nl'),
  Locale('id'), Locale('vi'), Locale('th'), Locale('sv'), Locale('da'),
  Locale('fi'), Locale('uk'), Locale('ms'), Locale('ro'), Locale('cs'),
];

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();
  // ... other init ...
  runApp(
    EasyLocalization(
      supportedLocales: _supportedLocales,
      path: 'assets/translations',
      fallbackLocale: const Locale('en'),
      child: const YourApp(),
    ),
  );
}
```

**`app.dart`:**
```dart
MaterialApp.router(
  localizationsDelegates: context.localizationDelegates,
  supportedLocales: context.supportedLocales,
  locale: context.locale,
  // ...
)
```

**`pubspec.yaml`:**
```yaml
dependencies:
  easy_localization: ^3.0.7
  intl: ^0.20.2

dependency_overrides:
  intl: ^0.20.2  # Resolves Syncfusion vs flutter_localizations conflict

flutter:
  assets:
    - assets/translations/
```

### 17.5 Using Translations

```dart
Text('settings_title'.tr())
Text('settings_version'.tr(args: ['1.2.3']))       // "Version 1.2.3"
Text('paywall_watch_ads_progress'.tr(args: ['2', '5'])) // "2 of 5 ads watched"
```

### 17.6 File Management

All 24 language files are **committed to git** alongside `en.json`.
The AI agent writes them from its native language knowledge — no API keys needed, no CI secrets,
no network dependency during builds. This is zero-cost and works fully offline.

Only `.fingerprint` may be excluded from git if preferred (it is a build cache):
```gitignore
assets/translations/.fingerprint
```

### 17.7 Adding a New String

1. Add key + English value to `en.json`
2. Use `'your_key'.tr()` in the widget
3. Run `dart run tool/translate.dart` — it lists the new key
4. Ask the AI agent to add it to all 24 language files
5. Commit

---

## SECTION 18 — Next.js Web: Landing Pages & Legal

All Codeink apps have a companion web presence hosted under:
`https://serviceworker-two.vercel.app/`

Parent project directory: `E:\Projects\NextJs\serviceworker`

### 18.1 Tech Stack

```
Next.js:    16+ (App Router — folder-based routing)
Language:   TypeScript
Styling:    Tailwind CSS v4
Icons:      lucide-react + react-icons (for brand icons)
Fonts:      next/font (Inter primary, system fallback)
Deployment: Vercel
```

### 18.2 App Router Structure

Each app gets one self-contained directory tree that can be copied as-is into the parent project:

```
app/
└── {{APP_ID}}/
    ├── data.ts           ← ALL content: APP, FEATURES, STEPS, PLANS, FAQS, NAV_LINKS, FOOTER_LINKS
    ├── shared.tsx        ← Glow, NavBar, Footer, BrandLogo, PlayBadge, ImgPlaceholder
    ├── page.tsx          ← Landing page — imports from data.ts + shared.tsx
    ├── about/
    │   └── page.tsx
    ├── contact/
    │   └── page.tsx
    ├── support/
    │   └── page.tsx      ← FAQ accordion + community links
    ├── legal/
    │   ├── LegalView.tsx ← Tabbed Privacy / ToS / EULA (client component)
    │   └── page.tsx      ← Server wrapper: reads ?tab= param, passes to LegalView
    └── download/
        └── page.tsx      ← Store badges + platform notes
```

**URL pattern** (standard across all Codeink landing pages):
```
Landing:  /{{APP_ID}}/
About:    /{{APP_ID}}/about/
Contact:  /{{APP_ID}}/contact/
Support:  /{{APP_ID}}/support/
Legal:    /{{APP_ID}}/legal?tab=privacy   ← Privacy Policy
          /{{APP_ID}}/legal?tab=tos       ← Terms of Service
          /{{APP_ID}}/legal?tab=eula      ← EULA
Download: /{{APP_ID}}/download/
```

> ⚠️ **AppConstants mismatch note**: Flutter's `AppConstants.privacyPolicyUrl` currently points to
> `/privacies/{{APP_ID}}/`. If the project uses the `/{{APP_ID}}/legal?tab=privacy` pattern,
> either update `AppConstants` to match, or create a Next.js redirect at `/privacies/{{APP_ID}}/`
> that redirects to `/{{APP_ID}}/legal?tab=privacy`. Choose one approach consistently per project.

### 18.3 App Data File (`data.ts`)

Single source of truth for all content. `page.tsx` and other pages import from here — no content hardcoded in components.

```ts
// app/{{APP_ID}}/data.ts
export const APP = {
  name:        '{{APP_NAME}}',
  tagline:     '{{APP_TAGLINE}}',
  oneLiner:    '{{ONE_LINER}}',       // Used in hero subtitle + footer
  packageId:   '{{BUNDLE_ID}}',
  playUrl:     '{{PLAY_STORE_URL}}',
  appStoreUrl: '{{APP_STORE_URL}}',   // Optional; omit if Android-only
  email:       '{{SUPPORT_EMAIL}}',
  company:     '{{COMPANY_NAME}}',    // e.g. "Codeink Technologies"
  lastUpdated: '{{LEGAL_DATE}}',      // ISO date shown on legal pages
} as const;

// NAV_LINKS, FEATURES, STEPS, PLANS, FAQS, FOOTER_LINKS follow the same pattern
// Derive all content from the Section 0 fields populated for this project.
```

### 18.4 Color Constants (`page.tsx` top)

Colors are **TS constants at the top of `page.tsx`** — NOT CSS variables or a config file.
This is how all existing landing pages work. Copy the accent values directly from Section 0.7:

```ts
// ── Accent values (must match Flutter app_colors.dart) ────────────────────────
const ACCENT       = '{{DESIGN.ACCENT}}'        // e.g. '#2979FF'
const ACCENT_DARK  = '{{DESIGN.ACCENT_DARK}}'   // e.g. '#2962FF'
const ACCENT_LIGHT = '{{DESIGN.ACCENT_LIGHT}}'  // e.g. '#82B1FF'
const ACCENT_BG    = '{{DESIGN.ACCENT_BG}}'     // e.g. '#0D1F3C'
const BG           = '{{DESIGN.BG}}'            // e.g. '#08090D'
```

These constants are used throughout `page.tsx` via inline `style={{ color: ACCENT }}` — never Tailwind arbitrary values for the accent so the single-source is always the constants block.

### 18.5 Shared Components (`shared.tsx`)

Every app has a `shared.tsx` exporting: `Glow`, `NavBar`, `Footer`, `BrandLogo`, `PlayBadge`, `ImgPlaceholder`.

**`ImgPlaceholder`** — standard placeholder used for every asset slot until user provides real files:

```tsx
function ImgPlaceholder({ label, aspect = 'aspect-video' }: { label: string; aspect?: string }) {
  return (
    <div
      className={`w-full ${aspect} rounded-2xl flex flex-col items-center justify-center gap-2`}
      style={{ background: 'rgba(255,255,255,0.04)' }}
    >
      <ImageIcon className="w-6 h-6 text-white/15" />
      <span className="text-xs text-white/20 text-center px-4">{label}</span>
    </div>
  );
}
```

**`NavBar`** — always glassmorphism regardless of secondary style choice:
```tsx
<header className="fixed top-0 inset-x-0 z-50 backdrop-blur-xl border-b"
  style={{ background: `${BG}b3`, borderColor: 'rgba(255,255,255,0.05)' }}>
```

**`Glow`** — ambient accent glow fixed behind content (top-left + bottom-right):
```tsx
<div className="fixed inset-0 overflow-hidden pointer-events-none">
  <div className="absolute top-[-10%] left-[-10%] w-[45%] h-[45%] blur-[130px] rounded-full"
    style={{ background: `${ACCENT}1A` }} />
  <div className="absolute bottom-[-10%] right-[-10%] w-[45%] h-[45%] blur-[130px] rounded-full"
    style={{ background: `${ACCENT}0D` }} />
</div>
```

### 18.6 Landing Page (Hero + Sections)

### 18.6 Landing Page (Hero + Sections)

Structure — top to bottom:
```
1. Navbar         — logo | nav links | "Download" CTA button
2. Hero           — headline, tagline, download buttons (Play Store / App Store), app screenshot
3. Features       — 3–6 feature cards in a grid
4. Community      — social platform links (brand colors, Section 7)
5. Screenshots    — horizontal scroll / carousel of app screens
6. Download CTA   — bold "Get {{APP_NAME}} Free" section
7. Footer         — links: About, Features, Support, Privacy, ToS, EULA | © Codeink Technologies
```

```tsx
// app/{{APP_ID}}/page.tsx — scaffold
import { APP_CONFIG } from './config';

export default function LandingPage() {
  return (
    <main className="bg-[#0A0A0A] text-white min-h-screen">
      <Navbar config={APP_CONFIG} />
      <HeroSection config={APP_CONFIG} />
      <FeaturesSection />
      <CommunitySection />
      <ScreenshotsSection />
      <DownloadCTA config={APP_CONFIG} />
      <Footer config={APP_CONFIG} />
    </main>
  );
}
```

Navbar rules:
```
- Sticky top, backdrop blur (glassmorphism accent) on scroll
- Logo left, nav links center, Download button right
- Download button: accent color, border-radius 999 (pill), no shadow
- Mobile: hamburger → slide-down menu
```

Hero rules:
```
- Headline: bold, large (text-5xl md:text-7xl), white
- Tagline: muted gray, text-xl
- Download buttons: Play Store (black pill) + App Store (white pill)
- App screenshot: floating mockup with soft glow in accent color (15% opacity)
- Background: pure black or very dark (#0A0A0A)
- NO full-page gradient backgrounds
```

### 18.6 Features Page

```tsx
// app/{{APP_ID}}/features/page.tsx
// Grid of feature cards — glassmorphism style
<div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
  {features.map((f) => (
    <FeatureCard
      key={f.id}
      icon={f.icon}
      title={f.title}
      description={f.description}
    />
  ))}
</div>

// FeatureCard uses glassmorphism (Section 19.2):
// bg-white/5 backdrop-blur-xl border border-white/10 rounded-2xl
```

### 18.7 About Page

Structure:
```
1. Hero          — "About {{APP_NAME}}" heading
2. Mission       — 2-3 paragraphs about Codeink Technologies
3. App story     — what problem it solves, who it's for
4. Team section  — "Made with love by Codeink Technologies"
5. Download CTA
```

### 18.8 Contact & Support Pages

**Contact (`/contact`):**
```
- Brief intro text
- Contact form: Name, Email, Subject (dropdown: General / Bug / Feature / Other), Message
- "Or email us directly:" → support email link
- Form posts to: POST /api/contact  (or mailto: fallback)
```

**Support (`/support`):**
```
1. Search bar (client-side FAQ search)
2. FAQ accordion: 5-10 common questions
3. "Still need help?" → contact form or mailto link
4. Community links (brand icons — same as Section 7)
```

### 18.9 Legal Pages

All legal pages share the same layout shell:

```tsx
// app/privacies/{{APP_ID}}/layout.tsx
export default function LegalLayout({ children }: { children: React.ReactNode }) {
  return (
    <div className="bg-[#0A0A0A] text-white min-h-screen">
      <LegalNavbar appId="{{APP_ID}}" appName="{{APP_NAME}}" />
      <main className="max-w-3xl mx-auto px-6 py-16">
        {children}
      </main>
      <LegalFooter appId="{{APP_ID}}" />
    </div>
  );
}
```

Legal pages TOC in LegalNavbar:
```
Privacy Policy | Terms of Service | EULA | Cookie Policy | Refund Policy
```

**Privacy Policy (`/privacies/{{APP_ID}}/`):**
```
Sections:
1. Introduction & scope
2. Information we collect (device ID, usage analytics, ad identifiers)
3. How we use your information (service delivery, ad targeting, analytics)
4. Third-party services (Google AdMob, RevenueCat, Firebase)
5. Data retention
6. Children's privacy (COPPA compliance — apps rated 4+)
7. Your rights (GDPR / CCPA)
8. Changes to this policy
9. Contact us
```

**Terms of Service (`/privacies/{{APP_ID}}/tos/`):**
```
Sections:
1. Acceptance of terms
2. License grant (personal, non-commercial, non-transferable)
3. Subscriptions & payments (RevenueCat, auto-renewal)
4. Free tier limitations
5. Prohibited conduct
6. Intellectual property
7. Disclaimer of warranties
8. Limitation of liability
9. Governing law
10. Contact
```

**EULA (`/privacies/{{APP_ID}}/eula/`):**
```
Sections:
1. Grant of license
2. Restrictions (no reverse engineering, no redistribution)
3. App store terms (Google Play / Apple App Store apply additionally)
4. Updates & maintenance
5. Termination
6. Disclaimer
7. Contact
```

**Cookie Policy (`/privacies/{{APP_ID}}/cookies/`):**
```
Sections:
1. What are cookies / local storage
2. What we store (SharedPreferences keys, cache, ad IDs)
3. Third-party tracking (AdMob, Firebase Analytics)
4. Managing storage on your device
5. Contact
```

**Refund Policy (`/privacies/{{APP_ID}}/refund/`):**
```
Sections:
1. Subscription cancellation (through App Store / Play Store)
2. Refund eligibility window (App Store: 14 days / Play Store: 48h)
3. Lifetime purchase refunds (case-by-case)
4. How to request a refund
5. Contact
```

---

## SECTION 19 — Web Design System

> **Critical agent rule**: The agent has NO design opinions on Codeink web projects.
> Colors come from Section 0.7 TS constants. Secondary style comes from Section 0.7.
> The agent implements what is specified. It adds nothing else.
> The existing projects (inwebedit, indocedit) are the reference standard — they stay intact.

### 19.1 Primary: Flat Design 2.0 (always-on)

Every surface on every page starts with this. No exceptions.

```
✅ DO:
  - Near-black page background — BG constant (e.g. #08090D / #0A0A0A)
  - Flat card surfaces: rgba(255,255,255,0.04) — no border, no shadow
  - Section zebra alternation: rgba(255,255,255,0.015) with border-y border-white/5
  - Accent tinted section backgrounds: ACCENT_BG constant (e.g. for privacy / CTA / pricing)
  - ACCENT constant on CTAs, active states, icon tile backgrounds (at 8% opacity: ACCENT + "14")
  - ACCENT_LIGHT constant on muted labels, checkmarks, eyebrow text
  - Inter font family only — extrabold headings, tight tracking
  - All colors via TS constants — style={{ color: ACCENT }} never Tailwind arbitrary [#hex]
  - Section padding: py-24 / py-20 for main sections, py-10 / py-12 for strips
  - Card radius: rounded-2xl (small cards), rounded-3xl (feature tiles), rounded-[28–40px] (CTA blocks)
```

```
❌ BANNED — agent never adds these regardless of how the layout looks:
  - Neon or glow effects: box-shadow with a colored spread, drop-shadow with accent color
  - Colored card borders: border-[accent]/20, border-red-500, any border in a non-white/black color
  - Gradient backgrounds on sections or the page: bg-gradient-*, from-*/to-*, linear-gradient
  - Gradient text: bg-clip-text text-transparent bg-gradient-* — plain white text only
  - Drop shadows on card tiles: no shadow-* classes, no box-shadow on feature/step/audience cards
  - Hover border color changes to accent on standard cards (hover:border-red-500/30 etc.)
  - Animated glow or pulse effects around elements
  - Multiple colors in the same icon set — community icons use their exact brand colors only
  - CSS variables for the app accent — always the TS constants block at the top of page.tsx
  - Agent-invented image filenames — only names listed in Section 0.8
  - Glassmorphism on feature cards, step cards, or any repeating grid tile
  - Any design choice not specified in Section 0.7
```

**Flat card** — the only recipe for repeating tiles (feature cards, step cards, audience cards):
```tsx
<div style={{ background: 'rgba(255,255,255,0.04)' }} className="p-6 rounded-3xl">
  {/* no border, no shadow, no backdrop-filter */}
</div>
```

**Zebra section** — alternating page sections for rhythm:
```tsx
<section className="border-y border-white/5" style={{ background: 'rgba(255,255,255,0.015)' }}>
```

**Accent background block** — CTA, privacy strip, no-account callout:
```tsx
<div style={{ background: ACCENT_BG }} className="rounded-[32px] p-10 lg:p-12">
```

### 19.2 Navbar (always backdrop-blur — the one fixed glassmorphism element)

The navbar uses `backdrop-blur-xl` always, regardless of secondary style choice.
It is not "glassmorphism" in the design sense — it is a functional scroll effect for legibility.

```tsx
<header
  className="fixed top-0 inset-x-0 z-50 backdrop-blur-xl border-b"
  style={{ background: `${BG}b3`, borderColor: 'rgba(255,255,255,0.05)' }}
>
  {/* b3 = 70% opacity. Border is white at 3% — barely visible, structural only. */}
```

### 19.3 Secondary Style (applies ONLY to surfaces listed in Section 0.7)

The agent reads `DESIGN.secondary_style` and `DESIGN.web_accent_surfaces` from Section 0.7.
It applies the chosen style **only to those listed surfaces**. Everything else stays flat.

**If `secondary_style: glassmorphism`** — listed surfaces only:
```tsx
<div
  className="rounded-[28px] backdrop-blur-xl"
  style={{
    background: 'rgba(255,255,255,0.04)',
    border: '1px solid rgba(255,255,255,0.08)',
  }}
>
  {/* Use for: hero card, paywall/pricing highlight, modal overlay */}
  {/* NOT for: repeating feature cards, step tiles, footer, navbar sections */}
```

**If `secondary_style: claymorphism`** — listed surfaces only:
```tsx
<div
  className="rounded-3xl"
  style={{
    background: ACCENT,
    boxShadow: 'inset -4px -4px 12px rgba(255,255,255,0.12), inset 4px 4px 12px rgba(0,0,0,0.20)',
  }}
>
  {/* Use for: primary download CTA button, "Get Pro" badge, featured pricing card */}
  {/* NOT for: standard buttons, nav links, card tiles, text containers */}
```

**If `secondary_style: minimalism`** — no secondary treatments at all. Pure flat everywhere.

### 19.4 Icon tile on feature cards

```tsx
<div
  className="w-11 h-11 rounded-2xl flex items-center justify-center mb-5"
  style={{ background: `${ACCENT}14` }}
>
  <FeatureIcon className="w-5 h-5" style={{ color: ACCENT_LIGHT }} />
</div>
{/* 14 hex = 8% opacity. Icon is ACCENT_LIGHT — NOT white, NOT full ACCENT. */}
```

### 19.5 Typography

```tsx
// Hero h1 — white, extrabold, tight
className="text-5xl lg:text-6xl font-extrabold tracking-tight leading-[1.06] text-white"
// NO gradient text. Plain white only.

// Section h2
className="text-4xl lg:text-5xl font-extrabold tracking-tight text-white"

// Eyebrow pill above section headings
<div
  className="inline-block px-4 py-1.5 mb-6 text-xs font-bold tracking-widest uppercase rounded-full"
  style={{ background: `${ACCENT}14`, color: ACCENT_LIGHT }}
/>

// Body / description text
className="text-gray-400 leading-relaxed"
// Muted but readable. NOT text-gray-600 (too dark on dark bg).

// Inline code
<code className="mx-1.5 px-1.5 py-0.5 rounded text-xs"
  style={{ background: 'rgba(255,255,255,0.08)' }} />
```

### 19.7 Community Section (Web)

Same brand colors and icons as Section 7 — use `react-icons` (fa6 set):

```tsx
import { FaDiscord, FaTelegram, FaWhatsapp, FaXTwitter, FaYoutube, FaFacebook } from 'react-icons/fa6';

const COMMUNITY_COLORS: Record<string, string> = {
  discord:  '#5865F2',
  telegram: '#26A5E4',
  whatsapp: '#25D366',
  twitter:  '#000000',
  youtube:  '#FF0000',
  facebook: '#1877F2',
};

const COMMUNITY_ICONS: Record<string, React.ComponentType> = {
  discord:  FaDiscord,
  telegram: FaTelegram,
  whatsapp: FaWhatsapp,
  twitter:  FaXTwitter,
  youtube:  FaYoutube,
  facebook: FaFacebook,
};

// Render as pills (same pill design as mobile home screen):
<a href={link.url} className="flex items-center gap-2 px-4 py-2 rounded-full text-white text-sm font-semibold"
   style={{ background: COMMUNITY_COLORS[link.kind] }}>
  <Icon size={14} /> {link.label}
</a>
```

### 19.8 Responsive Breakpoints

```
mobile:  < 768px   — single column, large tap targets
tablet:  768–1024px — 2-column grids
desktop: > 1024px  — 3-column grids, floating mockups
```

### 19.9 Asset Placeholders

Logos, screenshots, and app icons are **provided by the developer** after the landing page structure
is built. Structure pages to accept them via:
- `APP_CONFIG.logoUrl`
- `APP_CONFIG.iconUrl`
- `public/images/{{APP_ID}}/screenshot-*.png`

Never embed placeholder stock images. Use a grey-box skeleton or CSS-generated shape until
real assets are provided.

---

## SECTION 20 — Web Pre-Launch Checklist

### Structure
- [ ] All `{{PLACEHOLDER}}` tokens in `config.ts` replaced
- [ ] App accent color applied via CSS variables
- [ ] All page routes resolve (no 404s)
- [ ] Privacy URL matches `AppConstants.privacyPolicyUrl` exactly
- [ ] ToS URL matches `AppConstants.termsOfServiceUrl` exactly
- [ ] EULA URL matches `AppConstants.eulaUrl` exactly

### Content
- [ ] App name, tagline, and description accurate
- [ ] Legal pages contain real content (not lorem ipsum)
- [ ] Support email wired in Contact + Support + all legal footers
- [ ] Community links match campaign backend data
- [ ] Download buttons link to real Play Store / App Store listings

### Design
- [ ] Navbar: glassmorphism on scroll, logo left, Download CTA right
- [ ] Hero: app screenshot or icon displayed (no broken image)
- [ ] Feature cards: consistent layout, 3–6 per page
- [ ] All pages dark background (#0A0A0A default)
- [ ] No hardcoded colors outside config.ts / CSS variables
- [ ] Mobile responsive verified at 375px, 768px, 1280px

### Assets (provided by developer, not agent)
- [ ] App logo PNG / SVG (provided)
- [ ] App icon 512×512 (provided)
- [ ] App screenshots (provided)
- [ ] App store badges (Google Play / App Store — use official assets)

### SEO & Meta
- [ ] `<title>` and `<meta description>` set per page
- [ ] Open Graph tags set (og:title, og:description, og:image)
- [ ] `robots.txt` allows crawling
- [ ] Canonical URLs correct

### Deployment
- [ ] Vercel project linked to `serviceworker` repo
- [ ] Environment variables set (if any API keys needed)
- [ ] Custom domain configured (if applicable)
- [ ] `https://serviceworker-two.vercel.app/privacies/{{APP_ID}}/` resolves correctly

---

## SECTION 21 — Web Agent Instructions

When an AI agent builds the Next.js web presence for an app, it must:

1. **Confirm Section 0.9 is tagged** (see Section 16 step 1). Do not generate any web files until
   the blueprint is tagged to a specific project.
2. **Read Section 0.5** for the full list of web pages to generate. Generate exactly those pages —
   no more, no less. The standard legal and landing pages are always required.
3. **Pull feature cards from Section 0.3.** The landing page features grid uses `FEATURES[].title`
   and `FEATURES[].desc`. The icon field (`icon`) maps to a `lucide-react` component.
4. **Pull pro/free tier copy from Section 0.6** for the pricing section and paywall marketing text.
5. **Read Section 18** for structure. Read **Section 19** for design rules.
6. **Fill `config.ts`** from Section 1 values before generating any component.
7. **Generate in this order:**
   a. `app/{{APP_ID}}/config.ts`
   b. `app/{{APP_ID}}/layout.tsx`
   c. `app/{{APP_ID}}/page.tsx` (landing page)
   d. `app/{{APP_ID}}/about/page.tsx`
   e. `app/{{APP_ID}}/features/page.tsx`
   f. `app/{{APP_ID}}/contact/page.tsx`
   g. `app/{{APP_ID}}/support/page.tsx`
   h. `app/{{APP_ID}}/download/page.tsx`
   i. `app/privacies/{{APP_ID}}/layout.tsx`
   j. `app/privacies/{{APP_ID}}/page.tsx` (Privacy Policy)
   k. `app/privacies/{{APP_ID}}/tos/page.tsx`
   l. `app/privacies/{{APP_ID}}/eula/page.tsx`
   m. `app/privacies/{{APP_ID}}/cookies/page.tsx`
   n. `app/privacies/{{APP_ID}}/refund/page.tsx`
8. **Design:** glassmorphism on navbar/cards is correct and expected. Claymorphism on CTAs/buttons.
   Do not use multi-color gradient backgrounds.
9. **Community links:** use `react-icons/fa6` brand icons with exact brand colors (Section 19.5).
10. **Asset placeholders:** use CSS grey boxes or `<div>` placeholders — never stock images.
11. **Legal content:** write real, accurate legal text appropriate for a mobile app with ads and IAP.
   Reference Google AdMob, RevenueCat, Firebase in the Privacy Policy.
12. **URLs must match exactly:** privacy, terms, and EULA paths as defined in Section 18.2.
13. **Verify metadata** (title, og:tags) for each page before marking done.
14. **Run web pre-launch checklist** (Section 20) at the end.

---

*Maintained by Codeink Technologies.*
*Update this document whenever a new pattern is adopted so all future apps inherit it automatically.*
*Last updated: multilanguage AI-agent system, glassmorphism/claymorphism design guidelines,*
*Next.js 16 App Router landing pages + legal page system.*
