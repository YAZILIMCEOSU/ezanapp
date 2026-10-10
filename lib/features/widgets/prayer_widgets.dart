import 'package:flutter/material.dart';

import '../../core/utils/app_time.dart';
import '../../data/models/prayer.dart';
import '../../data/models/prayer_times_day.dart';
import '../../design/app_colors.dart';
import '../../design/app_spacing.dart';

/// Tek vakit satırı.
class PrayerTile extends StatelessWidget {
  const PrayerTile({
    required this.prayer,
    required this.time,
    required this.use24Hour,
    this.isNext = false,
    this.isCurrent = false,
    this.onTap,
    this.trailing,
    super.key,
  });

  final Prayer prayer;
  final DateTime? time;
  final bool use24Hour;
  final bool isNext;
  final bool isCurrent;
  final VoidCallback? onTap;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    final bool highlighted = isNext || isCurrent;
    return InkWell(
      onTap: onTap,
      borderRadius: AppRadius.allMd,
      child: AnimatedContainer(
        duration: AppMotion.medium,
        curve: AppMotion.standard,
        margin: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: 3,
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.md,
        ),
        decoration: BoxDecoration(
          color: highlighted
              ? prayer.color.withValues(alpha: 0.10)
              : Colors.transparent,
          borderRadius: AppRadius.allMd,
          border: Border.all(
            color: highlighted
                ? prayer.color.withValues(alpha: 0.35)
                : Colors.transparent,
          ),
        ),
        child: Row(
          children: <Widget>[
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: prayer.color.withValues(alpha: 0.14),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(prayer.icon, size: 19, color: prayer.color),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    prayer.label,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: highlighted ? prayer.color : scheme.onSurface,
                    ),
                  ),
                  if (isCurrent)
                    Text(
                      'Şu anki vakit',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: prayer.color,
                        fontWeight: FontWeight.w600,
                      ),
                    )
                  else if (isNext)
                    Text(
                      'Sıradaki vakit',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: prayer.color,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                ],
              ),
            ),
            Text(
              time == null
                  ? '--:--'
                  : AppTime.formatTime(time!, use24Hour: use24Hour),
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
                fontFeatures: const <FontFeature>[FontFeature.tabularFigures()],
              ),
            ),
            if (trailing != null) ...<Widget>[
              const SizedBox(width: AppSpacing.sm),
              trailing!,
            ],
          ],
        ),
      ),
    );
  }
}

/// Ana ekranın büyük geri sayım kartı.
class NextPrayerCountdownCard extends StatelessWidget {
  const NextPrayerCountdownCard({
    required this.day,
    required this.now,
    required this.use24Hour,
    required this.locationLabel,
    this.tomorrow,
    this.snapshot,
    this.onRefresh,
    this.sourceLabel,
    super.key,
  });

  final PrayerTimesDay day;
  final PrayerTimesDay? tomorrow;
  final PrayerScheduleSnapshot? snapshot;
  final DateTime now;
  final bool use24Hour;
  final String locationLabel;
  final Future<void> Function()? onRefresh;
  final String? sourceLabel;

