import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/crm/entities/debt.dart';
import '../../theme/app_theme.dart';
import '../controllers/crm_debts_controller.dart';
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
  final _scrollController = ScrollController();
  int _visibleCount = 30;
  bool _showClosedDebtors = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    Future.microtask(() => ref.read(crmDebtsControllerProvider.notifier).load());
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _nameController.dispose();
    _phoneController.dispose();
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      final total = ref.read(crmDebtsControllerProvider).items.length;
      if (_visibleCount >= total) {
        return;
      }
      setState(() {
        _visibleCount += 30;
      });
    }
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
        .where((item) => _hasRemaining(item))
        .toList();
    final nameOptions = activeItems
        .map((item) => item.fullName.trim())
        .where((name) => name.isNotEmpty)
        .toSet()
        .toList()
      ..sort();
    final filteredItems = activeItems.take(_visibleCount).toList();
    final totalsByName = <String, double>{};
    for (final item in activeItems) {
      final key = item.fullName.trim();
      if (key.isEmpty) {
        continue;
      }
      final remaining = _remainingAmount(item);
      totalsByName[key] = (totalsByName[key] ?? 0) + remaining;
    }
    final sortedNames = totalsByName.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final visibleNames = sortedNames.take(_visibleCount).toList();
    final totalDebt = sortedNames.fold<double>(0, (sum, entry) => sum + entry.value);
    final remainingByName = <String, double>{};
    final amountByName = <String, double>{};
    for (final item in state.items) {
      final name = item.fullName.trim();
      if (name.isEmpty) {
        continue;
      }
      remainingByName[name] = (remainingByName[name] ?? 0) + _remainingAmount(item);
      amountByName[name] = (amountByName[name] ?? 0) + item.amount;
    }
    final closedDebtorNames = remainingByName.entries
        .where((entry) => entry.value <= 0)
        .where((entry) => (amountByName[entry.key] ?? 0) > 0)
        .map((entry) => entry.key)
        .toList()
      ..sort();
    final closedDebtorCards = closedDebtorNames
        .map((name) => MapEntry<String, double>(name, 0))
        .toList();

    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showCreateDebtSheet(context, state, nameOptions),
        backgroundColor: AppColors.accentPrimary,
        foregroundColor: AppColors.background,
        shape: const CircleBorder(),
        child: const Icon(Icons.person_add_alt_1),
      ),
      body: ListView(
        controller: _scrollController,
        padding: const EdgeInsets.all(16),
        children: [
          Text('Qarzdorlar', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 12),
          InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: () => _showAllDebtsByDate(context),
            child: _TotalsHeader(total: totalDebt),
          ),
          const SizedBox(height: 12),
          _DebtorCards(
            items: visibleNames,
            onTap: (name) {
              final debtsForName = state.items
                  .where((item) => item.fullName.trim() == name)
                  .toList();
              _showDebtDetails(context, name, debtsForName);
            },
          ),
          const SizedBox(height: 12),
          InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: () => setState(() => _showClosedDebtors = !_showClosedDebtors),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'Yopilgan qarzdorlar',
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                  ),
                  Icon(
                    _showClosedDebtors ? Icons.expand_less : Icons.expand_more,
                    color: AppColors.textSecondary,
                  ),
                ],
              ),
            ),
          ),
          if (_showClosedDebtors) ...[
            const SizedBox(height: 12),
            if (closedDebtorCards.isEmpty)
              const Text('Yopilgan qarzdorlar yo\'q')
            else
              _DebtorCards(
                items: closedDebtorCards,
                onTap: (name) {
                  final debtsForName = state.items
                      .where((item) => item.fullName.trim() == name)
                      .toList();
                  _showDebtDetails(context, name, debtsForName);
                },
              ),
          ],
          const SizedBox(height: 16),
          if (state.isLoading && state.items.isEmpty)
            const Center(child: CircularProgressIndicator())
          else if (state.errorMessage != null && state.items.isEmpty)
            Text(state.errorMessage!)
          else if (filteredItems.isEmpty)
            const Text('Qarzdorlar yo\'q'),
        ],
      ),
    );
  }

  Future<void> _showDebtDetails(
    BuildContext context,
    String name,
    List<CrmDebt> debts,
  ) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.background,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return _DebtDetailsSheet(
          name: name,
        );
      },
    );
  }

  Future<void> _showCreateDebtSheet(
    BuildContext context,
    CrmDebtsState state,
    List<String> nameOptions,
  ) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.background,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        final bottomInset = MediaQuery.of(context).viewInsets.bottom;
        return Padding(
          padding: EdgeInsets.only(bottom: bottomInset),
          child: SafeArea(
            top: false,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: _DebtCreateCard(
                nameController: _nameController,
                phoneController: _phoneController,
                amountController: _amountController,
                noteController: _noteController,
                nameOptions: nameOptions,
                isSaving: state.isSaving,
                onSave: () async {
                  await _save();
                  if (context.mounted) {
                    Navigator.of(context).pop();
                  }
                },
                errorMessage: state.errorMessage,
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _showAllDebtsByDate(BuildContext context) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.background,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return const _AllDebtsByDateSheet();
      },
    );
  }
}

