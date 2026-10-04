import 'package:flutter/foundation.dart';

/// A release build serves live ads only when explicitly opted in at build time.
abstract final class AdConfig {
  static const productionEnabled = bool.fromEnvironment(
    'ENABLE_PRODUCTION_ADS',
    defaultValue: false,
  );
  static const testDeviceId = String.fromEnvironment('ADS_TEST_DEVICE_ID');
  static const umpTestDeviceId = String.fromEnvironment('UMP_TEST_DEVICE_ID');

  static bool get enabled =>
      !kIsWeb &&
      defaultTargetPlatform == TargetPlatform.android &&
      (!kReleaseMode || productionEnabled);
  static bool get useProduction => kReleaseMode && productionEnabled;

  static String get bannerUnitId => useProduction
      ? 'ca-app-pub-4138113569115613/8972822010'
      : 'ca-app-pub-3940256099942544/9214589741';
  static String get rewardedUnitId => useProduction
      ? 'ca-app-pub-4138113569115613/7199566185'
      : 'ca-app-pub-3940256099942544/5224354917';
}
