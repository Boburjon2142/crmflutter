import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/crm/entities/debt.dart';
import '../../theme/app_theme.dart';
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
  String? _selectedName;
  bool _listExpanded = false;

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
    final amount = stripNumberFormatting(_amountController.text.trim());
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
    final activeItems = state.items
        .where((item) => (item.amount - item.paidAmount) > 0)
        .toList();
    final nameOptions = activeItems
        .map((item) => item.fullName.trim())
        .where((name) => name.isNotEmpty)
        .toSet()
        .toList()
      ..sort();
    final filteredItems = _selectedName == null || _selectedName!.isEmpty
        ? activeItems
        : activeItems.where((item) => item.fullName == _selectedName).toList();
    final totalsByName = <String, double>{};
    for (final item in activeItems) {
      final key = item.fullName.trim();
      if (key.isEmpty) {
        continue;
      }
      final remaining =
          (item.amount - item.paidAmount) < 0 ? 0 : (item.amount - item.paidAmount);
      totalsByName[key] = (totalsByName[key] ?? 0) + remaining;
    }
    final sortedNames = totalsByName.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Scaffold(
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text('Qarzdorlar', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 12),
          LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth >= 900;
              final cards = [
                _DebtCreateCard(
                  nameController: _nameController,
                  phoneController: _phoneController,
                  amountController: _amountController,
                  noteController: _noteController,
                  nameOptions: nameOptions,
                  isSaving: state.isSaving,
                  onSave: _save,
                  errorMessage: state.errorMessage,
                ),
                _DebtorsListCard(
                  items: sortedNames,
                  selectedName: _selectedName,
                  isExpanded: _listExpanded,
                  onToggle: () {
                    setState(() {
                      _listExpanded = !_listExpanded;
                    });
                  },
                  onSelect: (value) {
                    setState(() {
                      _selectedName = value;
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
            _DebtTable(
              items: filteredItems,
              title: _selectedName,
              onPaidChanged: (debt, paidRaw) {
                final cleaned = stripNumberFormatting(paidRaw);
                final parsed = double.tryParse(cleaned) ?? 0;
                final nextPaid = debt.paidAmount + parsed;
                final clamped = nextPaid < 0
                    ? 0
                    : (nextPaid > debt.amount ? debt.amount : nextPaid);
                ref.read(crmDebtsControllerProvider.notifier).updatePaidAmount(
                      id: debt.id,
                      paidAmount: clamped.toStringAsFixed(0),
                      isPaid: clamped >= debt.amount,
                    );
              },
            ),
        ],
      ),
    );
  }
}

class _DebtCreateCard extends StatelessWidget {
  const _DebtCreateCard({
    required this.nameController,
    required this.phoneController,
    required this.amountController,
    required this.noteController,
    required this.nameOptions,
    required this.isSaving,
    required this.onSave,
    required this.errorMessage,
  });

  final TextEditingController nameController;
  final TextEditingController phoneController;
  final TextEditingController amountController;
  final TextEditingController noteController;
  final List<String> nameOptions;
  final bool isSaving;
  final VoidCallback onSave;
  final String? errorMessage;

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
            Text('Qarz qo\'shish',
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            Autocomplete<String>(
              optionsBuilder: (value) {
                final query = value.text.trim().toLowerCase();
                if (query.isEmpty) {
                  return const Iterable<String>.empty();
                }
                return nameOptions.where(
                  (option) => option.toLowerCase().contains(query),
                );
              },
              onSelected: (value) {
                nameController.text = value;
              },
              fieldViewBuilder: (context, controller, focusNode, onSubmit) {
                if (controller.text != nameController.text) {
                  controller.value = nameController.value;
                }
                return TextField(
                  controller: controller,
                  focusNode: focusNode,
                  decoration: const InputDecoration(hintText: 'F.I.Sh'),
                  onChanged: (value) {
                    if (nameController.text != value) {
                      nameController.value = controller.value;
                    }
                  },
                );
              },
            ),
            const SizedBox(height: 12),
            TextField(
              controller: phoneController,
              decoration: const InputDecoration(hintText: 'Telefon (ixtiyoriy)'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: amountController,
              decoration: const InputDecoration(hintText: 'Qarz summasi'),
              keyboardType: TextInputType.number,
              inputFormatters: [
                ThousandsSeparatorInputFormatter(),
              ],
            ),
            const SizedBox(height: 12),
            TextField(
              controller: noteController,
              decoration: const InputDecoration(hintText: 'Izoh (ixtiyoriy)'),
            ),
            const SizedBox(height: 12),
            FilledButton(
              onPressed: isSaving ? null : onSave,
              style: FilledButton.styleFrom(backgroundColor: Colors.red),
              child: const Text('Qarzni saqlash'),
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

class _DebtorsListCard extends StatelessWidget {
  const _DebtorsListCard({
    required this.items,
    required this.selectedName,
    required this.isExpanded,
    required this.onToggle,
    required this.onSelect,
  });

  final List<MapEntry<String, double>> items;
  final String? selectedName;
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
                  child: Text('Qarzdorlar ro\'yxati',
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
                        selectedName == null || selectedName!.isEmpty;
                    return _NameChip(
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
                  return _NameChip(
                    title: entry.key,
                    total: entry.value,
                    isSelected: selectedName == entry.key,
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

class _NameChip extends StatelessWidget {
  const _NameChip({
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
                formatNumber(total),
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

class _DebtTable extends StatefulWidget {
  const _DebtTable({
    required this.items,
    required this.title,
    required this.onPaidChanged,
  });

  final List<CrmDebt> items;
  final String? title;
  final void Function(CrmDebt debt, String paidRaw) onPaidChanged;

  @override
  State<_DebtTable> createState() => _DebtTableState();
}

class _DebtTableState extends State<_DebtTable> {
  final Map<int, TextEditingController> _controllers = {};
  final Map<int, FocusNode> _focusNodes = {};
  final Map<int, String> _lastSent = {};

  @override
  void initState() {
    super.initState();
    for (final item in widget.items) {
      _controllers[item.id] = TextEditingController(
        text: _paidText(item.paidAmount),
      );
      _focusNodes[item.id] = _buildFocusNode(item.id);
    }
  }

  @override
  void didUpdateWidget(covariant _DebtTable oldWidget) {
    super.didUpdateWidget(oldWidget);
    final ids = widget.items.map((e) => e.id).toSet();
    final removeIds = _controllers.keys.where((id) => !ids.contains(id)).toList();
    for (final id in removeIds) {
      _controllers.remove(id)?.dispose();
      _focusNodes.remove(id)?.dispose();
    }
    for (final item in widget.items) {
      final controller = _controllers.putIfAbsent(
        item.id,
        () => TextEditingController(),
      );
      final focusNode =
          _focusNodes.putIfAbsent(item.id, () => _buildFocusNode(item.id));
      final text = _paidText(item.paidAmount);
      if (!focusNode.hasFocus && controller.text != text) {
        controller.text = text;
      }
    }
  }

  @override
  void dispose() {
    for (final controller in _controllers.values) {
      controller.dispose();
    }
    for (final node in _focusNodes.values) {
      node.dispose();
    }
    super.dispose();
  }

  FocusNode _buildFocusNode(int id) {
    final node = FocusNode();
    node.addListener(() {
      if (!node.hasFocus) {
        _notifyPaidChanged(id);
      }
    });
    return node;
  }

  void _notifyPaidChanged(int id) {
    final item = widget.items
        .cast<CrmDebt?>()
        .firstWhere((e) => e?.id == id, orElse: () => null);
    if (item == null) {
      return;
    }
    final text = _controllers[id]?.text ?? '';
    final parsed = parseFormattedInt(text) ?? 0;
    if (parsed <= 0) {
      return;
    }
    if (_lastSent[id] == text) {
      return;
    }
    _lastSent[id] = text;
    widget.onPaidChanged(item, text);
    _controllers[id]?.clear();
  }

  String _paidText(double paidAmount) {
    return '';
  }

  double _currentPaidAmount(CrmDebt item) {
    final raw = _controllers[item.id]?.text ?? '';
    final parsed = parseFormattedInt(raw) ?? 0;
    return item.paidAmount + parsed.toDouble();
  }

  @override
  Widget build(BuildContext context) {
    final items = widget.items;
    final isNarrow = MediaQuery.of(context).size.width < 420;
    final headerStyle = Theme.of(context).textTheme.labelSmall;
    final cellStyle = isNarrow
        ? Theme.of(context).textTheme.bodySmall
        : Theme.of(context).textTheme.bodyMedium;

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
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Qarzlar: ${widget.title == null || widget.title!.isEmpty ? "Barchasi" : widget.title}',
                style: Theme.of(context).textTheme.titleSmall,
              ),
            ),
            const SizedBox(height: 12),
            if (isNarrow) ...[
              ...items.map((item) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _DebtCard(
                      item: item,
                      controller: _controllers[item.id]!,
                      focusNode: _focusNodes[item.id]!,
                      onPaidChanged: (value) => widget.onPaidChanged(item, value),
                    ),
                  )),
            ] else ...[
              Row(
                children: [
                  _TableCell(
                    'F.I.Sh',
                    flex: 2,
                    style: headerStyle,
                    maxLines: 2,
                  ),
                  _TableCell(
                    'Telefon',
                    style: headerStyle,
                    maxLines: 2,
                  ),
                  _TableCell(
                    'Izoh',
                    style: headerStyle,
                    maxLines: 2,
                  ),
                  _TableCell(
                    'Qarz',
                    style: headerStyle,
                    textAlign: TextAlign.end,
                    maxLines: 2,
                  ),
                  _TableCell(
                    "To'langan",
                    style: headerStyle,
                    textAlign: TextAlign.end,
                    maxLines: 2,
                  ),
                  _TableCell(
                    'Qoldiq',
                    style: headerStyle,
                    textAlign: TextAlign.end,
                    maxLines: 2,
                  ),
                ],
              ),
              const Divider(),
              ...items.map(
                (item) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Row(
                    children: [
                      _TableCell(
                        item.fullName,
                        flex: 2,
                        style: cellStyle,
                        maxLines: 2,
                      ),
                      _TableCell(
                        item.phone,
                        style: cellStyle,
                        maxLines: 2,
                      ),
                      _TableCell(
                        item.note.isEmpty ? '-' : item.note,
                        style: cellStyle,
                        maxLines: 2,
                      ),
                      _TableCell(
                        formatNumber(item.amount),
                        style: cellStyle,
                        textAlign: TextAlign.end,
                        maxLines: 1,
                      ),
                      Expanded(
                        child: SizedBox(
                          height: 36,
                          child: TextField(
                            controller: _controllers[item.id],
                            focusNode: _focusNodes[item.id],
                            textAlign: TextAlign.end,
                            style: cellStyle,
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              ThousandsSeparatorInputFormatter(),
                            ],
                          decoration: const InputDecoration(
                            hintText: '0',
                            isDense: true,
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 8,
                                vertical: 8,
                              ),
                            ),
                          onSubmitted: (value) =>
                              widget.onPaidChanged(item, value),
                          onEditingComplete: () {
                            final value = _controllers[item.id]?.text ?? '';
                            widget.onPaidChanged(item, value);
                            _focusNodes[item.id]?.unfocus();
                            },
                          ),
                        ),
                      ),
                      _TableCell(
                        formatNumber(
                          (item.amount - _currentPaidAmount(item)) < 0
                              ? 0
                              : (item.amount - _currentPaidAmount(item)),
                        ),
                        style: cellStyle,
                        textAlign: TextAlign.end,
                        maxLines: 1,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _TableCell extends StatelessWidget {
  const _TableCell(
    this.text, {
    this.flex = 1,
    this.textAlign,
    this.maxLines = 1,
    this.style,
  });

  final String text;
  final int flex;
  final TextAlign? textAlign;
  final int maxLines;
  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: flex,
      child: Text(
        text,
        maxLines: maxLines,
        overflow: TextOverflow.ellipsis,
        softWrap: true,
        textAlign: textAlign,
        style: style,
      ),
    );
  }
}

class _DebtCard extends StatelessWidget {
  const _DebtCard({
    required this.item,
    required this.controller,
    required this.focusNode,
    required this.onPaidChanged,
  });

  final CrmDebt item;
  final TextEditingController controller;
  final FocusNode focusNode;
  final ValueChanged<String> onPaidChanged;

  @override
  Widget build(BuildContext context) {
    final labelStyle = Theme.of(context).textTheme.labelSmall;
    final valueStyle = Theme.of(context).textTheme.bodySmall;
    final parsed = parseFormattedInt(controller.text) ?? 0;
    final remaining =
        (item.amount - (item.paidAmount + parsed)) < 0
            ? 0
            : (item.amount - (item.paidAmount + parsed));
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _CardRow(label: 'F.I.Sh', value: item.fullName),
          _CardRow(label: 'Telefon', value: item.phone),
          _CardRow(label: 'Izoh', value: item.note.isEmpty ? '-' : item.note),
          _CardRow(label: 'Qarz', value: formatNumber(item.amount)),
          Row(
            children: [
              Expanded(
                child: Text('To\'langan', style: labelStyle),
              ),
              SizedBox(
                width: 140,
                child: TextField(
                  controller: controller,
                  focusNode: focusNode,
                  textAlign: TextAlign.end,
                  style: valueStyle,
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    ThousandsSeparatorInputFormatter(),
                  ],
                  decoration: const InputDecoration(
                    hintText: '0',
                    isDense: true,
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                  ),
                  onSubmitted: onPaidChanged,
                  onEditingComplete: () {
                    onPaidChanged(controller.text);
                    focusNode.unfocus();
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          _CardRow(
            label: 'Qoldiq',
            value: formatNumber(remaining),
          ),
        ],
      ),
    );
  }
}

class _CardRow extends StatelessWidget {
  const _CardRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final labelStyle = Theme.of(context).textTheme.labelSmall;
    final valueStyle = Theme.of(context).textTheme.bodySmall;
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 80, child: Text(label, style: labelStyle)),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              style: valueStyle,
              softWrap: true,
            ),
          ),
        ],
      ),
    );
  }
}
