import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../theme/app_theme.dart';
import '../controllers/crm_orders_controller.dart';
import '../providers.dart';
import '../ui/formatters.dart';
import '../ui/section_header.dart';
import '../ui/transaction_list.dart';

class OrdersScreen extends ConsumerStatefulWidget {
  const OrdersScreen({super.key});

  @override
  ConsumerState<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends ConsumerState<OrdersScreen> {
  final _scrollController = ScrollController();
  String? _selectedCustomer;
  String? _appliedCustomer;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    Future.microtask(_load);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      ref
          .read(crmOrdersControllerProvider(const CrmOrdersQuery()).notifier)
          .loadMore();
    }
  }

  void _load() {
    ref
        .read(crmOrdersControllerProvider(const CrmOrdersQuery()).notifier)
        .loadInitial();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(
      crmOrdersControllerProvider(const CrmOrdersQuery()),
    );
    final customers = state.items
        .map((order) => order.fullName.trim())
        .where((name) => name.isNotEmpty)
        .toSet()
        .toList()
      ..sort();
    final filteredItems = _appliedCustomer == null ||
            _appliedCustomer!.trim().isEmpty
        ? state.items
        : state.items
            .where((order) => order.fullName == _appliedCustomer)
            .toList();

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SectionHeader(title: 'Buyurtmalar'),
              const SizedBox(height: AppSpacing.lg),
              _CustomerFilterCard(
                customers: customers,
                selectedCustomer: _selectedCustomer,
                onCustomerChanged: (value) {
                  setState(() {
                    _selectedCustomer = value;
                  });
                },
                onApply: () {
                  setState(() {
                    _appliedCustomer = _selectedCustomer;
                  });
                },
                onClear: () {
                  setState(() {
                    _selectedCustomer = null;
                    _appliedCustomer = null;
                  });
                },
              ),
            ],
          ),
        ),
        Expanded(
          child: state.isLoading && state.items.isEmpty
              ? const Center(child: CircularProgressIndicator())
              : state.errorMessage != null && state.items.isEmpty
                  ? _ErrorView(message: state.errorMessage!, onRetry: _load)
                  : ListView(
                      controller: _scrollController,
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.xl,
                      ),
                      children: [
                        TransactionList(
                          items: filteredItems
                              .map(
                                (order) => TransactionRowData(
                                  title: order.fullName,
                                  subtitle:
                                      '${order.orderSource} • ${_formatDate(order.createdAt)}',
                                  amount: formatMoney(order.totalPrice),
                                  isPositive: true,
                                  icon: Icons.receipt_long_outlined,
                                ),
                              )
                              .toList(),
                        ),
                        _PaginationFooter(
                          isLoading: state.isLoadingMore,
                          hasNext: state.hasNext,
                        ),
                      ],
                    ),
        ),
      ],
    );
  }
}

class _PaginationFooter extends StatelessWidget {
  const _PaginationFooter({required this.isLoading, required this.hasNext});

  final bool isLoading;
  final bool hasNext;

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 16),
        child: Center(child: CircularProgressIndicator()),
      );
    }
    if (!hasNext) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 16),
        child: Center(child: Text('Barchasi yuklandi')),
      );
    }
    return const SizedBox(height: 16);
  }
}

class _CustomerFilterCard extends StatelessWidget {
  const _CustomerFilterCard({
    required this.customers,
    required this.selectedCustomer,
    required this.onCustomerChanged,
    required this.onApply,
    required this.onClear,
  });

  final List<String> customers;
  final String? selectedCustomer;
  final ValueChanged<String?> onCustomerChanged;
  final VoidCallback onApply;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(AppRadii.lg),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Mijoz bo'yicha filter",
            style: Theme.of(context).textTheme.titleSmall,
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: selectedCustomer,
                  items: customers
                      .map(
                        (name) => DropdownMenuItem(
                          value: name,
                          child: Text(name, overflow: TextOverflow.ellipsis),
                        ),
                      )
                      .toList(),
                  onChanged: onCustomerChanged,
                  isExpanded: true,
                  hint: const Text('Mijozni tanlang'),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              SizedBox(
                width: 120,
                child: FilledButton(
                  onPressed: customers.isEmpty ? null : onApply,
                  child: const Text('Filter'),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              SizedBox(
                width: 120,
                child: OutlinedButton(
                  onPressed: onClear,
                  child: const Text('Tozalash'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 12),
            FilledButton(onPressed: onRetry, child: const Text('Qayta urinish')),
          ],
        ),
      ),
    );
  }
}

String _formatDate(DateTime? value) {
  if (value == null) {
    return '';
  }
  final local = value.toLocal();
  final two = (int v) => v.toString().padLeft(2, '0');
  return '${local.year}-${two(local.month)}-${two(local.day)} ${two(local.hour)}:${two(local.minute)}';
}
