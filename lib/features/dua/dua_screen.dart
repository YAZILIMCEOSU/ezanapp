import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';

import '../../data/models/dua_models.dart';
import '../../design/app_colors.dart';
import '../../design/app_spacing.dart';
import '../../state/content_providers.dart';
import '../../state/providers.dart';
import '../widgets/ad_banner.dart';
import '../widgets/app_shell.dart';
import '../widgets/state_views.dart';

/// Dualar ekranı: kategoriler, arama, favoriler ve kaynak künyesi.
///
/// Her duada kaynak **her zaman** gösterilir; kopyalama ve paylaşımda da
/// künye metne dahil edilir.
class DuaScreen extends ConsumerStatefulWidget {
  const DuaScreen({super.key});

  @override
  ConsumerState<DuaScreen> createState() => _DuaScreenState();
}

class _DuaScreenState extends ConsumerState<DuaScreen> {
  static const String _allCategory = '__all__';

  final TextEditingController _search = TextEditingController();
  Timer? _debounce;
  String _category = _allCategory;
  String _query = '';
  bool _onlyFavorites = false;

  @override
  void dispose() {
    _debounce?.cancel();
    _search.dispose();
    super.dispose();
  }

  void _onQueryChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 250), () {
      if (mounted) setState(() => _query = value);
    });
  }

  @override
  Widget build(BuildContext context) {
    final AsyncValue<DuaCatalog> catalog = ref.watch(duaCatalogProvider);
    final Set<String> favorites =
        ref.watch(duaFavoriteKeysProvider).value ?? const <String>{};
    final ThemeData theme = Theme.of(context);

    return Scaffold(
      appBar: AppBarHeader(
        title: 'Dualar',
        subtitle: catalog.maybeWhen(
          data: (DuaCatalog value) =>
              '${value.dualar.length} dua · kaynak künyeli',
          orElse: () => 'Kaynak künyeli dua seçkisi',
        ),
        actions: <Widget>[
          IconButton(
            tooltip: _onlyFavorites ? 'Tüm dualar' : 'Yalnızca favoriler',
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
                hintText: 'Dua adı, okunuşu veya anlamında ara',
                prefixIcon: const Icon(Icons.search_rounded, size: 20),
                suffixIcon: _search.text.isEmpty
                    ? null
                    : IconButton(
                        onPressed: () {
                          _search.clear();
                          setState(() => _query = '');
                        },
                        icon: const Icon(Icons.close_rounded, size: 18),
                      ),
              ),
            ),
          ),
          if (!_onlyFavorites)
            SizedBox(
              height: 38,
              child: catalog.maybeWhen(
                data: (DuaCatalog value) => ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.lg,
                  ),
                  children: <Widget>[
                    _CategoryChip(
                      label: 'Tümü',
                      count: value.dualar.length,
                      selected: _category == _allCategory,
                      onSelected: () =>
                          setState(() => _category = _allCategory),
                    ),
                    for (final DuaCategory category in value.categories)
                      _CategoryChip(
                        label: category.label,
                        count: value.byCategory(category.key).length,
                        selected: _category == category.key,
                        onSelected: () =>
                            setState(() => _category = category.key),
                      ),
                  ],
                ),
                orElse: () => const SizedBox.shrink(),
              ),
            ),
          const SizedBox(height: AppSpacing.sm),
          Expanded(
            child: catalog.when(
              loading: () => const LoadingView(message: 'Dualar yükleniyor…'),
              error: (Object error, StackTrace stackTrace) => ErrorView(
                error: error,
                onRetry: () {
                  ref.invalidate(duaCatalogProvider);
                  ref.invalidate(duaFavoriteKeysProvider);
                  ref.invalidate(duaFavoritesProvider);
                },
              ),
              data: (DuaCatalog value) {
                final List<Dua> items = _filter(value);
                if (items.isEmpty) {
                  return EmptyView(
                    icon: Icons.volunteer_activism_outlined,
                    title: _onlyFavorites
                        ? 'Favori dua yok'
                        : 'Sonuç bulunamadı',
                    message: _onlyFavorites
                        ? 'Beğendiğiniz duaları kalp simgesiyle favorilere ekleyebilirsiniz.'
                        : 'Farklı bir kelime veya kategori seçmeyi deneyin.',
                  );
                }
                return ListView.separated(
                  padding: const EdgeInsets.only(bottom: AppSpacing.lg),
                  itemCount: items.length,
                  separatorBuilder: (BuildContext context, int index) =>
                      const Divider(height: 1),
                  itemBuilder: (BuildContext context, int index) {
                    final Dua dua = items[index];
                    return _DuaCard(
                      dua: dua,
                      isFavorite: favorites.contains(dua.key),
                      categoryLabel: _labelFor(value, dua.category),
                      onToggleFavorite: () async {
                        await ref
                            .read(runtimeProvider)
                            .zikir
                            .toggleDuaFavorite(dua.key);
                        ref.invalidate(duaFavoriteKeysProvider);
                        ref.invalidate(duaFavoritesProvider);
                        if (!context.mounted) return;
                        final bool nowFavorite =
                            ref
                                .read(duaFavoriteKeysProvider)
                                .value
                                ?.contains(dua.key) ??
                            false;
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            duration: const Duration(seconds: 2),
                            content: Text(
                              nowFavorite
                                  ? '${dua.name} favorilere eklendi.'
                                  : '${dua.name} favorilerden çıkarıldı.',
                            ),
                          ),
                        );
                      },
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

  List<Dua> _filter(DuaCatalog catalog) {
    final bool searching = _query.trim().isNotEmpty;
    List<Dua> items = searching
        ? catalog.search(_query)
        : (_category == _allCategory
              ? catalog.dualar
              : catalog.byCategory(_category));

    if (_onlyFavorites) {
      final Set<String> favorites =
          ref.read(duaFavoriteKeysProvider).value ?? const <String>{};
      items = items.where((Dua dua) => favorites.contains(dua.key)).toList();
    }
    return items;
  }

  String? _labelFor(DuaCatalog catalog, String key) {
    for (final DuaCategory category in catalog.categories) {
      if (category.key == key) return category.label;
    }
    return null;
  }
}

/// Kategori seçim çipi (dua sayısını da gösterir).
class _CategoryChip extends StatelessWidget {
  const _CategoryChip({
    required this.label,
    required this.count,
    required this.selected,
    required this.onSelected,
  });

  final String label;
  final int count;
  final bool selected;
  final VoidCallback onSelected;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: AppSpacing.sm),
      child: FilterChip(
        label: Text('$label ($count)'),
        selected: selected,
        onSelected: (_) => onSelected(),
      ),
    );
  }
}

