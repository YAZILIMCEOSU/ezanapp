import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../data/models/quran_models.dart';
import '../../design/app_colors.dart';
import '../../design/app_spacing.dart';
import '../../design/app_theme.dart';
import '../../router/app_router.dart';
import '../../state/content_providers.dart';
import '../widgets/state_views.dart';

/// Kur'an içinde Arapça metin veya Türkçe meal araması.
class QuranSearchScreen extends ConsumerStatefulWidget {
  const QuranSearchScreen({super.key});

  @override
  ConsumerState<QuranSearchScreen> createState() => _QuranSearchScreenState();
}

class _QuranSearchScreenState extends ConsumerState<QuranSearchScreen> {
  final TextEditingController _controller = TextEditingController();
  Timer? _debounce;
  String _query = '';
  List<AyahSearchResult> _results = const <AyahSearchResult>[];
  bool _searching = false;
  String? _error;

  static const List<String> _suggestions = <String>[
    'sabır',
    'namaz',
    'zekat',
    'anne baba',
    'tevbe',
    'şükür',
    'kalp',
    'adalet',
  ];

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _onChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 320), () => _run(value));
  }

  Future<void> _run(String value) async {
    final String query = value.trim();
    if (query.length < 2) {
      setState(() {
        _query = query;
        _results = const <AyahSearchResult>[];
        _searching = false;
        _error = null;
      });
      return;
    }
    setState(() {
      _query = query;
      _searching = true;
    });
    try {
      final List<AyahSearchResult> results = await ref
          .read(runtimeProvider)
          .quran
          .search(query);
      if (!mounted) return;
      setState(() {
        _results = results;
        _searching = false;
        _error = null;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _searching = false;
        _error = 'Arama tamamlanamadı. Lütfen tekrar deneyin.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _controller,
          autofocus: true,
          textInputAction: TextInputAction.search,
          onChanged: _onChanged,
          onSubmitted: _run,
          decoration: const InputDecoration(
            border: InputBorder.none,
            hintText: 'Ayet, meal veya konu ara (en az 2 harf)',
          ),
        ),
        actions: <Widget>[
          if (_controller.text.isNotEmpty)
            IconButton(
              onPressed: () {
                _controller.clear();
                _run('');
              },
              icon: const Icon(Icons.close_rounded, size: 20),
            ),
        ],
      ),
      body: _body(theme),
    );
  }

  Widget _body(ThemeData theme) {
    if (_error != null) {
      return ErrorView(error: _error!, onRetry: () => _run(_query));
    }
    if (_searching) {
      return const LoadingView(message: 'Ayetler taranıyor…');
    }
    if (_query.length < 2) {
      return ListView(
        padding: const EdgeInsets.all(AppSpacing.xl),
        children: <Widget>[
          Text(
            'Sık aranan konular',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: <Widget>[
              for (final String suggestion in _suggestions)
                ActionChip(
                  label: Text(suggestion),
                  onPressed: () {
                    _controller.text = suggestion;
                    _run(suggestion);
                  },
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.xl),
          const Text(
            'Aramalar Türkçe karakterleri sadeleştirir: "namaz" yazınca "namâz" '
            've "şükür" yazınca "sukur" da bulunur.',
            style: TextStyle(height: 1.5),
          ),
        ],
      );
    }
    if (_results.isEmpty) {
      return EmptyView(
        icon: Icons.search_off_rounded,
        title: '"$_query" için sonuç yok',
        message: 'Farklı bir kelime deneyin veya Türkçe mealde geçen bir ifade yazın.',
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.only(bottom: AppSpacing.xxl),
      itemCount: _results.length,
      separatorBuilder: (BuildContext context, int index) =>
          const Divider(height: 1),
      itemBuilder: (BuildContext context, int index) {
        final AyahSearchResult result = _results[index];
        final Ayah ayah = result.ayah;
        return InkWell(
          onTap: () =>
              context.push(AppRoutes.surah(ayah.surah, ayah: ayah.number)),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.emerald600.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        '${result.surah.nameTurkish} · ${ayah.surah}:${ayah.number}',
                        style: theme.textTheme.labelSmall?.copyWith(
                          fontWeight: FontWeight.w800,
                          color: AppColors.emerald500,
                        ),
                      ),
                    ),
                    const Spacer(),
                    const Icon(Icons.chevron_right_rounded, size: 18),
                  ],
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  ayah.arabic,
                  textAlign: TextAlign.right,
                  textDirection: TextDirection.rtl,
                  style: AppTheme.arabic(theme.textTheme, size: 20),
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  ayah.turkish,
                  style: theme.textTheme.bodyMedium?.copyWith(height: 1.5),
                ),
                if (result.matchedName)
                  Padding(
                    padding: const EdgeInsets.only(top: AppSpacing.sm),
                    child: Text(
                      'Sure adı eşleşti: ${result.surah.nameTurkish}',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}
