import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/crm/entities/dashboard.dart';
import '../../theme/app_theme.dart';
import '../controllers/crm_dashboard_controller.dart';
import '../controllers/crm_orders_controller.dart';
import '../providers.dart';
import '../ui/action_button.dart';
import '../ui/balance_card.dart';
import '../ui/chart_card.dart';
import '../ui/formatters.dart';
import '../ui/section_header.dart';
import '../ui/transaction_list.dart';
import '../ui/wallet_card_carousel.dart';
import 'top_books_screen.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(crmDashboardControllerProvider.notifier).load();
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(crmDashboardControllerProvider);

    if (state.isLoading && state.data == null) {
      return const Center(child: CircularProgressIndicator());
    }
    if (state.errorMessage != null && state.data == null) {
      return _ErrorView(
        message: state.errorMessage!,
        onRetry: () => ref.read(crmDashboardControllerProvider.notifier).load(),
      );
    }

    final data = state.data;
    if (data == null) {
      return const SizedBox.shrink();
    }

    return RefreshIndicator(
      onRefresh: () => ref.read(crmDashboardControllerProvider.notifier).load(),
      child: ListView(
        padding: const EdgeInsets.all(AppSpacing.xl),
        children: [
          const SectionHeader(title: 'Boshqaruv'),
          const SizedBox(height: AppSpacing.lg),
          BalanceCard(
            title: 'Bugungi tushum',
            amount: formatMoney(data.revenueToday),
            subtitle: 'Haftalik buyurtmalar: ${data.weeklyOrders}',
            onTap: () => _showTodayOrders(context),
          ),
          const SizedBox(height: AppSpacing.xl),
          _ChartCard(hourly: data.hourly),
          const SizedBox(height: AppSpacing.xl),
          WalletCardCarousel(
            cards: [
              WalletCardData(
                title: 'Bugungi buyurtmalar',
                value: data.ordersToday.toString(),
                subtitle: 'Bugun',
              ),
              WalletCardData(
                title: 'Haftalik tushum',
                value: formatMoney(data.weeklyRevenue),
                subtitle: 'So\'nggi 7 kun',
              ),
              WalletCardData(
                title: 'Haftalik buyurtmalar',
                value: data.weeklyOrders.toString(),
                subtitle: 'So\'nggi 7 kun',
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xl),
          _TopBooksCard(items: data.topBooks),
        ],
      ),
    );
  }
}

Future<void> _showTodayOrders(BuildContext context) async {
  await showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppColors.background,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (context) => const _TodayOrdersSheet(),
  );
}

class _TodayOrdersSheet extends ConsumerStatefulWidget {
  const _TodayOrdersSheet();

  @override
  ConsumerState<_TodayOrdersSheet> createState() => _TodayOrdersSheetState();
}

