import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/crm/entities/search.dart';
import '../providers.dart';

class CrmSearchScreen extends ConsumerStatefulWidget {
  const CrmSearchScreen({super.key, required this.initialQuery});

  final String initialQuery;

  @override
  ConsumerState<CrmSearchScreen> createState() => _CrmSearchScreenState();
}

class _CrmSearchScreenState extends ConsumerState<CrmSearchScreen> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialQuery);
    Future.microtask(() {
      ref.read(crmSearchControllerProvider.notifier).run(widget.initialQuery);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    ref.read(crmSearchControllerProvider.notifier).run(_controller.text.trim());
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(crmSearchControllerProvider);
    final result = state.result;

    return Scaffold(
      appBar: AppBar(title: const Text('Qidiruv')),
      body: SafeArea(
        bottom: true,
        child: ListView(
          padding: EdgeInsets.fromLTRB(
            16,
            16,
            16,
            16 + MediaQuery.of(context).padding.bottom,
          ),
          children: [
            TextField(
              controller: _controller,
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.search),
                hintText: 'Qidiruv',
              ),
              onSubmitted: (_) => _submit(),
            ),
            const SizedBox(height: 12),
            FilledButton(onPressed: _submit, child: const Text('Qidirish')),
            const SizedBox(height: 16),
            if (state.isLoading)
              const Center(child: CircularProgressIndicator()),
            if (state.errorMessage != null)
              Text(state.errorMessage!, textAlign: TextAlign.center),
            if (result != null) ...[
              _QueryTitle(query: result.query),
              const SizedBox(height: 12),
              ...result.sections.map((section) => _SectionCard(section: section)),
            ],
          ],
        ),
      ),
    );
  }
}

class _QueryTitle extends StatelessWidget {
  const _QueryTitle({required this.query});

  final String query;

  @override
  Widget build(BuildContext context) {
    if (query.isEmpty) {
      return const SizedBox.shrink();
    }
    return Row(
      children: [
        Text(
          'Qidiruv natijalari',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const Spacer(),
        Text(
          '"$query"',
          style: Theme.of(context)
              .textTheme
              .labelLarge
              ?.copyWith(color: Colors.blue.shade700),
        ),
      ],
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.section});

  final CrmSearchSection section;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(section.title, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            if (section.items.isEmpty)
              const Text('Topilmadi')
            else
              ...section.items.take(5).map(
                    (item) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(item.title,
                              style: Theme.of(context).textTheme.bodyMedium),
                          if (item.subtitle.isNotEmpty)
                            Text(
                              item.subtitle,
                              style: Theme.of(context)
                                  .textTheme
                                  .labelSmall
                                  ?.copyWith(color: Colors.grey.shade600),
                            ),
                          if (item.meta.isNotEmpty)
                            Text(
                              item.meta,
                              style: Theme.of(context)
                                  .textTheme
                                  .labelSmall
                                  ?.copyWith(color: Colors.blueGrey),
                            ),
                        ],
                      ),
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}
