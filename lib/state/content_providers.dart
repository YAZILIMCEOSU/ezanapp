import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/services/location_service.dart';
import '../core/utils/logger.dart';
import '../data/models/ai_models.dart';
import '../data/models/app_settings.dart';
import '../data/models/hadith_models.dart';
import '../data/models/hijri_date.dart';
import '../data/models/ilahi_models.dart';
import '../data/models/prayer_times_day.dart';
import '../data/models/quran_models.dart';
import '../data/models/ramadan_models.dart';
import '../data/models/zikir_models.dart';
import '../data/repositories/daily_content_repository.dart';
import '../data/repositories/quran_repository.dart';
import 'providers.dart';

// ------------------------------------------------------------------ Günlük

/// Günün ayeti + hadisi + duası (önbellekten veya yerel veriden).
final FutureProvider<DailyContent> dailyContentProvider =
    FutureProvider<DailyContent>(
      (Ref ref) => ref.watch(runtimeProvider).dailyContent.load(DateTime.now()),
    );

/// Bugünün zikir özeti.
final FutureProvider<ZikirDailySummary> zikirDailySummaryProvider =
    FutureProvider<ZikirDailySummary>((Ref ref) async {
      final ZikirDailySummary summary = await ref
          .watch(runtimeProvider)
          .zikir
          .todaySummary(
            target: ref.watch(settingsProvider).zikirDefaultTarget * 3,
          );
      return summary;
    });

/// Günün hadisi (günlük içerikten).
final FutureProvider<Hadith?> dailyHadithProvider = FutureProvider<Hadith?>(
  (Ref ref) => ref.watch(runtimeProvider).hadith.dailyHadith(DateTime.now()),
);

// ------------------------------------------------------------------- Hadis

final FutureProvider<HadithCollection> hadithCollectionProvider =
    FutureProvider<HadithCollection>(
      (Ref ref) => ref.watch(runtimeProvider).hadith.collection(),
    );

final FutureProvider<List<Hadith>> hadithFavoritesProvider =
    FutureProvider<List<Hadith>>(
      (Ref ref) => ref.watch(runtimeProvider).hadith.favorites(),
    );

/// Konuya göre hadis listesi (arama ile birlikte kullanılır).
final hadithQueryProvider = FutureProvider.family<List<Hadith>, HadithQuery>((
  Ref ref,
  HadithQuery query,
) {
  final runtime = ref.watch(runtimeProvider);
  if (query.text.trim().isNotEmpty) {
    return runtime.hadith.search(query.text);
  }
  if (query.topic != null && query.topic != HadithQuery.allTopics) {
    return runtime.hadith.byTopic(query.topic!);
  }
  return runtime.hadith.all();
});

/// Hadis sorgusu (konu + serbest metin).
class HadithQuery {
  const HadithQuery({this.topic, this.text = ''});

  static const String allTopics = 'Tümü';

  final String? topic;
  final String text;

  HadithQuery copyWith({String? topic, String? text}) =>
      HadithQuery(topic: topic ?? this.topic, text: text ?? this.text);

  @override
  bool operator ==(Object other) =>
      other is HadithQuery && other.topic == topic && other.text == text;

  @override
  int get hashCode => Object.hash(topic, text);
}

/// Favori hadis kimlikleri (hızlı işaretleme için).
final FutureProvider<Set<int>> hadithFavoriteIdsProvider =
    FutureProvider<Set<int>>(
      (Ref ref) => ref.watch(runtimeProvider).hadith.favoriteIds(),
    );

// ------------------------------------------------------------------ Kur'an

final FutureProvider<List<Surah>> surahListProvider =
    FutureProvider<List<Surah>>(
      (Ref ref) => ref.watch(runtimeProvider).quran.surahs(),
    );

final surahContentProvider = FutureProvider.family<SurahContent, int>(
  (Ref ref, int number) => ref.watch(runtimeProvider).quran.loadSurah(number),
);

final FutureProvider<List<QuranBookmark>> quranBookmarksProvider =
    FutureProvider<List<QuranBookmark>>(
      (Ref ref) => ref.watch(runtimeProvider).quran.bookmarks(),
    );

final FutureProvider<ReadingProgress?> quranProgressProvider =
    FutureProvider<ReadingProgress?>(
      (Ref ref) => ref.watch(runtimeProvider).quran.lastProgress(),
    );

