import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/crm/entities/debt.dart';
import '../providers.dart';
import '../ui/formatters.dart';

class DebtsScreen extends ConsumerStatefulWidget {
  const DebtsScreen({super.key});

  @override
  ConsumerState<DebtsScreen> createState() => _DebtsScreenState();
}

class _DebtsScreenState extends ConsumerState<DebtsScreen> {
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();

  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(crmDebtsControllerProvider.notifier).load());
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final name = _nameController.text.trim();
    final amount = _amountController.text.trim();
    if (name.isEmpty || amount.isEmpty) {
      return;
    }
    await ref.read(crmDebtsControllerProvider.notifier).create(
          fullName: name,
          amount: amount,
          phone: _phoneController.text.trim(),
          note: _noteController.text.trim(),
        );
    _nameController.clear();
    _phoneController.clear();
    _amountController.clear();
    _noteController.clear();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(crmDebtsControllerProvider);

    return Scaffold(
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text('Qarzdorlar', style: Theme.of(context).textTheme.titleLarge),
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
                  Text('Qarz qo\'shish', style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _nameController,
                    decoration: const InputDecoration(hintText: 'F.I.Sh'),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _phoneController,
                    decoration: const InputDecoration(hintText: 'Telefon (ixtiyoriy)'),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _amountController,
                    decoration: const InputDecoration(hintText: 'Qarz summasi'),
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _noteController,
                    decoration: const InputDecoration(hintText: 'Izoh (ixtiyoriy)'),
                  ),
                  const SizedBox(height: 12),
                  FilledButton(
                    onPressed: state.isSaving ? null : _save,
                    style: FilledButton.styleFrom(backgroundColor: Colors.red),
                    child: const Text('Qarzni saqlash'),
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
            _DebtTable(items: state.items),
        ],
      ),
    );
  }
}

class _DebtTable extends StatelessWidget {
  const _DebtTable({required this.items});

  final List<CrmDebt> items;

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
          child: Text('Qarzdorlar yo\'q'),
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
                Expanded(flex: 2, child: Text('F.I.Sh')),
                Expanded(child: Text('Telefon')),
                Expanded(child: Text('Qarz')),
                Expanded(child: Text("To'langan")),
              ],
            ),
            const Divider(),
            ...items.map(
              (item) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Row(
                  children: [
                    Expanded(flex: 2, child: Text(item.fullName)),
                    Expanded(child: Text(item.phone)),
                    Expanded(child: Text(_fmt(item.amount))),
                    Expanded(child: Text(_fmt(item.paidAmount))),
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

String _fmt(double value) {
  return formatNumber(value);
}
