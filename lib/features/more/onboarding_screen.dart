import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/services/location_service.dart';
import '../../core/utils/logger.dart';
import '../../design/app_colors.dart';
import '../../design/app_spacing.dart';
import '../../router/app_router.dart';
import '../../state/providers.dart';

/// İlk açılış akışı: hoş geldin, konum tercihi ve bildirim izni.
///
/// Buradaki her adım gerçek bir işlem yapar (konum izni, bildirim izni);
/// kullanıcı isterse hepsini atlayabilir ve sonra ayarlardan değiştirebilir.
class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final PageController _controller = PageController();
  int _page = 0;

  bool _locationBusy = false;
  String? _locationMessage;
  bool _notificationsGranted = false;
  bool _notificationsRequested = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _finish() async {
    final runtime = ref.read(runtimeProvider);
    await runtime.preferences.setBool('onboarding_done', true);
    if (mounted) context.go(AppRoutes.home);
  }

  Future<void> _requestLocation() async {
    setState(() {
      _locationBusy = true;
      _locationMessage = null;
    });
    final bool ok = await ref
        .read(locationControllerProvider.notifier)
        .refreshFromGps();
    if (!mounted) return;
    setState(() {
      _locationBusy = false;
      _locationMessage = ok
          ? 'Konum alındı: ${ref.read(activeLocationProvider).label}'
          : ref.read(locationControllerProvider).error ??
                'Konum alınamadı. Şehir seçerek devam edebilirsiniz.';
    });
  }

  Future<void> _requestNotifications() async {
    final runtime = ref.read(runtimeProvider);
    bool granted = false;
    try {
      granted = await runtime.notifications.requestPermission();
    } catch (error) {
      AppLog.warning('Bildirim izni alınamadı: $error');
    }
    if (!mounted) return;
    setState(() {
      _notificationsRequested = true;
      _notificationsGranted = granted;
    });
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: <Widget>[
            Expanded(
              child: PageView(
                controller: _controller,
                onPageChanged: (int page) => setState(() => _page = page),
                children: <Widget>[
                  _WelcomePage(theme: theme),
                  _LocationPage(
                    theme: theme,
                    busy: _locationBusy,
                    message: _locationMessage,
                    onRequest: _requestLocation,
                    onPickCity: () => context.push(AppRoutes.cities),
                    currentLabel: ref.watch(activeLocationProvider).label,
                  ),
                  _NotificationPage(
                    theme: theme,
                    requested: _notificationsRequested,
                    granted: _notificationsGranted,
                    onRequest: _requestNotifications,
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(AppSpacing.xl),
              child: Row(
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      for (int i = 0; i < 3; i++)
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 220),
                          margin: const EdgeInsets.only(right: 6),
                          width: i == _page ? 22 : 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: i == _page
                                ? theme.colorScheme.primary
                                : theme.colorScheme.outlineVariant,
                            borderRadius: BorderRadius.circular(999),
                          ),
                        ),
                    ],
                  ),
                  const Spacer(),
                  TextButton(onPressed: _finish, child: const Text('Atla')),
                  const SizedBox(width: AppSpacing.sm),
                  FilledButton(
                    onPressed: () {
                      if (_page == 2) {
                        _finish();
                      } else {
                        _controller.nextPage(
                          duration: const Duration(milliseconds: 260),
                          curve: Curves.easeOutCubic,
                        );
                      }
                    },
                    child: Text(_page == 2 ? 'Başla' : 'Devam'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _WelcomePage extends StatelessWidget {
  const _WelcomePage({required this.theme});

  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.xxl),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Image.asset('assets/images/logo_mark.png', width: 96, height: 96),
          const SizedBox(height: AppSpacing.xl),
          Text(
            'EzanAI\'ye hoş geldiniz',
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.w800,
              letterSpacing: -0.6,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            'Namaz vakitleri, kıble, Kur\'an, ilahi, tesbih, hadis, Ramazan ve '
            'kaynaklı AI asistanı tek uygulamada. Reklamlar yalnızca ücretsiz '
            'sürümde gösterilir; premium ile tamamen kapanır.',
            style: theme.textTheme.bodyLarge?.copyWith(height: 1.5),
          ),
        ],
      ),
    );
  }
}

