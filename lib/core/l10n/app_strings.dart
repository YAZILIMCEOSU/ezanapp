import '../../data/models/prayer.dart';

/// Uygulama arayüzü için çoklu dil sözlüğü (Türkçe `tr`, İngilizce `en`, Arapça `ar`).
///
/// Varsayılan dil `tr` olduğunda mevcut tüm ekran ve test metinleri birebir korunur.
class AppStrings {
  const AppStrings(this.localeCode);

  final String localeCode;

  static const List<({String code, String name, String nativeName})>
  supportedLanguages = <({String code, String name, String nativeName})>[
    (code: 'tr', name: 'Türkçe', nativeName: 'Türkçe'),
    (code: 'en', name: 'İngilizce', nativeName: 'English'),
    (code: 'ar', name: 'Arapça', nativeName: 'العربية'),
  ];

  static String languageLabel(String code) {
    for (final lang in supportedLanguages) {
      if (lang.code == code) return '${lang.nativeName} (${lang.name})';
    }
    return 'Türkçe';
  }

  String trEnAr(String tr, String en, String ar) => switch (localeCode) {
    'en' => en,
    'ar' => ar,
    _ => tr,
  };

  // Alt gezinme sekmeleri
  String get tabHome => trEnAr('Ana Sayfa', 'Home', 'الرئيسية');
  String get tabPrayers => trEnAr('Vakitler', 'Prayer Times', 'أوقات الصلاة');
  String get tabQuran => trEnAr('Kur\'an', 'Quran', 'القرآن');
  String get tabIlahi => trEnAr('İlahi', 'Nasheeds', 'الأناشيد');
  String get tabMore => trEnAr('Daha Fazla', 'More', 'المزيد');

  // Namaz vakti adları
  String prayerName(Prayer prayer) => switch (localeCode) {
    'en' => switch (prayer) {
      Prayer.imsak => 'Fajr (Imsak)',
      Prayer.gunes => 'Sunrise',
      Prayer.ogle => 'Dhuhr',
      Prayer.ikindi => 'Asr',
      Prayer.aksam => 'Maghrib',
      Prayer.yatsi => 'Isha',
    },
    'ar' => switch (prayer) {
      Prayer.imsak => 'الفجر',
      Prayer.gunes => 'الشروق',
      Prayer.ogle => 'الظهر',
      Prayer.ikindi => 'العصر',
      Prayer.aksam => 'المغرب',
      Prayer.yatsi => 'العشاء',
    },
    _ => prayer.label,
  };

  // Ana ekran ve hızlı erişim
  String get quickAccess => trEnAr('Hızlı erişim', 'Quick Access', 'وصول سريع');
  String get qibla => trEnAr('Kıble', 'Qibla', 'القبلة');
  String get zikir => trEnAr('Tesbih', 'Tasbih', 'التسبيح');
  String get hadith => trEnAr('Hadis', 'Hadith', 'الحديث');
  String get dua => trEnAr('Dua', 'Supplications', 'الأدعية');
  String get ramadan => trEnAr('Ramazan', 'Ramadan', 'رمضان');
  String get aiAssistant =>
      trEnAr('AI İslam Asistanı', 'AI Islamic Assistant', 'المساعد الإسلامي');
  String get nearbyMosques =>
      trEnAr('Yakındaki Camiler', 'Nearby Mosques', 'المساجد القريبة');
  String get esmaulHusna =>
      trEnAr('Esmaül Hüsna', '99 Names of Allah', 'أسماء الله الحسنى');
  String get kazaAndKhutbah => trEnAr(
    'Kaza Takibi & Cuma Hutbeleri',
    'Qada Tracker & Khutbahs',
    'قضاء الصلوات وخطب الجمعة',
  );
  String get settings => trEnAr('Ayarlar', 'Settings', 'الإعدادات');
  String get language => trEnAr('Uygulama dili', 'App Language', 'لغة التطبيق');

  // Kur'an meal dil seçenekleri
  String get quranTranslationTitle =>
      trEnAr('Meal ve Dil Seçimi', 'Translation & Language', 'اختيار الترجمة');
  String get continueReading =>
      trEnAr('Okumaya devam et', 'Continue Reading', 'متابعة القراءة');
}
