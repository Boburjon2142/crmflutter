import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/catalog/entities/book.dart';
import '../providers.dart';
import '../ui/formatters.dart';

class InventoryScreen extends ConsumerStatefulWidget {
  const InventoryScreen({super.key});

  @override
  ConsumerState<InventoryScreen> createState() => _InventoryScreenState();
}

class _InventoryScreenState extends ConsumerState<InventoryScreen> {
  int? _selectedId;
  TextEditingController? _bookController;
  FocusNode? _bookFocusNode;
  final _deltaController = TextEditingController();
  bool _isSaving = false;
  DateTime _lastQueryTime = DateTime.fromMillisecondsSinceEpoch(0);
  String _lastQuery = '';

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(crmBooksControllerProvider(null).notifier).load();
    });
  }

  @override
  void dispose() {
    _bookController?.dispose();
    _bookFocusNode?.dispose();
    _deltaController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final delta =
        parseFormattedInt(_deltaController.text.trim(), allowNegative: true) ??
            0;
    if (_selectedId == null || delta == 0 || _isSaving) {
      return;
    }
    setState(() => _isSaving = true);
    try {
      await ref.read(adjustInventoryUseCaseProvider).call(
            bookId: _selectedId!,
            delta: delta,
            note: null,
          );
      _deltaController.clear();
      _selectedId = null;
      _bookController?.clear();
      await ref.read(crmBooksControllerProvider(null).notifier).load();
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(crmBooksControllerProvider(null));
    final selected = state.items
        .where((item) => item.id == _selectedId)
        .cast<Book?>()
        .firstWhere((item) => item != null, orElse: () => null);

    if (selected != null &&
        _bookFocusNode != null &&
        !_bookFocusNode!.hasFocus &&
        _bookController != null &&
        _bookController!.text != selected.title) {
      _bookController!.text = selected.title;
    }

    return Scaffold(
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Row(
            children: [
              Text('Ombor nazorati',
                  style: Theme.of(context).textTheme.titleLarge),
              const Spacer(),
              if (!state.isLoading)
                Chip(
                  label: Text('Kitoblar: ${state.items.length}'),
                  backgroundColor: Colors.blue.shade50,
                ),
            ],
          ),
          const SizedBox(height: 12),
          Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(color: Colors.grey.shade200),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Kitob', style: Theme.of(context).textTheme.labelLarge),
                  const SizedBox(height: 8),
                  Autocomplete<Book>(
                    displayStringForOption: (book) => book.title,
                    optionsBuilder: (value) {
                      final query = value.text.trim().toLowerCase();
                      if (query.isEmpty) {
                        return const Iterable<Book>.empty();
                      }
                      final now = DateTime.now();
                      if (_lastQuery == query &&
                          now.difference(_lastQueryTime).inMilliseconds < 150) {
                        return const Iterable<Book>.empty();
                      }
                      _lastQuery = query;
                      _lastQueryTime = now;
                      final results = <Book>[];
                      for (final book in state.items) {
                        if (results.length >= 30) {
                          break;
                        }
                        final title = book.title.toLowerCase();
                        final barcode = (book.barcode ?? '').toLowerCase();
                        if (title.contains(query) || barcode.contains(query)) {
                          results.add(book);
                        }
                      }
                      return results;
                    },
                    onSelected: (book) {
                      setState(() => _selectedId = book.id);
                    },
                    fieldViewBuilder: (context, controller, focusNode, onSubmit) {
                      _bookController ??= controller;
                      _bookFocusNode ??= focusNode;
                      return TextField(
                        controller: controller,
                        focusNode: focusNode,
                        decoration: const InputDecoration(
                          hintText: 'Kitob nomini kiriting',
                        ),
                        onChanged: (value) {
                          if (value.trim().length < 2) {
                            setState(() => _selectedId = null);
                            return;
                          }
                          final match = state.items
                              .where((book) =>
                                  book.title.toLowerCase() ==
                                  value.trim().toLowerCase())
                              .cast<Book?>()
                              .firstWhere(
                                (book) => book != null,
                                orElse: () => null,
                              );
                          setState(() {
                            _selectedId = match?.id;
                          });
                        },
                      );
                    },
                    optionsViewBuilder: (context, onSelected, options) {
                      return Align(
                        alignment: Alignment.topLeft,
                        child: Material(
                          elevation: 0,
                          color: Theme.of(context).colorScheme.surface,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: BorderSide(
                              color: Theme.of(context).dividerColor,
                            ),
                          ),
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(maxHeight: 260),
                            child: ListView.separated(
                              padding: const EdgeInsets.all(8),
                              shrinkWrap: true,
                              itemCount: options.length,
                              separatorBuilder: (_, __) =>
                                  const Divider(height: 1),
                              itemBuilder: (context, index) {
                                final book = options.elementAt(index);
                                return ListTile(
                                  title: Text(book.title),
                                  subtitle: book.barcode == null
                                      ? null
                                      : Text(book.barcode!),
                                  onTap: () => onSelected(book),
                                );
                              },
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 12),
                  Text('O\'zgarish', style: Theme.of(context).textTheme.labelLarge),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _deltaController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(hintText: 'Masalan: -2'),
                    inputFormatters: [
                      ThousandsSeparatorInputFormatter(allowNegative: true),
                    ],
                  ),
                  const SizedBox(height: 12),
                  FilledButton(
                    onPressed: state.isLoading || _isSaving ? null : _save,
                    child: _isSaving
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Saqlash'),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          if (state.isLoading && state.items.isEmpty)
            const Center(child: CircularProgressIndicator())
          else if (state.errorMessage != null && state.items.isEmpty)
            Text(state.errorMessage!)
          else
            _InventoryTable(items: state.items),
        ],
      ),
    );
  }
}

class _InventoryTable extends StatelessWidget {
  const _InventoryTable({required this.items});

  final List<Book> items;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: const [
                Expanded(flex: 3, child: Text('KITOB')),
                Expanded(flex: 3, child: Text('SHTRIX-KOD')),
                Expanded(child: Text('OMBOR')),
              ],
            ),
            const Divider(),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: items.length,
              itemBuilder: (context, index) {
                final book = items[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Row(
                    children: [
                      Expanded(flex: 3, child: Text(book.title)),
                      Expanded(
                        flex: 3,
                        child: Text(book.barcode ?? '-'),
                      ),
                      Expanded(child: Text(formatNumber(book.stockQuantity))),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
