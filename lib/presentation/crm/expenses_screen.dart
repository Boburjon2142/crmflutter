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
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();
  String? _selectedTitle;
  bool _typesExpanded = false;

  @override
  void initState() {
    super.initState();
    Future.microtask(
        () => ref.read(crmExpensesControllerProvider.notifier).load());
  }

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final title = _titleController.text.trim();
    final amount = stripNumberFormatting(_amountController.text.trim());
    if (title.isEmpty || amount.isEmpty) {
      return;
    }
    await ref.read(crmExpensesControllerProvider.notifier).create(
          title: title,
          amount: amount,
          note: _noteController.text.trim(),
        );
    _titleController.clear();
    _amountController.clear();
    _noteController.clear();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(crmExpensesControllerProvider);
    final titleOptions = state.items
        .map((item) => item.title.trim())
        .where((title) => title.isNotEmpty)
        .toSet()
        .toList()
      ..sort();
    final filteredItems = _selectedTitle == null ||
            _selectedTitle!.trim().isEmpty
        ? state.items
        : state.items
            .where((item) => item.title == _selectedTitle)
            .toList();
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

    return Scaffold(
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text('Chiqimlar', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 12),
          LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth >= 900;
              final cards = [
                _ExpenseCreateCard(
                  titleController: _titleController,
                  amountController: _amountController,
                  noteController: _noteController,
                  titleOptions: titleOptions,
                  isSaving: state.isSaving,
                  errorMessage: state.errorMessage,
                  onSave: _save,
                ),
                _ExpenseTypesCard(
                  items: sortedTitles,
                  selectedTitle: _selectedTitle,
                  isExpanded: _typesExpanded,
                  onToggle: () {
                    setState(() {
                      _typesExpanded = !_typesExpanded;
                    });
                  },
                  onSelect: (value) {
                    setState(() {
                      _selectedTitle = value;
                    });
                  },
                ),
              ];
              if (isWide) {
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: cards[0]),
                    const SizedBox(width: 16),
                    Expanded(child: cards[1]),
                  ],
                );
              }
              return Column(
                children: [
                  cards[0],
                  const SizedBox(height: 16),
                  cards[1],
                ],
              );
            },
          ),
          const SizedBox(height: 16),
          if (state.isLoading && state.items.isEmpty)
            const Center(child: CircularProgressIndicator())
          else if (state.errorMessage != null && state.items.isEmpty)
            Text(state.errorMessage!)
          else
            _ExpensesTable(
              items: filteredItems,
              title: _selectedTitle,
            ),
        ],
      ),
    );
  }
}

class _ExpenseCreateCard extends StatelessWidget {
  const _ExpenseCreateCard({
    required this.titleController,
    required this.amountController,
    required this.noteController,
    required this.titleOptions,
    required this.isSaving,
    required this.errorMessage,
    required this.onSave,
  });

  final TextEditingController titleController;
  final TextEditingController amountController;
  final TextEditingController noteController;
  final List<String> titleOptions;
  final bool isSaving;
  final String? errorMessage;
  final VoidCallback onSave;

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
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Chiqim qo\'shish',
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            Autocomplete<String>(
              optionsBuilder: (value) {
                final query = value.text.trim().toLowerCase();
                if (query.isEmpty) {
                  return const Iterable<String>.empty();
                }
                return titleOptions.where(
                  (option) => option.toLowerCase().contains(query),
                );
              },
              onSelected: (value) {
                titleController.text = value;
              },
              fieldViewBuilder: (context, controller, focusNode, onSubmit) {
                if (controller.text != titleController.text) {
                  controller.value = titleController.value;
                }
                return TextField(
                  controller: controller,
                  focusNode: focusNode,
                  decoration: const InputDecoration(hintText: 'Sarlavha'),
                  onChanged: (value) {
                    if (titleController.text != value) {
                      titleController.value = controller.value;
                    }
                  },
                );
              },
            ),
            const SizedBox(height: 12),
            TextField(
              controller: amountController,
              decoration: const InputDecoration(hintText: 'Summasi'),
              keyboardType: TextInputType.number,
              inputFormatters: [
                ThousandsSeparatorInputFormatter(),
              ],
            ),
            const SizedBox(height: 12),
            TextField(
              controller: noteController,
              decoration: const InputDecoration(hintText: 'Izoh'),
            ),
            const SizedBox(height: 12),
            FilledButton(
              onPressed: isSaving ? null : onSave,
              child: const Text('Saqlash'),
            ),
            if (errorMessage != null && errorMessage!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  errorMessage!,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.error,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _ExpenseTypesCard extends StatelessWidget {
  const _ExpenseTypesCard({
    required this.items,
    required this.selectedTitle,
    required this.isExpanded,
    required this.onToggle,
    required this.onSelect,
  });

  final List<MapEntry<String, double>> items;
  final String? selectedTitle;
  final bool isExpanded;
  final VoidCallback onToggle;
  final ValueChanged<String?> onSelect;

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
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text('Chiqim turlari',
                      style: Theme.of(context).textTheme.titleMedium),
                ),
                IconButton(
                  onPressed: onToggle,
                  icon: Icon(
                    isExpanded ? Icons.expand_less : Icons.expand_more,
                  ),
                ),
              ],
            ),
            if (isExpanded) ...[
              const SizedBox(height: 12),
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: items.length + 1,
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemBuilder: (context, index) {
                  if (index == 0) {
                    final isSelected =
                        selectedTitle == null || selectedTitle!.isEmpty;
                    return _TitleChip(
                      title: 'Barchasi',
                      total: items.fold<double>(
                        0,
                        (sum, item) => sum + item.value,
                      ),
                      isSelected: isSelected,
                      onTap: () => onSelect(null),
                    );
                  }
                  final entry = items[index - 1];
                  return _TitleChip(
                    title: entry.key,
                    total: entry.value,
                    isSelected: selectedTitle == entry.key,
                    onTap: () => onSelect(entry.key),
                  );
                },
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _TitleChip extends StatelessWidget {
  const _TitleChip({
    required this.title,
    required this.total,
    required this.isSelected,
    required this.onTap,
  });

  final String title;
  final double total;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: isSelected ? AppColors.accentPrimary : AppColors.surface,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: isSelected
                            ? AppColors.background
                            : AppColors.textPrimary,
                      ),
                ),
              ),
              Text(
                _fmt(total),
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: isSelected
                          ? AppColors.background
                          : AppColors.textPrimary,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ExpensesTable extends StatelessWidget {
  const _ExpensesTable({required this.items, required this.title});

  final List<CrmExpense> items;
  final String? title;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return Card(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: Colors.grey.shade200),
        ),
        child: const Padding(
          padding: EdgeInsets.all(16),
          child: Text('Chiqimlar yo\'q'),
        ),
      );
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
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Chiqim tarixi: ${title == null || title!.isEmpty ? "Barchasi" : title}',
                style: Theme.of(context).textTheme.titleSmall,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: const [
                Expanded(flex: 2, child: Text('Sarlavha')),
                Expanded(child: Text('Summa')),
                Expanded(child: Text('Sana')),
              ],
            ),
            const Divider(),
            ...items.map(
              (item) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Row(
                  children: [
                    Expanded(flex: 2, child: Text(item.title)),
                    Expanded(child: Text(_fmt(item.amount))),
                    Expanded(child: Text(_fmtDate(item.spentOn))),
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

String _fmt(double value) => formatNumber(value);

String _fmtDate(DateTime? value) {
  if (value == null) {
    return '';
  }
  final two = (int v) => v.toString().padLeft(2, '0');
  return '${value.year}-${two(value.month)}-${two(value.day)}';
}