  @override
  Widget build(BuildContext context) {
    final PrayerScheduleSnapshot snap =
        snapshot ??
        PrayerScheduleSnapshot.resolve(day: day, tomorrow: tomorrow, now: now);
    final Prayer current = snap.currentPrayer;
    final PrayerTime? next = snap.nextPrayer;
    final Duration remaining = snap.remaining;
    final Color accent = next?.prayer.color ?? current.color;
    final double progress = snap.progress;

    return Container(
      margin: AppSpacing.page,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: <Color>[
            accent.withValues(alpha: 0.22),
            AppColors.emerald900.withValues(alpha: 0.92),
          ],
        ),
        borderRadius: AppRadius.allLg,
        border: Border.all(color: accent.withValues(alpha: 0.28)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        current.isPrayerTime
                            ? '${current.label} vakti'
                            : current.label,
                        style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          color: Colors.white.withValues(alpha: 0.85),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        locationLabel,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.white.withValues(alpha: 0.7),
                        ),
                      ),
                    ],
                  ),
                ),
                if (onRefresh != null)
                  IconButton(
                    tooltip: 'Vakitleri yenile',
                    onPressed: () => onRefresh!.call(),
                    icon: Icon(
                      Icons.refresh_rounded,
                      color: Colors.white.withValues(alpha: 0.85),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              next == null
                  ? 'Yatsı sonrası'
                  : snap.isAfterIsha
                  ? '${next.prayer.label} (Yarın)'
                  : next.prayer.label,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.4,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: <Widget>[
                Flexible(
                  child: Text(
                    next == null ? '--:--' : AppTime.formatClock(remaining),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.displaySmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontFeatures: const <FontFeature>[
                        FontFeature.tabularFigures(),
                      ],
                      letterSpacing: -1.2,
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Flexible(
                  child: Text(
                    next == null
                        ? 'sonraki vakit yarın'
                        : 'kaldı · ${AppTime.formatTime(next.time, use24Hour: use24Hour)}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodyMedium
                        ?.copyWith(color: Colors.white.withValues(alpha: 0.8)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
            ClipRRect(
              borderRadius: BorderRadius.circular(999),
              child: LinearProgressIndicator(
                value: progress.clamp(0.0, 1.0),
                minHeight: 5,
                backgroundColor: Colors.white.withValues(alpha: 0.18),
                valueColor: AlwaysStoppedAnimation<Color>(accent),
              ),
            ),
            if (sourceLabel != null) ...<Widget>[
              const SizedBox(height: AppSpacing.md),
              Row(
                children: <Widget>[
                  Icon(
                    Icons.verified_outlined,
                    size: 13,
                    color: Colors.white.withValues(alpha: 0.7),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      sourceLabel!,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: Colors.white.withValues(alpha: 0.7),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Vakit verisinin kaynağını ve tazeliğini gösteren küçük not.
class PrayerSourceNote extends StatelessWidget {
  const PrayerSourceNote({
    required this.day,
    this.use24Hour = true,
    this.warning,
    super.key,
  });

  final PrayerTimesDay day;
  final bool use24Hour;
  final String? warning;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final String? cachedAt = day.cachedAt == null
        ? null
        : AppTime.formatTime(day.cachedAt!, use24Hour: use24Hour);
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.xl,
        0,
        AppSpacing.xl,
        AppSpacing.md,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Icon(
            warning == null
                ? Icons.cloud_done_outlined
                : Icons.cloud_off_rounded,
            size: 14,
            color: warning == null ? AppColors.success : AppColors.warning,
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              warning ??
                  '${day.sourceLabel}${cachedAt == null ? '' : ' · güncelleme $cachedAt'}',
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Vakit tablosunda (haftalık/aylık) tek satır.
class PrayerTableRow extends StatelessWidget {
  const PrayerTableRow({
    required this.day,
    required this.now,
    required this.use24Hour,
    this.onTap,
    super.key,
  });

  final PrayerTimesDay day;
  final DateTime now;
  final bool use24Hour;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final bool isToday = AppTime.isSameDay(day.date, now);
    final ColorScheme scheme = Theme.of(context).colorScheme;
    return InkWell(
      onTap: onTap,
      child: Container(
        color: isToday ? scheme.primary.withValues(alpha: 0.07) : null,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.sm,
        ),
        child: Row(
          children: <Widget>[
            SizedBox(
              width: 62,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    '${day.date.day} ${AppTime.turkishMonths[day.date.month - 1].substring(0, 3)}',
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: isToday ? scheme.primary : null,
                    ),
                  ),
                  Text(
                    AppTime.weekdayShort(day.date),
                    style: Theme.of(context).textTheme.labelSmall
                        ?.copyWith(color: scheme.onSurfaceVariant),
                  ),
                ],
              ),
            ),
            for (final Prayer prayer in Prayer.values)
              Expanded(
                child: Text(
                  day.times[prayer] == null
                      ? '--:--'
                      : AppTime.formatTime(
                          day.times[prayer]!,
                          use24Hour: use24Hour,
                        ),
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    fontFeatures: const <FontFeature>[
                      FontFeature.tabularFigures(),
                    ],
                    fontWeight: isToday ? FontWeight.w700 : FontWeight.w500,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
