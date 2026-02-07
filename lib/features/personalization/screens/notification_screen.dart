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
                  final iconConfig = _getIconConfig(context, notification);
                  final isRead = notification.isRead;
                  
                  return Card(
                    margin: EdgeInsets.only(bottom: DeviceUtils.m3Padding(4)),
                    clipBehavior: Clip.antiAlias,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: BorderSide(color: colorScheme.outlineVariant.withValues(alpha: 0.5)),
                    ),
                    child: Theme(
                      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                      child: ExpansionTile(
                        leading: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: iconConfig['color'] as Color,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(iconConfig['icon'] as IconData, color: Colors.white, size: 20),
                        ),
                        title: Text(
                          notification.title,
                          style: TextStyle(
                            fontWeight: isRead ? FontWeight.normal : FontWeight.bold,
                            fontSize: 15,
                            color: colorScheme.onSurface,
                          ),
                        ),
                        subtitle: Text(
                          timeago.format(notification.timestamp),
                          style: TextStyle(color: colorScheme.onSurfaceVariant, fontSize: 11),
                        ),
                        trailing: isRead 
                            ? null 
                            : Container(height: 8, width: 8, decoration: BoxDecoration(color: colorScheme.primary, shape: BoxShape.circle)),
                        childrenPadding: EdgeInsets.all(DeviceUtils.m3Padding(4)),
                        expandedCrossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            notification.body,
                            style: TextStyle(color: colorScheme.onSurfaceVariant, fontSize: 14, height: 1.5),
                          ),
                          if (notification.orderItems != null && notification.orderItems!.isNotEmpty) ...[
                            SizedBox(height: DeviceUtils.m3Padding(4)),
                            AaliyahDividerTheme.fullWidthDivider(context, height: 1),
                            SizedBox(height: DeviceUtils.m3Padding(3)),
                            ...notification.orderItems!.map((item) => _buildItemRow(context, item)),
                            SizedBox(height: DeviceUtils.m3Padding(2)),
                            _buildPaymentSummary(context, notification.paymentMethod, notification.totalAmount),
                          ],
                          SizedBox(height: DeviceUtils.m3Padding(2)),
                          Align(
                            alignment: AlignmentDirectional.centerEnd,
                            child: TextButton.icon(
                              onPressed: () => provider.removeNotification(notification),
                              icon: const Icon(Icons.delete_outline_rounded, size: 18, color: Colors.red),
                              label: const Text('Clear', style: TextStyle(color: Colors.red)),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
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
      child: Selector<NotificationController, int>(
        selector: (_, controller) => controller.notifications.where((n) => !n.isRead).length,
        builder: (context, unreadCount, _) {
          final notificationProvider = Provider.of<NotificationController>(context, listen: false);
          
          return AaliyahSmallAppBar(
            title: 'My Notifications',
            subtitle: unreadCount > 0 ? '$unreadCount unread' : null,
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

  Map<String, dynamic> _getIconConfig(BuildContext context, NotificationModel notification) {
    final colorScheme = Theme.of(context).colorScheme;
    final String title = notification.title.toLowerCase();
    if (title.contains('order') || title.contains('placed')) return {'icon': Icons.notifications_rounded, 'color': colorScheme.primary};
    if (title.contains('payment') || title.contains('success')) return {'icon': Icons.check_circle_outline_rounded, 'color': Colors.green};
    if (title.contains('offer') || title.contains('sale') || title.contains('discount')) return {'icon': Icons.discount_rounded, 'color': Colors.orange};
    if (title.contains('shipped') || title.contains('track')) return {'icon': Icons.local_shipping_rounded, 'color': Colors.indigo};
    return {'icon': Icons.info_outline_rounded, 'color': Colors.blue};
  }

  Widget _buildItemRow(BuildContext context, dynamic item) {
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: EdgeInsets.only(bottom: DeviceUtils.m3Padding(3)),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(DeviceUtils.m3Padding(2)),
            child: item.productImage.startsWith('http')
                ? SmartImage(imageUrl: item.productImage, height: 45, width: 45)
                : Image.asset(item.productImage, height: 45, width: 45, fit: BoxFit.cover),
          ),
          SizedBox(width: DeviceUtils.m3Padding(3)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.categoryName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                Text('Qty: ${item.quantity}  x  LKR ${item.price}', style: TextStyle(color: colorScheme.onSurfaceVariant, fontSize: 11)),
              ],
            ),
          ),
          Text('LKR ${(item.price * item.quantity).toStringAsFixed(0)}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
        ],
      ),
    );
  }

  Widget _buildPaymentSummary(BuildContext context, String? payment, double? total) {
    final colorScheme = Theme.of(context).colorScheme;
    return Column(
      children: [
        AaliyahDividerTheme.fullWidthDivider(context, height: 1),
        SizedBox(height: DeviceUtils.m3Padding(2)),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Payment', style: TextStyle(fontSize: 11, color: colorScheme.onSurfaceVariant)),
                Text(payment ?? 'N/A', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text('Total', style: TextStyle(fontSize: 11, color: colorScheme.onSurfaceVariant)),
                Text("LKR ${total?.toStringAsFixed(2) ?? '0.00'}", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: colorScheme.primary)),
              ],
            ),
          ],
        ),
      ],
    );
  }
}

