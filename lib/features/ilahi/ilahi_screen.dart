import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/utils/app_time.dart';
import '../../data/models/ilahi_models.dart';
import '../../design/app_colors.dart';
import '../../design/app_spacing.dart';
import '../../router/app_router.dart';
import '../../state/content_providers.dart';
import '../../state/providers.dart';
import '../widgets/ad_banner.dart';
import '../widgets/app_shell.dart';
import '../widgets/state_views.dart';
import 'player_controller.dart';

/// İlahi/dini ses ana ekranı: telifsiz katalog, isteğe bağlı indirme/yükleme, arama ve çalma listeleri.
class IlahiScreen extends ConsumerStatefulWidget {
  const IlahiScreen({super.key});

  @override
  ConsumerState<IlahiScreen> createState() => _IlahiScreenState();
}

class _IlahiScreenState extends ConsumerState<IlahiScreen> {
  String _query = '';
  String? _category;
  final Set<String> _downloadingIds = <String>{};

  @override
  Widget build(BuildContext context) {
    final AsyncValue<List<IlahiTrack>> catalog = ref.watch(
      ilahiCatalogProvider,
    );
    final Set<String> favorites =
        ref.watch(ilahiFavoriteIdsProvider).value ?? const <String>{};
    final String? playingId = ref
        .watch(playerControllerProvider)
        .currentTrackId;
    final bool playing = ref.watch(playerControllerProvider).playing;

    return Scaffold(
      appBar: AppBarHeader(
        title: 'İlahi ve Dini Sesler',
        subtitle: 'Telifsiz makamlar ve indirilebilir içerikler',
        actions: <Widget>[
          IconButton(
            tooltip: 'Cihazdan ses dosyası yükle',
            onPressed: () => _importLocalFile(context),
            icon: const Icon(Icons.upload_file_rounded, size: 20),
          ),
          IconButton(
            tooltip: 'Çalma listeleri',
            onPressed: () => context.push(AppRoutes.ilahiPlaylists),
            icon: const Icon(Icons.queue_music_rounded, size: 20),
          ),
          IconButton(
            tooltip: 'İndirilenler ve içe aktarım',
            onPressed: () => context.push(AppRoutes.ilahiDownloads),
            icon: const Icon(Icons.download_done_rounded, size: 20),
          ),
        ],
      ),
      bottomNavigationBar: const PlayerBar(),
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
              onChanged: (String value) => setState(() => _query = value),
              decoration: const InputDecoration(
                hintText: 'İlahi, makam, sure veya sanatçı ara',
                prefixIcon: Icon(Icons.search_rounded, size: 20),
              ),
            ),
          ),
          SizedBox(
            height: 40,
            child: ref
                .watch(ilahiFacetsProvider)
                .maybeWhen(
                  data:
                      (
                        ({List<String> categories, List<String> artists})
                        facets,
                      ) => ListView(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.lg,
                        ),
                        children: <Widget>[
                          FilterChip(
                            label: const Text('Tümü'),
                            selected: _category == null,
                            onSelected: (_) => setState(() => _category = null),
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          for (final String category
                              in facets.categories) ...<Widget>[
                            FilterChip(
                              label: Text(category),
                              selected: _category == category,
                              onSelected: (bool selected) => setState(
                                () => _category = selected ? category : null,
                              ),
                            ),
                            const SizedBox(width: AppSpacing.sm),
                          ],
                        ],
                      ),
                  orElse: () => const SizedBox.shrink(),
                ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Expanded(
            child: catalog.when(
              loading: () => const LoadingView(message: 'Katalog yükleniyor…'),
              error: (Object error, StackTrace stackTrace) => ErrorView(
                error: error,
                onRetry: () => ref.invalidate(ilahiCatalogProvider),
              ),
              data: (List<IlahiTrack> tracks) {
                final List<IlahiTrack> filtered = tracks.where((
                  IlahiTrack track,
                ) {
                  final bool matchesQuery =
                      _query.trim().isEmpty ||
                      track.title.toLowerCase().contains(
                        _query.toLowerCase(),
                      ) ||
                      track.artist.toLowerCase().contains(
                        _query.toLowerCase(),
                      ) ||
                      (track.album ?? '').toLowerCase().contains(
                        _query.toLowerCase(),
                      );
                  final bool matchesCategory =
                      _category == null || track.categories.contains(_category);
                  return matchesQuery && matchesCategory;
                }).toList();

                if (filtered.isEmpty) {
                  return EmptyView(
                    icon: Icons.library_music_outlined,
                    title: tracks.isEmpty
                        ? 'Katalog henüz boş'
                        : 'Sonuç bulunamadı',
                    message: tracks.isEmpty
                        ? 'Yayınlanan içerik kataloğu şu anda boş. Kendi ses dosyalarınızı '
                              '"İndirilenler" ekranından içe aktarabilir, çevrimdışı dinleyebilirsiniz.'
                        : 'Arama ve kategori filtrelerini değiştirmeyi deneyin.',
                  );
                }

                return ListView.separated(
                  padding: const EdgeInsets.only(bottom: AppSpacing.lg),
                  itemCount: filtered.length,
                  separatorBuilder: (BuildContext context, int index) =>
                      const Divider(height: 1),
                  itemBuilder: (BuildContext context, int index) {
                    final IlahiTrack track = filtered[index];
                    final bool isFavorite = favorites.contains(track.id);
                    final bool isCurrent = playingId == track.id;
                    final bool isDownloading = _downloadingIds.contains(
                      track.id,
                    );
                    final bool isOfflineReady =
                        track.isLocal ||
                        (track.localPath != null &&
                            track.localPath!.isNotEmpty);

                    return ListTile(
                      leading: CircleAvatar(
                        backgroundColor: isCurrent
                            ? AppColors.emerald500
                            : Theme.of(context)
                                  .colorScheme
                                  .surfaceContainerHighest,
                        child: Icon(
                          isCurrent && playing
                              ? Icons.graphic_eq_rounded
                              : Icons.music_note_rounded,
                          size: 20,
                          color: isCurrent ? Colors.white : null,
                        ),
                      ),
                      title: Text(
                        track.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      subtitle: Text(
                        <String>[
                          if (track.artist.isNotEmpty) track.artist,
                          if (track.durationSeconds > 0)
                            AppTime.formatClock(
                              Duration(seconds: track.durationSeconds),
                            ),
                          if (isOfflineReady)
                            'çevrimdışı yüklü'
                          else if (track.audioUrl.startsWith('asset:'))
                            'telifsiz dahili'
                          else
                            'indirilebilir',
                        ].join(' · '),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          if (isDownloading)
                            const Padding(
                              padding: EdgeInsets.symmetric(
                                horizontal: AppSpacing.sm,
                              ),
                              child: SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              ),
                            )
                          else
                            IconButton(
                              visualDensity: VisualDensity.compact,
                              tooltip: isOfflineReady
                                  ? 'Cihaza yüklendi (çevrimdışı hazır)'
                                  : 'Cihaza yükle / indir',
                              onPressed: isOfflineReady
                                  ? null
                                  : () => _downloadTrack(context, track),
                              icon: Icon(
                                isOfflineReady
                                    ? Icons.download_done_rounded
                                    : Icons.download_for_offline_outlined,
                                size: 20,
                                color: isOfflineReady
                                    ? AppColors.success
                                    : null,
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
                                  .ilahi
                                  .toggleFavorite(track.id);
                              ref.invalidate(ilahiFavoriteIdsProvider);
                            },
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
                            tooltip: 'Çal',
                            onPressed: () => _play(track, filtered),
                            icon: Icon(
                              isCurrent && playing
                                  ? Icons.pause_circle_filled_rounded
                                  : Icons.play_circle_fill_rounded,
                              size: 26,
                              color: AppColors.emerald500,
                            ),
                          ),
                        ],
                      ),
                      onTap: () => context.push(AppRoutes.player),
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

  Future<void> _downloadTrack(BuildContext context, IlahiTrack track) async {
    setState(() => _downloadingIds.add(track.id));
    final String? path = await ref.read(runtimeProvider).ilahi.download(track);
    if (!mounted) return;
    setState(() => _downloadingIds.remove(track.id));
    ref.invalidate(ilahiCatalogProvider);
    ref.invalidate(ilahiDownloadsProvider);
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            path != null
                ? '${track.title} çevrimdışı dinleme için cihaza yüklendi.'
                : 'İndirme tamamlanamadı; internet bağlantınızı kontrol edin.',
          ),
        ),
      );
    }
  }

  Future<void> _importLocalFile(BuildContext context) async {
    const XTypeGroup audioGroup = XTypeGroup(
      label: 'Ses dosyaları',
      extensions: <String>['mp3', 'wav', 'm4a', 'aac', 'ogg', 'flac'],
    );
    final XFile? file = await openFile(
      acceptedTypeGroups: <XTypeGroup>[audioGroup],
    );
    if (file == null) return;
    final IlahiTrack? added = await ref
        .read(runtimeProvider)
        .ilahi
        .importLocalFile(file.path);
    ref.invalidate(ilahiLocalProvider);
    ref.invalidate(ilahiCatalogProvider);
    ref.invalidate(ilahiFacetsProvider);
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          added != null
              ? '${added.title} listeye eklendi.'
              : 'Dosya içe aktarılamadı.',
        ),
      ),
    );
  }

  Future<void> _play(IlahiTrack track, List<IlahiTrack> queue) async {
    final controller = ref.read(playerControllerProvider.notifier);
    if (ref.read(playerControllerProvider).currentTrackId == track.id &&
        ref.read(playerControllerProvider).playing) {
      await controller.pause();
      return;
    }
    await controller.playTrack(track, queue: queue);
    await ref.read(runtimeProvider).ilahi.markPlayed(track.id);
    if (mounted && ref.read(playerControllerProvider).error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(ref.read(playerControllerProvider).error!)),
      );
    }
  }
}
