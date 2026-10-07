import 'package:flutter/foundation.dart';

/// Derleme zamanı özellik bayrakları — kademeli yayın için.
///
/// Faz 2+ modülleri (Kur'an, hadis, dualar, ilahi, Ramazan, AI, premium,
/// bulut yedekleme) **varsayılan olarak açıktır**; böylece geliştirme, test ve
/// CI her zaman tam kapsamı doğrular. Play'e MVP kapsamıyla çıkmak istendiğinde
/// yayın derlemesinde kapatılır:
///
/// ```bash
/// flutter build appbundle --release \
///   --dart-define=FEATURE_QURAN=false \
///   --dart-define=FEATURE_HADITH=false \
///   --dart-define=FEATURE_DUA=false \
///   --dart-define=FEATURE_ILAHI=false \
///   --dart-define=FEATURE_RAMADAN=false \
///   --dart-define=FEATURE_AI=false \
///   --dart-define=FEATURE_PREMIUM=false \
///   --dart-define=FEATURE_SYNC=false
/// ```
///
/// Kapatılan modülün sekmesi, ekran kartları ve menü girişleri görünmez; kapalı
/// bir yola gelen bağlantı (ör. eski bir bildirim) ana sayfaya yönlendirilir.
/// Böylece kullanıcı hiçbir zaman boş/çalışmayan bir ekranla karşılaşmaz.
@immutable
class AppFeatures {
  const AppFeatures({
    this.quran = true,
    this.hadith = true,
    this.dua = true,
    this.ilahi = true,
    this.ramadan = true,
    this.ai = true,
    this.premium = true,
    this.sync = true,
  });

  /// Derleme zamanından okunan etkin bayraklar.
  static const AppFeatures fromEnvironment = AppFeatures(
    quran: bool.fromEnvironment('FEATURE_QURAN', defaultValue: true),
    hadith: bool.fromEnvironment('FEATURE_HADITH', defaultValue: true),
    dua: bool.fromEnvironment('FEATURE_DUA', defaultValue: true),
    ilahi: bool.fromEnvironment('FEATURE_ILAHI', defaultValue: true),
    ramadan: bool.fromEnvironment('FEATURE_RAMADAN', defaultValue: true),
    ai: bool.fromEnvironment('FEATURE_AI', defaultValue: true),
    premium: bool.fromEnvironment('FEATURE_PREMIUM', defaultValue: true),
    sync: bool.fromEnvironment('FEATURE_SYNC', defaultValue: true),
  );

  /// Play'deki ilk sürüm için MVP kapsamı.
  ///
  /// Vakitler, ezan/vakit bildirimleri, kıble, tesbih, hicri takvim, ayarlar ve
  /// çevrimdışı çalışma kalır; içerik ve asistan modülleri sonraki sürümlere
  /// bırakılır (bkz. `docs/PHASES.md` §5-B).
  static const AppFeatures mvp = AppFeatures(
    quran: false,
    hadith: false,
    dua: false,
    ilahi: false,
    ramadan: false,
    ai: false,
    premium: false,
    sync: false,
  );

  /// Uygulamanın çalışma anındaki etkin bayrak kümesi.
  ///
  /// Varsayılan olarak derleme zamanı değerlerini kullanır; testler ve önizleme
  /// bu alanı geçici olarak değiştirebilir (bkz. `test/widget/mvp_mode_test.dart`).
  static AppFeatures active = fromEnvironment;

  final bool quran;
  final bool hadith;
  final bool dua;
  final bool ilahi;
  final bool ramadan;
  final bool ai;
  final bool premium;
  final bool sync;

  /// Tüm modüller açık mı? (Tam kapsamlı sürüm)
  bool get isFull =>
      quran && hadith && dua && ilahi && ramadan && ai && premium && sync;

  /// Kapatılan modüllerin okunabilir listesi (Hakkında ekranı/destek için).
  List<String> get disabledModules => <String>[
    if (!quran) 'Kur\'an',
    if (!hadith) 'Hadis',
    if (!dua) 'Dualar',
    if (!ilahi) 'İlahi',
    if (!ramadan) 'Ramazan',
    if (!ai) 'AI İslam Asistanı',
    if (!premium) 'Premium abonelik',
    if (!sync) 'Bulut yedekleme',
  ];

  /// Verilen yolun bu bayrak kümesiyle açık olup olmadığı.
  ///
  /// Yönlendirme (redirect) ve menü süzme aynı kuralı kullanır; böylece
  /// "girişi gizledim ama yol açık kaldı" durumu oluşmaz.
  bool allows(String location) {
    if (!quran && (location.startsWith('/quran') || location.startsWith('/kuran'))) {
      return false;
    }
    if (!hadith && location.startsWith('/hadis')) return false;
    if (!dua && location.startsWith('/dualar')) return false;
    if (!ilahi && location.startsWith('/ilahi')) return false;
    if (!ramadan && location.startsWith('/ramazan')) return false;
    if (!ai && location.startsWith('/ai')) return false;
    if (!premium && location.startsWith('/premium')) return false;
    if (!sync && location.startsWith('/ayarlar/yedekleme')) return false;
    return true;
  }
}
