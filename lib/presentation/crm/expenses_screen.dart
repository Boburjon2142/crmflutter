import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/crm/entities/expense.dart';
import '../../theme/app_theme.dart';
import '../providers.dart';
import '../ui/formatters.dart';

class ExpensesScreen extends ConsumerStatefulWidget {
  const ExpensesScreen({super.key});

  @override
  ConsumerState<ExpensesScreen> createState() => _ExpensesScreenState();
}

class _ExpensesScreenState extends ConsumerState<ExpensesScreen> {
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    Future.microtask(
        () => ref.read(crmExpensesControllerProvider.notifier).load());
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(crmExpensesControllerProvider);
    final totalsByTitle = <String, double>{};
    for (final item in state.items) {
      final key = item.title.trim();
      if (key.isEmpty) {
        continue;
      }
      totalsByTitle[key] = (totalsByTitle[key] ?? 0) + item.amount;
    }
    final sortedTitles = totalsByTitle.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final totalExpense =
        sortedTitles.fold<double>(0, (sum, entry) => sum + entry.value);

    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showCreateExpenseSheet(context, state.items),
        backgroundColor: AppColors.accentPrimary,
        foregroundColor: AppColors.background,
        shape: const CircleBorder(),
        child: const Icon(Icons.add),
      ),
      body: ListView(
        controller: _scrollController,
        padding: const EdgeInsets.all(16),
        children: [
          Text('Chiqimlar', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 12),
          InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: () => _showAllExpensesByDate(context),
            child: _TotalsHeader(total: totalExpense),
          ),
          const SizedBox(height: 12),
          if (state.isLoading && state.items.isEmpty)
            const Center(child: CircularProgressIndicator())
          else if (state.errorMessage != null && state.items.isEmpty)
            Text(state.errorMessage!)
          else if (sortedTitles.isEmpty)
            const Text('Chiqimlar yo\'q')
          else
            _ExpenseSummaryCards(
              items: sortedTitles,
              onTap: (title) => _showExpenseDetails(context, title),
            ),
        ],
      ),
    );
  }

  Future<void> _showCreateExpenseSheet(
    BuildContext context,
    List<CrmExpense> items,
  ) async {
    final titleOptions = items
        .map((item) => item.title.trim())
        .where((title) => title.isNotEmpty)
        .toSet()
        .toList()
      ..sort();
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.background,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return _ExpenseCreateSheet(titleOptions: titleOptions);
      },
    );
  }

  Future<void> _showExpenseDetails(BuildContext context, String title) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.background,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return _ExpenseDetailsSheet(title: title);
      },
    );
  }

  Future<void> _showAllExpensesByDate(BuildContext context) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.background,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return const _AllExpensesByDateSheet();
      },
    );
  }
}

class _ExpenseSummaryCards extends StatelessWidget {
  const _ExpenseSummaryCards({
    required this.items,
    required this.onTap,
  });