class _TodayOrdersSheetState extends ConsumerState<_TodayOrdersSheet> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref
          .read(crmOrdersControllerProvider(const CrmOrdersQuery()).notifier)
          .loadInitial();
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(
      crmOrdersControllerProvider(const CrmOrdersQuery()),
    );
    final today = _toTashkentTime(DateTime.now());
    final todayOrders = state.items.where((order) {
      final created = order.createdAt;
      if (created == null) {
        return false;
      }
      final local = _toTashkentTime(created);
      return local.year == today.year &&
          local.month == today.month &&
          local.day == today.day;
    }).toList()
      ..sort((a, b) {
        final aDate = a.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
        final bDate = b.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
        return bDate.compareTo(aDate);
      });

    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Bugungi buyurtmalar',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 4),
              Text(
                _formatDateLabel(today),
                style: Theme.of(context)
                    .textTheme
                    .labelMedium
                    ?.copyWith(color: AppColors.textSecondary),
              ),
              const SizedBox(height: 16),
              if (state.isLoading && state.items.isEmpty)
                const Center(child: CircularProgressIndicator())
              else if (state.errorMessage != null && state.items.isEmpty)
                Text(state.errorMessage!)
              else if (todayOrders.isEmpty)
                const Text('Bugungi buyurtmalar yo\'q')
              else
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: todayOrders.length,
                  itemBuilder: (context, index) {
                    final order = todayOrders[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: AppSpacing.md),
                      child: TransactionRow(
                        data: TransactionRowData(
                          title: order.fullName,
                          subtitle:
                              '${order.orderSource} • ${_formatDate(order.createdAt)}',
                          amount: formatMoney(order.totalPrice),
                          isPositive: true,
                          icon: Icons.receipt_long_outlined,
                        ),
                      ),
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

String _formatDateLabel(DateTime value) {
  final two = (int v) => v.toString().padLeft(2, '0');
  return '${value.year}-${two(value.month)}-${two(value.day)}';
}

String _formatDate(DateTime? value) {
  if (value == null) {
    return '';
  }
  final local = _toTashkentTime(value);
  final two = (int v) => v.toString().padLeft(2, '0');
  return '${local.year}-${two(local.month)}-${two(local.day)} ${two(local.hour)}:${two(local.minute)}';
}

DateTime _toTashkentTime(DateTime value) {
  if (value.isUtc) {
    return value.add(const Duration(hours: 5));
  }
  return value;
}

class _ChartCard extends StatelessWidget {
  const _ChartCard({required this.hourly});

  final List<CrmHourly> hourly;

  @override
  Widget build(BuildContext context) {
    final maxValue = hourly.isEmpty
        ? 1.0
        : hourly
            .map((e) => (e.total).toDouble())
            .reduce((a, b) => a > b ? a : b);
    return ChartCard(
      title: 'Soatlik tushum',
      subtitle: 'Bugun 08:00-20:00',
      onTap: () => _showHourlyDetails(context, hourly),
      child: Container(
        height: 260,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppRadii.lg),
          gradient: const LinearGradient(
            colors: [Color(0xFF0F172A), Color(0xFF111827)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          child: LayoutBuilder(
            builder: (context, constraints) {
              return CustomPaint(
                size: Size(constraints.maxWidth, constraints.maxHeight),
                painter: _BarsPainter(
                  values: hourly.map((e) => (e.total).toDouble()).toList(),
                  maxValue: maxValue,
                  barColor: AppColors.accentPrimary,
                ),
              );
            },
          ),
        ),
      ),
      footer: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            hourly.isNotEmpty ? hourly.first.label : '',
            style: Theme.of(context)
                .textTheme
                .labelSmall
                ?.copyWith(color: AppColors.textSecondary),
          ),
          Text(
            hourly.isNotEmpty ? hourly.last.label : '',
            style: Theme.of(context)
                .textTheme
                .labelSmall
                ?.copyWith(color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}

Future<void> _showHourlyDetails(
  BuildContext context,
  List<CrmHourly> hourly,
) async {
  await showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppColors.background,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (context) {
      return Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: SafeArea(
          top: false,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Soatlik tushum',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 4),
                Text(
                  'Bugun 08:00-20:00',
                  style: Theme.of(context)
                      .textTheme
                      .labelMedium
                      ?.copyWith(color: AppColors.textSecondary),
                ),
                const SizedBox(height: 16),
                if (hourly.isEmpty)
                  const Text('Ma\'lumot yo\'q')
                else
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: hourly.length,
                    itemBuilder: (context, index) {
                      final item = hourly[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.circular(AppRadii.lg),
                            border: Border.all(color: AppColors.border),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  item.label,
                                  style: Theme.of(context).textTheme.titleSmall,
                                ),
                              ),
                              Text(
                                formatMoney(item.total),
                                style: Theme.of(context)
                                    .textTheme
                                    .labelLarge
                                    ?.copyWith(color: AppColors.accentPrimary),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
              ],
            ),
          ),
        ),
      );
    },
  );
}

class _BarsPainter extends CustomPainter {
  _BarsPainter({
    required this.values,
    required this.maxValue,
    required this.barColor,
  });

  final List<double> values;
  final double maxValue;
  final Color barColor;

  @override
  void paint(Canvas canvas, Size size) {
    if (values.isEmpty) {
      return;
    }
    final paint = Paint()
      ..shader = LinearGradient(
        colors: [barColor, const Color(0xFF93C5FD)],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(Offset.zero & size)
      ..style = PaintingStyle.fill;

    final count = values.length;
    final gap = 8.0;
    final barWidth =
        (size.width - gap * (count - 1)) / count;
    final usableHeight = size.height;

    for (var i = 0; i < count; i++) {
      final value = values[i];
      final height = maxValue == 0
          ? 12.0
          : (value / maxValue) * (usableHeight - 12) + 8;
      final left = i * (barWidth + gap);
      final rect = RRect.fromRectAndRadius(
        Rect.fromLTWH(
          left,
          usableHeight - height,
          barWidth,
          height,
        ),
        const Radius.circular(10),
      );
      canvas.drawRRect(rect, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _BarsPainter oldDelegate) {
    return oldDelegate.values != values ||
        oldDelegate.maxValue != maxValue ||
        oldDelegate.barColor != barColor;
  }
}

class _TopBooksCard extends StatelessWidget {
  const _TopBooksCard({required this.items});

  final List<CrmTopBook> items;

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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                "Eng ko'p sotilgan kitoblar",
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const Spacer(),
              TextButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => CrmTopBooksScreen(items: items),
                    ),
                  );
                },
                child: const Text('Hammasi'),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          SizedBox(
            height: 140,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: items.length,
              separatorBuilder: (_, __) => const SizedBox(width: 12),
              itemBuilder: (context, index) {
                final item = items[index];
                return Container(
                  width: 200,
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(AppRadii.lg),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                      const Spacer(),
                      Text(
                        'Soni: ${item.quantity}',
                        style: Theme.of(context)
                            .textTheme
                            .labelSmall
                            ?.copyWith(color: AppColors.textSecondary),
                      ),
                      Text(
                        'Tushum: ${formatMoney(item.revenue)}',
                        style: Theme.of(context)
                            .textTheme
                            .labelSmall
                            ?.copyWith(color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                );
              },
            ),
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

void _noop() {}
