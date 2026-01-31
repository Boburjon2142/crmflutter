import 'package:flutter/material.dart';

import '../../domain/catalog/entities/book.dart';
import '../ui/formatters.dart';

class BookDetailScreen extends StatelessWidget {
  const BookDetailScreen({super.key, required this.book});

  final Book book;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(book.title)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          AspectRatio(
            aspectRatio: 2 / 3,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: book.coverImageUrl == null
                  ? Container(
                      color: Colors.blue.shade50,
                      child: const Icon(Icons.menu_book, size: 64),
                    )
                  : Image.network(
                      book.coverImageUrl!,
                      fit: BoxFit.cover,
                    ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            book.title,
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            book.author?.name ?? '',
            style: Theme.of(context)
                .textTheme
                .titleSmall
                ?.copyWith(color: Colors.grey.shade600),
          ),
          const SizedBox(height: 12),
          _InfoRow(label: 'Narxi', value: _formatPrice(book.salePrice)),
          _InfoRow(label: 'Kategoriya', value: book.category?.name ?? '-'),
          _InfoRow(label: 'Format', value: book.bookFormat ?? '-'),
          _InfoRow(
            label: 'Betlar',
            value: book.pages?.toString() ?? '-',
          ),
          _InfoRow(
            label: 'Ko\'rishlar',
            value: book.views.toString(),
          ),
          const SizedBox(height: 12),
          Text(
            'Tavsif',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Text(book.description.isEmpty ? 'Tavsif yo\'q' : book.description),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
            child: Text(
              label,
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(color: Colors.grey.shade600),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}

String _formatPrice(double? value) {
  if (value == null) {
    return '-';
  }
  return formatMoney(value);
}
