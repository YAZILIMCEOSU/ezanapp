import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/utils/app_time.dart';
import '../../data/models/hijri_date.dart';
import '../../design/app_colors.dart';
import '../../design/app_spacing.dart';
import '../../state/content_providers.dart';
import '../../state/providers.dart';
import '../widgets/state_views.dart';

/// Hicri takvim ve yaklaşan mübarek günler.
class IslamicDaysScreen extends ConsumerWidget {
  const IslamicDaysScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final HijriDate hijri = ref.watch(hijriTodayProvider);
    final AsyncValue<List<({String title, DateTime date, String description})>> days =
        ref.watch(specialDaysProvider);
    final DateTime now = DateTime.now();
    final int hijriMonthLength = ref.watch(runtimeProvider).hijri.monthLength(hijri);

    return Scaffold(
      appBar: AppBar(title: const Text('Hicri Takvim')),
      body: ListView(
        padding: const EdgeInsets.only(bottom: AppSpacing.xl),
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(AppSpacing.xl),
            child: Container(
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: <Color>[AppColors.emerald700, AppColors.emerald900],
                ),
                borderRadius: AppRadius.allLg,
              ),
              padding: const EdgeInsets.all(AppSpacing.xl),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    hijri.longFormatted,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                        ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    AppTime.formatDateLong(now),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.white.withValues(alpha: 0.8),
                        ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    '${hijri.monthName} ayı $hijriMonthLength gün çeker · '
                    'Hicri yıl ${hijri.year}',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: Colors.white.withValues(alpha: 0.75),
                        ),
                  ),
                ],
              ),
            ),
          ),
          const SectionHeader(title: 'Yaklaşan mübarek günler'),
          days.when(
            loading: () => const Padding(
              padding: EdgeInsets.all(AppSpacing.xl),
              child: LoadingView(message: 'Takvim hesaplanıyor…'),
            ),
            error: (Object error, StackTrace stackTrace) => ErrorView(
              error: error,
              onRetry: () => ref.invalidate(specialDaysProvider),
            ),
            data: (List<({String title, DateTime date, String description})> items) {
              if (items.isEmpty) {
                return const EmptyView(
                  icon: Icons.event_available_outlined,
                  title: 'Yaklaşan özel gün yok',
                  message: 'Hicri takvime göre yakın dönemde özel bir gün bulunmuyor.',
                );
              }
              return Column(
                children: <Widget>[
                  for (final ({String title, DateTime date, String description}) item in items)
                    ListTile(
                      leading: Container(
                        width: 46,
                        height: 46,
                        decoration: BoxDecoration(
                          color: AppColors.gold500.withValues(alpha: 0.16),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          '${item.date.day}',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w800,
                                color: AppColors.gold600,
                              ),
                        ),
                      ),
                      title: Text(item.title),
                      subtitle: Text(
                        '${AppTime.formatDateShort(item.date)} ${item.date.year} · '
                        '${AppTime.relativeDays(item.date, now)}\n${item.description}',
                      ),
                      isThreeLine: true,
                    ),
                ],
              );
            },
          ),
          const SectionHeader(title: 'Bilgi'),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: AppSpacing.xl),
            child: Text(
              'Hicri tarihler Umm al-Qura takvimine göre hesaplanır ve Diyanet '
              'takviminden ±1 gün farklı olabilir. Ayarlardan ±3 güne kadar '
              'kaydırma yapabilirsiniz.',
              style: TextStyle(height: 1.5),
            ),
          ),
        ],
      ),
    );
  }
}