final FutureProvider<List<ReadingProgress>> quranHistoryProvider =
    FutureProvider<List<ReadingProgress>>(
      (Ref ref) => ref.watch(runtimeProvider).quran.history(),
    );

final FutureProvider<int> quranCompletedJuzProvider = FutureProvider<int>(
  (Ref ref) => ref.watch(runtimeProvider).quran.completedJuzCount(),
);

final quranSearchProvider =
    FutureProvider.family<List<AyahSearchResult>, String>((
      Ref ref,
      String query,
    ) {
      if (query.trim().length < 2) {
        return Future<List<AyahSearchResult>>.value(const <AyahSearchResult>[]);
      }
      return ref.watch(runtimeProvider).quran.search(query);
    });

/// Seçili okuyucu (ayet sesi için).
final Provider<Reciter> selectedReciterProvider = Provider<Reciter>(
  (Ref ref) => Reciters.byId(ref.watch(settingsProvider).quranReciterId),
);

/// Favori ayet kimlikleri.
final FutureProvider<Set<int>> quranBookmarkIdsProvider =
    FutureProvider<Set<int>>((Ref ref) async {
      final List<QuranBookmark> bookmarks = await ref
          .watch(runtimeProvider)
          .quran
          .bookmarks();
      return <int>{
        for (final QuranBookmark bookmark in bookmarks)
          bookmark.surah * 1000 + bookmark.number,
      };
    });

// ------------------------------------------------------------------ Zikir

final FutureProvider<List<Zikir>> zikirListProvider =
    FutureProvider<List<Zikir>>((Ref ref) async {
      final runtime = ref.watch(runtimeProvider);
      final List<Zikir> builtIn = await runtime.zikir.zikirler();
      final List<Zikir> custom = await runtime.zikir.customZikirler();
      return <Zikir>[...builtIn, ...custom];
    });

final FutureProvider<List<Map<String, Object?>>> duaListProvider =
    FutureProvider<List<Map<String, Object?>>>(
      (Ref ref) => ref.watch(runtimeProvider).zikir.dualar(),
    );

final FutureProvider<List<ZikirStatPoint>> zikirHistoryProvider =
    FutureProvider<List<ZikirStatPoint>>(
      (Ref ref) => ref.watch(runtimeProvider).zikir.history(days: 14),
    );

final FutureProvider<Map<String, int>> zikirTotalsProvider =
    FutureProvider<Map<String, int>>(
      (Ref ref) => ref.watch(runtimeProvider).zikir.totalsByZikir(days: 30),
    );

final FutureProvider<int> zikirTotalCountProvider = FutureProvider<int>(
  (Ref ref) => ref.watch(runtimeProvider).zikir.totalCount(),
);

// ------------------------------------------------------------------ İlahi

final FutureProvider<List<IlahiTrack>> ilahiCatalogProvider =
    FutureProvider<List<IlahiTrack>>(
      (Ref ref) => ref.watch(runtimeProvider).ilahi.catalog(),
    );

final FutureProvider<List<IlahiTrack>> ilahiDownloadsProvider =
    FutureProvider<List<IlahiTrack>>(
      (Ref ref) => ref.watch(runtimeProvider).ilahi.downloaded(),
    );

final FutureProvider<List<IlahiTrack>> ilahiLocalProvider =
    FutureProvider<List<IlahiTrack>>(
      (Ref ref) => ref.watch(runtimeProvider).ilahi.localTracks(),
    );

final FutureProvider<List<IlahiTrack>> ilahiRecentsProvider =
    FutureProvider<List<IlahiTrack>>(
      (Ref ref) => ref.watch(runtimeProvider).ilahi.recents(),
    );

final FutureProvider<Set<String>> ilahiFavoriteIdsProvider =
    FutureProvider<Set<String>>(
      (Ref ref) => ref.watch(runtimeProvider).ilahi.favoriteIds(),
    );

final FutureProvider<List<Playlist>> playlistsProvider =
    FutureProvider<List<Playlist>>(
      (Ref ref) => ref.watch(runtimeProvider).ilahi.playlists(),
    );