class _DebtorCards extends StatelessWidget {
  const _DebtorCards({
    required this.items,
    required this.onTap,
  });

  final List<MapEntry<String, double>> items;
  final ValueChanged<String> onTap;

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

class _DebtCardView {
  _DebtCardView({
    required this.debt,
    List<CrmDebt>? notes,
  }) : notes = notes ?? <CrmDebt>[];

  final CrmDebt debt;
  final List<CrmDebt> notes;
}

List<_DebtCardView> _mergeNotesIntoDebts(List<CrmDebt> items) {
  final cards = <_DebtCardView>[];
  for (final item in items) {
    final isNoteOnly = item.amount == 0 && item.note.trim().isNotEmpty;
    if (isNoteOnly && cards.isNotEmpty) {
      cards.last.notes.add(item);
      continue;
    }
    cards.add(_DebtCardView(debt: item));
  }
  return cards;
}

double _remainingAmount(CrmDebt item) {
  final remaining = item.amount - item.paidAmount;
  return remaining <= 0.5 ? 0 : remaining;
}

bool _hasRemaining(CrmDebt item) {
  return _remainingAmount(item) > 0;
}

class _DebtDetailCard extends StatefulWidget {
  const _DebtDetailCard({
    required this.card,
    this.showProfile = false,
    this.onEditNote,
  });

  final _DebtCardView card;
  final bool showProfile;
  final ValueChanged<CrmDebt>? onEditNote;

  @override
  State<_DebtDetailCard> createState() => _DebtDetailCardState();
}

class _DebtDetailCardState extends State<_DebtDetailCard> {
  bool _showDetails = false;

