import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/catalog/entities/book.dart';
import '../../domain/crm/entities/dashboard.dart';
import '../../theme/app_theme.dart';
import '../providers.dart';
import '../ui/formatters.dart';

class CrmTopBooksScreen extends ConsumerStatefulWidget {
  const CrmTopBooksScreen({super.key, required this.items});

  final List<CrmTopBook> items;

  @override
  ConsumerState<CrmTopBooksScreen> createState() => _CrmTopBooksScreenState();
}

class _CrmTopBooksScreenState extends ConsumerState<CrmTopBooksScreen> {
  final Map<String, List<Book>> _booksCache = {};
  bool _isLoadingBook = false;

  @override
  void dispose() {
    _booksCache.clear();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final sorted = [...widget.items]
      ..sort((a, b) {
        final byQty = a.quantity.compareTo(b.quantity);
        if (byQty != 0) {
          return byQty;
        }
        return a.title.compareTo(b.title);
      });

    return Scaffold(
      appBar: AppBar(
        title: const Text("Eng ko'p sotilgan kitoblar"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: sorted.isEmpty
            ? Center(
                child: Text(
                  "Ma'lumot topilmadi",
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.copyWith(color: AppColors.textSecondary),
                ),
              )
            : Container(
                padding: const EdgeInsets.all(AppSpacing.xl),
                decoration: BoxDecoration(
                  color: AppColors.card,
                  borderRadius: BorderRadius.circular(AppRadii.lg),
                  border: Border.all(color: AppColors.border),
                ),
                child: Column(
                  children: [
                    _HeaderRow(),
                    const SizedBox(height: AppSpacing.sm),
                    Expanded(
                      child: ListView.separated(
                        itemCount: sorted.length,
                        separatorBuilder: (_, __) => const Divider(height: 1),
                        itemBuilder: (context, index) {
                          final item = sorted[index];
                          return Padding(
                            padding: const EdgeInsets.symmetric(
                              vertical: AppSpacing.md,
                            ),
                            child: InkWell(
                              borderRadius: BorderRadius.circular(12),
                              onTap: () => _showBookInfo(context, item.title),
                              child: Row(
                                children: [
                                  SizedBox(
                                    width: 32,
                                    child: Text(
                                      '${index + 1}',
                                      style:
                                          Theme.of(context).textTheme.bodyMedium,
                                    ),
                                  ),
                                  const SizedBox(width: AppSpacing.lg),
                                  Expanded(
                                    child: Text(
                                      item.title,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style:
                                          Theme.of(context).textTheme.bodyMedium,
                                    ),
                                  ),
                                  const SizedBox(width: AppSpacing.lg),
                                  SizedBox(
                                    width: 90,
                                    child: Text(
                                      item.quantity.toString(),
                                      textAlign: TextAlign.end,
                                      style:
                                          Theme.of(context).textTheme.bodyMedium,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }

  Future<void> _showBookInfo(BuildContext context, String title) async {
    if (_isLoadingBook) {
      return;
    }
    setState(() => _isLoadingBook = true);
    try {
      if (!_booksCache.containsKey(title)) {
        final books =
            await ref.read(getCrmBooksUseCaseProvider).call(query: title);
        _booksCache[title] = books;
      }
    } finally {
      if (mounted) {
        setState(() => _isLoadingBook = false);
      }
    }
    final items = _booksCache[title] ?? const <Book>[];
    final Book? matched = items.isNotEmpty
        ? items.firstWhere(
            (book) =>
                book.title.trim().toLowerCase() == title.trim().toLowerCase(),
            orElse: () => items.first,
          )
        : null;

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.background,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        if (matched == null) {
          return const Padding(
            padding: EdgeInsets.all(24),
            child: Text('Kitob topilmadi'),
          );
        }
        return Padding(
          padding:
              EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
          child: SafeArea(
            top: false,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    matched.title,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 12),
                  _InfoRow(
                    label: 'Ombor',
                    value: matched.stockQuantity.toString(),
                  ),
                  _InfoRow(
                    label: 'Sotuv narxi',
                    value: formatMoney(matched.salePrice ?? 0),
                  ),
                  _InfoRow(
                    label: 'Sotib olish narxi',
                    value: formatMoney(matched.purchasePrice ?? 0),
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

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadii.lg),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: Theme.of(context).textTheme.labelLarge,
              ),
            ),
            Text(
              value,
              style: Theme.of(context)
                  .textTheme
                  .titleSmall
                  ?.copyWith(color: AppColors.accentPrimary),
            ),
          ],
        ),
      ),
    );
  }
}

class _HeaderRow extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 32,
          child: Text(
            '#',
            style: Theme.of(context)
                .textTheme
                .labelSmall
                ?.copyWith(color: AppColors.textSecondary),
          ),
        ),
        const SizedBox(width: AppSpacing.lg),
        Expanded(
          child: Text(
            'Kitob',
            style: Theme.of(context)
                .textTheme
                .labelSmall
                ?.copyWith(color: AppColors.textSecondary),
          ),
        ),
        const SizedBox(width: AppSpacing.lg),
        SizedBox(
          width: 90,
          child: Text(
            'Sotilgan soni',
            textAlign: TextAlign.end,
            style: Theme.of(context)
                .textTheme
                .labelSmall
                ?.copyWith(color: AppColors.textSecondary),
          ),
        ),
      ],
    );
  }
}
