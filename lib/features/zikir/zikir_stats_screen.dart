import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/utils/app_time.dart';
import '../../data/models/zikir_models.dart';
import '../../design/app_colors.dart';
import '../../design/app_spacing.dart';
import '../../state/content_providers.dart';
import '../widgets/app_shell.dart';
import '../widgets/state_views.dart';

/// Zikir istatistikleri: günlük grafik, toplamlar ve zikir bazlı dağılım.
class ZikirStatsScreen extends ConsumerWidget {
  const ZikirStatsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<List<ZikirStatPoint>> history = ref.watch(
      zikirHistoryProvider,
    );
    final AsyncValue<Map<String, int>> totals = ref.watch(zikirTotalsProvider);
    final AsyncValue<int> total = ref.watch(zikirTotalCountProvider);
    final ThemeData theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Zikir İstatistikleri')),
      body: ListView(
        padding: const EdgeInsets.only(bottom: AppSpacing.xxl),
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: _StatCard(
                    label: 'Toplam zikir',
                    value: total.value?.toString() ?? '—',
                    icon: Icons.fingerprint_rounded,
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: _StatCard(
                    label: 'Son 14 gün',
                    value: history.value == null
                        ? '—'
                        : '${history.value!.fold<int>(0, (int sum, ZikirStatPoint p) => sum + p.count)}',
                    icon: Icons.calendar_view_week_rounded,
                  ),
                ),
              ],
            ),
          ),
          const SectionHeader(title: 'Günlük zikir sayısı'),
          history.when(
            loading: () => const Padding(
              padding: EdgeInsets.all(AppSpacing.xl),
              child: LoadingView(message: 'İstatistikler hazırlanıyor…'),
            ),
            error: (Object error, StackTrace stackTrace) => ErrorView(
              error: error,
              onRetry: () => ref.invalidate(zikirHistoryProvider),
            ),
            data: (List<ZikirStatPoint> points) {
              if (points.isEmpty) {
                return const EmptyView(
                  icon: Icons.insights_outlined,
                  title: 'Henüz veri yok',
                  message: 'Tesbih ekranında zikir çekmeye başladığınızda burada grafik oluşur.',
                );
              }
              final int maxValue = points
                  .map((ZikirStatPoint point) => point.count)
                  .fold<int>(0, (int a, int b) => a > b ? a : b);
              return Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.lg,
                  AppSpacing.md,
                  AppSpacing.xl,
                  AppSpacing.lg,
                ),
                child: SizedBox(
                  height: 200,
                  child: BarChart(
                    BarChartData(
                      maxY: (maxValue == 0 ? 10 : maxValue * 1.25).toDouble(),
                      gridData: FlGridData(
                        drawVerticalLine: false,
                        horizontalInterval: maxValue == 0 ? 5 : maxValue / 4,
                        getDrawingHorizontalLine: (double value) => FlLine(
                          color: theme.colorScheme.outlineVariant.withValues(
                            alpha: 0.4,
                          ),
                          strokeWidth: 1,
                        ),
                      ),
                      borderData: FlBorderData(show: false),
                      titlesData: FlTitlesData(
                        topTitles: const AxisTitles(),
                        rightTitles: const AxisTitles(),
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 34,
                            getTitlesWidget: (double value, TitleMeta meta) =>
                                Text(
                                  value.toInt().toString(),
                                  style: theme.textTheme.labelSmall,
                                ),
                          ),
                        ),
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 26,
                            getTitlesWidget: (double value, TitleMeta meta) {
                              final int index = value.toInt();
                              if (index < 0 || index >= points.length) {
                                return const SizedBox.shrink();
                              }
                              final DateTime date = points[index].date;
                              return Padding(
                                padding: const EdgeInsets.only(top: 6),
                                child: Text(
                                  '${date.day}.${date.month}',
                                  style: theme.textTheme.labelSmall,
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                      barTouchData: BarTouchData(
                        touchTooltipData: BarTouchTooltipData(
                          getTooltipItem:
                              (
                                BarChartGroupData group,
                                int groupIndex,
                                BarChartRodData rod,
                                int rodIndex,
                              ) {
                                final ZikirStatPoint point = points[group.x];
                                return BarTooltipItem(
                                  '${AppTime.formatDateShort(point.date)}\n${point.count} zikir',
                                  theme.textTheme.labelSmall!.copyWith(
                                    color: Colors.white,
                                  ),
                                );
                              },
                        ),
                      ),
                      barGroups: <BarChartGroupData>[
                        for (int i = 0; i < points.length; i++)
                          BarChartGroupData(
                            x: i,
                            barRods: <BarChartRodData>[
                              BarChartRodData(
                                toY: points[i].count.toDouble(),
                                width: 10,
                                color: points[i].count == 0
                                    ? theme.colorScheme.outlineVariant
                                    : AppColors.emerald500,
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ],
                          ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
          const SectionHeader(title: 'Zikir bazlı toplamlar (30 gün)'),
          totals.when(
            loading: () => const Padding(
              padding: EdgeInsets.all(AppSpacing.xl),
              child: LoadingView(message: 'Toplamlar hesaplanıyor…'),
            ),
            error: (Object error, StackTrace stackTrace) => ErrorView(
              error: error,
              onRetry: () => ref.invalidate(zikirTotalsProvider),
            ),
            data: (Map<String, int> values) {
              if (values.isEmpty) {
                return const EmptyView(
                  icon: Icons.bar_chart_rounded,
                  title: 'Dağılım yok',
                  message: 'Zikir çektikçe hangi zikri ne kadar yaptığınız burada listelenir.',
                );
              }
              final List<MapEntry<String, int>> sorted = values.entries.toList()
                ..sort(
                  (MapEntry<String, int> a, MapEntry<String, int> b) =>
                      b.value.compareTo(a.value),
                );
              final int max = sorted.first.value;
              return Column(
                children: <Widget>[
                  for (final MapEntry<String, int> entry in sorted)
                    ListTile(
                      title: Text(entry.key),
                      subtitle: Padding(
                        padding: const EdgeInsets.only(top: 6),
                        child: LinearProgressIndicator(
                          value: max == 0 ? 0 : entry.value / max,
                          minHeight: 6,
                          borderRadius: BorderRadius.circular(999),
                        ),
                      ),
                      trailing: Text(
                        '${entry.value}',
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
  });

  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest
            .withValues(alpha: 0.5),
        borderRadius: AppRadius.allLg,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Icon(
            icon,
            size: 18,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            value,
            style: Theme.of(context).textTheme.headlineSmall
                ?.copyWith(fontWeight: FontWeight.w800),
          ),
          Text(label, style: Theme.of(context).textTheme.labelSmall),
        ],
      ),
    );
  }
}
