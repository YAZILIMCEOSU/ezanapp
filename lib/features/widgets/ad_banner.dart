import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../../core/services/ads_service.dart';
import '../../design/app_spacing.dart';
import '../../state/providers.dart';

/// Alt banner reklam alanı.
///
/// * Premium kullanıcıda ve kimlik tanımlı değilken **hiçbir şey çizmez**;
///   böylece arayüzde boş alan kalmaz.
/// * Yüklenemezse sessizce kaybolur (kullanıcıyı hata mesajıyla yormaz).
class AdBanner extends ConsumerStatefulWidget {
  const AdBanner({
    this.margin = const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
    super.key,
  });

  final EdgeInsets margin;

  @override
  ConsumerState<AdBanner> createState() => _AdBannerState();
}

class _AdBannerState extends ConsumerState<AdBanner> {
  BannerAd? _ad;
  bool _loaded = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  void _load() {
    if (!mounted) return;
    final AdsService ads = ref.read(runtimeProvider).ads;
    if (!ads.bannerAvailable) return;
    final BannerAd? ad = ads.createBanner(
      onLoaded: () {
        if (mounted) setState(() => _loaded = true);
      },
      onFailed: () {
        if (mounted) setState(() => _loaded = false);
      },
    );
    if (ad == null) return;
    ad.load().catchError((Object error) {
      debugPrint('Banner yüklenemedi: $error');
    });
    setState(() => _ad = ad);
  }

  @override
  void dispose() {
    _ad?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool premium = ref.watch(isPremiumProvider);
    final BannerAd? ad = _ad;
    if (premium || ad == null || !_loaded) return const SizedBox.shrink();
    return Padding(
      padding: widget.margin,
      child: ClipRRect(
        borderRadius: AppRadius.allSm,
        child: SizedBox(
          width: ad.size.width.toDouble(),
          height: ad.size.height.toDouble(),
          child: AdWidget(ad: ad),
        ),
      ),
    );
  }
}
