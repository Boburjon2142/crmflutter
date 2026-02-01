import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/catalog/entities/book.dart';
import '../providers.dart';
import '../ui/formatters.dart';

class PricesScreen extends ConsumerStatefulWidget {
  const PricesScreen({super.key, this.barcode});

  final String? barcode;

  @override
  ConsumerState<PricesScreen> createState() => _PricesScreenState();
}

class _PricesScreenState extends ConsumerState<PricesScreen> {
  final _controller = TextEditingController();
  String? _query = '';
  bool _barcodeMode = false;

  @override
  void initState() {
    super.initState();
    if (widget.barcode != null && widget.barcode!.trim().isNotEmpty) {
      _barcodeMode = true;
      _query = null;
      _controller.text = widget.barcode!.trim();
    }
    Future.microtask(
      () => ref.read(crmBooksControllerProvider(_query).notifier).load(),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _search() {
    setState(() {
      _barcodeMode = false;
      _query = _controller.text.trim();
    });
    ref.read(crmBooksControllerProvider(_query).notifier).load();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(crmBooksControllerProvider(_query));
    final items = _barcodeMode
        ? state.items
            .where(
              (book) =>
                  (book.barcode ?? '').trim() == _controller.text.trim(),
            )
            .toList()
        : state.items;

    return Scaffold(
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text('Narxlar', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 12),
          TextField(
            controller: _controller,
            decoration: const InputDecoration(
              prefixIcon: Icon(Icons.search),
              hintText: 'Mahsulot qidirish',
            ),
            onSubmitted: (_) => _search(),
          ),
          const SizedBox(height: 12),
          FilledButton(onPressed: _search, child: const Text('Qidirish')),
          const SizedBox(height: 16),
          if (state.isLoading && state.items.isEmpty)
            const Center(child: CircularProgressIndicator())
          else if (state.errorMessage != null && state.items.isEmpty)
            Text(state.errorMessage!)
          else
            items.isEmpty
                ? const Text('Kitob topilmadi')
                : _PricesTable(items: items),
        ],
      ),
    );
  }
}

class _PricesTable extends StatelessWidget {
  const _PricesTable({required this.items});

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
                Expanded(flex: 3, child: Text('MAHSULOT')),
                Expanded(child: Text('SOTIB OLISH')),
                Expanded(child: Text('SOTISH')),
              ],
            ),
            const Divider(),
            ...items.map(
              (book) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Row(
                  children: [
                    Expanded(flex: 3, child: Text(book.title)),
                    Expanded(child: Text(_fmt(book.purchasePrice))),
                    Expanded(child: Text(_fmt(book.salePrice))),
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

String _fmt(double? value) {
  if (value == null) {
    return '-';
  }
  return formatNumber(value);
}
