import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:aaliyahs_collection_estore/widgets/smart_image.dart';
import 'package:accordion/accordion.dart';
import 'package:accordion/controllers.dart';

import 'package:aaliyahs_collection_estore/controllers/notification_controller.dart';
import 'package:aaliyahs_collection_estore/util/constants/colors.dart';
import 'package:aaliyahs_collection_estore/util/constants/ui_constants.dart';

class NotificationScreen extends StatelessWidget {
  const NotificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDarkMode ? const Color(0xFF1A1A1A) : const Color(0xFFF9F9F9),
      appBar: _buildAppBar(context, isDarkMode),
      body: Consumer<NotificationController>(
        builder: (context, provider, child) {
          if (provider.notifications.isEmpty) {
            return _buildEmptyState(context);
          }
          
          return Accordion(
            maxOpenSections: 1,
            headerBackgroundColorOpened: aaliyahPrimaryColor,
            scaleWhenAnimating: true,
            openAndCloseAnimation: true,
            headerPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 15),
            sectionOpeningHapticFeedback: SectionHapticFeedback.heavy,
            sectionClosingHapticFeedback: SectionHapticFeedback.light,
            paddingListHorizontal: TUIConstants.horizontalPadding,
            paddingListTop: TUIConstants.verticalPadding,
            children: provider.notifications.map((notification) {
              final iconConfig = _getIconConfig(notification, isDarkMode);
              final isRead = notification.isRead;
              
              return AccordionSection(
                isOpen: false,
                leftIcon: Icon(iconConfig['icon'], color: Colors.white),
                headerBackgroundColor: iconConfig['color'],
                headerBackgroundColorOpened: iconConfig['color'],
                header: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            notification.title,
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
                          ),
                        ),
                        if (!isRead) Container(height: 8, width: 8, decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle)),
                      ],
                    ),
                    Text(
                      timeago.format(notification.timestamp),
                      style: const TextStyle(color: Colors.white70, fontSize: 11),
                    ),
                  ],
                ),
                content: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      notification.body,
                      style: TextStyle(color: isDarkMode ? Colors.grey.shade400 : Colors.grey.shade700, fontSize: 14, height: 1.5),
                    ),
                    if (notification.orderItems != null && notification.orderItems!.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      const Divider(),
                      const SizedBox(height: 12),
                      ...notification.orderItems!.map((item) => _buildItemRow(item, isDarkMode)),
                      const SizedBox(height: 8),
                      _buildPaymentSummary(notification.paymentMethod, notification.totalAmount, isDarkMode),
                    ],
                    const SizedBox(height: 10),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton.icon(
                        onPressed: () => provider.removeNotification(notification),
                        icon: const Icon(Icons.delete_outline, size: 18, color: Colors.red),
                        label: const Text("Clear", style: TextStyle(color: Colors.red)),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          );
        },
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context, bool isDarkMode) {
    return AppBar(
      title: const Text("My Notifications"),
      actions: [
        IconButton(
          onPressed: () => Provider.of<NotificationController>(context, listen: false).markAllAsRead(),
          icon: Icon(Icons.done_all_rounded, color: isDarkMode ? Colors.white : aaliyahPrimaryColor),
          tooltip: "Mark all as read",
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            height: 120,
            width: 120,
            decoration: BoxDecoration(
              color: aaliyahPrimaryColor.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            padding: const EdgeInsets.all(25),
            child: const Icon(Icons.notifications_none_rounded, size: 60, color: aaliyahPrimaryColor),
          ),
          const SizedBox(height: 24),
          const Text("No Notifications!", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text(
            "You don't have any notifications yet.\nWe'll notify you when something arrives.",
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey.shade500, fontSize: 14),
          ),
        ],
      ),
    );
  }

  Map<String, dynamic> _getIconConfig(NotificationModel notification, bool isDarkMode) {
    final String title = notification.title.toLowerCase();
    if (title.contains('order') || title.contains('placed')) return {'icon': Icons.notifications_outlined, 'color': aaliyahPrimaryColor};
    if (title.contains('payment') || title.contains('success')) return {'icon': Icons.check_circle_outline_rounded, 'color': Colors.green};
    if (title.contains('offer') || title.contains('sale') || title.contains('discount')) return {'icon': Icons.discount_outlined, 'color': Colors.orange};
    if (title.contains('shipped') || title.contains('track')) return {'icon': Icons.local_shipping_outlined, 'color': Colors.indigo};
    return {'icon': Icons.info_outline_rounded, 'color': Colors.blue};
  }

  Widget _buildItemRow(dynamic item, bool isDarkMode) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: item.productImage.startsWith('http')
                ? SmartImage(imageUrl: item.productImage, height: 45, width: 45, fit: BoxFit.cover)
                : Image.asset(item.productImage, height: 45, width: 45, fit: BoxFit.cover),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.categoryName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                Text("Qty: ${item.quantity}  x  LKR ${item.price}", style: TextStyle(color: Colors.grey.shade600, fontSize: 11)),
              ],
            ),
          ),
          Text("LKR ${(item.price * item.quantity).toStringAsFixed(0)}", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
        ],
      ),
    );
  }

  Widget _buildPaymentSummary(String? payment, double? total, bool isDarkMode) {
    return Column(
      children: [
        const Divider(),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Payment", style: TextStyle(fontSize: 11, color: Colors.grey)),
                Text(payment ?? "N/A", style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                const Text("Total", style: TextStyle(fontSize: 11, color: Colors.grey)),
                Text("LKR ${total?.toStringAsFixed(2) ?? '0.00'}", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: aaliyahPrimaryColor)),
              ],
            ),
          ],
        ),
      ],
    );
  }
}

