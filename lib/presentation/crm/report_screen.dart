import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/catalog/entities/book.dart';
import '../../theme/app_theme.dart';
import '../providers.dart';
import '../ui/formatters.dart';
import '../ui/section_header.dart';
import '../ui/transaction_list.dart';

class ReportScreen extends ConsumerStatefulWidget {
  const ReportScreen({super.key});

  @override
  ConsumerState<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends ConsumerState<ReportScreen> {
  DateTime? _startDate;
  DateTime? _endDate;
  TimeOfDay _startTime = const TimeOfDay(hour: 0, minute: 0);
  TimeOfDay _endTime = const TimeOfDay(hour: 23, minute: 59);

  @override
  void initState() {
    super.initState();
    Future.microtask(_load);
    Future.microtask(() {
      ref.read(crmBooksControllerProvider(null).notifier).load();
    });
  }

  Future<void> _load() async {
    await ref.read(crmReportControllerProvider.notifier).load(
          start: _startDate?.toIso8601String().split('T').first,
          end: _endDate?.toIso8601String().split('T').first,
          startTime: _formatTime(_startTime),
          endTime: _formatTime(_endTime),
        );
  }

  Future<void> _pickDate({required bool isStart}) async {
    final initialDate =
        isStart ? (_startDate ?? DateTime.now()) : (_endDate ?? DateTime.now());
    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        if (isStart) {
          _startDate = picked;
        } else {
          _endDate = picked;
        }
      });
      _load();
    }
  }

  Future<void> _pickTime({required bool isStart}) async {
    final initial = isStart ? _startTime : _endTime;
    final picked = await showTimePicker(context: context, initialTime: initial);
    if (picked != null) {
      setState(() {
        if (isStart) {
          _startTime = picked;
        } else {
          _endTime = picked;
        }
      });
      _load();
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(crmReportControllerProvider);
    final data = state.data ?? {};
    final booksState = ref.watch(crmBooksControllerProvider(null));
    final inventoryStats = _inventoryStats(booksState.items);
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.xl),
      children: [
        const SectionHeader(title: 'Hisobot'),
        const SizedBox(height: AppSpacing.lg),
        Container(
          padding: const EdgeInsets.all(AppSpacing.xl),
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(AppRadii.lg),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: _DateField(
                      label: 'Boshlanish',
                      value: _startDate,
                      onTap: () => _pickDate(isStart: true),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _DateField(
                      label: 'Tugash',
                      value: _endDate,
                      onTap: () => _pickDate(isStart: false),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              FilledButton(
                onPressed: _load,
                style: FilledButton.styleFrom(
                  minimumSize: const Size.fromHeight(48),
                ),
                child: const Text('Filtrlash'),
              ),
              const SizedBox(height: AppSpacing.md),
              _QuickRanges(
                ranges: _quickRanges(data),
                onSelect: (range) {
                  setState(() {
                    _startDate = range.start;
                    _endDate = range.end;
                  });
                  _load();
                },
              ),
              const SizedBox(height: AppSpacing.md),
              Row(
                children: [
                  Expanded(
                    child: _TimeChip(
                      label: 'Boshlanish',
                      value: _formatTime(_startTime),
                      onTap: () => _pickTime(isStart: true),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _TimeChip(
                      label: 'Tugash',
                      value: _formatTime(_endTime),
                      onTap: () => _pickTime(isStart: false),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.xl),
        if (state.isLoading && state.data == null)
          const Center(child: CircularProgressIndicator())
        else if (state.errorMessage != null && state.data == null)
          Text(state.errorMessage!)
        else
          Column(
            children: [
              _TotalRow(
                label: 'Oylik kirim (sotuv)',
                value: formatMoneyDynamic(data['income_total']),
                isPositive: true,
              ),
              const SizedBox(height: AppSpacing.md),
              _TotalRow(
                label: 'Oylik chiqim',
                value: formatMoneyDynamic(data['expense_total']),
                isPositive: false,
              ),
              const SizedBox(height: AppSpacing.md),
              _TotalRow(
                label: 'Qoldiq',
                value: formatMoneyDynamic(data['net_total']),
                isPositive: (data['net_total'] ?? 0) >= 0,
              ),
              const SizedBox(height: AppSpacing.lg),
              _MetricsGrid(
                isLoading: booksState.isLoading,
                items: [
                  _MetricItem(
                    label: 'Mavjud kitob turlari',
                    value: _formatMetricCount(
                      data['books_count'],
                      booksState.items.length,
                    ),
                  ),
                  _MetricItem(
                    label: 'Umumiy soni',
                    value: _formatMetricNumber(data['books_total_quantity']),
                  ),
                  _MetricItem(
                    label: 'Umumiy narxi',
                    value: _formatMetricMoney(data['books_total_value']),
                  ),
                  _MetricItem(
                    label: 'Sof foyda',
                    value: _formatMetricMoney(data['books_net_profit']),
                  ),
                ],
              ),
            ],
          ),
      ],
    );
  }
}

class _DateField extends StatelessWidget {
  const _DateField({
    required this.label,
    required this.value,
    required this.onTap,
  });

  final String label;
  final DateTime? value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final text = value == null ? '' : value!.toIso8601String().split('T').first;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadii.md),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppRadii.md),
          border: Border.all(color: AppColors.border),
          color: AppColors.surface,
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context)
                        .textTheme
                        .labelMedium
                        ?.copyWith(color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    text.isEmpty ? 'Tanlash' : text,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.labelLarge,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            const Icon(Icons.calendar_month_outlined, size: 18),
          ],
        ),
      ),
    );
  }
}

