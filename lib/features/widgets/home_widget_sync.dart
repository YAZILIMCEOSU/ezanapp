import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/services/home_widget_service.dart';
import '../../data/models/prayer.dart';
import '../../data/models/prayer_times_day.dart';
import '../../state/providers.dart';

/// Vakit bilgisi her yenilendiğinde **ana ekran widget'ını** günceller.
///
/// Uygulama ağaç köküne sarılır; kullanıcı hangi ekranda olursa olsun bir kez
/// çalışır. Widget'a yazılan veri yalnızca yereldir (ağ yok, konum sızdırmaz —
/// yalnızca şehir adı).
class HomeWidgetSync extends ConsumerWidget {
  const HomeWidgetSync({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen<AsyncValue<TodayTimes>>(prayerTimesProvider, (
      AsyncValue<TodayTimes>? previous,
      AsyncValue<TodayTimes> next,
    ) {
      final TodayTimes? times = next.value;
      if (times == null) return;
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
    }, fireImmediately: true);

    return child;
  }
}
