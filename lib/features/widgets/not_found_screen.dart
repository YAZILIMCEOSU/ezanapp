import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../design/app_spacing.dart';
import '../../router/app_router.dart';

/// Bilinmeyen bir adrese gidildiğinde gösterilen dostane ekran.
class NotFoundScreen extends StatelessWidget {
  const NotFoundScreen({required this.location, super.key});

  final String location;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Sayfa bulunamadı')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xxl),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Icon(
                Icons.explore_off_outlined,
                size: 48,
                color: theme.colorScheme.onSurfaceVariant,
              ),
              const SizedBox(height: AppSpacing.lg),
              Text(
                'Aradığınız sayfaya ulaşamadım',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                'Bağlantı eskimiş olabilir. Ana sayfadan devam edebilirsiniz.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.xl),
              FilledButton.icon(
                onPressed: () => context.go(AppRoutes.home),
                icon: const Icon(Icons.home_rounded, size: 18),
                label: const Text('Ana sayfaya dön'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
