import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/app_runtime.dart';
import '../../core/utils/app_time.dart';
import '../../data/models/app_settings.dart';
import '../../data/models/city.dart';
import '../../data/models/prayer.dart';
import '../../data/models/prayer_times_day.dart';
import '../../data/prayer/prayer_calculator.dart';
import '../../design/app_colors.dart';
import '../../design/app_spacing.dart';
import '../../state/providers.dart';
import '../widgets/app_shell.dart';

/// **Vakit doğrulama (tanılama) ekranı.**
///
/// "İkindi 1 dakika geç görünüyor" gibi şikâyetlerin kaynağını tek ekranda
/// gösterir:
///
/// * hangi ilçe koordinatıyla, hangi saat diliminde hesaplandığı,
/// * verinin hangi kaynaktan (Diyanet / yedek / cihaz / kayıt) geldiği,
/// * açık bir **manuel düzeltme** olup olmadığı (en sık sebep),
/// * uygulamanın gösterdiği saat ile Diyanet'in resmî saatinin **yan yana
///   karşılaştırması** (fark dakika olarak).
///
/// Böylece kullanıcı "1 dakika" farkın nereden geldiğini tahmin etmek zorunda
/// kalmaz; ekran doğrudan söyler ve tek dokunuşla düzeltme sunar.
class PrayerVerifyScreen extends ConsumerStatefulWidget {
  const PrayerVerifyScreen({super.key});

  @override
  ConsumerState<PrayerVerifyScreen> createState() => _PrayerVerifyScreenState();
}

class _PrayerVerifyScreenState extends ConsumerState<PrayerVerifyScreen> {
  bool _busy = false;
  String? _error;
  PrayerTimesDay? _official;
  String? _officialWarning;