final playlistTracksProvider = FutureProvider.family<List<IlahiTrack>, int>((
  Ref ref,
  int playlistId,
) async {
  final runtime = ref.watch(runtimeProvider);
  final List<Playlist> lists = await runtime.ilahi.playlists();
  Playlist? playlist;
  for (final Playlist candidate in lists) {
    if (candidate.id == playlistId) {
      playlist = candidate;
      break;
    }
  }
  if (playlist == null) return const <IlahiTrack>[];
  final List<IlahiTrack> all = <IlahiTrack>[
    ...await runtime.ilahi.catalog(),
    ...await runtime.ilahi.localTracks(),
  ];
  return <IlahiTrack>[
    for (final String id in playlist.trackIds)
      ...all.where((IlahiTrack track) => track.id == id),
  ];
});

/// Katalog içindeki kategori ve sanatçı listesi.
final FutureProvider<({List<String> categories, List<String> artists})>
ilahiFacetsProvider =
    FutureProvider<({List<String> categories, List<String> artists})>(
      (Ref ref) => ref.watch(runtimeProvider).ilahi.facets(),
    );

// ---------------------------------------------------------------- Ramazan

final FutureProvider<HijriDate> ramadanHijriProvider =
    FutureProvider<HijriDate>((Ref ref) async {
      final runtime = ref.watch(runtimeProvider);
      final int offset = ref.watch(settingsProvider).hijriOffsetDays;
      return runtime.hijri.toHijri(DateTime.now(), dayOffset: offset);
    });

/// Sahur/iftar zamanları ve geri sayım verisi.
final FutureProvider<
  ({
    PrayerTimesDay today,
    PrayerTimesDay tomorrow,
    DateTime imsak,
    DateTime iftar,
  })
>
ramadanTodayProvider =
    FutureProvider<
      ({
        PrayerTimesDay today,
        PrayerTimesDay tomorrow,
        DateTime imsak,
        DateTime iftar,
      })
    >((Ref ref) {
      final runtime = ref.watch(runtimeProvider);
      return runtime.ramadan.todayTimes(
        location: ref.watch(activeLocationProvider),
        method: ref.watch(calculationMethodProvider),
      );
    });

/// Ramazan imsakiyesi (tüm ay).
final FutureProvider<List<PrayerTimesDay>> imsakiyeProvider =
    FutureProvider<List<PrayerTimesDay>>(
      (Ref ref) => ref
          .watch(runtimeProvider)
          .ramadan
          .imsakiye(
            location: ref.watch(activeLocationProvider),
            method: ref.watch(calculationMethodProvider),
          ),
    );

final FutureProvider<List<JuzProgress>> hatimProgressProvider =
    FutureProvider<List<JuzProgress>>(
      (Ref ref) => ref.watch(runtimeProvider).ramadan.juzProgress(),
    );

final FutureProvider<List<RamadanDayLog>> ramadanLogsProvider =
    FutureProvider<List<RamadanDayLog>>(
      (Ref ref) => ref.watch(runtimeProvider).ramadan.monthLogs(),
    );

final FutureProvider<RamadanDayLog?> todayLogProvider =
    FutureProvider<RamadanDayLog?>(
      (Ref ref) => ref.watch(runtimeProvider).ramadan.dayLog(DateTime.now()),
    );

final FutureProvider<List<KazaFast>> kazaFastsProvider =
    FutureProvider<List<KazaFast>>(
      (Ref ref) => ref.watch(runtimeProvider).ramadan.kazaFasts(),
    );

final FutureProvider<RamadanSummary> ramadanSummaryProvider =
    FutureProvider<RamadanSummary>(
      (Ref ref) => ref.watch(runtimeProvider).ramadan.summary(),
    );

final FutureProvider<List<({String title, DateTime date, String description})>>
specialDaysProvider =
    FutureProvider<List<({String title, DateTime date, String description})>>(
      (Ref ref) =>
          Future<
            List<({String title, DateTime date, String description})>
          >.value(ref.watch(runtimeProvider).ramadan.upcomingSpecialDays()),
    );

// ------------------------------------------------------------- AI asistan

/// Sohbet geçmişi listesi.
final FutureProvider<List<AiConversation>> aiConversationsProvider =
    FutureProvider<List<AiConversation>>(
      (Ref ref) => ref.watch(runtimeProvider).ai.conversations(),
    );

/// Bugünkü AI kullanım sayısı.
final FutureProvider<int> aiUsageProvider = FutureProvider<int>(
  (Ref ref) => ref.watch(runtimeProvider).ai.todayUsage(),
);

