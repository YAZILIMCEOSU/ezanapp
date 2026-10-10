import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/utils/app_time.dart';
import '../../data/models/ilahi_models.dart';
import '../../design/app_colors.dart';
import '../../design/app_spacing.dart';
import 'player_controller.dart';

/// Tam ekran oynatıcı: kuyruk, konum, ses ve hız kontrolleri.
class PlayerScreen extends ConsumerWidget {
  const PlayerScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final PlayerUiState player = ref.watch(playerControllerProvider);
    final PlayerController controller = ref.read(
      playerControllerProvider.notifier,
    );
    final ThemeData theme = Theme.of(context);

    if (player.track == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Oynatıcı')),
        body: const Center(
          child: Padding(
            padding: EdgeInsets.all(AppSpacing.xxl),
            child: Text(
              'Şu anda çalan bir içerik yok. İlahi veya Kur\'an ekranından bir parça seçin.',
              textAlign: TextAlign.center,
            ),
          ),
        ),
      );
    }

    final IlahiTrack track = player.track!;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Şimdi çalıyor'),
        actions: <Widget>[
          IconButton(
            tooltip: player.offlineMode ? 'Çevrimdışı' : 'Akış',
            onPressed: null,
            icon: Icon(
              player.offlineMode
                  ? Icons.download_done_rounded
                  : Icons.cloud_outlined,
              size: 18,
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: <Widget>[
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(AppSpacing.xl),
                child: Column(
                  children: <Widget>[
                    Container(
                      width: 200,
                      height: 200,
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: AppColors.emeraldGradient,
                        ),
                        borderRadius: AppRadius.allLg,
                      ),
                      child: Icon(
                        player.playing
                            ? Icons.graphic_eq_rounded
                            : Icons.music_note_rounded,
                        size: 72,
                        color: Colors.white.withValues(alpha: 0.9),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    Text(
                      track.title,
                      textAlign: TextAlign.center,
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      track.artist,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    if (track.album != null && track.album!.isNotEmpty)
                      Text(
                        track.album!,
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    const SizedBox(height: AppSpacing.lg),
                    if (track.license.isNotEmpty)
                      Chip(
                        visualDensity: VisualDensity.compact,
                        avatar: const Icon(Icons.verified_outlined, size: 16),
                        label: Text(
                          'Lisans: ${track.license}',
                          style: theme.textTheme.labelSmall,
                        ),
                      ),
                    const SizedBox(height: AppSpacing.lg),
                    Slider(
                      value: player.progress.clamp(0.0, 1.0),
                      onChanged: (double value) =>
                          controller.seekToFraction(value),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.md,
                      ),
                      child: Row(
                        children: <Widget>[
                          Text(
                            AppTime.formatClock(player.position),
                            style: theme.textTheme.labelSmall,
                          ),
                          const Spacer(),
                          Text(
                            player.duration.inMilliseconds > 0
                                ? AppTime.formatClock(player.duration)
                                : '—',
                            style: theme.textTheme.labelSmall,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        IconButton(
                          tooltip: 'Tekrar',
                          onPressed: controller.toggleRepeat,
                          icon: Icon(
                            Icons.repeat_one_rounded,
                            color: player.repeatOne
                                ? AppColors.emerald500
                                : null,
                          ),
                        ),
                        IconButton(
                          iconSize: 36,
                          tooltip: 'Önceki',
                          onPressed: controller.previous,
                          icon: const Icon(Icons.skip_previous_rounded),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Container(
                          decoration: const BoxDecoration(
                            color: AppColors.emerald500,
                            shape: BoxShape.circle,
                          ),
                          child: IconButton(
                            iconSize: 42,
                            tooltip: player.playing ? 'Duraklat' : 'Çal',
                            onPressed: controller.togglePlayPause,
                            icon: Icon(
                              player.buffering
                                  ? Icons.hourglass_top_rounded
                                  : player.playing
                                  ? Icons.pause_rounded
                                  : Icons.play_arrow_rounded,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        IconButton(
                          iconSize: 36,
                          tooltip: 'Sonraki',
                          onPressed: player.hasNext ? controller.next : null,
                          icon: const Icon(Icons.skip_next_rounded),
                        ),
                        IconButton(
                          tooltip: 'Listeyi kapat',
                          onPressed: controller.stop,
                          icon: const Icon(Icons.stop_circle_outlined),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Row(
                      children: <Widget>[
                        const Icon(Icons.volume_down_rounded, size: 18),
                        Expanded(
                          child: Slider(
                            value: player.volume.clamp(0.0, 1.0),
                            divisions: 10,
                            onChanged: controller.setVolume,
                          ),
                        ),
                        const Icon(Icons.volume_up_rounded, size: 18),
                      ],
                    ),
                    if (player.error != null)
                      Container(
                        margin: const EdgeInsets.only(top: AppSpacing.md),
                        padding: const EdgeInsets.all(AppSpacing.md),
                        decoration: BoxDecoration(
                          color: AppColors.warning.withValues(alpha: 0.12),
                          borderRadius: AppRadius.allMd,
                        ),
                        child: Row(
                          children: <Widget>[
                            const Icon(
                              Icons.warning_amber_rounded,
                              size: 18,
                              color: AppColors.warning,
                            ),
                            const SizedBox(width: AppSpacing.sm),
                            Expanded(
                              child: Text(
                                player.error!,
                                style: theme.textTheme.labelSmall,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ),
            if (player.queue.length > 1)
              Container(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.28,
                ),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest.withValues(
                    alpha: 0.5,
                  ),
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(20),
                  ),
                ),
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: player.queue.length,
                  itemBuilder: (BuildContext context, int index) {
                    final IlahiTrack item = player.queue[index];
                    final bool current = index == player.index;
                    return ListTile(
                      dense: true,
                      leading: Icon(
                        current
                            ? Icons.graphic_eq_rounded
                            : Icons.music_note_rounded,
                        color: current ? AppColors.emerald500 : null,
                        size: 18,
                      ),
                      title: Text(
                        item.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontWeight: current ? FontWeight.w700 : null,
                        ),
                      ),
                      subtitle: Text(
                        item.artist,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.labelSmall,
                      ),
                      onTap: () =>
                          controller.playQueue(player.queue, startIndex: index),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}
