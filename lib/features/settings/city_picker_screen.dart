import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/utils/logger.dart';
import '../../data/models/city.dart';
import '../../design/app_spacing.dart';
import '../../state/providers.dart';
import '../widgets/state_views.dart';

/// Şehir/ilçe arama ve seçim ekranı (Türkiye + dünya).
class CityPickerScreen extends ConsumerStatefulWidget {
  const CityPickerScreen({super.key});

  @override
  ConsumerState<CityPickerScreen> createState() => _CityPickerScreenState();
}

class _CityPickerScreenState extends ConsumerState<CityPickerScreen> {
  final TextEditingController _controller = TextEditingController();
  Timer? _debounce;
  List<City> _results = const <City>[];
  List<City> _featured = const <City>[];
  bool _loading = true;
  String? _error;
  bool _includeWorld = true;

  @override
  void initState() {
    super.initState();
    _loadFeatured();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    super.dispose();
  }

  Future<void> _loadFeatured() async {
    try {
      final List<City> featured = await ref
          .read(runtimeProvider)
          .cities
          .featuredProvinces();
      if (!mounted) return;
      setState(() {
        _featured = featured;
        _loading = false;
      });
    } catch (error) {
      AppLog.warning('Öne çıkan iller yüklenemedi: $error');
      if (mounted) {
        setState(() {
          _loading = false;
          _error = 'Şehir listesi yüklenemedi.';
        });
      }
    }
  }

  void _onQueryChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 220), () => _search(value));
  }

  Future<void> _search(String value) async {
    if (value.trim().length < 2) {
      setState(() => _results = const <City>[]);
      return;
    }
    setState(() => _loading = true);
    try {
      final List<City> results = await ref
          .read(runtimeProvider)
          .cities
          .search(value, includeWorld: _includeWorld);
      if (!mounted) return;
      setState(() {
        _results = results;
        _loading = false;
        _error = null;
      });
    } catch (error) {
      AppLog.warning('Şehir araması başarısız: $error');
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = 'Arama sırasında bir sorun oluştu.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final City? current = ref.watch(activeLocationProvider).city;
    final bool querying = _controller.text.trim().length >= 2;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Konum seç'),
        actions: <Widget>[
          IconButton(
            tooltip: 'Otomatik konum (GPS)',
            onPressed: _useGps,
            icon: const Icon(Icons.my_location_rounded, size: 20),
          ),
        ],
      ),
      body: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg,
              AppSpacing.sm,
              AppSpacing.lg,
              AppSpacing.sm,
            ),
            child: TextField(
              controller: _controller,
              autofocus: false,
              textInputAction: TextInputAction.search,
              onChanged: _onQueryChanged,
              decoration: InputDecoration(
                hintText: 'İlçe, il veya şehir ara',
                prefixIcon: const Icon(Icons.search_rounded, size: 20),
                suffixIcon: _controller.text.isEmpty
                    ? null
                    : IconButton(
                        onPressed: () {
                          _controller.clear();
                          setState(() => _results = const <City>[]);
                        },
                        icon: const Icon(Icons.close_rounded, size: 18),
                      ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            child: Row(
              children: <Widget>[
                FilterChip(
                  label: const Text('Yalnızca Türkiye'),
                  selected: !_includeWorld,
                  onSelected: (bool selected) {
                    setState(() => _includeWorld = !selected);
                    if (querying) _search(_controller.text);
                  },
                ),
                const Spacer(),
                Text(
                  querying ? '${_results.length} sonuç' : 'Öne çıkan iller',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          if (current != null)
            ListTile(
              leading: const Icon(Icons.check_circle_rounded),
              title: Text('Seçili: ${current.displayName}'),
              subtitle: Text(
                'Koordinat: ${current.latitude.toStringAsFixed(3)}, ${current.longitude.toStringAsFixed(3)}',
              ),
            ),
          const Divider(height: 1),
          Expanded(child: _body(querying)),
        ],
      ),
    );
  }

  Widget _body(bool querying) {
    if (_error != null) {
      return ErrorView(error: _error!, onRetry: () => _loadFeatured());
    }
    if (_loading && (querying || _featured.isEmpty)) {
      return const LoadingView(message: 'Şehirler hazırlanıyor…');
    }
    final List<City> items = querying ? _results : _featured;
    if (items.isEmpty) {
      return EmptyView(
        icon: Icons.search_off_rounded,
        title: querying ? 'Sonuç bulunamadı' : 'Liste yüklenemedi',
        message: querying
            ? 'Farklı bir yazım deneyin. Örnek: "Polatlı", "Hamburg".'
            : 'Şehir verisi okunamadı, aramayı deneyin.',
      );
    }
    return ListView.separated(
      itemCount: items.length,
      separatorBuilder: (BuildContext context, int index) =>
          const Divider(height: 1),
      itemBuilder: (BuildContext context, int index) {
        final City city = items[index];
        return ListTile(
          leading: Icon(
            city.isTurkish ? Icons.location_city_rounded : Icons.public_rounded,
          ),
          title: Text(city.name),
          subtitle: Text(
            city.isTurkish
                ? (city.province != null && city.province != city.name
                      ? '${city.province} · ilçe kodu ${city.id}'
                      : 'İl merkezi · kod ${city.id}')
                : '${city.country} · kod ${city.id}',
          ),
          trailing: const Icon(Icons.chevron_right_rounded),
          onTap: () => _select(city),
        );
      },
    );
  }

  Future<void> _select(City city) async {
    await ref.read(locationControllerProvider.notifier).selectCity(city);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${city.displayName} seçildi. Vakitler güncellendi.'),
      ),
    );
    if (Navigator.of(context).canPop()) {
      context.pop();
    } else {
      context.go('/prayers');
    }
  }

  Future<void> _useGps() async {
    final bool ok = await ref
        .read(locationControllerProvider.notifier)
        .refreshFromGps();
    if (!mounted) return;
    final String message = ok
        ? 'Konum güncellendi: ${ref.read(activeLocationProvider).label}'
        : ref.read(locationControllerProvider).error ?? 'Konum alınamadı.';
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
    if (ok && Navigator.of(context).canPop()) context.pop();
  }
}
