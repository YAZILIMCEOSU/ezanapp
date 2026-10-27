import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/services/home_widget_service.dart';
import '../../core/utils/logger.dart';
import '../../data/models/prayer.dart';
import '../../data/models/prayer_times_day.dart';
import '../../state/providers.dart';

/// Vakit bilgisi her yenilendiğinde **ana ekran widget'ını** günceller.
///
/// Uygulama ağaç köküne sarılır; kullanıcı hangi ekranda olursa olsun bir kez
/// çalışır. Widget'a yazılan veri yalnızca yereldir (ağ yok, konum sızdırmaz —
/// yalnızca şehir adı).
class HomeWidgetSync extends ConsumerStatefulWidget {
  const HomeWidgetSync({required this.child, super.key});

  final Widget child;

  @override
  ConsumerState<HomeWidgetSync> createState() => _HomeWidgetSyncState();
}

class _HomeWidgetSyncState extends ConsumerState<HomeWidgetSync> {
  @override
  void initState() {
    super.initState();
    // İlk açılışta ilk kare çizildikten sonra widget'a hemen yazılır; böylece
    // kullanıcı uygulamayı açmadan ana ekranda doğru geri sayım görünür.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _sync(ref.read(prayerTimesProvider).value);
    });
  }

  void _sync(TodayTimes? times) {
    if (times == null) return;
    try {
      final PrayerScheduleSnapshot snapshot = times.snapshot(DateTime.now());
      final PrayerTime? nextPrayer = snapshot.nextPrayer;
      if (nextPrayer == null) return;
      final String hijri = ref.read(hijriTodayProvider).formatted;
      unawaited(
        ref
            .read(homeWidgetServiceProvider)
            .sync(
              HomeWidgetService.payloadFor(
                city: times.locationLabel,
                prayerLabel: nextPrayer.prayer.label,
                prayerTime: nextPrayer.time,
                hijri: hijri,
              ),
            ),
      );
    } catch (error) {
      AppLog.debug('Ana ekran widget verisi hazırlanamadı: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<AsyncValue<TodayTimes>>(prayerTimesProvider, (
      AsyncValue<TodayTimes>? previous,
      AsyncValue<TodayTimes> next,
    ) => _sync(next.value));

    return widget.child;
  }
}
