import 'package:intl/intl.dart';

/// Tarih/saat yardımcıları — Türkçe yerelleştirme ile.
abstract final class AppTime {
  static const List<String> turkishMonths = <String>[
    'Ocak',
    'Şubat',
    'Mart',
    'Nisan',
    'Mayıs',
    'Haziran',
    'Temmuz',
    'Ağustos',
    'Eylül',
    'Ekim',
    'Kasım',
    'Aralık',
  ];

  static const List<String> turkishWeekdays = <String>[
    'Pazartesi',
    'Salı',
    'Çarşamba',
    'Perşembe',
    'Cuma',
    'Cumartesi',
    'Pazar',
  ];

  static const List<String> turkishWeekdaysShort = <String>[
    'Pzt',
    'Sal',
    'Çar',
    'Per',
    'Cum',
    'Cmt',
    'Paz',
  ];

  static const List<String> hijriMonths = <String>[
    'Muharrem',
    'Safer',
    'Rebîülevvel',
    'Rebîülâhir',
    'Cemâziyelevvel',
    'Cemâziyelâhir',
    'Recep',
    'Şaban',
    'Ramazan',
    'Şevval',
    'Zilkade',
    'Zilhicce',
  ];

  /// "14:05" biçiminde 24 saatlik gösterim.
  static String formatTime(DateTime time, {bool use24Hour = true}) {
    if (use24Hour) return DateFormat('HH:mm').format(time);
    return DateFormat('hh:mm a', 'en').format(time);
  }

  static String formatTimeOfDay(int hour, int minute, {bool use24Hour = true}) {
    if (use24Hour) {
      return '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';
    }
    final int h12 = hour % 12 == 0 ? 12 : hour % 12;
    final String suffix = hour < 12 ? 'ÖÖ' : 'ÖS';
    return '${h12.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')} $suffix';
  }

  /// 3 sa 12 dk biçiminde kalan süre.
  static String formatCountdown(Duration duration) {
    final Duration d = duration.isNegative ? Duration.zero : duration;
    final int hours = d.inHours;
    final int minutes = d.inMinutes.remainder(60);
    final int seconds = d.inSeconds.remainder(60);
    if (hours > 0) {
      return '${hours}s ${minutes.toString().padLeft(2, '0')}dk';
    }
    if (minutes > 0) {
      return '${minutes}dk ${seconds.toString().padLeft(2, '0')}sn';
    }
    return '${seconds}sn';
  }

  /// Dijital sayaç biçimi: 03:12:45
  static String formatClock(Duration duration) {
    final Duration d = duration.isNegative ? Duration.zero : duration;
    final String h = d.inHours.toString().padLeft(2, '0');
    final String m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final String s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$h:$m:$s';
  }

  static String formatDateLong(DateTime date) {
    return '${date.day} ${turkishMonths[date.month - 1]} ${date.year}, '
        '${turkishWeekdays[date.weekday - 1]}';
  }

  static String formatDateShort(DateTime date) {
    return '${date.day} ${turkishMonths[date.month - 1]}';
  }

  static String formatDateNumeric(DateTime date) =>
      '${date.day.toString().padLeft(2, '0')}.${date.month.toString().padLeft(2, '0')}.${date.year}';

  static String weekday(DateTime date) => turkishWeekdays[date.weekday - 1];

  static String weekdayShort(DateTime date) =>
      turkishWeekdaysShort[date.weekday - 1];

  static bool isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  static DateTime dateOnly(DateTime value) =>
      DateTime(value.year, value.month, value.day);

  static int minutesSinceMidnight(DateTime value) =>
      value.hour * 60 + value.minute;

  /// Gün batımından sonra yatsıya kadar "gece" kabul eden selamlama.
  static String greetingFor(DateTime now, {required bool afterMaghrib}) {
    final int hour = now.hour;
    if (hour >= 4 && hour < 6) return 'Hayırlı seherler';
    if (hour >= 6 && hour < 12) return 'Hayırlı sabahlar';
    if (hour >= 12 && hour < 15) return 'Hayırlı öğle vakti';
    if (hour >= 15 && hour < 18) return 'Hayırlı ikindiler';
    if (hour >= 18 && hour < 21 && !afterMaghrib) return 'Hayırlı akşamlar';
    if (hour >= 21 || hour < 4) return 'Hayırlı geceler';
    return 'Hayırlı akşamlar';
  }

  static String relativeDays(DateTime target, DateTime now) {
    final int diff = dateOnly(target).difference(dateOnly(now)).inDays;
    return switch (diff) {
      0 => 'Bugün',
      1 => 'Yarın',
      -1 => 'Dün',
      _ => diff > 1 ? '$diff gün sonra' : '${diff.abs()} gün önce',
    };
  }

  static String formatBytes(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(0)} KB';
    if (bytes < 1024 * 1024 * 1024)
      return '${(bytes / 1024 / 1024).toStringAsFixed(1)} MB';
    return '${(bytes / 1024 / 1024 / 1024).toStringAsFixed(2)} GB';
  }
}