/// Aktif sohbetin mesajları ve gönderme akışı.
class ChatController extends AsyncNotifier<AiConversation?> {
  @override
  Future<AiConversation?> build() async {
    final runtime = ref.watch(runtimeProvider);
    final List<AiConversation> existing = await runtime.ai.conversations(
      limit: 1,
    );
    if (existing.isEmpty) return null;
    final AiConversation conversation = existing.first;
    final List<AiMessage> messages = await runtime.ai.messages(conversation.id);
    return conversation.copyWith(messages: messages);
  }

  bool _sending = false;
  bool get isSending => _sending;

  /// Soru gönderir; yanıt gelene kadar geçici "yazıyor" mesajı eklenir.
  Future<void> send(String question) async {
    final String text = question.trim();
    if (text.isEmpty || _sending) return;

    final runtime = ref.read(runtimeProvider);
    _sending = true;

    AiConversation? conversation = state.value;
    if (conversation == null) {
      final String id = await runtime.ai.createConversation(_titleFor(text));
      conversation = AiConversation(
        id: id,
        title: _titleFor(text),
        messages: const <AiMessage>[],
        updatedAt: DateTime.now(),
      );
    }

    final AiMessage userMessage = AiMessage(
      id: 'u${DateTime.now().microsecondsSinceEpoch}',
      text: text,
      fromUser: true,
      createdAt: DateTime.now(),
    );
    await runtime.ai.appendMessage(conversation.id, userMessage);
    state = AsyncValue<AiConversation?>.data(
      conversation.copyWith(
        messages: <AiMessage>[...conversation.messages, userMessage],
        updatedAt: DateTime.now(),
      ),
    );

    final bool premium = ref.read(isPremiumProvider);
    final bool allowed = await runtime.ai.canAsk(premium: premium);
    if (!allowed) {
      state = AsyncValue<AiConversation?>.data(
        conversation.copyWith(
          messages: <AiMessage>[
            ...conversation.messages,
            userMessage,
            AiMessage(
              id: 'limit${DateTime.now().microsecondsSinceEpoch}',
              text:
                  'Bugünkü ücretsiz soru hakkınız doldu. Premium ile sınırsız '
                  'soru sorabilir veya yarın tekrar deneyebilirsiniz.',
              fromUser: false,
              createdAt: DateTime.now(),
              failed: true,
            ),
          ],
        ),
      );
      _sending = false;
      return;
    }

    try {
      final List<AiMessage> history = conversation.messages.reversed
          .take(6)
          .toList();
      final AiAnswer answer = await runtime.ai.ask(text, history: history);
      await runtime.ai.incrementUsage();

      final AiMessage reply = AiMessage(
        id: 'a${DateTime.now().microsecondsSinceEpoch}',
        text: answer.text,
        fromUser: false,
        createdAt: answer.createdAt,
        sources: answer.sources,
        madhabNotes: answer.madhabNotes,
        mode: answer.mode,
        disclaimer: answer.disclaimer,
        relatedQuestions: answer.relatedQuestions,
      );
      await runtime.ai.appendMessage(conversation.id, reply);
      ref.invalidate(aiUsageProvider);

      state = AsyncValue<AiConversation?>.data(
        conversation.copyWith(
          messages: <AiMessage>[...conversation.messages, userMessage, reply],
          updatedAt: DateTime.now(),
        ),
      );
    } catch (error, stack) {
      AppLog.warning('AI yanıtı alınamadı: $error');
      AppLog.debug('$stack');
      state = AsyncValue<AiConversation?>.data(
        conversation.copyWith(
          messages: <AiMessage>[
            ...conversation.messages,
            userMessage,
            AiMessage(
              id: 'e${DateTime.now().microsecondsSinceEpoch}',
              text:
                  'Şu anda yanıt üretemedim. İnternet bağlantınızı kontrol edip '
                  'tekrar deneyin; çevrimdışıyken de temel bilgi tabanı çalışır.',
              fromUser: false,
              createdAt: DateTime.now(),
              failed: true,
            ),
          ],
        ),
      );
    } finally {
      _sending = false;
    }
  }

  /// Yeni sohbet başlatır.
  Future<void> startNew() async {
    state = const AsyncValue<AiConversation?>.data(null);
  }

