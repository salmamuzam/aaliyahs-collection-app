
import 'package:aaliyahs_collection_estore/provider/notification_provider.dart';
import 'package:aaliyahs_collection_estore/src/constants/colors.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:cached_network_image/cached_network_image.dart';

class NotificationScreen extends StatelessWidget {
  const NotificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDarkMode ? const Color(0xFF1A1A1A) : const Color(0xFFF9F9F9),
      appBar: AppBar(
        title: Text(
          "My Notifications",
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
        ),
        centerTitle: false,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        scrolledUnderElevation: 0,
        iconTheme: IconThemeData(
          color: isDarkMode ? Colors.white : Colors.black, // Ensure back arrow is white in dark mode
        ),
        actions: [
          IconButton(
            onPressed: () {
              Provider.of<NotificationProvider>(context, listen: false).markAllAsRead();
            },
            icon: Icon(
              Icons.done_all_rounded, 
              color: isDarkMode ? Colors.white : aaliyahPrimaryColor // Tick is white in dark mode
            ),
            tooltip: "Mark all as read",
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Consumer<NotificationProvider>(
        builder: (context, provider, child) {
          if (provider.notifications.isEmpty) {
            return _buildEmptyState(context);
          }
          
          return ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            itemCount: provider.notifications.length,
            itemBuilder: (context, index) {
              final notification = provider.notifications[index];
              return _buildNotificationItem(context, notification, provider, isDarkMode);
            },
          );
        },
      ),
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
            child: Icon(
              Icons.notifications_none_rounded,
              size: 60,
              color: aaliyahPrimaryColor,
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            "No Notifications!",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "You don't have any notifications yet.\nWe'll notify you when something arrives.",
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.grey.shade500,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationItem(
      BuildContext context, 
      NotificationModel notification, 
      NotificationProvider provider,
      bool isDarkMode
  ) {
    return Dismissible(
      key: ValueKey(notification.timestamp.toString() + notification.title),
      direction: DismissDirection.endToStart,
      onDismissed: (_) {
        provider.removeNotification(notification);
      },
      background: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.red.shade400,
          borderRadius: BorderRadius.circular(16),
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

  const ExpandableNotificationCard({
    super.key,
    required this.notification,
    required this.isDarkMode,
  });

  @override
  State<ExpandableNotificationCard> createState() => _ExpandableNotificationCardState();
}

class _ExpandableNotificationCardState extends State<ExpandableNotificationCard> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final hasItems = widget.notification.orderItems != null && widget.notification.orderItems!.isNotEmpty;
    final isRead = widget.notification.isRead;
    
    // Determine Icon based on content
    IconData iconData = Icons.info_outline_rounded;
    Color iconColor = Colors.blue;
    
    final titleLower = widget.notification.title.toLowerCase();
    if (titleLower.contains('order') || titleLower.contains('placed')) {
      iconData = Icons.notifications_outlined;
      iconColor = widget.isDarkMode ? Colors.white : aaliyahPrimaryColor;
    } else if (titleLower.contains('payment') || titleLower.contains('success')) {
      iconData = Icons.check_circle_outline_rounded;
      iconColor = widget.isDarkMode ? Colors.white : Colors.green;
    } else if (titleLower.contains('offer') || titleLower.contains('sale') || titleLower.contains('discount')) {
      iconData = Icons.discount_outlined;
      iconColor = widget.isDarkMode ? Colors.white : Colors.orange;
    } else if (titleLower.contains('shipped') || titleLower.contains('track')) {
       iconData = Icons.local_shipping_outlined;
       iconColor = widget.isDarkMode ? Colors.white : Colors.indigo;
    }

    return GestureDetector(
      onTap: () {
         if (hasItems) {
           setState(() => _isExpanded = !_isExpanded);
         }
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: widget.isDarkMode ? const Color(0xFF252525) : Colors.white,
          borderRadius: BorderRadius.circular(16),
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
                // Icon Container
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: iconColor.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    iconData,
                    color: iconColor,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                
                // Content
                Expanded(
                  child: Column(
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
                          const SizedBox(width: 8),
                          if (!isRead)
                             Container(
                               height: 8,
                               width: 8,
                               decoration: BoxDecoration(
                                 color: aaliyahPrimaryColor,
                                 shape: BoxShape.circle,
                               ),
                             )
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        widget.notification.body,
                        style: TextStyle(
                          color: widget.isDarkMode ? Colors.grey.shade400 : Colors.grey.shade600,
                          fontSize: 13,
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 8),
                      // Time
                      Text(
                        timeago.format(widget.notification.timestamp),
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey.shade500,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Expand Arrow
                if (hasItems)
                  Padding(
                    padding: const EdgeInsets.only(left: 8, top: 2),
                    child: Icon(
                      _isExpanded ? Icons.keyboard_arrow_up_rounded : Icons.keyboard_arrow_down_rounded,
                      color: Colors.grey.shade400,
                      size: 20,
                    ),
                  )
              ],
            ),
            
            // Expanded List
            if (_isExpanded && hasItems) ...[
              const SizedBox(height: 16),
              Divider(color: widget.isDarkMode ? Colors.white10 : Colors.grey.shade100, height: 1),
              const SizedBox(height: 12),
              
              _buildExpandedDetails(),
            ]
          ],
        ),
      ),
    );
  }

  Widget _buildExpandedDetails() {
    final items = widget.notification.orderItems!;
    final total = widget.notification.totalAmount;
    final payment = widget.notification.paymentMethod;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Items List
        ...items.map((item) => Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: item.productImage.startsWith('http')
                  ? CachedNetworkImage(
                      imageUrl: item.productImage,
                      height: 50,
                      width: 50,
                      fit: BoxFit.cover,
                      errorWidget: (context, url, error) => Container(color: Colors.grey.shade200, child: const Icon(Icons.error, size: 15)),
                    )
                  : Image.asset(item.productImage, height: 50, width: 50, fit: BoxFit.cover),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.productName,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: widget.isDarkMode ? Colors.white : Colors.black87,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "Qty: ${item.quantity}  x  LKR ${item.price}",
                      style: TextStyle(
                        color: widget.isDarkMode ? Colors.grey.shade400 : Colors.grey.shade600,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                "LKR ${(item.price * item.quantity).toStringAsFixed(0)}",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: widget.isDarkMode ? Colors.white : Colors.black,
                ),
              ),
            ],
          ),
        )),

        const SizedBox(height: 8),
        Divider(color: widget.isDarkMode ? Colors.white10 : Colors.grey.shade200),
        const SizedBox(height: 8),

        // Payment & Total
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
             Column(
               crossAxisAlignment: CrossAxisAlignment.start,
               children: [
                 Text("Payment", style: TextStyle(fontSize: 12, color: Colors.grey.shade500)),
                 const SizedBox(height: 4),
                 Text(
                   payment ?? "N/A",
                   style: TextStyle(
                     fontWeight: FontWeight.w600,
                     color: widget.isDarkMode ? Colors.white70 : Colors.black87,
                     fontSize: 13,
                   ),
                 ),
               ],
             ),
             Column(
               crossAxisAlignment: CrossAxisAlignment.end,
               children: [
                 Text("Total Amount", style: TextStyle(fontSize: 12, color: Colors.grey.shade500)),
                 const SizedBox(height: 4),
                 Text(
                   "LKR ${total?.toStringAsFixed(2) ?? '0.00'}",
                   style: TextStyle(
                     fontWeight: FontWeight.bold,
                     color: aaliyahPrimaryColor,
                     fontSize: 16,
                   ),
                 ),
               ],
             ),
          ],
        )
      ],
    );
  }
}