  @override
  Widget build(BuildContext context) {
    final item = widget.card.debt;
    final notes = widget.card.notes;
    final isNoteOnly = item.amount == 0;
    final hasNote = item.note.trim().isNotEmpty;
    final hasProducts = item.orderItems.isNotEmpty;
    final hasDetails = hasNote || notes.isNotEmpty || hasProducts;
    final showDetails = _showDetails;
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: hasDetails ? () => setState(() => _showDetails = !_showDetails) : null,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (widget.showProfile)
              Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Text(
                  item.fullName.trim(),
                  style: Theme.of(context)
                      .textTheme
                      .labelSmall
                      ?.copyWith(color: AppColors.textSecondary),
                ),
              ),
            Row(
              children: [
                Expanded(
                  child: Text(
                    isNoteOnly ? 'Izoh' : formatMoney(_remainingAmount(item)),
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                ),
                Text(
                  _formatDebtDate(item.createdAt),
                  style: Theme.of(context)
                      .textTheme
                      .labelSmall
                      ?.copyWith(color: AppColors.textSecondary),
                ),
              ],
            ),
            if (hasNote && showDetails) ...[
              const SizedBox(height: 8),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      item.note,
                      style: Theme.of(context)
                          .textTheme
                          .bodySmall
                          ?.copyWith(color: AppColors.textSecondary),
                    ),
                  ),
                  if (widget.onEditNote != null)
                    IconButton(
                      onPressed: () => widget.onEditNote!(item),
                      icon: const Icon(Icons.edit_outlined, size: 18),
                      visualDensity: VisualDensity.compact,
                      color: AppColors.textSecondary,
                      tooltip: 'Izohni tahrirlash',
                    ),
                ],
              ),
            ],
            if (notes.isNotEmpty && showDetails) ...[
              const SizedBox(height: 8),
              Text(
                'Izohlar',
                style: Theme.of(context)
                    .textTheme
                    .labelSmall
                    ?.copyWith(color: AppColors.textSecondary),
              ),
              const SizedBox(height: 6),
              ...notes.map(
                (noteItem) => Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          noteItem.note,
                          style: Theme.of(context)
                              .textTheme
                              .bodySmall
                              ?.copyWith(color: AppColors.textSecondary),
                        ),
                      ),
                      if (widget.onEditNote != null)
                        IconButton(
                          onPressed: () => widget.onEditNote!(noteItem),
                          icon: const Icon(Icons.edit_outlined, size: 18),
                          visualDensity: VisualDensity.compact,
                          color: AppColors.textSecondary,
                          tooltip: 'Izohni tahrirlash',
                        ),
                    ],
                  ),
                ),
              ),
            ],
            if (hasProducts && showDetails) ...[
              const SizedBox(height: 8),
              Text(
                'Mahsulotlar',
                style: Theme.of(context)
                    .textTheme
                    .labelSmall
                    ?.copyWith(color: AppColors.textSecondary),
              ),
              const SizedBox(height: 6),
              ...item.orderItems.map(
                (orderItem) => Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          orderItem.title,
                          style: Theme.of(context).textTheme.bodySmall,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${orderItem.quantity} x ${formatMoney(orderItem.price)}',
                        style: Theme.of(context)
                            .textTheme
                            .labelSmall
                            ?.copyWith(color: AppColors.textSecondary),
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

class _AllDebtsByDateSheet extends ConsumerStatefulWidget {
  const _AllDebtsByDateSheet();

  @override
  ConsumerState<_AllDebtsByDateSheet> createState() =>
      _AllDebtsByDateSheetState();
}

class _AllDebtsByDateSheetState extends ConsumerState<_AllDebtsByDateSheet> {
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
    final state = ref.watch(crmDebtsControllerProvider);
    final debts = state.items
        .where((item) => _matchesRange(item.createdAt))
        .where(
          (item) =>
              _hasRemaining(item) ||
              (item.amount == 0 && item.note.trim().isNotEmpty),
        )
        .toList()
      ..sort((a, b) {
        final aDate = a.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
        final bDate = b.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
        return bDate.compareTo(aDate);
      });
    final cards = _mergeNotesIntoDebts(debts);
    final totalRemaining = cards.fold<double>(
      0,
      (sum, card) {
        return sum + _remainingAmount(card.debt);
      },
    );

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
                'Qoldiq: ${formatMoney(totalRemaining)}',
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
              if (cards.isEmpty)
                Text(
                  'Qarzlar topilmadi',
                  style: Theme.of(context).textTheme.bodyMedium,
                )
              else
                ...cards.map(
                  (card) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _DebtDetailCard(
                      card: card,
                      showProfile: true,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

String _formatDebtDate(DateTime? value) {
  if (value == null) {
    return '-';
  }
  final local = _toTashkentTime(value);
  final year = local.year.toString().padLeft(4, '0');
  final month = local.month.toString().padLeft(2, '0');
  final day = local.day.toString().padLeft(2, '0');
  final hour = local.hour.toString().padLeft(2, '0');
  final minute = local.minute.toString().padLeft(2, '0');
  return '$year-$month-$day $hour:$minute';
}

DateTime _toTashkentTime(DateTime value) {
  if (value.isUtc) {
    return value.add(const Duration(hours: 5));
  }
  return value;
}

class _DebtDetailsSheet extends ConsumerStatefulWidget {
  const _DebtDetailsSheet({
    required this.name,
  });

  final String name;

  @override
  ConsumerState<_DebtDetailsSheet> createState() => _DebtDetailsSheetState();
}

class _DebtDetailsSheetState extends ConsumerState<_DebtDetailsSheet> {
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();
  final _paidController = TextEditingController();
  final _noteOnlyController = TextEditingController();
  final _editNoteController = TextEditingController();
  bool _isSaving = false;
  bool _isPaying = false;
  bool _isSavingNote = false;
  bool _isUpdatingNote = false;
  bool _showNewDebt = false;
  bool _showNewNote = false;
  bool _showPaidDebts = false;
  bool _isAutoFormattingNote = false;
  bool _isSyncingAmount = false;
  int? _editingDebtId;
  Timer? _noteDebounce;

  @override
  void initState() {
    super.initState();
    _noteController.addListener(() => _onNoteChanged(_noteController));
    _noteOnlyController.addListener(() => _onNoteChanged(_noteOnlyController));
  }

  @override
  void dispose() {
    _noteDebounce?.cancel();
    _amountController.dispose();
    _noteController.dispose();
    _paidController.dispose();
    _noteOnlyController.dispose();
    _editNoteController.dispose();
    super.dispose();
  }

  void _onNoteChanged(TextEditingController controller) {
    _noteDebounce?.cancel();
    _noteDebounce = Timer(const Duration(milliseconds: 180), () {
      if (!mounted) {
        return;
      }
      _syncAmountFromNote(controller);
    });
  }

  void _syncAmountFromNote(TextEditingController controller) {
    if (_isAutoFormattingNote || _isSyncingAmount) {
      return;
    }
    final text = controller.text;
    final updatedText = _insertInlineResults(text);
    if (updatedText != text) {
      _isAutoFormattingNote = true;
      controller.value = TextEditingValue(
        text: updatedText,
        selection: TextSelection.collapsed(offset: updatedText.length),
      );
      _isAutoFormattingNote = false;
    }
    final sums = _calculateExpressions(updatedText);
    if (sums == null || sums <= 0) {
      return;
    }
    final formatted = formatNumber(sums);
    _isSyncingAmount = true;
    _amountController.value = TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
    _isSyncingAmount = false;
  }

  double? _evaluateExpression(String input) {
    final tokens = _tokenizeExpression(input);
    if (tokens.isEmpty) {
      return null;
    }
    final output = <String>[];
    final ops = <String>[];
    int prec(String op) => (op == '+' || op == '-') ? 1 : 2;
    for (final token in tokens) {
      if (_isNumberToken(token)) {
        output.add(token);
      } else if (token == '(') {
        ops.add(token);
      } else if (token == ')') {
        while (ops.isNotEmpty && ops.last != '(') {
          output.add(ops.removeLast());
        }
        if (ops.isNotEmpty && ops.last == '(') {
          ops.removeLast();
        }
      } else {
        while (ops.isNotEmpty &&
            ops.last != '(' &&
            prec(ops.last) >= prec(token)) {
          output.add(ops.removeLast());
        }
        ops.add(token);
      }
    }
    while (ops.isNotEmpty) {
      output.add(ops.removeLast());
    }
    final stack = <double>[];
    for (final token in output) {
      if (_isNumberToken(token)) {
        stack.add(double.parse(token));
      } else {
        if (stack.length < 2) {
          return null;
        }
        final b = stack.removeLast();
        final a = stack.removeLast();
        switch (token) {
          case '+':
            stack.add(a + b);
            break;
          case '-':
            stack.add(a - b);
            break;
          case '*':
            stack.add(a * b);
            break;
          case '/':
            stack.add(b == 0 ? 0 : a / b);
            break;
        }
      }
    }
    if (stack.length != 1) {
      return null;
    }
    return stack.first;
  }

  double? _calculateExpressions(String text) {
    final matches = RegExp(r'([0-9.\s+\-*/()]+)=').allMatches(text);
    if (matches.isEmpty) {
      return null;
    }
    double total = 0;
    for (final match in matches) {
      final expr = match.group(1)?.trim();
      if (expr == null || expr.isEmpty) {
        continue;
      }
      final result = _evaluateExpression(expr);
      if (result == null) {
        continue;
      }
      total += result;
    }
    return total;
  }

  String _insertInlineResults(String text) {
    final regex = RegExp(r'([0-9.\s+\-*/()]+)=(?!\s*\d)');
    if (!regex.hasMatch(text)) {
      return text;
    }
    return text.replaceAllMapped(regex, (match) {
      final expr = match.group(1)?.trim() ?? '';
      final result = _evaluateExpression(expr);
      if (result == null) {
        return match.group(0) ?? '';
      }
      final formatted = formatNumber(result);
      return '$expr=$formatted';
    });
  }

  List<String> _tokenizeExpression(String input) {
    final cleaned = input.replaceAll(RegExp(r'[\s,]'), '');
    if (cleaned.isEmpty) {
      return const [];
    }
    final tokens = <String>[];
    final buffer = StringBuffer();
    for (var i = 0; i < cleaned.length; i++) {
      final ch = cleaned[i];
      if (RegExp(r'[0-9.]').hasMatch(ch)) {
        buffer.write(ch);
        continue;
      }
      if (buffer.isNotEmpty) {
        tokens.add(buffer.toString());
        buffer.clear();
      }
      if (RegExp(r'[+\-*/()]').hasMatch(ch)) {
        tokens.add(ch);
      }
    }
    if (buffer.isNotEmpty) {
      tokens.add(buffer.toString());
    }
    return tokens;
  }

  bool _isNumberToken(String token) {
    return double.tryParse(token) != null;
  }

  Future<void> _submit() async {
    final amountRaw = stripNumberFormatting(_amountController.text.trim());
    if (amountRaw.isEmpty) {
      return;
    }
    setState(() => _isSaving = true);
    try {
      final state = ref.read(crmDebtsControllerProvider);
      final debts = state.items
          .where((item) => item.fullName.trim() == widget.name)
          .toList();
      final phone = debts.firstWhere(
        (item) => item.phone.trim().isNotEmpty,
        orElse: () => debts.isNotEmpty
            ? debts.first
            : const CrmDebt(
                id: 0,
                fullName: '',
                phone: '',
                amount: 0,
                paidAmount: 0,
                isPaid: false,
                note: '',
                createdAt: null,
              ),
      ).phone;
      await ref.read(crmDebtsControllerProvider.notifier).create(
            fullName: widget.name,
            amount: amountRaw,
            phone: phone,
            note: _noteController.text.trim(),
          );
      await ref.read(crmDebtsControllerProvider.notifier).load();
      _amountController.clear();
      _noteController.clear();
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  Future<void> _submitNoteOnly() async {
    final note = _noteOnlyController.text.trim();
    if (note.isEmpty) {
      return;
    }
    setState(() => _isSavingNote = true);
    try {
      final state = ref.read(crmDebtsControllerProvider);
      final debts = state.items
          .where((item) => item.fullName.trim() == widget.name)
          .toList();
      final phone = debts.firstWhere(
        (item) => item.phone.trim().isNotEmpty,
        orElse: () => debts.isNotEmpty
            ? debts.first
            : const CrmDebt(
                id: 0,
                fullName: '',
                phone: '',
                amount: 0,
                paidAmount: 0,
                isPaid: false,
                note: '',
                createdAt: null,
              ),
      ).phone;
      await ref.read(crmDebtsControllerProvider.notifier).create(
            fullName: widget.name,
            amount: '0',
            phone: phone,
            note: note,
          );
      await ref.read(crmDebtsControllerProvider.notifier).load();
      _noteOnlyController.clear();
    } finally {
      if (mounted) {
        setState(() => _isSavingNote = false);
      }
    }
  }

  Future<void> _submitPayment() async {
    final amountRaw = stripNumberFormatting(_paidController.text.trim());
    if (amountRaw.isEmpty) {
      return;
    }
    setState(() => _isPaying = true);
    try {
      final state = ref.read(crmDebtsControllerProvider);
      final debts = state.items
          .where((item) => item.fullName.trim() == widget.name)
          .toList();
      if (debts.isEmpty) {
        return;
      }
      final parsed = double.tryParse(amountRaw) ?? 0;
      if (parsed <= 0) {
        return;
      }
      // Pay debts from oldest to newest.
      final sortedDebts = List<CrmDebt>.from(debts)
        ..sort((a, b) {
          final aDate = a.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
          final bDate = b.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
          return aDate.compareTo(bDate);
        });
      var remainingPayment = parsed;
      for (final debt in sortedDebts) {
        final remainingDebt = _remainingAmount(debt);
        if (remainingDebt <= 0) {
          continue;
        }
        if (remainingPayment <= 0) {
          break;
        }
        final applyAmount =
            remainingPayment > remainingDebt ? remainingDebt : remainingPayment;
        final nextPaid = debt.paidAmount + applyAmount;
        final clamped = nextPaid < 0
            ? 0
            : (nextPaid > debt.amount ? debt.amount : nextPaid);
        await ref.read(crmDebtsControllerProvider.notifier).updatePaidAmount(
              id: debt.id,
              paidAmount: clamped.toStringAsFixed(0),
              isPaid: clamped >= debt.amount,
            );
        remainingPayment -= applyAmount;
      }
      await ref.read(crmDebtsControllerProvider.notifier).load();
      _paidController.clear();
    } finally {
      if (mounted) {
        setState(() => _isPaying = false);
      }
    }
  }

  void _startEditDebtNote(CrmDebt debt) {
    setState(() {
      _editingDebtId = debt.id;
      _editNoteController.text = debt.note;
    });
  }

  Future<void> _submitEditedNote() async {
    final id = _editingDebtId;
    if (id == null) {
      return;
    }
    setState(() => _isUpdatingNote = true);
    try {
      await ref.read(crmDebtsControllerProvider.notifier).updateNote(
            id: id,
            note: _editNoteController.text.trim(),
          );
      if (!mounted) {
        return;
      }
      setState(() {
        _editingDebtId = null;
        _editNoteController.clear();
      });
    } finally {
      if (mounted) {
        setState(() => _isUpdatingNote = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    final state = ref.watch(crmDebtsControllerProvider);
    final debts = state.items
        .where((item) => item.fullName.trim() == widget.name)
        .where(
          (item) =>
              _hasRemaining(item) ||
              (item.amount == 0 && item.note.trim().isNotEmpty),
        )
        .toList()
      ..sort((a, b) {
        final aDate = a.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
        final bDate = b.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
        return bDate.compareTo(aDate);
      });
    final cards = _mergeNotesIntoDebts(debts);
    final totalRemaining = cards.fold<double>(
      0,
      (sum, card) {
        return sum + _remainingAmount(card.debt);
      },
    );
    final paidDebts = state.items
        .where((item) => item.fullName.trim() == widget.name)
        .where(
          (item) =>
              (!_hasRemaining(item) && item.amount > 0) ||
              (item.amount == 0 && item.note.trim().isNotEmpty),
        )
        .toList()
      ..sort((a, b) {
        final aDate = a.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
        final bDate = b.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
        return bDate.compareTo(aDate);
      });
    final paidCards = _mergeNotesIntoDebts(paidDebts)
        .where((card) => card.debt.amount > 0 && !_hasRemaining(card.debt))
        .toList();
    return Padding(
      padding: EdgeInsets.only(bottom: bottomInset),
      child: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(widget.name, style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 4),
              Text(
                'Qoldiq: ${formatMoney(totalRemaining)}',
                style: Theme.of(context)
                    .textTheme
                    .labelMedium
                    ?.copyWith(color: AppColors.textSecondary),
              ),
              const SizedBox(height: 16),
              if (cards.isEmpty)
                Text(
                  'Qarzdor topilmadi',
                  style: Theme.of(context).textTheme.bodyMedium,
                )
              else
                ...cards.map(
                  (card) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _DebtDetailCard(
                      card: card,
                      onEditNote: _startEditDebtNote,
                    ),
                  ),
                ),
              if (_editingDebtId != null) ...[
                const SizedBox(height: 12),
                Text(
                  'Izohni tahrirlash',
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _editNoteController,
                  decoration: const InputDecoration(hintText: 'Izoh'),
                  maxLines: 4,
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _isUpdatingNote
                            ? null
                            : () => setState(() {
                                  _editingDebtId = null;
                                  _editNoteController.clear();
                                }),
                        child: const Text('Bekor qilish'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: FilledButton(
                        onPressed: _isUpdatingNote ? null : _submitEditedNote,
                        child: _isUpdatingNote
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Text('Saqlash'),
                      ),
                    ),
                  ],
                ),
              ],
              const SizedBox(height: 12),
              InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: () => setState(() => _showPaidDebts = !_showPaidDebts),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          'To\'langan qarzlar',
                          style: Theme.of(context).textTheme.titleSmall,
                        ),
                      ),
                      Icon(
                        _showPaidDebts ? Icons.expand_less : Icons.expand_more,
                        color: AppColors.textSecondary,
                      ),
                    ],
                  ),
                ),
              ),
              if (_showPaidDebts) ...[
                const SizedBox(height: 8),
                if (paidCards.isEmpty)
                  Text(
                    'To\'langan qarzlar yo\'q',
                    style: Theme.of(context).textTheme.bodyMedium,
                  )
                else
                  ...paidCards.map(
                    (card) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _DebtDetailCard(
                        card: card,
                        onEditNote: _startEditDebtNote,
                      ),
                    ),
                  ),
              ],
              const SizedBox(height: 8),
              InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: () => setState(() => _showNewDebt = !_showNewDebt),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Yangi qarz',
                          style: Theme.of(context).textTheme.titleSmall,
                        ),
                      ),
                      Icon(
                        _showNewDebt ? Icons.expand_less : Icons.expand_more,
                        color: AppColors.textSecondary,
                      ),
                    ],
                  ),
                ),
              ),
              if (_showNewDebt) ...[
                const SizedBox(height: 8),
                TextField(
                  controller: _noteController,
                  decoration: const InputDecoration(
                    hintText: 'Izoh (ixtiyoriy)',
                  ),
                  maxLines: 3,
                  keyboardType: TextInputType.multiline,
                  textInputAction: TextInputAction.newline,
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _amountController,
                  decoration: const InputDecoration(
                    hintText: 'Qarz summasi',
                  ),
                  keyboardType: TextInputType.number,
                  inputFormatters: [ThousandsSeparatorInputFormatter()],
                ),
                const SizedBox(height: 12),
                FilledButton(
                  onPressed: _isSaving ? null : _submit,
                  child: _isSaving
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Saqlash'),
                ),
              ],
              const SizedBox(height: 12),
              InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: () => setState(() => _showNewNote = !_showNewNote),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Yangi izoh',
                          style: Theme.of(context).textTheme.titleSmall,
                        ),
                      ),
                      Icon(
                        _showNewNote ? Icons.expand_less : Icons.expand_more,
                        color: AppColors.textSecondary,
                      ),
                    ],
                  ),
                ),
              ),
              if (_showNewNote) ...[
                const SizedBox(height: 8),
                TextField(
                  controller: _noteOnlyController,
                  decoration: const InputDecoration(
                    hintText: 'Izoh',
                  ),
                  maxLines: 2,
                ),
                const SizedBox(height: 12),
                FilledButton(
                  onPressed: _isSavingNote ? null : _submitNoteOnly,
                  child: _isSavingNote
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Izohni saqlash'),
                ),
              ],
              const SizedBox(height: 16),
              Text(
                'To\'lov qo\'shish',
                style: Theme.of(context).textTheme.titleSmall,
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _paidController,
                decoration: const InputDecoration(
                  hintText: 'To\'langan summa',
                ),
                keyboardType: TextInputType.number,
                inputFormatters: [ThousandsSeparatorInputFormatter()],
              ),
              const SizedBox(height: 8),
              FilledButton(
                onPressed: _isPaying ? null : _submitPayment,
                child: _isPaying
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('To\'lovni saqlash'),
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

String _formatDateOnly(DateTime value) {
  final two = (int v) => v.toString().padLeft(2, '0');
  return '${value.year}-${two(value.month)}-${two(value.day)}';
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
