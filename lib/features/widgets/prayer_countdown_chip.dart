import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/utils/app_time.dart';
import '../../data/models/prayer.dart';
import '../../data/models/prayer_times_day.dart';
import '../../state/providers.dart';

/// Üst çubukta görünen "sonraki vakit" geri sayımı.
class PrayerCountdownChip extends ConsumerWidget {
  const PrayerCountdownChip({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<TodayTimes> times = ref.watch(prayerTimesProvider);
    final DateTime now = ref.watch(clockProvider).value ?? DateTime.now();
    final bool use24Hour = ref.watch(settingsProvider).use24Hour;

    return times.maybeWhen(
      data: (TodayTimes value) {
        final PrayerScheduleSnapshot snap = value.snapshot(now);
        final PrayerTime? next = snap.nextPrayer;
        if (next == null) return const SizedBox.shrink();
        final Duration remaining = snap.remaining;
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: next.prayer.color.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Icon(next.prayer.icon, size: 15, color: next.prayer.color),
                const SizedBox(width: 6),
                Text(
                  '${next.prayer.label} ${AppTime.formatTime(next.time, use24Hour: use24Hour)}'
                  ' · ${AppTime.formatCountdown(remaining)}',
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: next.prayer.color,
                  ),
                ),
              ],
            ),
          ),
        );
      },
      orElse: () => const SizedBox.shrink(),
    );
  }
}
