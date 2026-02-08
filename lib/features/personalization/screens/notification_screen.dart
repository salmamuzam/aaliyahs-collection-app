import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:aaliyahs_collection_estore/common/widgets/images/smart_image.dart';

import 'package:aaliyahs_collection_estore/features/personalization/controllers/notification_controller.dart';
import 'package:aaliyahs_collection_estore/features/personalization/models/notification_model.dart';
import 'package:aaliyahs_collection_estore/utils/device/device_utility.dart';
import 'package:aaliyahs_collection_estore/utils/theme/widget_themes/divider_theme.dart';
import 'package:aaliyahs_collection_estore/common/widgets/appbar/flexible_app_bars.dart';

class NotificationScreen extends StatelessWidget {
  const NotificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: _buildAppBar(context),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: Consumer<NotificationController>(
            builder: (context, provider, child) {
              if (provider.notifications.isEmpty) {
                return _buildEmptyState(context);
              }
              
              return ListView.builder(
                padding: EdgeInsets.all(DeviceUtils.m3Margin),
                itemCount: provider.notifications.length,
                itemBuilder: (context, index) {
                  final notification = provider.notifications[index];
                  return _NotificationCard(notification: notification);
                },
              );
            },
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return PreferredSize(
      preferredSize: const Size.fromHeight(64.0),
      child: Consumer<NotificationController>(
        builder: (context, notificationProvider, _) {
          return AaliyahSmallAppBar(
            title: 'My Notifications',
            actions: [
              IconButton(
                onPressed: () => notificationProvider.markAllAsRead(),
                icon: Icon(Icons.done_all_rounded, color: colorScheme.primary),
                tooltip: 'Mark all as read',
              ),
              SizedBox(width: DeviceUtils.m3Padding(2)),
            ],
          );
        },
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            height: 120,
            width: 120,
            decoration: BoxDecoration(
              color: colorScheme.primary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            padding: EdgeInsets.all(DeviceUtils.m3Padding(6)),
            child: Icon(Icons.notifications_none_rounded, size: 60, color: colorScheme.primary),
          ),
          SizedBox(height: DeviceUtils.m3Padding(6)),
          const Text('No Notifications!', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          SizedBox(height: DeviceUtils.m3Padding(2)),
          Text(
            "You don't have any notifications yet.\nWe'll notify you when something arrives.",
            textAlign: TextAlign.center,
            style: TextStyle(color: colorScheme.onSurfaceVariant, fontSize: 14),
          ),
        ],
      ),
    );
  }
}

class _NotificationCard extends StatefulWidget {
  final NotificationModel notification;

  const _NotificationCard({required this.notification});

  @override
  State<_NotificationCard> createState() => _NotificationCardState();
}

class _NotificationCardState extends State<_NotificationCard> with SingleTickerProviderStateMixin {
  bool _isExpanded = false;
  late AnimationController _animationController;
  late Animation<double> _expandAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _expandAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _toggleExpanded() {
    setState(() {
      _isExpanded = !_isExpanded;
      if (_isExpanded) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final iconConfig = _getIconConfig(context, widget.notification);
    final isRead = widget.notification.isRead;

    return Padding(
      padding: EdgeInsets.only(bottom: DeviceUtils.m3Padding(3)),
      child: Material(
        elevation: isRead ? 0 : 2,
        borderRadius: BorderRadius.circular(20),
        color: isRead 
            ? colorScheme.surfaceContainerLowest 
            : colorScheme.surfaceContainer,
        child: InkWell(
          onTap: _toggleExpanded,
          borderRadius: BorderRadius.circular(20),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isRead 
                    ? colorScheme.outlineVariant.withValues(alpha: 0.3) 
                    : colorScheme.primary.withValues(alpha: 0.3),
                width: isRead ? 1 : 2,
              ),
            ),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Icon
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: iconConfig['color'] as Color,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(iconConfig['icon'] as IconData, color: Colors.white, size: 20),
                      ),
                      const SizedBox(width: 12),
                      
                      // Content
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    _getDisplayTitle(widget.notification.title),
                                    style: TextStyle(
                                      fontWeight: isRead ? FontWeight.w600 : FontWeight.bold,
                                      fontSize: 14,
                                      color: colorScheme.onSurface,
                                    ),
                                  ),
                                ),
                                if (!isRead)
                                  Container(
                                    height: 7,
                                    width: 7,
                                    decoration: BoxDecoration(
                                      color: colorScheme.primary,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Wrap(
                              crossAxisAlignment: WrapCrossAlignment.center,
                              spacing: 12,
                              children: [
                                Text(
                                  timeago.format(widget.notification.timestamp),
                                  style: TextStyle(
                                    color: colorScheme.onSurfaceVariant,
                                    fontSize: 11,
                                  ),
                                ),
                                if (!_isExpanded && widget.notification.orderItems != null && widget.notification.orderItems!.isNotEmpty)
                                  _buildCollapsedSummary(context),
                              ],
                            ),
                          ],
                        ),
                      ),
                      
