import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import 'ad_config.dart';
import 'ads_service.dart';

/// A fixed slot below the map. It never overlays the board or controls.
class BannerSlot extends StatefulWidget {
  const BannerSlot({super.key});

  @override
  State<BannerSlot> createState() => _BannerSlotState();
}

class _BannerSlotState extends State<BannerSlot> {
  BannerAd? _banner;
  BannerAd? _pendingBanner;
  bool _loading = false;
  Timer? _retry;
  Timer? _loadTimeout;

  @override
  void initState() {
    super.initState();
    AdsService.instance.addListener(_onAdsChanged);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  void _onAdsChanged() {
    if (!AdsService.instance.ready) {
      _retry?.cancel();
      _loadTimeout?.cancel();
      _pendingBanner?.dispose();
      _pendingBanner = null;
      _loading = false;
      final old = _banner;
      if (mounted) setState(() => _banner = null);
      if (old != null) {
        WidgetsBinding.instance.addPostFrameCallback((_) => old.dispose());
      }
    } else {
      _load();
    }
  }

  Future<void> _load() async {
    if (!mounted || !AdsService.instance.ready || _loading || _banner != null) {
      return;
    }
    final width = (MediaQuery.sizeOf(context).width - 24).floor();
    if (width < 300) return;
    _loading = true;
    try {
      final size = await AdSize.getLargeAnchoredAdaptiveBannerAdSize(width);
      if (!mounted || !AdsService.instance.ready || size == null) {
        _loading = false;
        return;
      }
      final ad = BannerAd(
        adUnitId: AdConfig.bannerUnitId,
        size: size,
        request: const AdRequest(),
        listener: BannerAdListener(
          onAdLoaded: (ad) {
            if (_pendingBanner != ad) {
              return;
            }
            _loadTimeout?.cancel();
            _pendingBanner = null;
            _loading = false;
            if (!mounted || !AdsService.instance.ready) {
              ad.dispose();
              return;
            }
            setState(() => _banner = ad as BannerAd);
          },
          onAdFailedToLoad: (ad, error) {
            if (_pendingBanner != ad) return;
            _loadTimeout?.cancel();
            _pendingBanner = null;
            ad.dispose();
            _loading = false;
            debugPrint('Banner unavailable: ${error.code}');
            _retry?.cancel();
            if (mounted && AdsService.instance.ready) {
              _retry = Timer(const Duration(seconds: 45), _load);
            }
          },
        ),
      );
      _pendingBanner = ad;
      _loadTimeout = Timer(const Duration(seconds: 30), () {
        if (_pendingBanner != ad) return;
        _pendingBanner = null;
        _loading = false;
        ad.dispose();
        if (mounted && AdsService.instance.ready) {
          _retry = Timer(const Duration(seconds: 45), _load);
        }
      });
      await ad.load();
    } catch (error) {
      _loadTimeout?.cancel();
      _pendingBanner?.dispose();
      _pendingBanner = null;
      _loading = false;
      debugPrint('Banner unavailable: $error');
      if (mounted && AdsService.instance.ready) {
        _retry?.cancel();
        _retry = Timer(const Duration(seconds: 45), _load);
      }
    }
  }

  @override
  void dispose() {
    AdsService.instance.removeListener(_onAdsChanged);
    _retry?.cancel();
    _loadTimeout?.cancel();
    _pendingBanner?.dispose();
    _banner?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ad = _banner;
    if (ad == null) return const SizedBox.shrink();
    return SafeArea(
      top: false,
      child: Center(
        heightFactor: 1,
        child: SizedBox(
          width: ad.size.width.toDouble(),
          height: ad.size.height.toDouble(),
          child: AdWidget(ad: ad),
        ),
      ),
    );
  }
}
