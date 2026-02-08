import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:toastification/toastification.dart';
import 'package:flutter/services.dart';
import 'package:aaliyahs_collection_estore/utils/constants/image_strings.dart';
import 'package:aaliyahs_collection_estore/features/shop/controllers/navigation_controller.dart';
import 'package:aaliyahs_collection_estore/common/widgets/images/smart_image.dart';

import 'package:aaliyahs_collection_estore/features/personalization/controllers/notification_controller.dart';
import 'package:aaliyahs_collection_estore/features/personalization/models/notification_model.dart';
import 'package:aaliyahs_collection_estore/utils/device/device_utility.dart';
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
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Center(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Icon/Illustration Container with glassmorphism effect
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
                      Icons.notifications_outlined,
                      size: 80,
                      color: colorScheme.primary.withValues(alpha: 0.1),
                    ),
                    Image.asset(
                      emptyNotificationsIllustration,
                      height: 140,
                    ).animate().scale(duration: 600.ms, curve: Curves.easeOutBack).fadeIn(),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              
              // Text Content
              Text(
                'No Notifications Yet',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onSurface,
                    ),
              ),
              const SizedBox(height: 12),
              Text(
                'We\'ll let you know when there are updates on your orders.',
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
                IntrinsicHeight(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Icon Column
                        Column(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: iconConfig['color'] as Color,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(iconConfig['icon'] as IconData, color: Colors.white, size: 20),
                            ),
                          ],
                        ),
                        const SizedBox(width: 12),
                        
                        // Content Column
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      _getDisplayTitle(widget.notification),
                                      style: TextStyle(
                                        fontWeight: isRead ? FontWeight.w600 : FontWeight.bold,
                                        fontSize: 12,
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
                              const SizedBox(height: 10),
                              Text(
                                timeago.format(widget.notification.timestamp),
                                style: TextStyle(
                                  color: colorScheme.onSurfaceVariant,
                                  fontSize: 11,
                                ),
                              ),
                              if (!_isExpanded && widget.notification.orderItems != null && widget.notification.orderItems!.isNotEmpty) ...[
                                const SizedBox(height: 8),
                                _buildCollapsedSummary(context),
                              ],

                              if (!_isExpanded) const SizedBox(height: 4),
                            ],
                          ),
                        ),
                        
                        // Action Column (Arrow UP, Bin DOWN)
                        Padding(
                          padding: const EdgeInsets.only(left: 8),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              // Arrow at the top
                              AnimatedRotation(
                                turns: _isExpanded ? 0.5 : 0,
                                duration: const Duration(milliseconds: 300),
                                child: Icon(
                                  Icons.keyboard_arrow_down_rounded,
                                  color: colorScheme.onSurfaceVariant,
                                  size: 20,
                                ),
                              ),
                              
                              // Bin at the bottom (aligned with summary row)
                              if (!_isExpanded)
                                IconButton(
                                  onPressed: () {
                                    Provider.of<NotificationController>(context, listen: false)
                                        .removeNotification(widget.notification);
                                    
                                    toastification.show(
                                      context: context,
                                      type: ToastificationType.success,
                                      style: ToastificationStyle.fillColored,
                                      title: const Text('Success!'),
                                      description: const Text('Your notification has been cleared!'),
                                      autoCloseDuration: const Duration(seconds: 3),
                                    );
                                  },
                                  icon: Icon(Icons.delete_outline_rounded, size: 18, color: Colors.red.withValues(alpha: 0.6)),
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(),
                                  visualDensity: VisualDensity.compact,
                                  tooltip: 'Clear notification',
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
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
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 3),
      decoration: BoxDecoration(
        color: colorScheme.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: colorScheme.primary.withValues(alpha: 0.2),
          width: 0.5,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '$itemCount ${itemCount == 1 ? 'item' : 'items'}',
            style: TextStyle(
              fontSize: 10,
              color: colorScheme.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            '•',
            style: TextStyle(
              fontSize: 10,
              color: colorScheme.primary.withValues(alpha: 0.5),
            ),
          ),
          const SizedBox(width: 6),
          Text(
            'LKR ${total.toStringAsFixed(2)}',
            style: TextStyle(
              fontSize: 10,
              color: colorScheme.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
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
          const SizedBox(height: 16),
          
          if (widget.notification.orderItems != null && widget.notification.orderItems!.isNotEmpty) ...[
            // Order Items Section
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
              child: Text(
                'Order Items',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurfaceVariant,
                  letterSpacing: 0.5,
                ),
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
            
            const SizedBox(height: 4),
            
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
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.categoryName,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 2),
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
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Payment',
              style: TextStyle(
                fontSize: 11,
                color: colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              payment ?? 'N/A',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
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
                  fontSize: 11,
                  color: colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                "LKR ${total?.toStringAsFixed(2) ?? '0.00'}",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
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

  String _getDisplayTitle(NotificationModel notification) {
    // 1. If we have a direct orderId field, use it
    if (notification.orderId != null && notification.orderId!.isNotEmpty) {
      return 'Order No. ${notification.orderId}';
    }

    // 2. Fallback to existing logic: Extract from title like "Aaliyah's Collection - Order #12345"
    final title = notification.title;
    if (title.contains(' - Order')) {
      final parts = title.split(' - ');
      if (parts.length > 1) {
        return parts[1].replaceAll('#', 'No. '); // Returns "Order No. 12345"
      }
    }
    
    // 3. Last fallback
    return title;
  }
}
