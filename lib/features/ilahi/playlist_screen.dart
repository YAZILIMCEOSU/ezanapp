import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../data/models/ilahi_models.dart';
import '../../design/app_colors.dart';
import '../../design/app_spacing.dart';
import '../../router/app_router.dart';
import '../../state/content_providers.dart';
import '../../state/providers.dart';
import '../widgets/app_shell.dart';
import '../widgets/state_views.dart';
import 'player_controller.dart';

/// Çalma listeleri: liste oluşturma, parça ekleme/çıkarma ve oynatma.
///
/// [playlistId] verilmişse doğrudan o listenin içeriği gösterilir.
class PlaylistScreen extends ConsumerWidget {
  const PlaylistScreen({this.playlistId, super.key});

  final int? playlistId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return playlistId == null
        ? const _PlaylistIndex()
        : _PlaylistDetail(playlistId: playlistId!);
  }
}

class _PlaylistIndex extends ConsumerWidget {
  const _PlaylistIndex();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<List<Playlist>> playlists = ref.watch(playlistsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Çalma listeleri'),
        actions: <Widget>[
          IconButton(
            tooltip: 'Yeni liste',
            onPressed: () => _create(context, ref),
            icon: const Icon(Icons.add_rounded, size: 22),
          ),
        ],
      ),
      bottomNavigationBar: const PlayerBar(),
      body: playlists.when(
        loading: () => const LoadingView(message: 'Listeler yükleniyor…'),
        error: (Object error, StackTrace stackTrace) =>
            ErrorView(error: error, onRetry: () => ref.invalidate(playlistsProvider)),
        data: (List<Playlist> items) {
          if (items.isEmpty) {
            return const EmptyView(
              icon: Icons.queue_music_rounded,
              title: 'Çalma listeniz yok',
              message: 'İlahi ekranındaki menüden yeni bir liste oluşturup parça '
                  'ekleyebilirsiniz.',
            );
          }
          return ListView.separated(
            itemCount: items.length,
            separatorBuilder: (BuildContext context, int index) => const Divider(height: 1),
            itemBuilder: (BuildContext context, int index) {
              final Playlist playlist = items[index];
              return ListTile(
                leading: const Icon(Icons.queue_music_rounded),
                title: Text(playlist.name),
                subtitle: Text('${playlist.trackIds.length} parça'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    IconButton(
                      tooltip: 'Çal',
                      onPressed: playlist.trackIds.isEmpty
                          ? null
                          : () => _play(ref, playlist.id),
                      icon: const Icon(
                        Icons.play_circle_fill_rounded,
                        color: AppColors.emerald500,
                        size: 26,
                      ),
                    ),
                    IconButton(
                      tooltip: 'Sil',
                      onPressed: () => _delete(context, ref, playlist),
                      icon: const Icon(Icons.delete_outline_rounded, size: 20),
                    ),
                  ],
                ),
                onTap: () => context.push(AppRoutes.playlist(playlist.id)),
              );
            },
          );
        },
      ),
    );
  }

  Future<void> _create(BuildContext context, WidgetRef ref) async {
    final TextEditingController controller = TextEditingController();
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) => AlertDialog(
        title: const Text('Yeni çalma listesi'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(hintText: 'Liste adı (ör. Ramazan geceleri)'),
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Vazgeç'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Oluştur'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    final String name = controller.text.trim();
    if (name.isEmpty) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Liste adı boş olamaz.')),
        );
      }
      return;
    }
    await ref.read(runtimeProvider).ilahi.createPlaylist(name);
    ref.invalidate(playlistsProvider);
  }

  Future<void> _delete(BuildContext context, WidgetRef ref, Playlist playlist) async {
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) => AlertDialog(
        title: Text('"${playlist.name}" silinsin mi?'),
        content: const Text('Liste silinir; indirilen ses dosyaları cihazda kalır.'),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Vazgeç'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.danger),
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Sil'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    await ref.read(runtimeProvider).ilahi.deletePlaylist(playlist.id);
    ref.invalidate(playlistsProvider);
  }

  Future<void> _play(WidgetRef ref, int playlistId) async {
    final List<IlahiTrack> tracks =
        await ref.read(playlistTracksProvider(playlistId).future);
    if (tracks.isEmpty) return;
    await ref.read(playerControllerProvider.notifier).playQueue(tracks);
  }
}

class _PlaylistDetail extends ConsumerWidget {
  const _PlaylistDetail({required this.playlistId});

