import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';

class TransactionList extends StatelessWidget {
  const TransactionList({
    super.key,
    required this.items,
    this.onTap,
  });

  final List<TransactionRowData> items;
  final ValueChanged<TransactionRowData>? onTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: items
          .map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.md),
              child: RepaintBoundary(
                child: TransactionRow(data: item, onTap: onTap),
              ),
            ),
          )
          .toList(),
    );
  }
}

class TransactionRowData {
  const TransactionRowData({
    required this.title,
    required this.subtitle,
    required this.amount,
    this.isPositive = true,
    this.icon = Icons.payments_outlined,
  });

  final String title;
  final String subtitle;
  final String amount;
  final bool isPositive;
  final IconData icon;
}

class TransactionRow extends StatelessWidget {
  const TransactionRow({super.key, required this.data, this.onTap});

  final TransactionRowData data;
  final ValueChanged<TransactionRowData>? onTap;

  @override
  Widget build(BuildContext context) {
    final accent =
        data.isPositive ? AppColors.accentSuccess : AppColors.accentDanger;

    return InkWell(
      onTap: onTap == null ? null : () => onTap!(data),
      borderRadius: BorderRadius.circular(AppRadii.lg),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(AppRadii.lg),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: accent.withOpacity(0.15),
                borderRadius: BorderRadius.circular(AppRadii.md),
              ),
              child: Icon(data.icon, color: accent, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(data.title,
                      style: Theme.of(context).textTheme.bodyLarge),
                  const SizedBox(height: 4),
                  Text(
                    data.subtitle,
                    style: Theme.of(context)
                        .textTheme
                        .labelSmall
                        ?.copyWith(color: AppColors.textSecondary),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Text(
              data.amount,
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(color: accent),
            ),
          ],
        ),
      ),
    );
  }
}
