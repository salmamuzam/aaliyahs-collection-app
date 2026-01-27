import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:cached_network_image/cached_network_image.dart';

import 'package:aaliyahs_collection_estore/src/features/shop/providers/notification_provider.dart';
import 'package:aaliyahs_collection_estore/src/constants/colors.dart';
import 'package:aaliyahs_collection_estore/src/constants/ui_constants.dart';

class NotificationScreen extends StatelessWidget {
  const NotificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDarkMode ? const Color(0xFF1A1A1A) : const Color(0xFFF9F9F9),
      appBar: _buildAppBar(context, isDarkMode),
      body: Consumer<NotificationProvider>(
        builder: (context, provider, child) {
          if (provider.notifications.isEmpty) {
            return _buildEmptyState(context);
          }
          
          return ListView.builder(
            cacheExtent: 1000.0,
            padding: const EdgeInsets.symmetric(
              horizontal: TUIConstants.horizontalPadding, 
              vertical: TUIConstants.verticalPadding
            ),
            itemCount: provider.notifications.length,
            itemBuilder: (context, index) {
              final notification = provider.notifications[index];
              return _buildDismissibleItem(context, notification, provider, isDarkMode);
            },
          );
        },
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context, bool isDarkMode) {
    return AppBar(
      title: Text(
        "My Notifications",
        style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
      ),
      centerTitle: false,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      elevation: 0,
      scrolledUnderElevation: 0,
      iconTheme: IconThemeData(color: isDarkMode ? Colors.white : Colors.black),
      actions: [
        IconButton(
          onPressed: () => Provider.of<NotificationProvider>(context, listen: false).markAllAsRead(),
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

  Widget _buildDismissibleItem(BuildContext context, NotificationModel notification, NotificationProvider provider, bool isDarkMode) {
    return Dismissible(
      key: ValueKey("${notification.timestamp}${notification.title}"),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => provider.removeNotification(notification),
      background: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.red.shade400,
          borderRadius: BorderRadius.circular(TUIConstants.cardRadius),
        ),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: const Icon(Icons.delete_outline_rounded, color: Colors.white, size: 28),
      ),
      child: ExpandableNotificationCard(notification: notification, isDarkMode: isDarkMode),
    );
  }
}

class ExpandableNotificationCard extends StatefulWidget {
  final NotificationModel notification;
  final bool isDarkMode;

  const ExpandableNotificationCard({super.key, required this.notification, required this.isDarkMode});

  @override
  State<ExpandableNotificationCard> createState() => _ExpandableNotificationCardState();
}

class _ExpandableNotificationCardState extends State<ExpandableNotificationCard> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final bool hasItems = widget.notification.orderItems?.isNotEmpty ?? false;
    final bool isRead = widget.notification.isRead;
    
    final iconConfig = _getIconConfig();

    return GestureDetector(
      onTap: () => hasItems ? setState(() => _isExpanded = !_isExpanded) : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: widget.isDarkMode ? const Color(0xFF252525) : Colors.white,
          borderRadius: BorderRadius.circular(TUIConstants.cardRadius),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: widget.isDarkMode ? 0.3 : 0.03),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
          border: Border.all(
            color: widget.isDarkMode 
               ? Colors.white.withValues(alpha: 0.05) 
               : (isRead ? Colors.transparent : aaliyahPrimaryColor.withValues(alpha: 0.2)),
            width: 1,
          ),
        ),
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildIconContainer(iconConfig['icon'], iconConfig['color']),
                const SizedBox(width: 16),
                Expanded(child: _buildMainContent(isRead)),
                if (hasItems) _buildExpandIcon(),
              ],
            ),
            if (_isExpanded && hasItems) _buildExpandedDetails(),
          ],
        ),
      ),
    );
  }

  Map<String, dynamic> _getIconConfig() {
    final String title = widget.notification.title.toLowerCase();
    if (title.contains('order') || title.contains('placed')) return {'icon': Icons.notifications_outlined, 'color': widget.isDarkMode ? Colors.white : aaliyahPrimaryColor};
    if (title.contains('payment') || title.contains('success')) return {'icon': Icons.check_circle_outline_rounded, 'color': widget.isDarkMode ? Colors.white : Colors.green};
    if (title.contains('offer') || title.contains('sale') || title.contains('discount')) return {'icon': Icons.discount_outlined, 'color': widget.isDarkMode ? Colors.white : Colors.orange};
    if (title.contains('shipped') || title.contains('track')) return {'icon': Icons.local_shipping_outlined, 'color': widget.isDarkMode ? Colors.white : Colors.indigo};
    return {'icon': Icons.info_outline_rounded, 'color': Colors.blue};
  }

  Widget _buildIconContainer(IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: color.withValues(alpha: 0.1), shape: BoxShape.circle),
      child: Icon(icon, color: color, size: 24),
    );
  }

  Widget _buildMainContent(bool isRead) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                widget.notification.title,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                  color: widget.isDarkMode ? Colors.white : const Color(0xFF1E1E1E),
                ),
              ),
            ),
            if (!isRead) Container(height: 8, width: 8, decoration: const BoxDecoration(color: aaliyahPrimaryColor, shape: BoxShape.circle)),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          widget.notification.body,
          style: TextStyle(color: widget.isDarkMode ? Colors.grey.shade400 : Colors.grey.shade600, fontSize: 13, height: 1.4),
        ),
        const SizedBox(height: 8),
        Text(
          timeago.format(widget.notification.timestamp),
          style: TextStyle(fontSize: 11, color: Colors.grey.shade500, fontWeight: FontWeight.w500),
        ),
      ],
    );
  }

  Widget _buildExpandIcon() {
    return Padding(
      padding: const EdgeInsets.only(left: 8, top: 2),
      child: Icon(
        _isExpanded ? Icons.keyboard_arrow_up_rounded : Icons.keyboard_arrow_down_rounded,
        color: Colors.grey.shade400,
        size: 20,
      ),
    );
  }

  Widget _buildExpandedDetails() {
    final items = widget.notification.orderItems!;
    final total = widget.notification.totalAmount;
    final payment = widget.notification.paymentMethod;

    return Column(
      children: [
        const SizedBox(height: 16),
        Divider(color: widget.isDarkMode ? Colors.white10 : Colors.grey.shade100, height: 1),
        const SizedBox(height: 12),
        ...items.map((item) => _buildItemRow(item)),
        const SizedBox(height: 8),
        Divider(color: widget.isDarkMode ? Colors.white10 : Colors.grey.shade200),
        const SizedBox(height: 8),
        _buildPaymentSummary(payment, total),
      ],
    );
  }

  Widget _buildItemRow(dynamic item) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: item.productImage.startsWith('http')
                ? CachedNetworkImage(imageUrl: item.productImage, height: 50, width: 50, fit: BoxFit.cover)
                : Image.asset(item.productImage, height: 50, width: 50, fit: BoxFit.cover),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.productName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                const SizedBox(height: 4),
                Text("Qty: ${item.quantity}  x  LKR ${item.price}", style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
              ],
            ),
          ),
          Text("LKR ${(item.price * item.quantity).toStringAsFixed(0)}", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
        ],
      ),
    );
  }

  Widget _buildPaymentSummary(String? payment, double? total) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildSummaryColumn("Payment", payment ?? "N/A"),
        _buildSummaryColumn("Total Amount", "LKR ${total?.toStringAsFixed(2) ?? '0.00'}", isTotal: true),
      ],
    );
  }

  Widget _buildSummaryColumn(String label, String value, {bool isTotal = false}) {
    return Column(
      crossAxisAlignment: isTotal ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontSize: 12, color: Colors.grey.shade500)),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontWeight: isTotal ? FontWeight.bold : FontWeight.w600,
            color: isTotal ? aaliyahPrimaryColor : (widget.isDarkMode ? Colors.white70 : Colors.black87),
            fontSize: isTotal ? 16 : 13,
          ),
        ),
      ],
    );
  }
}
