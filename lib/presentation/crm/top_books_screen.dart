import 'package:flutter/material.dart';

import '../../domain/crm/entities/dashboard.dart';
import '../../theme/app_theme.dart';

class CrmTopBooksScreen extends StatelessWidget {
  const CrmTopBooksScreen({super.key, required this.items});

  final List<CrmTopBook> items;

  @override
  Widget build(BuildContext context) {
    final sorted = [...items]
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
                            child: Row(
                              children: [
                                SizedBox(
                                  width: 32,
                                  child: Text(
                                    '${index + 1}',
                                    style: Theme.of(context).textTheme.bodyMedium,
                                  ),
                                ),
                                const SizedBox(width: AppSpacing.lg),
                                Expanded(
                                  child: Text(
                                    item.title,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: Theme.of(context).textTheme.bodyMedium,
                                  ),
                                ),
                                const SizedBox(width: AppSpacing.lg),
                                SizedBox(
                                  width: 90,
                                  child: Text(
                                    item.quantity.toString(),
                                    textAlign: TextAlign.end,
                                    style: Theme.of(context).textTheme.bodyMedium,
                                  ),
                                ),
                              ],
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
