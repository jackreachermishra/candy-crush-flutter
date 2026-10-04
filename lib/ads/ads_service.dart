import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import 'ad_config.dart';
import 'reward_attempt.dart';

/// Owns consent and the single rewarded ad. Game screens remain usable if ads fail.
class AdsService extends ChangeNotifier {
  AdsService._();
  static final instance = AdsService._();

  bool _started = false;
  bool _sdkInitialized = false;
  bool _ready = false;
  bool _privacyOptionsRequired = false;
  bool _loadingRewarded = false;
  bool _showingRewarded = false;
  int _rewardRequestId = 0;
  Timer? _rewardTimeout;
  RewardedAd? _rewarded;

  bool get ready => _ready;
  bool get privacyOptionsRequired => _privacyOptionsRequired;
  bool get rewardedReady => _ready && _rewarded != null && !_showingRewarded;
  bool get rewardedLoading => _loadingRewarded;

  Future<void> initialize() async {
    if (_started || !AdConfig.enabled) return;
    _started = true;
    try {
      final params = ConsentRequestParameters(
        consentDebugSettings:
            !kReleaseMode && AdConfig.umpTestDeviceId.isNotEmpty
            ? ConsentDebugSettings(
                testIdentifiers: [AdConfig.umpTestDeviceId],
                debugGeography: DebugGeography.debugGeographyEea,
              )
            : null,
      );
      final updated = Completer<void>();
      ConsentInformation.instance.requestConsentInfoUpdate(
        params,
        () => updated.complete(),
        (error) {
          debugPrint('Consent update failed: ${error.errorCode}');
          updated.complete();
        },
      );
      await updated.future.timeout(const Duration(seconds: 25));
      final formFinished = Completer<void>();
      ConsentForm.loadAndShowConsentFormIfRequired((error) {
        if (error != null) {
          debugPrint('Consent form failed: ${error.errorCode}');
        }
        formFinished.complete();
      });
      await formFinished.future.timeout(const Duration(seconds: 60));
      await _refreshConsent();
    } catch (error) {
      debugPrint('Ad consent unavailable: $error');
      // UMP may retain a valid decision from a previous launch.
      await _refreshConsent();
    }
  }

  Future<void> _refreshConsent() async {
    try {
      _privacyOptionsRequired =
          await ConsentInformation.instance
              .getPrivacyOptionsRequirementStatus() ==
          PrivacyOptionsRequirementStatus.required;
      final mayRequest = await ConsentInformation.instance.canRequestAds();
      if (!mayRequest) {
        _ready = false;
        _rewardRequestId++;
        _rewardTimeout?.cancel();
        _loadingRewarded = false;
        _rewarded?.dispose();
        _rewarded = null;
        notifyListeners();
        return;
      }
      if (!_sdkInitialized) {
        if (!kReleaseMode && AdConfig.testDeviceId.isNotEmpty) {
          await MobileAds.instance.updateRequestConfiguration(
            RequestConfiguration(testDeviceIds: [AdConfig.testDeviceId]),
          );
        }
        await MobileAds.instance.initialize();
        _sdkInitialized = true;
      }
      _ready = true;
      notifyListeners();
      loadRewarded();
    } catch (error) {
      _ready = false;
      debugPrint('Ads unavailable: $error');
      notifyListeners();
    }
  }

  Future<void> showPrivacyOptions() async {
    if (!_privacyOptionsRequired) return;
    final finished = Completer<void>();
    ConsentForm.showPrivacyOptionsForm((error) {
      if (error != null) {
        debugPrint('Privacy options failed: ${error.errorCode}');
      }
      finished.complete();
    });
    await finished.future;
    await _refreshConsent();
  }

  void loadRewarded() {
    if (!_ready || _loadingRewarded || _rewarded != null || _showingRewarded) {
      return;
    }
    _loadingRewarded = true;
    final requestId = ++_rewardRequestId;
    _rewardTimeout?.cancel();
    _rewardTimeout = Timer(const Duration(seconds: 30), () {
      if (requestId != _rewardRequestId) return;
      _rewardRequestId++;
      _loadingRewarded = false;
      debugPrint('Rewarded ad request timed out');
      notifyListeners();
    });
    RewardedAd.load(
      adUnitId: AdConfig.rewardedUnitId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          if (requestId != _rewardRequestId) {
            ad.dispose();
            return;
          }
          _rewardTimeout?.cancel();
          _loadingRewarded = false;
          if (!_ready) {
            ad.dispose();
            return;
          }
          _rewarded = ad;
          notifyListeners();
        },
        onAdFailedToLoad: (error) {
          if (requestId != _rewardRequestId) return;
          _rewardTimeout?.cancel();
          _loadingRewarded = false;
          debugPrint('Rewarded ad unavailable: ${error.code}');
          notifyListeners();
        },
      ),
    );
  }

  /// Returns true only after the SDK's earned-reward callback has fired.
  Future<bool> showRewarded() async {
    final ad = _rewarded;
    if (!_ready || ad == null || _showingRewarded) {
      loadRewarded();
      return false;
    }
    _rewarded = null;
    _showingRewarded = true;
    notifyListeners();
    final finished = Completer<bool>();
    final attempt = RewardAttempt();
    void finish(RewardedAd shownAd) {
      shownAd.dispose();
      _showingRewarded = false;
      if (!finished.isCompleted) finished.complete(attempt.finish());
      notifyListeners();
      loadRewarded();
    }

    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (shownAd) => finish(shownAd),
      onAdFailedToShowFullScreenContent: (shownAd, error) {
        debugPrint('Rewarded ad could not show: ${error.code}');
        finish(shownAd);
      },
    );
    try {
      await ad.show(onUserEarnedReward: (_, __) => attempt.markEarned());
    } catch (error) {
      debugPrint('Rewarded ad failed: $error');
      if (!finished.isCompleted) finish(ad);
    }
    return finished.future;
  }
}