  Future<void> openConversation(String id) async {
    final runtime = ref.read(runtimeProvider);
    final List<AiMessage> messages = await runtime.ai.messages(id);
    final List<AiConversation> all = await runtime.ai.conversations();
    AiConversation? found;
    for (final AiConversation candidate in all) {
      if (candidate.id == id) {
        found = candidate;
        break;
      }
    }
    state = AsyncValue<AiConversation?>.data(
      (found ??
              AiConversation(
                id: id,
                title: 'Sohbet',
                messages: messages,
                updatedAt: DateTime.now(),
              ))
          .copyWith(messages: messages),
    );
  }

  static String _titleFor(String question) =>
      question.length <= 38 ? question : '${question.substring(0, 35)}…';
}

final AsyncNotifierProvider<ChatController, AiConversation?>
chatControllerProvider = AsyncNotifierProvider<ChatController, AiConversation?>(
  ChatController.new,
);

// ------------------------------------------------------------- Yardımcılar

/// Konum izni durumunu sorgular (ekranlarda uyarı göstermek için).
final FutureProvider<LocationStatus> locationStatusProvider =
    FutureProvider<LocationStatus>(
      (Ref ref) => ref.watch(runtimeProvider).location.checkStatus(),
    );

/// Kullanıcının tesbih ekranında seçtiği zikir.
final NotifierProvider<SelectedZikirController, String>
selectedZikirKeyProvider = NotifierProvider<SelectedZikirController, String>(
  SelectedZikirController.new,
);

class SelectedZikirController extends Notifier<String> {
  @override
  String build() => 'subhanallah';

  void select(String key) => state = key;
}

/// Sayaç oturumları (tesbih ekranı ve istatistikler için).
final NotifierProvider<ZikirCounterController, ZikirCounterState>
zikirCounterProvider =
    NotifierProvider<ZikirCounterController, ZikirCounterState>(
      ZikirCounterController.new,
    );

class ZikirCounterState {
  const ZikirCounterState({
    this.count = 0,
    this.target = 33,
    this.zikirKey = 'subhanallah',
    this.completedSessions = 0,
  });

  final int count;
  final int target;
  final String zikirKey;
  final int completedSessions;

  double get progress => target <= 0 ? 0 : (count / target).clamp(0.0, 1);
  bool get reached => count >= target;
  int get remaining => (target - count).clamp(0, target);

  ZikirCounterState copyWith({
    int? count,
    int? target,
    String? zikirKey,
    int? completedSessions,
  }) => ZikirCounterState(
    count: count ?? this.count,
    target: target ?? this.target,
    zikirKey: zikirKey ?? this.zikirKey,
    completedSessions: completedSessions ?? this.completedSessions,
  );
}

/// Zikir sayacı — her dokunuşta kaydeder, hedef dolunca oturumu kapatır.
class ZikirCounterController extends Notifier<ZikirCounterState> {
  @override
  ZikirCounterState build() {
    final AppSettings settings = ref.watch(settingsProvider);
    return ZikirCounterState(
      zikirKey: ref.watch(selectedZikirKeyProvider),
      target: settings.zikirDefaultTarget,
    );
  }

  Future<void> increment() async {
    final ZikirCounterState next = state.copyWith(count: state.count + 1);
    state = next;
    await ref
        .read(runtimeProvider)
        .zikir
        .recordCount(state.zikirKey, 1, target: state.target);
    if (next.reached) {
      state = next.copyWith(
        completedSessions: next.completedSessions + 1,
        count: 0,
      );
      ref.invalidate(zikirDailySummaryProvider);
      ref.invalidate(zikirTotalCountProvider);
    }
  }

  Future<void> decrement() async {
    if (state.count == 0) return;
    state = state.copyWith(count: state.count - 1);
  }

  Future<void> reset() async {
    state = state.copyWith(count: 0);
  }

  void selectZikir(String key, int target) {
    ref.read(selectedZikirKeyProvider.notifier).select(key);
    state = ZikirCounterState(zikirKey: key, target: target);
  }

  void setTarget(int target) =>
      state = state.copyWith(target: target.clamp(1, 10000));

  Future<void> completeSession() async {
    if (state.count == 0) return;
    state = state.copyWith(
      completedSessions: state.completedSessions,
      count: 0,
    );
  }
}