                      // Expand icon
                      AnimatedRotation(
                        turns: _isExpanded ? 0.5 : 0,
                        duration: const Duration(milliseconds: 300),
                        child: Icon(
                          Icons.keyboard_arrow_down_rounded,
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Expanded content
                SizeTransition(
                  sizeFactor: _expandAnimation,
                  child: _buildExpandedContent(context),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCollapsedSummary(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final itemCount = widget.notification.orderItems?.length ?? 0;
    final total = widget.notification.totalAmount ?? 0;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: colorScheme.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: colorScheme.primary.withValues(alpha: 0.2),
          width: 0.5,
        ),
      ),
      child: Text(
        '$itemCount ${itemCount == 1 ? 'item' : 'items'} • LKR ${total.toStringAsFixed(2)}',
        style: TextStyle(
          fontSize: 10,
          color: colorScheme.primary,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildExpandedContent(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLowest.withValues(alpha: 0.3),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Message body
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: colorScheme.outlineVariant.withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.info_outline_rounded,
                    size: 18,
                    color: colorScheme.primary,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      widget.notification.body,
                      style: TextStyle(
                        color: colorScheme.onSurfaceVariant,
                        fontSize: 12,
                        height: 1.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          if (widget.notification.orderItems != null && widget.notification.orderItems!.isNotEmpty) ...[
            // Order Items Section
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
              child: Row(
                children: [
                  Icon(
                    Icons.inventory_2_outlined,
                    size: 16,
                    color: colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'Order Items',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onSurfaceVariant,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),
            
            // Product items with cards
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: widget.notification.orderItems!
                    .map((item) => _buildItemCard(context, item))
                    .toList(),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Payment Summary Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      colorScheme.primary.withValues(alpha: 0.1),
                      colorScheme.primaryContainer.withValues(alpha: 0.1),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: colorScheme.primary.withValues(alpha: 0.2),
                  ),
                ),
                child: _buildPaymentSummary(
                  context,
                  widget.notification.paymentMethod,
                  widget.notification.totalAmount,
                ),
              ),
            ),
            
            const SizedBox(height: 16),
          ],
          
          // Actions
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () {
                  Provider.of<NotificationController>(context, listen: false)
                      .removeNotification(widget.notification);
                },
                icon: const Icon(Icons.delete_outline_rounded, size: 18),
                label: const Text('Clear Notification'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.red,
                  side: BorderSide(color: Colors.red.withValues(alpha: 0.3)),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildItemCard(BuildContext context, dynamic item) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      margin: EdgeInsets.only(bottom: DeviceUtils.m3Padding(2)),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          // Product image with shadow
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Container(
                height: 70,
                width: 70,
                color: colorScheme.surfaceContainerHighest,
                child: item.productImage.startsWith('http')
                    ? SmartImage(
                        imageUrl: item.productImage,
                        height: 70,
                        width: 70,
                        alignment: Alignment.topCenter,
                      )
                    : Image.asset(
                        item.productImage,
                        height: 70,
                        width: 70,
                        fit: BoxFit.cover,
                        alignment: Alignment.topCenter,
                      ),
              ),
            ),
          ),
          SizedBox(width: DeviceUtils.m3Padding(3)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.categoryName,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    '${item.quantity} x LKR ${item.price}',
                    style: TextStyle(
                      color: colorScheme.onSurfaceVariant,
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentSummary(BuildContext context, String? payment, double? total) {
    final colorScheme = Theme.of(context).colorScheme;
    return Column(
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: colorScheme.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.receipt_long_rounded,
                size: 20,
                color: colorScheme.primary,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Payment Method',
                    style: TextStyle(
                      fontSize: 11,
                      color: colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    payment ?? 'N/A',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: colorScheme.primary.withValues(alpha: 0.3),
              width: 1.5,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total Amount',
                style: TextStyle(
                  fontSize: 13,
                  color: colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                "LKR ${total?.toStringAsFixed(2) ?? '0.00'}",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: colorScheme.primary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Map<String, dynamic> _getIconConfig(BuildContext context, NotificationModel notification) {
    final colorScheme = Theme.of(context).colorScheme;
    final String title = notification.title.toLowerCase();
    if (title.contains('order') || title.contains('placed')) return {'icon': Icons.shopping_bag_rounded, 'color': colorScheme.primary};
    if (title.contains('payment') || title.contains('success')) return {'icon': Icons.check_circle_rounded, 'color': Colors.green};
    if (title.contains('offer') || title.contains('sale') || title.contains('discount')) return {'icon': Icons.local_offer_rounded, 'color': Colors.orange};
    if (title.contains('shipped') || title.contains('track')) return {'icon': Icons.local_shipping_rounded, 'color': Colors.indigo};
    return {'icon': Icons.notifications_rounded, 'color': Colors.blue};
  }

  String _getDisplayTitle(String title) {
    // Extract order number from titles like "Aaliyah's Collection - Order #12345"
    if (title.contains(' - Order')) {
      final parts = title.split(' - ');
      if (parts.length > 1) {
        return parts[1]; // Returns "Order #12345"
      }
    }
    return title;
  }
}