  final List<MapEntry<String, double>> items;
  final ValueChanged<String> onTap;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final entry = items[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: RepaintBoundary(
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: () => onTap(entry.key),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.border),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        entry.key,
                        style: Theme.of(context).textTheme.titleSmall,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.card,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Text(
                        formatMoney(entry.value),
                        style: Theme.of(context)
                            .textTheme
                            .labelLarge
                            ?.copyWith(color: AppColors.accentPrimary),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _ExpenseDetailsSheet extends ConsumerWidget {
  const _ExpenseDetailsSheet({required this.title});

  final String title;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(crmExpensesControllerProvider);
    final items = state.items
        .where((item) => item.title.trim() == title)
        .toList()
      ..sort((a, b) {
        final aDate = a.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
        final bDate = b.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
        return bDate.compareTo(aDate);
      });
    final total = items.fold<double>(0, (sum, item) => sum + item.amount);

    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(title, style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 4),
              Text(
                'Jami: ${formatMoney(total)}',
                style: Theme.of(context)
                    .textTheme
                    .labelMedium
                    ?.copyWith(color: AppColors.textSecondary),
              ),
              const SizedBox(height: 16),
              if (items.isEmpty)
                Text(
                  'Chiqimlar topilmadi',
                  style: Theme.of(context).textTheme.bodyMedium,
                )
              else
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    final item = items[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _ExpenseDetailCard(item: item),
                    );
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AllExpensesByDateSheet extends ConsumerStatefulWidget {
  const _AllExpensesByDateSheet();

  @override
  ConsumerState<_AllExpensesByDateSheet> createState() =>
      _AllExpensesByDateSheetState();
}

class _AllExpensesByDateSheetState
    extends ConsumerState<_AllExpensesByDateSheet> {
  DateTime? _startDate;
  DateTime? _endDate;

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
    }
  }

  bool _matchesRange(DateTime? value) {
    if (value == null) {
      return false;
    }
    final date = DateTime(value.year, value.month, value.day);
    if (_startDate != null) {
      final start = DateTime(_startDate!.year, _startDate!.month, _startDate!.day);
      if (date.isBefore(start)) {
        return false;
      }
    }
    if (_endDate != null) {
      final end = DateTime(_endDate!.year, _endDate!.month, _endDate!.day);
      if (date.isAfter(end)) {
        return false;
      }
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(crmExpensesControllerProvider);
    final items = state.items
        .where((item) => _matchesRange(item.spentOn ?? item.createdAt))
        .toList()
      ..sort((a, b) {
        final aDate = a.createdAt ?? a.spentOn ?? DateTime.fromMillisecondsSinceEpoch(0);
        final bDate = b.createdAt ?? b.spentOn ?? DateTime.fromMillisecondsSinceEpoch(0);
        return bDate.compareTo(aDate);
      });
    final total = items.fold<double>(0, (sum, item) => sum + item.amount);

    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('Barchasi', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 4),
              Text(
                'Jami: ${formatMoney(total)}',
                style: Theme.of(context)
                    .textTheme
                    .labelMedium
                    ?.copyWith(color: AppColors.textSecondary),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _DateChip(
                      label: 'Boshlanish',
                      value: _startDate,
                      onTap: () => _pickDate(isStart: true),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _DateChip(
                      label: 'Tugash',
                      value: _endDate,
                      onTap: () => _pickDate(isStart: false),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              if (items.isEmpty)
                Text(
                  'Chiqimlar topilmadi',
                  style: Theme.of(context).textTheme.bodyMedium,
                )
              else
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    final item = items[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _ExpenseDetailCard(item: item),
                    );
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ExpenseDetailCard extends StatelessWidget {
  const _ExpenseDetailCard({required this.item});

  final CrmExpense item;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  formatMoney(item.amount),
                  style: Theme.of(context).textTheme.titleSmall,
                ),
              ),
              Text(
                _formatExpenseDateTime(item),
                style: Theme.of(context)
                    .textTheme
                    .labelSmall
                    ?.copyWith(color: AppColors.textSecondary),
              ),
            ],
          ),
          if (item.note.trim().isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              item.note,
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(color: AppColors.textSecondary),
            ),
          ],
        ],
      ),
    );
  }
}

class _DateChip extends StatelessWidget {
  const _DateChip({
    required this.label,
    required this.value,
    required this.onTap,
  });

  final String label;
  final DateTime? value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final text = value == null ? 'Tanlash' : _formatDateOnly(value!);
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
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
            Text(text, style: Theme.of(context).textTheme.labelLarge),
          ],
        ),
      ),
    );
  }
}

class _ExpenseCreateSheet extends ConsumerStatefulWidget {
  const _ExpenseCreateSheet({required this.titleOptions});

  final List<String> titleOptions;

  @override
  ConsumerState<_ExpenseCreateSheet> createState() =>
      _ExpenseCreateSheetState();
}

