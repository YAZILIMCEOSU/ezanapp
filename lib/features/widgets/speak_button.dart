import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/services/tts_service.dart';
import '../../design/app_spacing.dart';
import '../../state/providers.dart';

/// **Sesli okuma düğmesi** — hutbe, dua ve uzun metinler için.
///
/// * İlk dokunuşta metni cihazın Türkçe konuşma motoruyla okur.
/// * Okuma sürerken "Durdur" düğmesine dönüşür.
/// * Sesli okuma desteklenmiyorsa kullanıcıya anlaşılır tek satırlık bilgi
///   gösterir (çökmez, sessizce yutmaz).
class SpeakButton extends ConsumerStatefulWidget {
  const SpeakButton({
    required this.text,
    this.label = 'Sesli Oku',
    this.compact = false,
    super.key,
  });

  /// Okunacak metin (Arapça hat otomatik ayıklanır).
  final String text;
  final String label;

  /// Simge düğmesi olarak göster (dar alanlar için).
  final bool compact;

  @override
  ConsumerState<SpeakButton> createState() => _SpeakButtonState();
}

class _SpeakButtonState extends ConsumerState<SpeakButton> {
  bool _speaking = false;
  Timer? _watchdog;

  @override
  void dispose() {
    _watchdog?.cancel();
    unawaited(ref.read(ttsServiceProvider).stop());
    super.dispose();
  }

  void _showMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(duration: const Duration(seconds: 3), content: Text(message)),
    );
  }

  Future<void> _toggle() async {
    final TtsService tts = ref.read(ttsServiceProvider);
    if (_speaking) {
      await tts.stop();
      _watchdog?.cancel();
      if (mounted) setState(() => _speaking = false);
      return;
    }
    final TtsStart result = await tts.speak(widget.text);
    if (result == TtsStart.started) {
      if (!mounted) return;
      setState(() => _speaking = true);
      _startWatchdog();
      return;
    }
    if (result == TtsStart.empty) {
      _showMessage('Bu metin sesli okunamıyor.');
      return;
    }
    if (result == TtsStart.unsupported) {
      _showMessage(
        'Sesli okuma bu cihazda/ortamda kullanılamıyor. Metni kopyalayıp '
        'cihazınızın ekran okuyucusuyla dinleyebilirsiniz.',
      );
      return;
    }
    _showMessage(
      'Cihazınızda Türkçe konuşma sesi bulunamadı. Ayarlar > Diller ve '
      'giriş > Metin okuma bölümünden Türkçe sesi indirebilirsiniz.',
    );
  }

  /// Okuma bitince düğmeyi otomatik olarak "Sesli Oku"ya döndürür.
  void _startWatchdog() {
    _watchdog?.cancel();
    _watchdog = Timer(const Duration(seconds: 2), () async {
      if (!mounted || !_speaking) return;
      final bool speaking = await ref.read(ttsServiceProvider).isSpeaking();
      if (!mounted) return;
      if (!speaking) {
        setState(() => _speaking = false);
      } else {
        _startWatchdog();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final IconData icon = _speaking
        ? Icons.stop_circle_outlined
        : Icons.volume_up_outlined;
    final String tooltip = _speaking ? 'Sesli okumayı durdur' : widget.label;

    if (widget.compact) {
      return IconButton(
        visualDensity: VisualDensity.compact,
        tooltip: tooltip,
        onPressed: _toggle,
        icon: Icon(
          icon,
          size: 18,
          color: _speaking ? Theme.of(context).colorScheme.primary : null,
        ),
      );
    }
    return OutlinedButton.icon(
      onPressed: _toggle,
      icon: Icon(icon, size: 18),
      label: Text(_speaking ? 'Durdur' : widget.label),
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.xs,
        ),
      ),
    );
  }
}
