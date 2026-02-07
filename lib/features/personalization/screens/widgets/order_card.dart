import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:aaliyahs_collection_estore/features/personalization/screens/order_detail_screen.dart';
import 'package:aaliyahs_collection_estore/utils/theme/widget_themes/text_theme.dart';
import 'package:aaliyahs_collection_estore/utils/theme/widget_themes/divider_theme.dart';
import 'package:auto_size_text/auto_size_text.dart';

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
            children: [
              _buildStatusRow(context, status, orderDateStr, statusColor, Icons.receipt_long_rounded, isDarkMode),
              AaliyahDividerTheme.fullWidthDivider(context, height: 32),
              _buildInfoRow(context, orderId, isDarkMode),
            ],
          ),
        ),
      ),
    ),
  );
}

  Widget _buildStatusRow(BuildContext context, String status, String date, Color color, IconData icon, bool isDarkMode) {
    return Row(
      children: [
        Icon(icon, color: isDarkMode ? Colors.white : Colors.black87, size: 24),
        const SizedBox(width: 15),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                status.toUpperCase(),
                style: (Theme.of(context).extension<AaliyahTypography>()?.titleSmallEmphasized ?? Theme.of(context).textTheme.titleSmall)?.copyWith(
                  color: color,
                  letterSpacing: 0.5,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 2),
              AutoSizeText(
                date,
                style: (Theme.of(context).extension<AaliyahTypography>()?.bodyMediumEmphasized ?? Theme.of(context).textTheme.bodyMedium)?.copyWith(
                  color: isDarkMode ? Colors.white : Colors.black,
                ),
                maxLines: 1,
                minFontSize: 11,
              ),
            ],
          ),
        ),
        const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: Colors.grey),
      ],
    );
  }

  Widget _buildInfoRow(BuildContext context, String orderId, bool isDarkMode) {
    return Row(
      children: [
        _buildInfoColumn(context, 'Order number', orderId, Icons.receipt_long_rounded, isDarkMode),
      ],
    );
  }

  Widget _buildInfoColumn(BuildContext context, String label, String value, IconData icon, bool isDarkMode) {
    final colorScheme = Theme.of(context).colorScheme;
    return Expanded(
      child: Row(
        children: [
          Icon(icon, color: Colors.grey.shade400, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: Theme.of(context).extension<AaliyahTypography>()?.labelSmallEmphasized.copyWith(color: colorScheme.onSurfaceVariant)),
                AutoSizeText(
                  value,
                  style: (Theme.of(context).extension<AaliyahTypography>()?.bodyMediumEmphasized ?? Theme.of(context).textTheme.bodyMedium)?.copyWith(
                    color: isDarkMode ? Colors.white : Colors.black,
                  ),
                  maxLines: 1,
                  minFontSize: 10,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
