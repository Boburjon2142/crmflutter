import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/catalog/entities/book.dart';
import '../controllers/crm_pos_controller.dart';
import '../providers.dart';
import '../ui/formatters.dart';

class PosScreen extends ConsumerStatefulWidget {
  const PosScreen({super.key});

  @override
  ConsumerState<PosScreen> createState() => _PosScreenState();
}

class _PosScreenState extends ConsumerState<PosScreen> {
  final _searchController = TextEditingController();
  final _discountController = TextEditingController();
  String _query = '';

  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(crmBooksControllerProvider(_query).notifier).load());
  }

  @override
  void dispose() {
    _searchController.dispose();
    _discountController.dispose();
    super.dispose();
  }

  void _search() {
    setState(() => _query = _searchController.text.trim());
    ref.read(crmBooksControllerProvider(_query).notifier).load();
  }

  @override
  Widget build(BuildContext context) {
    final booksState = ref.watch(crmBooksControllerProvider(_query));
    final posState = ref.watch(crmPosControllerProvider);
    final posController = ref.read(crmPosControllerProvider.notifier);

    return Scaffold(
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text('POS', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 12),
          TextField(
            controller: _searchController,
            decoration: const InputDecoration(
              prefixIcon: Icon(Icons.search),
              hintText: 'Mahsulot qidirish',
            ),
            onSubmitted: (_) => _search(),
          ),
          const SizedBox(height: 12),
          FilledButton(onPressed: _search, child: const Text('Qidirish')),
          const SizedBox(height: 16),
          _BooksGrid(
            items: booksState.items,
            isLoading: booksState.isLoading,
            onAdd: posController.addBook,
          ),
          const SizedBox(height: 16),
          _CartPanel(
            state: posState,
            onUpdate: posController.updateQuantity,
            onRemove: posController.remove,
            discountController: _discountController,
            onSubmit: (discount) => posController.submit(
              discountAmount: discount,
            ),
          ),
        ],
      ),
    );
  }
}

class _BooksGrid extends StatelessWidget {
  const _BooksGrid({
    required this.items,
    required this.isLoading,
    required this.onAdd,
  });

  final List<Book> items;
  final bool isLoading;
  final ValueChanged<Book> onAdd;

  @override
  Widget build(BuildContext context) {
    if (isLoading && items.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: items.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.8,
      ),
      itemBuilder: (context, index) {
        final book = items[index];
        return InkWell(
          onTap: () => onAdd(book),
          child: Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(color: Colors.grey.shade200),
            ),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: Colors.blue.shade50,
                      ),
                      child: const Icon(Icons.menu_book, size: 40),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    book.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _fmt(book.salePrice),
                    style: Theme.of(context)
                        .textTheme
                        .labelSmall
                        ?.copyWith(color: Colors.blue.shade700),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _CartPanel extends StatelessWidget {
  const _CartPanel({
    required this.state,
    required this.onUpdate,
    required this.onRemove,
    required this.onSubmit,
    required this.discountController,
  });

  final CrmPosState state;
  final void Function(Book book, int quantity) onUpdate;
  final void Function(Book book) onRemove;
  final ValueChanged<String?> onSubmit;
  final TextEditingController discountController;

  @override
  Widget build(BuildContext context) {
    if (state.items.isEmpty) {
      return const SizedBox.shrink();
    }
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
              children: [
                Text('Savat', style: Theme.of(context).textTheme.titleMedium),
                const Spacer(),
                Text(_fmtMoney(_subtotal(state.items))),
              ],
            ),
            const SizedBox(height: 12),
            ...state.items.map(
              (item) => Row(
                children: [
                  Expanded(child: Text(item.book.title)),
                  IconButton(
                    onPressed: () =>
                        onUpdate(item.book, item.quantity - 1),
                    icon: const Icon(Icons.remove),
                  ),
                  Text(item.quantity.toString()),
                  IconButton(
                    onPressed: () =>
                        onUpdate(item.book, item.quantity + 1),
                    icon: const Icon(Icons.add),
                  ),
                  IconButton(
                    onPressed: () => onRemove(item.book),
                    icon: const Icon(Icons.delete_outline),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: discountController,
              keyboardType: TextInputType.number,
              inputFormatters: [
                ThousandsSeparatorInputFormatter(),
              ],
              decoration: const InputDecoration(
                labelText: 'Chegirma (so\'m)',
                hintText: '0',
              ),
            ),
            const SizedBox(height: 12),
            ValueListenableBuilder<TextEditingValue>(
              valueListenable: discountController,
              builder: (context, value, _) {
                final subtotal = _subtotal(state.items);
                final discount = _parseDiscount(value.text);
                final total = subtotal - discount;
                return Column(
                  children: [
                    Row(
                      children: [
                        Text(
                          'Jami',
                          style: Theme.of(context).textTheme.labelMedium,
                        ),
                        const Spacer(),
                        Text(
                          _fmtMoney(subtotal),
                          style: Theme.of(context).textTheme.labelMedium,
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Text(
                          'Chegirma',
                          style: Theme.of(context).textTheme.labelMedium,
                        ),
                        const Spacer(),
                        Text(
                          '-${_fmtMoney(discount)}',
                          style: Theme.of(context).textTheme.labelMedium,
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Text(
                          'To\'lov',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const Spacer(),
                        Text(
                          _fmtMoney(total < 0 ? 0 : total),
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ],
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 12),
            FilledButton(
              onPressed: state.isSubmitting
                  ? null
                  : () => onSubmit(_sanitizeDiscount(discountController.text)),
              child: const Text('To\'lovni yakunlash'),
            ),
            if (state.errorMessage != null) ...[
              const SizedBox(height: 8),
              Text(
                state.errorMessage!,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

String _fmt(double? value) {
  if (value == null) {
    return '-';
  }
  return formatMoney(value);
}

String _fmtMoney(double value) {
  return formatMoney(value);
}

double _subtotal(List<PosItem> items) {
  return items.fold<double>(0, (sum, item) => sum + item.total);
}

double _parseDiscount(String raw) {
  if (raw.trim().isEmpty) {
    return 0;
  }
  final normalized = raw.replaceAll(' ', '').replaceAll(',', '');
  return double.tryParse(normalized) ?? 0;
}

String? _sanitizeDiscount(String raw) {
  final value = _parseDiscount(raw);
  if (value <= 0) {
    return null;
  }
  return value.toStringAsFixed(0);
}