/// Tek dua kartı: Arapça metin, okunuş, meal, künye, favori ve paylaşım.
class _DuaCard extends StatelessWidget {
  const _DuaCard({
    required this.dua,
    required this.isFavorite,
    required this.onToggleFavorite,
    this.categoryLabel,
  });

  final Dua dua;
  final bool isFavorite;
  final Future<void> Function() onToggleFavorite;
  final String? categoryLabel;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.lg,
        AppSpacing.lg,
        AppSpacing.md,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(
                child: Text(
                  dua.name,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              IconButton(
                visualDensity: VisualDensity.compact,
                tooltip: isFavorite ? 'Favoriden çıkar' : 'Favorilere ekle',
                onPressed: onToggleFavorite,
                icon: Icon(
                  isFavorite
                      ? Icons.favorite_rounded
                      : Icons.favorite_border_rounded,
                  size: 19,
                  color: isFavorite ? AppColors.danger : null,
                ),
              ),
              IconButton(
                visualDensity: VisualDensity.compact,
                tooltip: 'Kopyala',
                onPressed: () async {
                  await Clipboard.setData(ClipboardData(text: dua.shareText()));
                  if (!context.mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      duration: Duration(seconds: 2),
                      content: Text('Dua panoya kopyalandı (kaynağıyla).'),
                    ),
                  );
                },
                icon: const Icon(Icons.copy_rounded, size: 18),
              ),
              IconButton(
                visualDensity: VisualDensity.compact,
                tooltip: 'Paylaş',
                onPressed: () => SharePlus.instance.share(
                  ShareParams(text: dua.shareText()),
                ),
                icon: const Icon(Icons.ios_share_rounded, size: 18),
              ),
            ],
          ),
          if (categoryLabel != null || dua.time != null) ...<Widget>[
            const SizedBox(height: AppSpacing.xs),
            Wrap(
              spacing: AppSpacing.sm,
              children: <Widget>[
                if (categoryLabel != null)
                  _MetaChip(
                    icon: Icons.label_outline_rounded,
                    text: categoryLabel!,
                  ),
                if (dua.time != null)
                  _MetaChip(
                    icon: Icons.schedule_rounded,
                    text: dua.time!,
                  ),
              ],
            ),
          ],
          if (dua.hasArabic) ...<Widget>[
            const SizedBox(height: AppSpacing.md),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: AppColors.emerald500.withValues(alpha: 0.08),
                borderRadius: AppRadius.allMd,
              ),
              child: Text(
                dua.arabic,
                textAlign: TextAlign.right,
                textDirection: TextDirection.rtl,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontFamily: 'Amiri',
                  height: 1.9,
                ),
              ),
            ),
          ],
          if (dua.transliteration.isNotEmpty) ...<Widget>[
            const SizedBox(height: AppSpacing.md),
            Text(
              dua.transliteration,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontStyle: FontStyle.italic,
                height: 1.55,
              ),
            ),
          ],
          if (dua.meaning.isNotEmpty) ...<Widget>[
            const SizedBox(height: AppSpacing.sm),
            Text(
              dua.meaning,
              style: theme.textTheme.bodyMedium?.copyWith(height: 1.6),
            ),
          ],
          const SizedBox(height: AppSpacing.md),
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
                  dua.reference,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MetaChip extends StatelessWidget {
  const _MetaChip({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Icon(icon, size: 12, color: theme.colorScheme.onSurfaceVariant),
        const SizedBox(width: 4),
        Text(
          text,
          style: theme.textTheme.labelSmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}