class _LocationPage extends StatelessWidget {
  const _LocationPage({
    required this.theme,
    required this.busy,
    required this.message,
    required this.onRequest,
    required this.onPickCity,
    required this.currentLabel,
  });

  final ThemeData theme;
  final bool busy;
  final String? message;
  final VoidCallback onRequest;
  final VoidCallback onPickCity;
  final String currentLabel;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.xxl),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const Icon(
            Icons.explore_outlined,
            size: 56,
            color: AppColors.emerald500,
          ),
          const SizedBox(height: AppSpacing.xl),
          Text(
            'Vakitler hangi konuma göre?',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            'Otomatik konum, bulunduğunuz ilçenin resmî Diyanet vakitlerini kullanır. '
            'Manuel şehir seçerseniz yalnızca o şehir için hesaplanır.',
            style: theme.textTheme.bodyMedium?.copyWith(height: 1.5),
          ),
          const SizedBox(height: AppSpacing.lg),
          Row(
            children: <Widget>[
              Icon(
                Icons.place_outlined,
                size: 16,
                color: theme.colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  'Seçili konum: $currentLabel',
                  style: theme.textTheme.labelLarge,
                ),
              ),
            ],
          ),
          if (message != null) ...<Widget>[
            const SizedBox(height: AppSpacing.sm),
            Text(
              message!,
              style: theme.textTheme.bodySmall?.copyWith(
                color: message!.startsWith('Konum alındı')
                    ? AppColors.success
                    : theme.colorScheme.error,
              ),
            ),
          ],
          const SizedBox(height: AppSpacing.xl),
          FilledButton.icon(
            onPressed: busy ? null : onRequest,
            icon: busy
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.my_location_rounded, size: 18),
            label: Text(busy ? 'Konum alınıyor…' : 'Konumumu kullan'),
          ),
          const SizedBox(height: AppSpacing.md),
          OutlinedButton.icon(
            onPressed: onPickCity,
            icon: const Icon(Icons.search_rounded, size: 18),
            label: const Text('Şehir seç'),
          ),
        ],
      ),
    );
  }
}

class _NotificationPage extends StatelessWidget {
  const _NotificationPage({
    required this.theme,
    required this.requested,
    required this.granted,
    required this.onRequest,
  });

  final ThemeData theme;
  final bool requested;
  final bool granted;
  final VoidCallback onRequest;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.xxl),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const Icon(
            Icons.notifications_active_outlined,
            size: 56,
            color: AppColors.gold500,
          ),
          const SizedBox(height: AppSpacing.xl),
          Text(
            'Ezan vakti geldiğinde haber verelim',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            'Vakit bildirimleri, ön hatırlatma, Cuma ve Ramazan bildirimlerini '
            'buradan açabilirsiniz. Dilediğiniz zaman Ayarlar > Bildirimler\'den '
            'kapatabilirsiniz.',
            style: theme.textTheme.bodyMedium?.copyWith(height: 1.5),
          ),
          const SizedBox(height: AppSpacing.xl),
          if (requested)
            Row(
              children: <Widget>[
                Icon(
                  granted
                      ? Icons.check_circle_rounded
                      : Icons.info_outline_rounded,
                  size: 18,
                  color: granted ? AppColors.success : AppColors.warning,
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    granted ? 'Bildirim izni verildi.' : 'İzin verilmedi. Ayarlardan daha sonra açabilirsiniz.',
                    style: theme.textTheme.bodySmall,
                  ),
                ),
              ],
            )
          else
            FilledButton.icon(
              onPressed: onRequest,
              icon: const Icon(Icons.notifications_rounded, size: 18),
              label: const Text('Bildirimlere izin ver'),
            ),
          const SizedBox(height: AppSpacing.md),
          Text(
            'Namaz vakti bildirimleri cihazda zamanlanır; internet gerekmez.',
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

/// Konum izni durumu metni için yardımcı (onboarding dışında da kullanılır).
String locationStatusLabel(LocationStatus status) => status.label;