  Future<void> _compare() async {
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final AppRuntime runtime = ref.read(runtimeProvider);
      final UserLocation location = ref.read(activeLocationProvider);
      // Referans: **düzeltmesiz** Diyanet yöntemi, zorla yeniden çekilir.
      final PrayerTimesDay official = await runtime.prayerTimes.getDay(
        location: location,
        date: DateTime.now(),
        method: CalculationMethod.diyanet,
        forceRefresh: true,
      );
      if (!mounted) return;
      setState(() {
        _official = official;
        _officialWarning = runtime.prayerTimes.lastWarning;
        _busy = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _error = 'Karşılaştırma yapılamadı. İnternet bağlantınızı kontrol edin.';
        _busy = false;
      });
    }
  }

  Future<void> _resetOffsets() async {
    await ref
        .read(settingsControllerProvider.notifier)
        .clearManualOffsets();
    ref.invalidate(prayerTimesProvider);
    ref.invalidate(prayerRangeProvider);
    if (!mounted) return;
    setState(() => _official = null);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Tüm manuel düzeltmeler sıfırlandı.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final AppSettings settings = ref.watch(settingsProvider);
    final UserLocation location = ref.watch(activeLocationProvider);
    final ThemeData theme = Theme.of(context);
    final CalculationMethod base = CalculationMethod.fromId(
      settings.calculationMethodId,
    );
    final CalculationMethod method = settings.resolvedMethod(base);
    final List<MapEntry<String, int>> offsets = settings.manualOffsets.entries
        .where((MapEntry<String, int> e) => e.value != 0)
        .toList();
    final bool online = ref.watch(isOnlineProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Vakit doğrulama')),
      body: ListView(
        padding: const EdgeInsets.only(bottom: AppSpacing.xxl),
        children: <Widget>[
          const SectionHeader(title: 'Konum'),
          ListTile(
            leading: const Icon(Icons.place_outlined),
            title: Text(location.label),
            subtitle: Text(
              '${location.latitude.toStringAsFixed(4)}, '
              '${location.longitude.toStringAsFixed(4)} · '
              '${location.mode.label}'
              '${location.gpsAccuracyMeters == null ? '' : ' · hassasiyet ±${location.gpsAccuracyMeters!.round()} m'}',
            ),
          ),
          ListTile(
            leading: const Icon(Icons.schedule_rounded),
            title: const Text('Saat dilimi'),
            subtitle: Text(
              'UTC${_offsetLabel(DateTime.now().timeZoneOffset)}'
              '${base.country.isEmpty ? '' : ' · ${base.country}'}',
            ),
          ),
          const SectionHeader(title: 'Yöntem'),
          ListTile(
            leading: const Icon(Icons.explore_outlined),
            title: Text(method.name),
            subtitle: Text(
              settings.asrHanafi
                  ? 'Hanefî ikindi (asr-ı sânî) açık'
                  : 'Standart ikindi (asr-ı evvel)',
            ),
          ),
          if (offsets.isNotEmpty)
            ListTile(
              leading: const Icon(
                Icons.warning_amber_rounded,
                color: AppColors.warning,
              ),
              title: const Text('Manuel düzeltme açık'),
              subtitle: Text(
                '${offsets.map((MapEntry<String, int> e) => '${Prayer.fromKey(e.key).label} ${e.value > 0 ? '+' : ''}${e.value} dk').join(', ')}\n'
                'Vakitler resmî saatten bu kadar kaymış görünür. "Sıfırla" ile Diyanet saatine dönebilirsiniz.',
              ),
              isThreeLine: true,
              trailing: TextButton(
                onPressed: _resetOffsets,
                child: const Text('Sıfırla'),
              ),
            )
          else
            const ListTile(
              leading: Icon(Icons.check_circle_outline_rounded),
              title: Text('Manuel düzeltme yok'),
              subtitle: Text('Vakitler doğrudan resmî/hesaplanan saatten geliyor.'),
            ),
          const SectionHeader(title: 'Uygulamanın gösterdiği vakitler'),
          ..._timesBlock(context, ref, theme),
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.xl,
              AppSpacing.md,
              AppSpacing.xl,
              AppSpacing.md,
            ),
            child: FilledButton.icon(
              onPressed: _busy || !online ? null : _compare,
              icon: _busy
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.fact_check_outlined),
              label: Text(
                !online
                    ? 'İnternet yok: karşılaştırma için bağlanın'
                    : 'Diyanet resmî verisiyle karşılaştır',
              ),
            ),
          ),
          if (_error != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
              child: Text(
                _error!,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.error,
                ),
              ),
            ),
          if (_official != null) ...<Widget>[
            SectionHeader(title: 'Karşılaştırma'),
            if (_officialWarning != null)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
                child: Text(
                  _officialWarning!,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: AppColors.warning,
                  ),
                ),
              ),
            _ComparisonTable(
              shown: ref.watch(prayerTimesProvider).valueOrNull?.day,
              official: _official!,
              use24Hour: settings.use24Hour,
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.xl,
                AppSpacing.sm,
                AppSpacing.xl,
                AppSpacing.md,
              ),
              child: Text(
                'Fark 0–1 dakika ise saat doğrudur (hem Diyanet hem uygulama '
                'dakikaya yuvarlar; aynı gün içinde ±1 dakika normaldir). '
                'Fark daha büyükse yukarıdaki "manuel düzeltme" ve "yöntem" '
                'bölümlerine bakın.',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  List<Widget> _timesBlock(
    BuildContext context,
    WidgetRef ref,
    ThemeData theme,
  ) {
    final TodayTimes? times = ref.watch(prayerTimesProvider).valueOrNull;
    if (times == null) {
      return const <Widget>[
        ListTile(
          leading: Icon(Icons.hourglass_empty_rounded),
          title: Text('Vakitler henüz yüklenmedi'),
        ),
      ];
    }
    final AppSettings settings = ref.watch(settingsProvider);
    return <Widget>[
      for (final Prayer prayer in Prayer.values)
        ListTile(
          dense: true,
          leading: Icon(prayer.icon, color: prayer.color, size: 20),
          title: Text(prayer.label),
          trailing: Text(
            times.day.timeOf(prayer) == null
                ? '--:--'
                : AppTime.formatTime(
                    times.day.timeOf(prayer)!,
                    use24Hour: settings.use24Hour,
                  ),
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
              fontFeatures: const <FontFeature>[
                FontFeature.tabularFigures(),
              ],
            ),
          ),
        ),
      ListTile(
        dense: true,
        leading: const Icon(Icons.info_outline_rounded, size: 20),
        title: Text(times.day.displaySource),
        subtitle: times.warning == null ? null : Text(times.warning!),
      ),
      if (times.day.cachedAt != null)
        ListTile(
          dense: true,
          leading: const Icon(Icons.update_rounded, size: 20),
          title: Text(
            'Veri zamanı: ${AppTime.formatTime(times.day.cachedAt!, use24Hour: true)}',
          ),
        ),
    ];
  }

  static String _offsetLabel(Duration offset) {
    final int minutes = offset.inMinutes;
    final String sign = minutes < 0 ? '-' : '+';
    final int abs = minutes.abs();
    final String mm = (abs % 60).toString().padLeft(2, '0');
    return '$sign${abs ~/ 60}:$mm';
  }
}

