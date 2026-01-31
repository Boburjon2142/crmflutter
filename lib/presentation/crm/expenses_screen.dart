import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/crm/entities/expense.dart';
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

  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(crmExpensesControllerProvider.notifier).load());
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
    final amount = _amountController.text.trim();
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

    return Scaffold(
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text('Chiqimlar', style: Theme.of(context).textTheme.titleLarge),
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
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text('Chiqim qo\'shish',
                      style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _titleController,
                    decoration: const InputDecoration(hintText: 'Sarlavha'),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _amountController,
                    decoration: const InputDecoration(hintText: 'Summasi'),
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _noteController,
                    decoration: const InputDecoration(hintText: 'Izoh'),
                  ),
                  const SizedBox(height: 12),
                  FilledButton(
                    onPressed: state.isSaving ? null : _save,
                    child: const Text('Saqlash'),
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
            _ExpensesTable(items: state.items),
        ],
      ),
    );
  }
}

class _ExpensesTable extends StatelessWidget {
  const _ExpensesTable({required this.items});

  final List<CrmExpense> items;

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