class _TimeChip extends StatelessWidget {
  const _TimeChip({
    required this.label,
    required this.value,
    required this.onTap,
  });

  final String label;
  final String value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadii.lg),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppRadii.lg),
          border: Border.all(color: AppColors.border),
          color: AppColors.surface,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context)
                  .textTheme
                  .labelSmall
                  ?.copyWith(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: Theme.of(context).textTheme.labelLarge,
            ),
          ],
        ),
      ),
    );
  }
}

class _QuickRanges extends StatelessWidget {
  const _QuickRanges({required this.ranges, required this.onSelect});

  final List<_QuickRange> ranges;
  final ValueChanged<_QuickRange> onSelect;

  @override
  Widget build(BuildContext context) {
    if (ranges.isEmpty) {
      return const SizedBox.shrink();
    }
    return Row(
      children: ranges
          .map(
            (range) => Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: OutlinedButton(
                  onPressed: () => onSelect(range),
                  child: Text(range.label),
                ),
              ),
            ),
          )
          .toList(),
    );
  }
}

class _TotalRow extends StatelessWidget {
  const _TotalRow({
    required this.label,
    required this.value,
    required this.isPositive,
  });

  final String label;
  final String value;
  final bool isPositive;

  @override
  Widget build(BuildContext context) {
    return TransactionRow(
      data: TransactionRowData(
        title: label,
        subtitle: 'Hisobot natijasi',
        amount: value,
        isPositive: isPositive,
        icon: Icons.trending_up,
      ),
      onTap: null,
    );
  }
}

class _QuickRange {
  const _QuickRange({
    required this.label,
    required this.start,
    required this.end,
  });

  final String label;
  final DateTime start;
  final DateTime end;
}

List<_QuickRange> _quickRanges(Map<String, dynamic> data) {
  final raw = data['quick_ranges'];
  if (raw is! List) {
    return const [];
  }
  return raw
      .whereType<Map<String, dynamic>>()
      .map((item) {
        final label = item['label']?.toString() ?? '';
        final start = DateTime.tryParse(item['start']?.toString() ?? '');
        final end = DateTime.tryParse(item['end']?.toString() ?? '');
        if (start == null || end == null) {
          return null;
        }
        return _QuickRange(label: label, start: start, end: end);
      })
      .whereType<_QuickRange>()
      .toList();
}

class _MetricItem {
  const _MetricItem({required this.label, required this.value});

  final String label;
  final String value;
}

class _MetricsGrid extends StatelessWidget {
  const _MetricsGrid({
    required this.isLoading,
    required this.items,
  });

  final bool isLoading;
  final List<_MetricItem> items;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(AppRadii.lg),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          const Row(
            children: [
              Expanded(child: Text('Ko\'rsatkichlar')),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          if (isLoading)
            const Center(child: CircularProgressIndicator())
          else
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: items.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 2.1,
              ),
              itemBuilder: (context, index) {
                final item = items[index];
                return Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(AppRadii.md),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        item.label,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context)
                            .textTheme
                            .labelSmall
                            ?.copyWith(color: AppColors.textSecondary),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        item.value,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.labelLarge,
                      ),
                    ],
                  ),
                );
              },
            ),
        ],
      ),
    );
  }
}

class _InventoryStats {
  const _InventoryStats({
    required this.typesCount,
    required this.totalQuantity,
    required this.totalSaleValue,
    required this.netProfit,
  });

  final int typesCount;
  final int totalQuantity;
  final num totalSaleValue;
  final num netProfit;
}

_InventoryStats _inventoryStats(List<Book> books) {
  var totalQuantity = 0;
  num totalSaleValue = 0;
  num netProfit = 0;
  final bookKeys = <String>{};

  for (final book in books) {
    totalQuantity += book.stockQuantity;
    final salePrice = book.salePrice ?? 0;
    final purchasePrice = book.purchasePrice ?? 0;
    totalSaleValue += salePrice * book.stockQuantity;
    netProfit += (salePrice - purchasePrice) * book.stockQuantity;
    final key = '${book.id}::${book.title}'.toLowerCase().trim();
    bookKeys.add(key);
  }

  final typesCount = books.length;
  return _InventoryStats(
    typesCount: typesCount,
    totalQuantity: totalQuantity,
    totalSaleValue: totalSaleValue,
    netProfit: netProfit,
  );
}

num _numFromDynamic(dynamic value, {num fallback = 0}) {
  if (value == null) {
    return fallback;
  }
  if (value is num) {
    return value;
  }
  final raw = value.toString().replaceAll(' ', '').replaceAll(',', '');
  final parsed = num.tryParse(raw);
  return parsed ?? fallback;
}

String _formatMetricNumber(dynamic value) {
  if (value == null) {
    return '-';
  }
  final parsed = _numFromDynamic(value, fallback: 0).toInt();
  return formatNumber(parsed);
}

String _formatMetricMoney(dynamic value) {
  if (value == null) {
    return '-';
  }
  final parsed = _numFromDynamic(value, fallback: 0);
  return formatMoney(parsed);
}

String _formatMetricCount(dynamic value, int fallbackCount) {
  final parsed = _numFromDynamic(value, fallback: 0).toInt();
  final resolved = parsed > fallbackCount ? parsed : fallbackCount;
  return formatNumber(resolved);
}

String _formatTime(TimeOfDay time) {
  final hour = time.hour.toString().padLeft(2, '0');
  final minute = time.minute.toString().padLeft(2, '0');
  return '$hour:$minute';
}