  final int playlistId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<List<IlahiTrack>> tracks = ref.watch(playlistTracksProvider(playlistId));
    final List<Playlist> playlists = ref.watch(playlistsProvider).value ?? const <Playlist>[];
    Playlist? playlist;
    for (final Playlist item in playlists) {
      if (item.id == playlistId) playlist = item;
    }
    final PlayerUiState player = ref.watch(playerControllerProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(playlist?.name ?? 'Çalma listesi'),
        actions: <Widget>[
          IconButton(
            tooltip: 'Parça ekle',
            onPressed: () => _addTracks(context, ref),
            icon: const Icon(Icons.add_rounded, size: 22),
          ),
        ],
      ),
      bottomNavigationBar: const PlayerBar(),
      body: tracks.when(
        loading: () => const LoadingView(message: 'Liste yükleniyor…'),
        error: (Object error, StackTrace stackTrace) => ErrorView(
          error: error,
          onRetry: () => ref.invalidate(playlistTracksProvider(playlistId)),
        ),
        data: (List<IlahiTrack> items) {
          if (items.isEmpty) {
            return const EmptyView(
              icon: Icons.playlist_add_rounded,
              title: 'Liste boş',
              message: 'Sağ üstteki + düğmesiyle katalogdan parça ekleyebilirsiniz.',
            );
          }
          return Column(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Row(
                  children: <Widget>[
                    Expanded(
                      child: FilledButton.icon(
                        onPressed: () => ref
                            .read(playerControllerProvider.notifier)
                            .playQueue(items),
                        icon: const Icon(Icons.play_arrow_rounded),
                        label: Text('Tümünü çal (${items.length})'),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView.separated(
                  itemCount: items.length,
                  separatorBuilder: (BuildContext context, int index) =>
                      const Divider(height: 1),
                  itemBuilder: (BuildContext context, int index) {
                    final IlahiTrack track = items[index];
                    final bool current = player.currentTrackId == track.id;
                    return ListTile(
                      leading: Icon(
                        current && player.playing
                            ? Icons.graphic_eq_rounded
                            : Icons.music_note_rounded,
                        color: current ? AppColors.emerald500 : null,
                      ),
                      title: Text(track.title, maxLines: 1, overflow: TextOverflow.ellipsis),
                      subtitle: Text(
                        track.artist,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          IconButton(
                            tooltip: 'Çal',
                            onPressed: () => ref
                                .read(playerControllerProvider.notifier)
                                .playQueue(items, startIndex: index),
                            icon: const Icon(Icons.play_circle_outline_rounded, size: 22),
                          ),
                          IconButton(
                            tooltip: 'Listeden çıkar',
                            onPressed: () async {
                              await ref
                                  .read(runtimeProvider)
                                  .ilahi
                                  .removeFromPlaylist(playlistId, track.id);
                              ref.invalidate(playlistTracksProvider(playlistId));
                              ref.invalidate(playlistsProvider);
                            },
                            icon: const Icon(Icons.remove_circle_outline_rounded, size: 20),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _addTracks(BuildContext context, WidgetRef ref) async {
    final List<IlahiTrack> catalog =
        ref.read(ilahiCatalogProvider).value ?? const <IlahiTrack>[];
    if (catalog.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Katalog boş. Önce içerik yüklenmeli.')),
      );
      return;
    }

    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (BuildContext sheetContext) => StatefulBuilder(
        builder: (BuildContext context, StateSetter setSheetState) {
          final Set<String> selected = <String>{
            for (final IlahiTrack track
                in ref.watch(playlistTracksProvider(playlistId)).value ??
                    const <IlahiTrack>[])
              track.id,
          };
          return SizedBox(
            height: MediaQuery.of(sheetContext).size.height * 0.75,
            child: Column(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
                  child: Row(
                    children: <Widget>[
                      Text(
                        'Parça ekle',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const Spacer(),
                      Text('${selected.length} seçili'),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Expanded(
                  child: ListView(
                    children: <Widget>[
                      for (final IlahiTrack track in catalog)
                        CheckboxListTile(
                          value: selected.contains(track.id),
                          title: Text(
                            track.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          subtitle: Text(track.artist),
                          onChanged: (bool? checked) async {
                            if (checked == true) {
                              await ref
                                  .read(runtimeProvider)
                                  .ilahi
                                  .addToPlaylist(playlistId, track.id);
                            } else {
                              await ref
                                  .read(runtimeProvider)
                                  .ilahi
                                  .removeFromPlaylist(playlistId, track.id);
                            }
                            ref.invalidate(playlistTracksProvider(playlistId));
                            ref.invalidate(playlistsProvider);
                            setSheetState(() {});
                          },
                        ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
