import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';

import '../../data/models/hadith_models.dart';
import '../../design/app_colors.dart';
import '../../design/app_spacing.dart';
import '../../design/app_theme.dart';
import '../../state/content_providers.dart';
import '../../state/providers.dart';
import '../widgets/state_views.dart';

/// Tek bir hadisin ayrıntısı: Arapça metin, meal, kaynak ve paylaşım.
class HadithDetailScreen extends ConsumerWidget {
  const HadithDetailScreen({required this.hadithId, super.key});

  final int hadithId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<List<Hadith>> all = ref.watch(
      hadithQueryProvider(const HadithQuery()),
    );
    final Set<int> favorites =
        ref.watch(hadithFavoriteIdsProvider).value ?? const <int>{};
    final String localeCode = ref.watch(
      settingsProvider.select((s) => s.localeCode),
    );
    final ThemeData theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Hadis')),
      body: all.when(
        loading: () => const LoadingView(message: 'Hadis yükleniyor…'),
        error: (Object error, StackTrace stackTrace) => ErrorView(error: error),
        data: (List<Hadith> items) {
          Hadith? hadith;
          for (final Hadith candidate in items) {
            if (candidate.id == hadithId) {
              hadith = candidate;
              break;
            }
          }
          if (hadith == null) {
            return const EmptyView(
              icon: Icons.search_off_rounded,
              title: 'Hadis bulunamadı',
              message:
                  'Bu hadis kaydı açılamadı. Listeye dönüp yeniden deneyin.',
            );
          }
          final Hadith item = hadith;
          final bool isFavorite = favorites.contains(item.id);
          return ListView(
            padding: const EdgeInsets.all(AppSpacing.lg),
            children: <Widget>[
              Container(
                padding: const EdgeInsets.all(AppSpacing.xl),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest.withValues(
                    alpha: 0.4,
                  ),
                  borderRadius: AppRadius.allLg,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    Text(
                      item.arabic,
                      textAlign: TextAlign.right,
                      textDirection: TextDirection.rtl,
                      style: AppTheme.arabic(theme.textTheme, size: 24),
                    ),
                    const Divider(height: AppSpacing.xxl),
                    Text(
                      item.turkish,
                      style: theme.textTheme.bodyLarge?.copyWith(height: 1.7),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              _SourceCard(hadith: item),
              const SizedBox(height: AppSpacing.lg),
              if (item.topics.isNotEmpty)
                Wrap(
                  spacing: AppSpacing.sm,
                  runSpacing: AppSpacing.sm,
                  children: <Widget>[
                    for (final String topic in item.topics)
                      Chip(
                        label: Text(Hadith.localizedTopic(topic, localeCode)),
                        visualDensity: VisualDensity.compact,
                      ),
                  ],
                ),
              const SizedBox(height: AppSpacing.lg),
              Row(
                children: <Widget>[
                  FilledButton.icon(
                    onPressed: () async {
                      await ref
                          .read(runtimeProvider)
                          .hadith
                          .toggleFavorite(item.id);
                      ref.invalidate(hadithFavoriteIdsProvider);
                      ref.invalidate(hadithFavoritesProvider);
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              isFavorite
                                  ? 'Favoriden çıkarıldı.'
                                  : 'Favorilere eklendi.',
                            ),
                          ),
                        );
                      }
                    },
                    icon: Icon(
                      isFavorite
                          ? Icons.favorite_rounded
                          : Icons.favorite_border_rounded,
                      size: 18,
                    ),
                    label: Text(isFavorite ? 'Favorilerde' : 'Favorilere ekle'),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  OutlinedButton.icon(
                    onPressed: () => SharePlus.instance.share(
                      ShareParams(
                        text:
                            '${item.turkish}\n\n— ${item.primarySource} · ${item.reference}\n'
                            '(EzanAI ile paylaşıldı)',
                        subject: 'Hadis · ${item.reference}',
                      ),
                    ),
                    icon: const Icon(Icons.ios_share_rounded, size: 18),
                    label: const Text('Paylaş'),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              TextButton.icon(
                onPressed: () async {
                  await Clipboard.setData(ClipboardData(text: item.turkish));
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Hadis metni kopyalandı.')),
                    );
                  }
                },
                icon: const Icon(Icons.copy_all_rounded, size: 18),
                label: const Text('Metni kopyala'),
              ),
              const SizedBox(height: AppSpacing.lg),
              Text(
                'Hadis metinleri açık lisanslı Riyâzü\'s-Sâlihîn derlemesinden alınmıştır. '
                'Kaynak ve hadis numarası her kayıtta gösterilir; hüküm çıkarmadan önce '
                'mutlaka ehil bir âlime danışın.',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  height: 1.5,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _SourceCard extends StatelessWidget {
  const _SourceCard({required this.hadith});

  final Hadith hadith;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.gold500.withValues(alpha: 0.10),
        borderRadius: AppRadius.allMd,
        border: Border.all(color: AppColors.gold500.withValues(alpha: 0.35)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              const Icon(
                Icons.verified_rounded,
                size: 18,
                color: AppColors.gold600,
              ),
              const SizedBox(width: AppSpacing.sm),
              Text(
                'Kaynak bilgisi',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Kitap: ${hadith.primarySource}',
            style: theme.textTheme.bodySmall,
          ),
          Text(
            'Referans: ${hadith.reference}',
            style: theme.textTheme.bodySmall,
          ),
          if (hadith.topics.isNotEmpty)
            Text(
              'Konular: ${hadith.topics.join(', ')}',
              style: theme.textTheme.bodySmall,
            ),
        ],
      ),
    );
  }
}
