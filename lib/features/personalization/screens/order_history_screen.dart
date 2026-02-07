import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:aaliyahs_collection_estore/features/shop/controllers/order_controller.dart';
import 'package:aaliyahs_collection_estore/features/personalization/controllers/user_controller.dart';
import 'package:aaliyahs_collection_estore/utils/constants/colors.dart';
import 'package:aaliyahs_collection_estore/utils/constants/ui_constants.dart';
import 'package:aaliyahs_collection_estore/features/personalization/screens/widgets/order_card.dart';
import 'package:aaliyahs_collection_estore/features/personalization/screens/order_detail_screen.dart';
import 'package:aaliyahs_collection_estore/utils/device/device_utility.dart';
import 'package:aaliyahs_collection_estore/common/widgets/appbar/flexible_app_bars.dart';

import 'package:aaliyahs_collection_estore/common/widgets/loaders/expressive_loader.dart';
import 'package:aaliyahs_collection_estore/common/widgets/menus/expressive_menu.dart';

class OrderHistoryScreen extends StatefulWidget {
  const OrderHistoryScreen({super.key});

  @override
  State<OrderHistoryScreen> createState() => _OrderHistoryScreenState();
}

class _OrderHistoryScreenState extends State<OrderHistoryScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = Provider.of<UserController>(context, listen: false).user;
      if (user != null) {
        Provider.of<OrderController>(context, listen: false).fetchUserOrders(user.email);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final isCompact = DeviceUtils.isCompact;

    return Scaffold(
      backgroundColor: isDarkMode ? aaliyahDarkColor : const Color(0xFFF8F9FA),
      appBar: _buildAppBar(context, isDarkMode),
      body: Consumer<OrderController>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return Center(
              child: ExpressiveLoader(
                size: ExpressiveLoader.responsiveSize(context, baseSize: 64),
                semanticLabel: 'Loading your past orders',
              ),
            );
          }

          final orders = provider.orders;

          if (orders.isEmpty) {
            return _buildEmptyState();
          }

          if (isCompact) {
            // Compact: Single pane with list only
            return ListView.builder(
              cacheExtent: 800.0,
              padding: const EdgeInsets.symmetric(
                horizontal: TUIConstants.horizontalPadding * 1.25, 
                vertical: TUIConstants.verticalPadding
              ),
              itemCount: orders.length,
              itemBuilder: (context, index) => OrderCard(order: orders[index]),
            );
          }

          // Tablet/Desktop: List-Detail Pattern
          return Row(
            children: [
              // Left Pane: Order List (Fixed)
              Container(
                width: DeviceUtils.recommendedFixedPaneWidth,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerLow,
                  border: Border(
                    right: BorderSide(
                      color: Theme.of(context).colorScheme.outlineVariant,
                    ),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: EdgeInsets.all(DeviceUtils.m3Margin),
                      child: Text(
                        'Order History',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Expanded(
                      child: ListView.builder(
                        padding: EdgeInsets.symmetric(
                          horizontal: DeviceUtils.m3Padding(3),
                          vertical: DeviceUtils.m3Padding(2),
                        ),
                        itemCount: orders.length,
                        itemBuilder: (context, index) {
                          final order = orders[index];
                          final isSelected = provider.selectedOrderId == order['orderId'];
                          
                          return Card.outlined(
                            margin: EdgeInsets.only(bottom: DeviceUtils.m3Padding(2)),
                            color: isSelected 
                                ? Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.3)
                                : Theme.of(context).colorScheme.surface,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(TUIConstants.shapeRadiusMedium),
                              side: BorderSide(
                                color: isSelected 
                                    ? Theme.of(context).colorScheme.primary 
                                    : Theme.of(context).colorScheme.outlineVariant,
                                width: isSelected ? 2 : 1,
                              ),
                            ),
                            child: Semantics(
                              selected: isSelected,
                              label: "Order #${order['orderId'] ?? 'N/A'}. Amount: LKR ${order['amount'] ?? '0.00'}",
                              child: ListTile(
                                selected: isSelected,
                                title: Text(
                                  "Order #${order['orderId'] ?? 'N/A'}",
                                  style: TextStyle(
                                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                  ),
                                ),
                                subtitle: Text(
                                  "LKR ${order['amount'] ?? '0.00'}",
                                  style: TextStyle(
                                    color: isSelected 
                                        ? Theme.of(context).colorScheme.onSecondaryContainer
                                        : Theme.of(context).colorScheme.primary,
                                  ),
                                ),
                                trailing: Icon(
                                  isSelected ? Icons.check_circle_rounded : Icons.chevron_right,
                                  color: isSelected 
                                      ? Theme.of(context).colorScheme.primary
                                      : null,
                                ),
                                onTap: () => provider.selectOrder(order['orderId']),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
              
              // Right Pane: Order Details (Flexible)
              Expanded(
                child: provider.selectedOrderId == null
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.receipt_long_outlined,
                              size: 80,
                              color: Colors.grey.withValues(alpha: 0.5),
                            ),
                            SizedBox(height: DeviceUtils.m3Padding(4)),
                            Text(
                              'Select an order to view details',
                              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      )
                    : _buildOrderDetailPane(
                        orders.firstWhere(
                          (o) => o['orderId'] == provider.selectedOrderId,
                        ),
                        isDarkMode,
                      ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildOrderDetailPane(Map<String, dynamic> order, bool isDarkMode) {
    return OrderDetailScreen(order: order, isEmbedded: true);
  }

  PreferredSizeWidget _buildAppBar(BuildContext context, bool isDarkMode) {
    return PreferredSize(
      preferredSize: const Size.fromHeight(64.0),
      child: Selector<OrderController, int>(
        selector: (_, controller) => controller.orders.length,
        builder: (context, orderCount, _) {
          return AaliyahSmallAppBar(
            title: 'Orders',
            subtitle: orderCount > 0 ? "$orderCount ${orderCount == 1 ? 'order' : 'orders'}" : null,
            leading: IconButton(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.arrow_back),
            ),
            actions: [
              AaliyahExpressiveMenu(
                isVibrant: true, // Prominent filter
                width: 260,
                items: [
                  const AaliyahMenuItem(
                    label: 'All Orders',
                    value: 'all',
                    leadingIcon: Icons.list_alt_rounded,
                    trailingText: 'Default',
                  ),
                  const Divider(height: 1),
                  AaliyahMenuItem(
                    label: 'Processing',
                    value: 'processing',
                    leadingIcon: Icons.sync_rounded,
                    supportingText: 'Orders being prepared',
                    badge: orderCount > 0 ? '2' : null,
                  ),
                  AaliyahMenuItem(
                    label: 'Delivered',
                    value: 'delivered',
                    leadingIcon: Icons.task_alt_rounded,
                    supportingText: 'Successfully received',
                    badge: orderCount > 0 ? '${orderCount - 2}' : null,
                  ),
                  const AaliyahMenuItem(
                    label: 'Cancelled',
                    value: 'cancelled',
                    leadingIcon: Icons.cancel_outlined,
                    supportingText: 'Returned or failed',
                  ),
                ],
                child: const IconButton(
                  onPressed: null, // MenuAnchor handles the tap
                  tooltip: 'Filter orders',
                  icon: Icon(Icons.filter_list_rounded),
                ),
              ),
              Semantics(
                label: 'Refresh orders',
                button: true,
                child: IconButton(
                  onPressed: () {
                    final user = Provider.of<UserController>(context, listen: false).user;
                    if (user != null) {
                      Provider.of<OrderController>(context, listen: false).fetchUserOrders(user.email);
                    }
                  },
                  tooltip: 'Refresh',
                  icon: const Icon(Icons.refresh_rounded),
                ),
              ),
            ],
            backgroundColor: Colors.transparent,
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.history, size: 80, color: Colors.grey.withValues(alpha: 0.5)),
          const SizedBox(height: 24),
          const Text(
            'No past orders',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey),
          ),
          const SizedBox(height: 8),
          const Text(
            "When you buy something, it'll show up here",
            style: TextStyle(fontSize: 14, color: Colors.grey),
          ),
        ],
      ),
    );
  }
}
