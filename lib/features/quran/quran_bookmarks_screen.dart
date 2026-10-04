import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/utils/app_time.dart';
import '../../data/models/quran_models.dart';
import '../../design/app_colors.dart';
import '../../design/app_spacing.dart';
import '../../router/app_router.dart';
import '../../state/content_providers.dart';
import '../../state/providers.dart';
import '../widgets/state_views.dart';

/// Favori ayetler ve okuma geçmişi.
class QuranBookmarksScreen extends ConsumerStatefulWidget {
  const QuranBookmarksScreen({super.key});

  @override
  ConsumerState<QuranBookmarksScreen> createState() =>
      _QuranBookmarksScreenState();
}

class _QuranBookmarksScreenState extends ConsumerState<QuranBookmarksScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabs = TabController(length: 2, vsync: this);

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Favoriler ve Geçmiş'),
        bottom: TabBar(
          controller: _tabs,
          tabs: const <Widget>[
            Tab(text: 'Favori ayetler'),
            Tab(text: 'Okuma geçmişi'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabs,
        children: const <Widget>[_BookmarkList(), _HistoryList()],
      ),
    );
  }
}

class _BookmarkList extends ConsumerWidget {
  const _BookmarkList();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<List<QuranBookmark>> bookmarks = ref.watch(
      quranBookmarksProvider,
    );
    final Map<int, String> surahNames = <int, String>{
      for (final Surah surah
          in ref.watch(surahListProvider).value ?? const <Surah>[])
        surah.number: surah.nameTurkish,
    };

    return bookmarks.when(
      loading: () => const LoadingView(message: 'Favoriler yükleniyor…'),
      error: (Object error, StackTrace stackTrace) => ErrorView(
        error: error,
        onRetry: () => ref.invalidate(quranBookmarksProvider),
      ),
      data: (List<QuranBookmark> items) {
        if (items.isEmpty) {
          return const EmptyView(
            icon: Icons.bookmark_border_rounded,
            title: 'Henüz favori ayetiniz yok',
            message:
                'Okuma ekranındaki yer imi simgesine dokunarak ayetleri '
                'favorilere ekleyebilirsiniz.',
          );
        }
        return ListView.separated(
          padding: const EdgeInsets.only(bottom: AppSpacing.xxl),
          itemCount: items.length,
          separatorBuilder: (BuildContext context, int index) =>
              const Divider(height: 1),
          itemBuilder: (BuildContext context, int index) {
            final QuranBookmark bookmark = items[index];
            final String surahName =
                surahNames[bookmark.surah] ?? '${bookmark.surah}. sure';
            return ListTile(
              leading: const Icon(
                Icons.bookmark_rounded,
                color: AppColors.gold600,
              ),
              title: Text('$surahName · ${bookmark.number}. ayet'),
              subtitle: Text(
                bookmark.note?.isNotEmpty ?? false
                    ? bookmark.note!
                    : 'Eklendi: ${AppTime.formatDateShort(bookmark.createdAt)}',
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              trailing: IconButton(
                tooltip: 'Favoriden çıkar',
                icon: const Icon(Icons.delete_outline_rounded, size: 20),
                onPressed: () async {
                  await ref
                      .read(runtimeProvider)
                      .quran
                      .toggleBookmark(bookmark.surah, bookmark.number);
                  ref.invalidate(quranBookmarksProvider);
                  ref.invalidate(quranBookmarkIdsProvider);
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Favoriden çıkarıldı.')),
                    );
                  }
                },
              ),
              onTap: () => context.push(
                AppRoutes.surah(bookmark.surah, ayah: bookmark.number),
              ),
            );
          },
        );
      },
    );
  }
}

class _HistoryList extends ConsumerWidget {
  const _HistoryList();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<List<ReadingProgress>> history = ref.watch(
      quranHistoryProvider,
    );
    final Map<int, Surah> surahs = <int, Surah>{
      for (final Surah surah
          in ref.watch(surahListProvider).value ?? const <Surah>[])
        surah.number: surah,
    };

    return history.when(
      loading: () => const LoadingView(message: 'Geçmiş yükleniyor…'),
      error: (Object error, StackTrace stackTrace) => ErrorView(
        error: error,
        onRetry: () => ref.invalidate(quranHistoryProvider),
      ),
      data: (List<ReadingProgress> items) {
        if (items.isEmpty) {
          return const EmptyView(
            icon: Icons.history_rounded,
            title: 'Okuma geçmişi boş',
            message: 'Bir sure okumaya başladığınızda burada listelenir.',
          );
        }
        return ListView.separated(
          padding: const EdgeInsets.only(bottom: AppSpacing.xxl),
          itemCount: items.length,
          separatorBuilder: (BuildContext context, int index) =>
              const Divider(height: 1),
          itemBuilder: (BuildContext context, int index) {
            final ReadingProgress progress = items[index];
            final Surah? surah = surahs[progress.surah];
            return ListTile(
              leading: const Icon(Icons.menu_book_rounded),
              title: Text(
                surah == null
                    ? '${progress.surah}. sure'
                    : '${surah.nameTurkish} (${progress.surah}. sure)',
              ),
              subtitle: Text(
                '${progress.lastAyah}. ayette kaldınız · '
                '${AppTime.formatDateShort(progress.readAt)} '
                '${AppTime.formatTime(progress.readAt)}',
              ),
              trailing: const Icon(Icons.chevron_right_rounded),
              onTap: () => context.push(
                AppRoutes.surah(progress.surah, ayah: progress.lastAyah),
              ),
            );
          },
        );
      },
    );
  }
}
