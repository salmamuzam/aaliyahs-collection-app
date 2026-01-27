import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:aaliyahs_collection_estore/src/features/personalization/screens/profile/order_detail_screen.dart';
import 'package:aaliyahs_collection_estore/src/constants/ui_constants.dart';

class OrderCard extends StatelessWidget {
  final Map<String, dynamic> order;

  const OrderCard({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    const int shippingLagDays = 3;
    const int orderIdPadding = 4;
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

    final String status = order['status'] ?? "Processing";
    final DateTime date = order['timestamp'] != null 
        ? DateTime.fromMillisecondsSinceEpoch(order['timestamp']) 
        : (order['date'] != null ? DateTime.parse(order['date']) : DateTime.now());
    final String orderId = "CWT${order['id'].toString().padLeft(orderIdPadding, '0')}";
    
    final DateTime shippingDate = date.add(const Duration(days: shippingLagDays));
    final String shippingDateStr = DateFormat('dd MMM yyyy').format(shippingDate);
    final String orderDateStr = DateFormat('dd MMM yyyy').format(date);

    Color statusColor = const Color(0xFF4DB6AC); // Default teal
    IconData statusIcon = Icons.inventory_2_outlined;

    final bool isDelivered = status.toLowerCase().contains("delivered");
    final bool isEnRoute = status.toLowerCase().contains("way");

    if (isDelivered) {
      statusColor = Colors.green;
      statusIcon = Icons.local_shipping_outlined;
    } else if (isEnRoute) {
      statusColor = Colors.blue;
      statusIcon = Icons.local_shipping_outlined;
    }

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => OrderDetailScreen(order: order)),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 15),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
          borderRadius: BorderRadius.circular(TUIConstants.cardRadius),
          border: Border.all(color: isDarkMode ? Colors.grey.shade800 : Colors.grey.shade100),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          children: [
            _buildStatusRow(status, orderDateStr, statusColor, statusIcon, isDarkMode),
            const SizedBox(height: 20),
            _buildInfoRow(orderId, shippingDateStr, isDarkMode),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusRow(String status, String date, Color color, IconData icon, bool isDarkMode) {
    return Row(
      children: [
        Icon(icon, color: isDarkMode ? Colors.white : Colors.black87, size: 24),
        const SizedBox(width: 15),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                status,
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.w900,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                date,
                style: TextStyle(
                  color: isDarkMode ? Colors.white : Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
        const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
      ],
    );
  }

  Widget _buildInfoRow(String orderId, String shippingDate, bool isDarkMode) {
    return Row(
      children: [
        _buildInfoColumn("Order", orderId, Icons.sell_outlined, isDarkMode),
        _buildInfoColumn("Shipping Date", shippingDate, Icons.calendar_month_outlined, isDarkMode),
      ],
    );
  }

  Widget _buildInfoColumn(String label, String value, IconData icon, bool isDarkMode) {
    return Expanded(
      child: Row(
        children: [
          Icon(icon, color: Colors.grey.shade400, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: TextStyle(color: Colors.grey.shade500, fontSize: 12)),
                Text(
                  value,
                  style: TextStyle(
                    color: isDarkMode ? Colors.white : Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
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
