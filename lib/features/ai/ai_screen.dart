import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';

import '../../data/models/ai_models.dart';
import '../../data/repositories/ai_repository.dart';
import '../../design/app_colors.dart';
import '../../design/app_spacing.dart';
import '../../state/content_providers.dart';
import '../../state/providers.dart';
import '../widgets/state_views.dart';

/// AI İslam Asistanı: kaynak gösteren, mezhep farklarını belirten sohbet.
class AiScreen extends ConsumerStatefulWidget {
  const AiScreen({super.key});

  @override
  ConsumerState<AiScreen> createState() => _AiScreenState();
}

class _AiScreenState extends ConsumerState<AiScreen> {
  final TextEditingController _input = TextEditingController();
  final ScrollController _scroll = ScrollController();

  static const List<String> _suggestions = <String>[
    'Sabah namazının vakti ne zaman biter?',
    'Zekât kimlere verilir?',
    'Hanefî ve Şâfiî\'ye göre ikindi vakti farkı nedir?',
    'Kur\'an okumanın fazileti hakkında hadis var mı?',
  ];

  @override
  void dispose() {
    _input.dispose();
    _scroll.dispose();
    super.dispose();
  }

  Future<void> _send([String? preset]) async {
    final String question = (preset ?? _input.text).trim();
    if (question.isEmpty) return;
    _input.clear();
    await ref.read(chatControllerProvider.notifier).send(question);
    if (!mounted) return;
    await Future<void>.delayed(const Duration(milliseconds: 80));
    if (_scroll.hasClients) {
      await _scroll.animateTo(
        _scroll.position.maxScrollExtent,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final AsyncValue<AiConversation?> chat = ref.watch(chatControllerProvider);
    final int usage = ref.watch(aiUsageProvider).value ?? 0;
    final bool premium = ref.watch(isPremiumProvider);
    final bool online = ref.watch(isOnlineProvider);
    final ThemeData theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('AI İslam Asistanı'),
        actions: <Widget>[
          IconButton(
            tooltip: 'Sohbetler',
            onPressed: _showConversations,
            icon: const Icon(Icons.forum_outlined, size: 20),
          ),
          IconButton(
            tooltip: 'Yeni sohbet',
            onPressed: () =>
                ref.read(chatControllerProvider.notifier).startNew(),
            icon: const Icon(Icons.add_comment_outlined, size: 20),
          ),
        ],
      ),
      body: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            child: Row(
              children: <Widget>[
                Icon(
                  online ? Icons.cloud_done_outlined : Icons.cloud_off_outlined,
                  size: 15,
                  color: online ? AppColors.success : AppColors.warning,
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    online
                        ? 'Yanıtlar Kur\'an, sahih hadis ve fıkıh kaynaklarına dayanır.'
                        : 'Çevrimdışı: temel bilgi tabanından yanıtlanır.',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
                if (!premium)
                  Text(
                    'Kalan: ${(kFreeDailyAiLimit - usage).clamp(0, kFreeDailyAiLimit)}',
                    style: theme.textTheme.labelSmall,
                  ),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: chat.when(
              loading: () => const LoadingView(message: 'Sohbet hazırlanıyor…'),
              error: (Object error, StackTrace stackTrace) => ErrorView(
                error: error,
                onRetry: () => ref.invalidate(chatControllerProvider),
              ),
              data: (AiConversation? conversation) {
                final List<AiMessage> messages =
                    conversation?.messages ?? const <AiMessage>[];
                if (messages.isEmpty) {
                  return _EmptyChat(suggestions: _suggestions, onPick: _send);
                }
                return ListView.builder(
                  controller: _scroll,
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  itemCount: messages.length,
                  itemBuilder: (BuildContext context, int index) =>
                      _MessageBubble(
                        message: messages[index],
                        onAsk: (String question) => _send(question),
                      ),
                );
              },
            ),
          ),
          if (messagesEmpty(chat))
            _SuggestionBar(suggestions: _suggestions, onPick: _send),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg,
                AppSpacing.sm,
                AppSpacing.lg,
                AppSpacing.md,
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: <Widget>[
                  Expanded(
                    child: TextField(
                      controller: _input,
                      minLines: 1,
                      maxLines: 4,
                      textInputAction: TextInputAction.send,
                      onSubmitted: (_) => _send(),
                      decoration: const InputDecoration(
                        hintText: 'Dini bir soru yazın…',
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  IconButton.filled(
                    tooltip: 'Gönder',
                    onPressed: chat.isLoading ? null : () => _send(),
                    icon: chat.isLoading
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.send_rounded, size: 20),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  bool messagesEmpty(AsyncValue<AiConversation?> chat) =>
      chat.value?.messages.isEmpty ?? true;

  void _showConversations() {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (BuildContext sheetContext) => SizedBox(
        height: MediaQuery.of(sheetContext).size.height * 0.6,
        child: Consumer(
          builder: (BuildContext context, WidgetRef ref, Widget? child) {
            final AsyncValue<List<AiConversation>> conversations = ref.watch(
              aiConversationsProvider,
            );
            return conversations.when(
              loading: () =>
                  const LoadingView(message: 'Sohbetler yükleniyor…'),
              error: (Object error, StackTrace stackTrace) => ErrorView(
                error: error,
                onRetry: () => ref.invalidate(aiConversationsProvider),
              ),
              data: (List<AiConversation> items) {
                if (items.isEmpty) {
                  return const EmptyView(
                    icon: Icons.forum_outlined,
                    title: 'Henüz sohbet yok',
                    message:
                        'İlk sorunuzu yazdığınızda sohbet burada listelenir.',
                  );
                }
                return ListView(
                  children: <Widget>[
                    for (final AiConversation item in items)
                      ListTile(
                        leading: const Icon(Icons.chat_bubble_outline_rounded),
                        title: Text(
                          item.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        subtitle: Text(
                          '${item.messages.length} mesaj',
                          style: Theme.of(context).textTheme.labelSmall,
                        ),
                        trailing: IconButton(
                          tooltip: 'Sohbeti sil',
                          onPressed: () async {
                            await ref
                                .read(runtimeProvider)
                                .ai
                                .deleteConversation(item.id);
                            ref.invalidate(aiConversationsProvider);
                          },
                          icon: const Icon(
                            Icons.delete_outline_rounded,
                            size: 20,
                          ),
                        ),
                        onTap: () async {
                          await ref
                              .read(chatControllerProvider.notifier)
                              .openConversation(item.id);
                          if (sheetContext.mounted) {
                            Navigator.of(sheetContext).pop();
                          }
                        },
                      ),
                  ],
                );
              },
            );
          },
        ),
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  const _MessageBubble({required this.message, this.onAsk});

  final AiMessage message;

  /// Önerilen soruya dokunulduğunda çağrılır.
  final ValueChanged<String>? onAsk;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final bool user = message.fromUser;
    return Align(
      alignment: user ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.86,
        ),
        margin: const EdgeInsets.only(bottom: AppSpacing.md),
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: user
              ? theme.colorScheme.primary.withValues(alpha: 0.12)
              : message.failed
              ? AppColors.warning.withValues(alpha: 0.12)
              : theme.colorScheme.surfaceContainerHighest.withValues(
                  alpha: 0.65,
                ),
          borderRadius: AppRadius.allLg,
          border: user
              ? null
              : Border.all(
                  color: theme.colorScheme.outlineVariant.withValues(
                    alpha: 0.5,
                  ),
                ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            SelectableText(
              message.text,
              style: theme.textTheme.bodyMedium?.copyWith(height: 1.6),
            ),
            if (!user && message.relatedQuestions.isNotEmpty) ...<Widget>[
              const SizedBox(height: AppSpacing.md),
              Text(
                'Bunları da sorabilirsiniz',
                style: theme.textTheme.labelSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              Wrap(
                spacing: AppSpacing.sm,
                runSpacing: AppSpacing.xs,
                children: <Widget>[
                  for (final String question in message.relatedQuestions)
                    ActionChip(
                      label: Text(question),
                      visualDensity: VisualDensity.compact,
                      onPressed: onAsk == null ? null : () => onAsk!(question),
                    ),
                ],
              ),
            ],
            if (message.sources.isNotEmpty) ...<Widget>[
              const SizedBox(height: AppSpacing.md),
              Text(
                'Kaynaklar',
                style: theme.textTheme.labelSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: AppColors.emerald500,
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              for (final AiSource source in message.sources)
                Padding(
                  padding: const EdgeInsets.only(top: 3),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Icon(
                        _iconFor(source.kind),
                        size: 13,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                      const SizedBox(width: AppSpacing.xs),
                      Expanded(
                        child: Text(
                          source.detail == null
                              ? source.label
                              : '${source.label} · ${source.detail}',
                          style: theme.textTheme.labelSmall,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
            if (message.madhabNotes.isNotEmpty) ...<Widget>[
              const SizedBox(height: AppSpacing.md),
              Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: AppColors.gold500.withValues(alpha: 0.12),
                  borderRadius: AppRadius.allMd,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      'Mezhep/görüş farkları',
                      style: theme.textTheme.labelSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    for (final String note in message.madhabNotes)
                      Text(
                        '• $note',
                        style: theme.textTheme.labelSmall?.copyWith(
                          height: 1.5,
                        ),
                      ),
                  ],
                ),
              ),
            ],
            if (message.disclaimer != null && !user) ...<Widget>[
              const SizedBox(height: AppSpacing.sm),
              Text(
                message.disclaimer!,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
            if (!user) ...<Widget>[
              const SizedBox(height: AppSpacing.sm),
              Align(
                alignment: Alignment.centerRight,
                child: IconButton(
                  visualDensity: VisualDensity.compact,
                  tooltip: 'Yanıtı paylaş',
                  onPressed: () => SharePlus.instance.share(
                    ShareParams(
                      text:
                          '${message.text}\n\n'
                          '${message.sources.map((AiSource s) => '• ${s.label}${s.detail == null ? '' : ' · ${s.detail}'}').join('\n')}\n\n'
                          '(EzanAI AI asistanı — kaynaklı yanıt)',
                    ),
                  ),
                  icon: const Icon(Icons.ios_share_rounded, size: 17),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  IconData _iconFor(AiSourceKind kind) => switch (kind) {
    AiSourceKind.quran => Icons.menu_book_rounded,
    AiSourceKind.hadith => Icons.format_quote_rounded,
    AiSourceKind.fiqh => Icons.balance_rounded,
    AiSourceKind.other => Icons.info_outline_rounded,
  };
}

class _EmptyChat extends StatelessWidget {
  const _EmptyChat({required this.suggestions, required this.onPick});

  final List<String> suggestions;
  final Future<void> Function([String? preset]) onPick;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.xl),
      children: <Widget>[
        const Icon(
          Icons.auto_awesome_rounded,
          size: 44,
          color: AppColors.gold500,
        ),
        const SizedBox(height: AppSpacing.lg),
        Text(
          'Kaynaklı dini soru-cevap',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          'Sorularınızı yazın; yanıtlar Kur\'an ayetleri, sahih hadisler ve güvenilir '
          'fıkıh kaynaklarına dayanarak kaynak gösterilir. Farklı mezhep görüşleri '
          'ayrıca belirtilir ve kesin hüküm yerine bilgi verilir.',
          style: theme.textTheme.bodyMedium?.copyWith(height: 1.6),
        ),
        const SizedBox(height: AppSpacing.xl),
        Text('Örnek sorular', style: theme.textTheme.titleSmall),
        const SizedBox(height: AppSpacing.sm),
        for (final String suggestion in suggestions)
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.sm),
            child: OutlinedButton(
              onPressed: () => onPick(suggestion),
              style: OutlinedButton.styleFrom(
                alignment: Alignment.centerLeft,
                padding: const EdgeInsets.all(AppSpacing.md),
              ),
              child: Text(suggestion, style: theme.textTheme.bodySmall),
            ),
          ),
      ],
    );
  }
}

class _SuggestionBar extends StatelessWidget {
  const _SuggestionBar({required this.suggestions, required this.onPick});

  final List<String> suggestions;
  final Future<void> Function([String? preset]) onPick;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 38,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
        itemCount: suggestions.length,
        separatorBuilder: (BuildContext context, int index) =>
            const SizedBox(width: AppSpacing.sm),
        itemBuilder: (BuildContext context, int index) => ActionChip(
          label: Text(
            suggestions[index].length > 28
                ? '${suggestions[index].substring(0, 26)}…'
                : suggestions[index],
            style: Theme.of(context).textTheme.labelSmall,
          ),
          onPressed: () => onPick(suggestions[index]),
        ),
      ),
    );
  }
}
