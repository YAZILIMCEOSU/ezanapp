import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/config/app_config.dart';
import '../../core/utils/app_time.dart';
import '../../core/utils/logger.dart';
import '../../design/app_colors.dart';
import '../../design/app_spacing.dart';
import '../../state/providers.dart';
import '../widgets/app_shell.dart';

/// Hakkında ekranı: sürüm, kaynaklar, lisanslar ve gizlilik özeti.
class AboutScreen extends ConsumerStatefulWidget {
  const AboutScreen({super.key});

  @override
  ConsumerState<AboutScreen> createState() => _AboutScreenState();
}

class _AboutScreenState extends ConsumerState<AboutScreen> {
  String _version = '—';
  Map<String, String> _diagnostics = const <String, String>{};

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final PackageInfo info = await PackageInfo.fromPlatform();
      if (mounted) {
        setState(() => _version = '${info.version} (+${info.buildNumber})');
      }
    } catch (error) {
      AppLog.debug('Paket bilgisi okunamadı: $error');
    }
    if (!mounted) return;
    final Map<String, String> diagnostics = ref
        .read(runtimeProvider)
        .diagnostics();
    if (mounted) setState(() => _diagnostics = diagnostics);
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Hakkında')),
      body: ListView(
        padding: const EdgeInsets.only(bottom: AppSpacing.xxl),
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(AppSpacing.xl),
            child: Column(
              children: <Widget>[
                Container(
                  width: 84,
                  height: 84,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: <Color>[
                        AppColors.emerald600,
                        AppColors.emerald900,
                      ],
                    ),
                    borderRadius: AppRadius.allLg,
                  ),
                  child: const Icon(
                    Icons.mosque_rounded,
                    color: AppColors.gold400,
                    size: 42,
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                Text(
                  'Ezan',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.4,
                  ),
                ),
                Text(
                  'Akıllı İslam Asistanı · Sürüm $_version',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          const SectionHeader(title: 'Uygulama durumu'),
          for (final MapEntry<String, String> entry in _diagnostics.entries)
            ListTile(
              dense: true,
              title: Text(entry.key),
              trailing: Text(
                entry.value,
                style: theme.textTheme.labelMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          const SectionHeader(title: 'Veri kaynakları'),
          const _SourceTile(
            icon: Icons.calculate_outlined,
            title: 'Namaz vakitleri',
            description:
                'T.C. Diyanet İşleri Başkanlığı yöntemi (İmsak 18°, Yatsı 17°, temkin '
                'düzeltmeleri) ile yerel hesap; çevrimiçiyken resmî vakit verisi ve '
                'Aladhan karşılaştırması kullanılır. Çevrimdışıyken vakitler cihazda '
                'hesaplanır.',
          ),
          const _SourceTile(
            icon: Icons.menu_book_outlined,
            title: 'Kur\'an metni ve meal',
            description:
                'Arapça metin: Tanzil (CC BY-ND). Türkçe meal: QuranEnc açık çevirisi. '
                'Tilavetler: EveryAyah açık arşivi.',
          ),
          const _SourceTile(
            icon: Icons.format_quote_outlined,
            title: 'Hadisler',
            description:
                'Riyâzü\'s-Sâlihîn derlemesi (açık lisanslı JSON veri kümesi). Her hadis '
                'kaydında kitap ve hadis numarası gösterilir.',
          ),
          const _SourceTile(
            icon: Icons.fingerprint_rounded,
            title: 'Zikir ve dualar',
            description:
                'Kur\'an ve sahih hadis kaynaklı zikir metinleri, Arapça metin, okunuş ve '
                'anlamıyla birlikte sunulur.',
          ),
          const SectionHeader(title: 'Gizlilik'),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: AppSpacing.xl),
            child: Text(
              '• Konum yalnızca namaz vakti ve kıble hesabı için cihazda kullanılır; '
              'sunucuya gönderilmez.\n'
              '• Favoriler, okuma geçmişi, zikir kayıtları ve AI sohbetleri cihazdaki '
              'SQLite veritabanında saklanır.\n'
              '• API anahtarları uygulamaya gömülmez; AI ve katalog istekleri kendi '
              'backend\'imiz üzerinden yapılır.\n'
              '• Kullanım istatistikleri ve çökme raporları varsayılan olarak kapalıdır ve '
              'ayarlardan yönetilebilir.\n'
              '• Verilerinizi Ayarlar > Verilerimi sil ile tek dokunuşla silebilirsiniz.',
              style: TextStyle(height: 1.7, fontSize: 12.5),
            ),
          ),
          const SectionHeader(title: 'Yasal'),
          ListTile(
            leading: const Icon(Icons.privacy_tip_outlined),
            title: const Text('Gizlilik politikası'),
            subtitle: const Text('Hangi veriler işleniyor, nasıl silinir?'),
            trailing: const Icon(Icons.open_in_new_rounded, size: 18),
            onTap: () => _openUrl(AppConfig.privacyPolicyUrl),
          ),
          ListTile(
            leading: const Icon(Icons.description_outlined),
            title: const Text('Kullanım koşulları'),
            subtitle: const Text('Uygulamanın kullanım şartları'),
            trailing: const Icon(Icons.open_in_new_rounded, size: 18),
            onTap: () => _openUrl(AppConfig.termsUrl),
          ),
          ListTile(
            leading: const Icon(Icons.gavel_outlined),
            title: const Text('Açık kaynak lisansları'),
            subtitle: const Text('Kullanılan paketlerin lisans metinleri'),
            onTap: () => showLicensePage(
              context: context,
              applicationName: 'Ezan',
              applicationVersion: _version,
              applicationIcon: const Icon(Icons.mosque_rounded, size: 40),
              applicationLegalese:
                  '© ${DateTime.now().year} Ezan · Tüm hakları saklıdır.',
            ),
          ),
          ListTile(
            leading: const Icon(Icons.mail_outline_rounded),
            title: const Text('İletişim ve destek'),
            subtitle: const Text('destek@ezanai.app'),
            onTap: () => _openMail(subject: 'Ezan $_version'),
          ),
          if (AppConfig.apiBaseUrl.isNotEmpty)
            const ListTile(
              leading: Icon(Icons.dns_outlined),
              title: Text('Servis adresi'),
              subtitle: Text(AppConfig.apiBaseUrl),
            ),
          Padding(
            padding: const EdgeInsets.all(AppSpacing.xl),
            child: Text(
              'Bu uygulama dini içerik sunar; kesin hüküm vermez. Fıkhî konularda '
              'mutlaka ehil bir âlime veya resmî fetva kurumuna danışın.',
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                height: 1.5,
              ),
            ),
          ),
          Center(
            child: Text(
              'Son güncelleme: ${AppTime.formatDateLong(DateTime.now())}',
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _openUrl(String url) async {
    final Uri uri = Uri.parse(url);
    try {
      final bool opened = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );
      if (!opened && mounted) {
        _showMessage('Bağlantı açılamadı: $url');
      }
    } catch (error) {
      AppLog.warning('Bağlantı açılamadı ($url): $error');
      if (mounted) _showMessage('Bağlantı açılamadı: $url');
    }
  }

  Future<void> _openMail({required String subject}) async {
    final Uri uri = Uri(
      scheme: 'mailto',
      path: AppConfig.supportEmail,
      query: 'subject=$subject',
    );
    try {
      await launchUrl(uri);
    } catch (error) {
      AppLog.warning('E-posta uygulaması açılamadı: $error');
      if (mounted) _showMessage('E-posta uygulaması bulunamadı.');
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }
}

class _SourceTile extends StatelessWidget {
  const _SourceTile({
    required this.icon,
    required this.title,
    required this.description,
  });

  final IconData icon;
  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      subtitle: Text(
        description,
        style: const TextStyle(height: 1.5, fontSize: 12.5),
      ),
      isThreeLine: true,
    );
  }
}
