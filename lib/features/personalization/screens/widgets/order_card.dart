import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:aaliyahs_collection_estore/features/personalization/screens/order_detail_screen.dart';
import 'package:aaliyahs_collection_estore/utils/theme/widget_themes/text_theme.dart';

class OrderCard extends StatelessWidget {
  final Map<String, dynamic> order;

  const OrderCard({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

    final String paymentMethod = (order['payment_method'] ?? '').toString().toLowerCase();
    final bool isPaid = paymentMethod.contains('paid') || paymentMethod.contains('stripe');
    
    final String status = isPaid ? 'Paid' : 'Pending';
    final Color statusColor = isPaid ? Colors.green : Colors.orangeAccent;
    
    final DateTime date = order['timestamp'] != null 
        ? DateTime.fromMillisecondsSinceEpoch(order['timestamp']) 
        : (order['date'] != null ? DateTime.parse(order['date']) : DateTime.now());
    
    final String orderId = order['id'] ?? '#N/A';
    final String orderDateStr = DateFormat('dd MMM yyyy, hh:mm a').format(date);

    return Semantics(
      label: 'Order $orderId, placed on $orderDateStr. Status: $status.',
      button: true,
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => OrderDetailScreen(order: order)),
        );
      },
      child: Card.outlined(
        margin: const EdgeInsets.only(bottom: 16),
        child: InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => OrderDetailScreen(order: order)),
            );
          },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // First row: Status Badge
              Align(
                alignment: Alignment.centerLeft,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: statusColor.withValues(alpha: 0.3)),
                  ),
                  child: Text(
                    status,
                    style: TextStyle(
                      color: statusColor,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              // Second row: Order Number
              Row(
                children: [
                  Icon(Icons.receipt_long_rounded, color: isDarkMode ? Colors.white : Colors.black87, size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      orderId,
                      style: (Theme.of(context).extension<AaliyahTypography>()?.titleMediumEmphasized ?? Theme.of(context).textTheme.titleMedium)?.copyWith(
                        color: isDarkMode ? Colors.white : Colors.black,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
                // Third row: Date and Time
                Row(
                  children: [
                    Icon(Icons.calendar_today_rounded, color: Colors.grey.shade400, size: 16),
                    const SizedBox(width: 8),
                    Text(
                      orderDateStr,
                      style: (Theme.of(context).extension<AaliyahTypography>()?.bodyMediumEmphasized ?? Theme.of(context).textTheme.bodyMedium)?.copyWith(
                        color: isDarkMode ? Colors.grey.shade300 : Colors.grey.shade700,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                if (order['customer']?['city'] != null) ...[
                  const SizedBox(height: 8),
                  // Fourth row: Location (City)
                  Row(
                    children: [
                      Icon(Icons.location_on_outlined, color: Colors.grey.shade400, size: 16),
                      const SizedBox(width: 8),
                      Text(
                        order['customer']['city'],
                        style: (Theme.of(context).extension<AaliyahTypography>()?.bodyMediumEmphasized ?? Theme.of(context).textTheme.bodyMedium)?.copyWith(
                          color: isDarkMode ? Colors.grey.shade300 : Colors.grey.shade700,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
        ),
      ),
    ),
  );
}
}