class _ExpenseCreateSheetState extends ConsumerState<_ExpenseCreateSheet> {
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  bool _isSaving = false;

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  Future<void> _save() async {
    final title = _titleController.text.trim();
    final amount = stripNumberFormatting(_amountController.text.trim());
    if (title.isEmpty || amount.isEmpty) {
      return;
    }
    setState(() => _isSaving = true);
    try {
      final spentOn = _formatDateOnly(_selectedDate);
      await ref.read(crmExpensesControllerProvider.notifier).create(
            title: title,
            amount: amount,
            spentOn: spentOn,
            note: _noteController.text.trim(),
          );
      await ref.read(crmExpensesControllerProvider.notifier).load();
      _titleController.clear();
      _amountController.clear();
      _noteController.clear();
      if (mounted) {
        Navigator.of(context).pop();
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    return Padding(
      padding: EdgeInsets.only(bottom: bottomInset),
      child: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Chiqim qo\'shish',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 12),
              Autocomplete<String>(
                optionsBuilder: (value) {
                  final query = value.text.trim().toLowerCase();
                  if (query.isEmpty) {
                    return const Iterable<String>.empty();
                  }
                  return widget.titleOptions.where(
                    (option) => option.toLowerCase().contains(query),
                  );
                },
                onSelected: (value) {
                  _titleController.text = value;
                },
                fieldViewBuilder: (context, controller, focusNode, onSubmit) {
                  if (controller.text != _titleController.text) {
                    controller.value = _titleController.value;
                  }
                  return TextField(
                    controller: controller,
                    focusNode: focusNode,
                    decoration: const InputDecoration(hintText: 'Sarlavha'),
                    onChanged: (value) {
                      if (_titleController.text != value) {
                        _titleController.value = controller.value;
                      }
                    },
                  );
                },
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _amountController,
                decoration: const InputDecoration(hintText: 'Summasi'),
                keyboardType: TextInputType.number,
                inputFormatters: [
                  ThousandsSeparatorInputFormatter(),
                ],
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _noteController,
                decoration: const InputDecoration(hintText: 'Izoh'),
              ),
              const SizedBox(height: 12),
              InkWell(
                onTap: _pickDate,
                borderRadius: BorderRadius.circular(AppRadii.md),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(AppRadii.md),
                    border: Border.all(color: AppColors.border),
                    color: AppColors.surface,
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          _formatDateOnly(_selectedDate),
                          style: Theme.of(context).textTheme.labelLarge,
                        ),
                      ),
                      const Icon(Icons.calendar_month_outlined, size: 18),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              FilledButton(
                onPressed: _isSaving ? null : _save,
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
    );
  }
}

class _TotalsHeader extends StatelessWidget {
  const _TotalsHeader({required this.total});

  final double total;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              'Barchasi',
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
          Text(
            formatMoney(total),
            style: Theme.of(context)
                .textTheme
                .titleSmall
                ?.copyWith(color: AppColors.accentPrimary),
          ),
        ],
      ),
    );
  }
}

String _formatDateOnly(DateTime value) {
  final two = (int v) => v.toString().padLeft(2, '0');
  return '${value.year}-${two(value.month)}-${two(value.day)}';
}

String _formatExpenseDateTime(CrmExpense item) {
  final dateBase = item.spentOn ?? item.createdAt;
  if (dateBase == null) {
    return '-';
  }
  final dateLocal = _toTashkentTime(dateBase);
  final timeBase = item.createdAt ?? item.spentOn;
  final timeLocal = timeBase == null ? null : _toTashkentTime(timeBase);
  final two = (int v) => v.toString().padLeft(2, '0');
  final date =
      '${dateLocal.year}-${two(dateLocal.month)}-${two(dateLocal.day)}';
  if (timeLocal == null) {
    return date;
  }
  return '$date ${two(timeLocal.hour)}:${two(timeLocal.minute)}';
}

DateTime _toTashkentTime(DateTime value) {
  if (value.isUtc) {
    return value.add(const Duration(hours: 5));
  }
  return value;
}
