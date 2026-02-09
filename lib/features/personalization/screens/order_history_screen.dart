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
import 'package:flutter_animate/flutter_animate.dart';
import 'package:aaliyahs_collection_estore/utils/constants/image_strings.dart';
import 'package:flutter/services.dart';
import 'package:aaliyahs_collection_estore/features/shop/controllers/navigation_controller.dart';

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

        
          return Row(
            children: [
           
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
    return AaliyahSmallAppBar(
      title: 'My Orders',
      leading: IconButton(
        onPressed: () => Navigator.pop(context),
        icon: const Icon(Icons.arrow_back),
      ),
      backgroundColor: Colors.transparent,
    );
  }

  Widget _buildEmptyState() {
    final colorScheme = Theme.of(context).colorScheme;
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Align(
        alignment: Alignment.topCenter,
        child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(40, 32, 40, 24),
          child: Column(
            children: [
          
              Container(
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: colorScheme.primary.withValues(alpha: 0.05),
                  shape: BoxShape.circle,
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Icon(
                      Icons.history_rounded,
                      size: 80,
                      color: colorScheme.primary.withValues(alpha: 0.1),
                    ),
                    Image.asset(
                      emptyOrdersIllustration,
                      height: 140,
                    ).animate().scale(duration: 600.ms, curve: Curves.easeOutBack).fadeIn(),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              
              // Text Content
              Text(
                'No Order!',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onSurface,
                    ),
              ),
              const SizedBox(height: 12),
              Text(
                'Browse Our Collections',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                      height: 1.5,
                    ),
              ),
              const SizedBox(height: 32),
              
              // Action Button
              SizedBox(
                width: double.infinity,
                child: FilledButton.tonal(
                  onPressed: () {
                    HapticFeedback.lightImpact();
                    Provider.of<NavigationController>(context, listen: false).setIndex(1); // Go to Shop
                    Navigator.popUntil(context, (route) => route.isFirst);
                  },
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    backgroundColor: isDarkMode ? colorScheme.primaryContainer : colorScheme.primary,
                    foregroundColor: isDarkMode ? colorScheme.onPrimaryContainer : colorScheme.onPrimary,
                  ),
                  child: const Text(
                    'Start Shopping',
                    style: TextStyle(fontWeight: FontWeight.bold),
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
