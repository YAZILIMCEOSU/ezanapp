import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/utils/app_time.dart';
import '../../core/utils/logger.dart';
import '../../data/models/ilahi_models.dart';
import '../../design/app_colors.dart';
import '../../design/app_spacing.dart';
import '../../state/content_providers.dart';
import '../../state/providers.dart';
import '../widgets/app_shell.dart';
import '../widgets/state_views.dart';
import 'player_controller.dart';

/// İndirilen ve cihaza aktarılan sesler — çevrimdışı dinleme.
class DownloadsScreen extends ConsumerWidget {
  const DownloadsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<List<IlahiTrack>> downloads = ref.watch(ilahiDownloadsProvider);
    final AsyncValue<List<IlahiTrack>> local = ref.watch(ilahiLocalProvider);
    final AsyncValue<List<IlahiTrack>> catalog = ref.watch(ilahiCatalogProvider);
    final PlayerUiState player = ref.watch(playerControllerProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('İndirilenler')),
      bottomNavigationBar: const PlayerBar(),
      body: ListView(
        padding: const EdgeInsets.only(bottom: AppSpacing.xxl),
        children: <Widget>[
          const SectionHeader(title: 'İndirilen ilahiler'),
          downloads.when(
            loading: () => const Padding(
              padding: EdgeInsets.all(AppSpacing.xl),
              child: LoadingView(message: 'İndirilenler okunuyor…'),
            ),
            error: (Object error, StackTrace stackTrace) => ErrorView(
              error: error,
              onRetry: () => ref.invalidate(ilahiDownloadsProvider),
            ),
            data: (List<IlahiTrack> items) {
              if (items.isEmpty) {
                return const EmptyView(
                  icon: Icons.download_outlined,
                  title: 'İndirilmiş ilahi yok',
                  message: 'Katalogdaki bir parçayı indirerek internet olmadan '
                      'dinleyebilirsiniz.',
                );
              }
              return Column(
                children: <Widget>[
                  for (final IlahiTrack track in items)
                    ListTile(
                      leading: Icon(
                        player.currentTrackId == track.id && player.playing
                            ? Icons.graphic_eq_rounded
                            : Icons.download_done_rounded,
                        color: AppColors.emerald500,
                      ),
                      title: Text(track.title, maxLines: 1, overflow: TextOverflow.ellipsis),
                      subtitle: Text('${track.artist} · çevrimdışı hazır'),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          IconButton(
                            tooltip: 'Çal',
                            onPressed: () => ref
                                .read(playerControllerProvider.notifier)
                                .playQueue(items, startIndex: items.indexOf(track)),
                            icon: const Icon(Icons.play_circle_fill_rounded, size: 26),
                          ),
                          IconButton(
                            tooltip: 'İndirmeyi sil',
                            onPressed: () async {
                              await ref
                                  .read(runtimeProvider)
                                  .ilahi
                                  .deleteDownload(track.id);
                              ref.invalidate(ilahiDownloadsProvider);
                              ref.invalidate(ilahiCatalogProvider);
                            },
                            icon: const Icon(Icons.delete_outline_rounded, size: 20),
                          ),
                        ],
                      ),
                    ),
                ],
              );
            },
          ),
          const SectionHeader(title: 'Katalogdan indir'),
          catalog.when(
            loading: () => const Padding(
              padding: EdgeInsets.all(AppSpacing.xl),
              child: LoadingView(message: 'Katalog yükleniyor…'),
            ),
            error: (Object error, StackTrace stackTrace) => ErrorView(
              error: error,
              onRetry: () => ref.invalidate(ilahiCatalogProvider),
            ),
            data: (List<IlahiTrack> items) {
              final Set<String> downloaded = (downloads.value ?? const <IlahiTrack>[])
                  .map((IlahiTrack track) => track.id)
                  .toSet();
              if (items.isEmpty) {
                return const Padding(
                  padding: EdgeInsets.symmetric(horizontal: AppSpacing.xl),
                  child: Text(
                    'Yayınlanmış katalog bulunmuyor. Cihazınızdaki ses dosyalarını '
                    'aşağıdan içe aktarabilirsiniz.',
                  ),
                );
              }
              return Column(
                children: <Widget>[
                  for (final IlahiTrack track in items)
                    ListTile(
                      leading: const Icon(Icons.cloud_download_outlined),
                      title: Text(track.title, maxLines: 1, overflow: TextOverflow.ellipsis),
                      subtitle: Text(
                        track.audioUrl.isEmpty
                            ? '${track.artist} · ses bağlantısı yok'
                            : '${track.artist} · ${track.license.isEmpty ? 'lisans bilgisi yok' : track.license}',
                      ),
                      trailing: downloaded.contains(track.id)
                          ? const Text('İndirildi')
                          : IconButton(
                              tooltip: 'İndir',
                              onPressed: track.audioUrl.isEmpty
                                  ? null
                                  : () => _download(context, ref, track),
                              icon: const Icon(Icons.download_rounded),
                            ),
                    ),
                ],
              );
            },
          ),
          const SectionHeader(title: 'Cihazdan aktarılan sesler'),
          ListTile(
            leading: const Icon(Icons.folder_open_rounded),
            title: const Text('Ses dosyası içe aktar'),
            subtitle: const Text(
              'Lisansı size ait olan ilahi/dini ses dosyalarını (mp3, m4a, wav) uygulamaya ekleyin',
            ),
            onTap: () => _importFile(context, ref),
          ),
          local.when(
            loading: () => const SizedBox.shrink(),
            error: (Object error, StackTrace stackTrace) => ErrorView(
              error: error,
              onRetry: () => ref.invalidate(ilahiLocalProvider),
            ),
            data: (List<IlahiTrack> items) => Column(
              children: <Widget>[
                for (final IlahiTrack track in items)
                  ListTile(
                    leading: const Icon(Icons.audiotrack_rounded),
                    title: Text(track.title, maxLines: 1, overflow: TextOverflow.ellipsis),
                    subtitle: const Text('Cihazda · çevrimdışı'),
                    trailing: IconButton(
                      tooltip: 'Kaldır',
                      onPressed: () async {
                        await ref
                            .read(runtimeProvider)
                            .ilahi
                            .deleteLocalTrack(track.id);
                        ref.invalidate(ilahiLocalProvider);
                      },
                      icon: const Icon(Icons.delete_outline_rounded, size: 20),
                    ),
                    onTap: () => ref
                        .read(playerControllerProvider.notifier)
                        .playTrack(track, queue: items),
                  ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(AppSpacing.xl),
            child: Text(
              'İndirilen sesler cihazın uygulama klasöründe saklanır. Telif hakkı '
              'bulunan içerikleri yalnızca hak sahibi olduğunuz durumlarda içe aktarın.',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(height: 1.5),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _download(BuildContext context, WidgetRef ref, IlahiTrack track) async {
    if (ref.read(settingsProvider).streamingOnlyOnWifi) {
      final bool online = ref.read(isOnlineProvider);
      if (!online) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Çevrimdışısınız. İnternet bağlantısı kurulduğunda indirin.'),
          ),
        );
        return;
      }
    }
    final ScaffoldMessengerState messenger = ScaffoldMessenger.of(context);
    messenger.showSnackBar(
      SnackBar(content: Text('${track.title} indiriliyor…')),
    );
    try {
      final String? path = await ref.read(runtimeProvider).ilahi.download(track);
      if (path == null) {
        messenger.showSnackBar(
          const SnackBar(
            content: Text('İndirme tamamlanamadı. Bağlantınızı kontrol edin.'),
          ),
        );
        return;
      }
      ref.invalidate(ilahiDownloadsProvider);
      ref.invalidate(ilahiCatalogProvider);
      messenger.showSnackBar(
        SnackBar(content: Text('${track.title} çevrimdışı dinlemeye hazır.')),
      );
    } catch (error) {
      AppLog.warning('İndirme hatası: $error');
      messenger.showSnackBar(
        const SnackBar(content: Text('İndirme sırasında bir sorun oluştu.')),
      );
    }
  }

  Future<void> _importFile(BuildContext context, WidgetRef ref) async {
    const XTypeGroup audioGroup = XTypeGroup(
      label: 'Ses dosyaları',
      extensions: <String>['mp3', 'm4a', 'aac', 'wav', 'ogg', 'opus', 'flac'],
    );
    try {
      final XFile? file = await openFile(acceptedTypeGroups: <XTypeGroup>[audioGroup]);
      if (file == null) return;
      final IlahiTrack? imported =
          await ref.read(runtimeProvider).ilahi.importLocalFile(file.path);
      ref.invalidate(ilahiLocalProvider);
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            imported == null
                ? 'Dosya eklenemedi. Farklı bir dosya deneyin.'
                : '${imported.title} cihaz kütüphanenize eklendi.',
          ),
        ),
      );
    } catch (error, stackTrace) {
      AppLog.error('Dosya içe aktarılamadı', error: error, stackTrace: stackTrace);
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Dosya seçici açılamadı. Cihazınızda bir dosya yöneticisi '
              'kurulu olduğundan emin olun.'),
        ),
      );
    }
  }
}