/// Uygulama ile resmî vakitlerin dakika farkını gösteren tablo.
class _ComparisonTable extends StatelessWidget {
  const _ComparisonTable({
    required this.shown,
    required this.official,
    required this.use24Hour,
  });

  final PrayerTimesDay? shown;
  final PrayerTimesDay official;
  final bool use24Hour;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final PrayerTimesDay? current = shown;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
      child: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              children: <Widget>[
                Expanded(
                  flex: 3,
                  child: Text('Vakit', style: theme.textTheme.labelSmall),
                ),
                Expanded(
                  flex: 3,
                  child: Text('Uygulama', style: theme.textTheme.labelSmall),
                ),
                Expanded(
                  flex: 3,
                  child: Text('Diyanet', style: theme.textTheme.labelSmall),
                ),
                Expanded(
                  flex: 3,
                  child: Text(
                    'Fark',
                    textAlign: TextAlign.end,
                    style: theme.textTheme.labelSmall,
                  ),
                ),
              ],
            ),
          ),
          for (final Prayer prayer in Prayer.values)
            _ComparisonRow(
              prayer: prayer,
              shown: current?.timeOf(prayer),
              official: official.timeOf(prayer),
              use24Hour: use24Hour,
              theme: theme,
            ),
        ],
      ),
    );
  }
}

/// Karşılaştırma tablosunda tek vakit satırı.
class _ComparisonRow extends StatelessWidget {
  const _ComparisonRow({
    required this.prayer,
    required this.shown,
    required this.official,
    required this.use24Hour,
    required this.theme,
  });

  final Prayer prayer;
  final DateTime? shown;
  final DateTime? official;
  final bool use24Hour;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    final int? diff = (shown == null || official == null)
        ? null
        : shown!.difference(official!).inMinutes;
    final bool ok = diff == null || diff.abs() <= 1;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: <Widget>[
          Expanded(
            flex: 3,
            child: Text(prayer.label, style: theme.textTheme.bodyMedium),
          ),
          Expanded(
            flex: 3,
            child: Text(
              shown == null
                  ? '--:--'
                  : AppTime.formatTime(shown!, use24Hour: use24Hour),
              style: theme.textTheme.bodyMedium,
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              official == null
                  ? '--:--'
                  : AppTime.formatTime(official!, use24Hour: use24Hour),
              style: theme.textTheme.bodyMedium,
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              diff == null
                  ? '—'
                  : diff == 0
                  ? 'aynı'
                  : '${diff > 0 ? '+' : ''}$diff dk',
              textAlign: TextAlign.end,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w700,
                color: ok ? AppColors.success : AppColors.warning,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
