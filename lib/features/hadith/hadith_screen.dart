import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../data/models/hadith_models.dart';
import '../../design/app_colors.dart';
import '../../design/app_spacing.dart';
import '../../router/app_router.dart';
import '../../state/content_providers.dart';
import '../../state/providers.dart';
import '../widgets/ad_banner.dart';
import '../widgets/app_shell.dart';
import '../widgets/state_views.dart';

/// Hadis ekranı: konu başlıkları, arama, favoriler ve kaynak bilgisi.
class HadithScreen extends ConsumerStatefulWidget {
  const HadithScreen({super.key});

  @override
  ConsumerState<HadithScreen> createState() => _HadithScreenState();
}

class _HadithScreenState extends ConsumerState<HadithScreen> {
  final TextEditingController _search = TextEditingController();
  Timer? _debounce;
  HadithQuery _query = const HadithQuery();
  bool _onlyFavorites = false;

  @override
  void dispose() {
    _debounce?.cancel();
    _search.dispose();
    super.dispose();
  }

  void _onQueryChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      setState(() => _query = _query.copyWith(text: value));
    });
  }

  @override
  Widget build(BuildContext context) {
    final AsyncValue<HadithCollection> collection = ref.watch(
      hadithCollectionProvider,
    );
    final AsyncValue<List<Hadith>> hadiths = _onlyFavorites
        ? ref.watch(hadithFavoritesProvider)
        : ref.watch(hadithQueryProvider(_query));
    final Set<int> favorites =
        ref.watch(hadithFavoriteIdsProvider).value ?? const <int>{};
    final ThemeData theme = Theme.of(context);

    return Scaffold(
      appBar: AppBarHeader(
        title: 'Hadis',
        subtitle: collection.maybeWhen(
          data: (HadithCollection value) =>
              '${value.name} · ${value.count} hadis',
          orElse: () => 'Sahih kaynaklardan seçkiler',
        ),
        actions: <Widget>[
          IconButton(
            tooltip: _onlyFavorites ? 'Tüm hadisler' : 'Yalnızca favoriler',
            onPressed: () => setState(() => _onlyFavorites = !_onlyFavorites),
            icon: Icon(
              _onlyFavorites
                  ? Icons.favorite_rounded
                  : Icons.favorite_border_rounded,
              size: 20,
            ),
          ),
        ],
      ),
      body: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg,
              AppSpacing.sm,
              AppSpacing.lg,
              AppSpacing.sm,
            ),
            child: TextField(
              controller: _search,
              onChanged: _onQueryChanged,
              decoration: InputDecoration(
                hintText: 'Hadis metni veya konu ara',
                prefixIcon: const Icon(Icons.search_rounded, size: 20),
                suffixIcon: _search.text.isEmpty
                    ? null
                    : IconButton(
                        onPressed: () {
                          _search.clear();
                          setState(() => _query = _query.copyWith(text: ''));
                        },
                        icon: const Icon(Icons.close_rounded, size: 18),
                      ),
              ),
            ),
          ),
          if (!_onlyFavorites)
            SizedBox(
              height: 38,
              child: collection.maybeWhen(
                data: (HadithCollection value) => ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.lg,
                  ),
                  children: <Widget>[
                    for (final String topic in <String>[
                      HadithQuery.allTopics,
                      ...value.topics,
                    ])
                      Padding(
                        padding: const EdgeInsets.only(right: AppSpacing.sm),
                        child: FilterChip(
                          label: Text(topic),
                          selected: _query.topic == topic,
                          onSelected: (bool selected) => setState(
                            () => _query = _query.copyWith(
                              topic: selected ? topic : HadithQuery.allTopics,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
                orElse: () => const SizedBox.shrink(),
              ),
            ),
          const SizedBox(height: AppSpacing.sm),
          Expanded(
            child: hadiths.when(
              loading: () => const LoadingView(message: 'Hadisler yükleniyor…'),
              error: (Object error, StackTrace stackTrace) => ErrorView(
                error: error,
                onRetry: () {
                  ref.invalidate(hadithCollectionProvider);
                  ref.invalidate(hadithFavoritesProvider);
                },
              ),
              data: (List<Hadith> items) {
                if (items.isEmpty) {
                  return EmptyView(
                    icon: Icons.format_quote_outlined,
                    title: _onlyFavorites
                        ? 'Favori hadis yok'
                        : 'Sonuç bulunamadı',
                    message: _onlyFavorites
                        ? 'Beğendiğiniz hadisleri kalp simgesiyle favorilere ekleyebilirsiniz.'
                        : 'Farklı bir kelime veya konu seçmeyi deneyin.',
                  );
                }
                return ListView.separated(
                  padding: const EdgeInsets.only(bottom: AppSpacing.lg),
                  itemCount: items.length,
                  separatorBuilder: (BuildContext context, int index) =>
                      const Divider(height: 1),
                  itemBuilder: (BuildContext context, int index) {
                    final Hadith hadith = items[index];
                    final bool isFavorite = favorites.contains(hadith.id);
                    return InkWell(
                      onTap: () =>
                          context.push(AppRoutes.hadithDetail(hadith.id)),
                      child: Padding(
                        padding: const EdgeInsets.all(AppSpacing.lg),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              hadith.shortTurkish,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                height: 1.55,
                              ),
                            ),
                            const SizedBox(height: AppSpacing.sm),
                            Row(
                              children: <Widget>[
                                Icon(
                                  Icons.verified_outlined,
                                  size: 14,
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                                const SizedBox(width: AppSpacing.xs),
                                Expanded(
                                  child: Text(
                                    '${hadith.primarySource} · ${hadith.reference}',
                                    style: theme.textTheme.labelSmall?.copyWith(
                                      color: theme.colorScheme.onSurfaceVariant,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                IconButton(
                                  visualDensity: VisualDensity.compact,
                                  tooltip: isFavorite
                                      ? 'Favoriden çıkar'
                                      : 'Favorilere ekle',
                                  onPressed: () async {
                                    await ref
                                        .read(runtimeProvider)
                                        .hadith
                                        .toggleFavorite(hadith.id);
                                    ref.invalidate(hadithFavoriteIdsProvider);
                                    ref.invalidate(hadithFavoritesProvider);
                                  },
                                  icon: Icon(
                                    isFavorite
                                        ? Icons.favorite_rounded
                                        : Icons.favorite_border_rounded,
                                    size: 19,
                                    color: isFavorite ? AppColors.danger : null,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          const AdBanner(),
        ],
      ),
    );
  }
}
