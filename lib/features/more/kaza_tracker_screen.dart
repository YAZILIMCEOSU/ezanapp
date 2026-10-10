import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';

import '../../design/app_colors.dart';
import '../../design/app_spacing.dart';
import '../../state/providers.dart';

/// Kaza namazı/orucu takibi ve Cuma hutbeleri/mesajları ekranı.
class KazaTrackerScreen extends ConsumerStatefulWidget {
  const KazaTrackerScreen({super.key});

  @override
  ConsumerState<KazaTrackerScreen> createState() => _KazaTrackerScreenState();
}

class _KazaTrackerScreenState extends ConsumerState<KazaTrackerScreen>
    with SingleTickerProviderStateMixin {
  static const String _prefsKey = 'kaza_tracker_counts_v1';

  static const List<({String key, String title, String subtitle})> _kazaItems =
      <({String key, String title, String subtitle})>[
        (
          key: 'sabah',
          title: 'Sabah Namazı',
          subtitle: '2 rekât farz kaza namazı',
        ),
        (
          key: 'ogle',
          title: 'Öğle Namazı',
          subtitle: '4 rekât farz kaza namazı',
        ),
        (
          key: 'ikindi',
          title: 'İkindi Namazı',
          subtitle: '4 rekât farz kaza namazı',
        ),
        (
          key: 'aksam',
          title: 'Akşam Namazı',
          subtitle: '3 rekât farz kaza namazı',
        ),
        (
          key: 'yatsi',
          title: 'Yatsı Namazı',
          subtitle: '4 rekât farz kaza namazı',
        ),
        (
          key: 'vitir',
          title: 'Vitir Namazı',
          subtitle: '3 rekât vâcip kaza namazı (Hanefî)',
        ),
        (
          key: 'oruc',
          title: 'Ramazan Kaza Orucu',
          subtitle: 'Tutulamayan farz oruç gün sayısı',
        ),
      ];

  late final TabController _tabController = TabController(
    length: 2,
    vsync: this,
  );
  Map<String, int> _counts = <String, int>{};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _load() {
    final Map<String, Object?>? raw = ref
        .read(runtimeProvider)
        .preferences
        .getJson(_prefsKey);
    if (raw == null) return;
    setState(() {
      _counts = <String, int>{
        for (final entry in raw.entries)
          if (entry.value is num) entry.key: (entry.value! as num).toInt(),
      };
    });
  }

  Future<void> _updateCount(String key, int delta) async {
    final int current = _counts[key] ?? 0;
    final int next = (current + delta).clamp(0, 99999);
    setState(() => _counts[key] = next);
    await ref.read(runtimeProvider).preferences.setJson(
      _prefsKey,
      <String, Object?>{
        for (final entry in _counts.entries) entry.key: entry.value,
      },
    );
  }

  Future<void> _addDaysForAllPrayers(int days) async {
    setState(() {
      for (final item in _kazaItems) {
        if (item.key == 'oruc') continue;
        _counts[item.key] = ((_counts[item.key] ?? 0) + days).clamp(0, 99999);
      }
    });
    await ref.read(runtimeProvider).preferences.setJson(
      _prefsKey,
      <String, Object?>{
        for (final entry in _counts.entries) entry.key: entry.value,
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final int totalRemaining = _kazaItems.fold<int>(
      0,
      (int sum, item) => sum + (_counts[item.key] ?? 0),
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Kaza Takibi & Hutbeler'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const <Widget>[
            Tab(text: 'Kaza Takibi'),
            Tab(text: 'Cuma Hutbeleri'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: <Widget>[
          ListView(
            padding: const EdgeInsets.all(AppSpacing.lg),
            children: <Widget>[
              Container(
                padding: const EdgeInsets.all(AppSpacing.lg),
                decoration: BoxDecoration(
                  color: AppColors.emerald700.withValues(alpha: 0.12),
                  borderRadius: AppRadius.allLg,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      'Toplam Kalan Kaza Borcu: $totalRemaining',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      'Kıldığınız her kaza namazı için (-) düğmesine dokunarak borcunuzdan düşebilirsiniz.',
                      style: theme.textTheme.bodySmall,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Wrap(
                      spacing: AppSpacing.sm,
                      runSpacing: AppSpacing.xs,
                      children: <Widget>[
                        OutlinedButton.icon(
                          onPressed: () => _addDaysForAllPrayers(30),
                          icon: const Icon(Icons.add_rounded, size: 16),
                          label: const Text('+1 Ay Namaz Borcu Ekle'),
                        ),
                        OutlinedButton.icon(
                          onPressed: () => _addDaysForAllPrayers(365),
                          icon: const Icon(Icons.add_rounded, size: 16),
                          label: const Text('+1 Yıl Namaz Borcu Ekle'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              for (final item in _kazaItems)
                Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                  child: Card(
                    margin: EdgeInsets.zero,
                    child: ListTile(
                      title: Text(
                        item.title,
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                      subtitle: Text(item.subtitle),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          IconButton(
                            tooltip: 'Kaza kıldım (-1)',
                            onPressed: (_counts[item.key] ?? 0) <= 0
                                ? null
                                : () {
                                    HapticFeedback.selectionClick();
                                    _updateCount(item.key, -1);
                                  },
                            icon: const Icon(
                              Icons.remove_circle_outline_rounded,
                            ),
                          ),
                          SizedBox(
                            width: 44,
                            child: Text(
                              '${_counts[item.key] ?? 0}',
                              textAlign: TextAlign.center,
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          IconButton(
                            tooltip: 'Borç ekle (+1)',
                            onPressed: () {
                              HapticFeedback.selectionClick();
                              _updateCount(item.key, 1);
                            },
                            icon: const Icon(Icons.add_circle_outline_rounded),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          ),
          ListView.separated(
            padding: const EdgeInsets.all(AppSpacing.lg),
            itemCount: _khutbahs.length,
            separatorBuilder: (BuildContext context, int index) =>
                const SizedBox(height: AppSpacing.md),
            itemBuilder: (BuildContext context, int index) {
              final khutbah = _khutbahs[index];
              return Card(
                margin: EdgeInsets.zero,
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Row(
                        children: <Widget>[
                          const Icon(
                            Icons.menu_book_rounded,
                            color: AppColors.emerald500,
                            size: 20,
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          Expanded(
                            child: Text(
                              khutbah.title,
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        khutbah.summary,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          height: 1.55,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        khutbah.source,
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Align(
                        alignment: Alignment.centerRight,
                        child: FilledButton.tonalIcon(
                          onPressed: () => SharePlus.instance.share(
                            ShareParams(
                              text:
                                  '${khutbah.title}\n\n${khutbah.summary}\n\n'
                                  '${khutbah.source} · (Ezan)',
                            ),
                          ),
                          icon: const Icon(Icons.ios_share_rounded, size: 16),
                          label: const Text('Hutbeyi / Mesajı Paylaş'),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  static const List<({String title, String summary, String source})> _khutbahs =
      <({String title, String summary, String source})>[
        (
          title: 'Cuma Hutbesi: Namaz — Müminin Miracı ve Huzur Kaynağı',
          summary:
              'Namaz, kulun Rabbiyle buluşması ve kötülüklerden arınmasıdır. '
              'Beş vakit namazı vaktinde ve huşû ile eda etmek kalbe sekînet indirir. '
              'Hayırlı ve bereketli Cumalar dileriz.',
          source: 'Ankebût Suresi, 45. Ayet · Buhârî, Mevâkît 5',
        ),
        (
          title: 'Cuma Hutbesi: İhlas, Takva ve Güzel Ahlak',
          summary:
              'Allah katında en değerli olanınız O\'na karşı en çok takva sahibi olanınızdır. '
              'Ameller niyetlere göredir; yapılan her iyiliği yalnızca Allah rızası için yapmak müminin şiarıdır.',
          source: 'Hucurât Suresi, 13. Ayet · Buhârî, Bed\'ü\'l-Vahy 1',
        ),
        (
          title: 'Cuma Hutbesi: Aile Bağları ve Sıla-i Rahîm',
          summary:
              'Anne-babaya ihsan, eş ve çocuklara merhamet, akraba ve komşularla güzel geçim '
              'rızkın bereketlenmesine ve ömrün hayırla uzamasına vesiledir.',
          source: 'İsrâ Suresi, 23. Ayet · Müslim, Birr 20',
        ),
        (
          title: 'Cuma Hutbesi: Helal Kazanç, Doğruluk ve Kul Hakkı',
          summary:
              'Ticarette ve günlük muamelelerde dürüst olmak, ölçü ve tartıyı adaletle yapmak '
              've kul hakkından sakınmak dünya ve ahiret saadetinin temelidir.',
          source: 'Mutaffifîn Suresi, 1–3. Ayetler · Tirmizî, Büyû 4',
        ),
        (
          title: 'Cuma Tebrik Mesajı: Rahmet ve Dua Günü',
          summary:
              'Gönüllerimiz duada birleşsin, kalplerimiz Kur\'an ve sünnet nuruyla dolsun. '
              'Rabbimiz dualarımızı ve ibadetlerimizi kabul eylesin. Cumanız mübarek olsun.',
          source: 'Cum\'a Suresi, 9–10. Ayetler',
        ),
      ];
}
