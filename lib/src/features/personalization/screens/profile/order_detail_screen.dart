import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:aaliyahs_collection_estore/src/constants/colors.dart';
import 'package:aaliyahs_collection_estore/src/constants/ui_constants.dart';

class OrderDetailScreen extends StatelessWidget {
  final Map<String, dynamic> order;

  const OrderDetailScreen({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final List items = order['items'] ?? [];
    final double total = double.tryParse(order['amount'].toString()) ?? 0.0;
    final DateTime orderDate = DateTime.parse(order['date']);

    return Scaffold(
      backgroundColor: isDarkMode ? aaliyahDarkColor : Colors.white,
      appBar: _buildAppBar(context, isDarkMode),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(
          horizontal: TUIConstants.horizontalPadding * 1.25, 
          vertical: TUIConstants.verticalPadding
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildOrderHeader(order['id'].toString(), orderDate),
            const SizedBox(height: 24),
            _buildSectionTitle("Products"),
            const SizedBox(height: 16),
            ...items.map((item) => _buildOrderItem(item, isDarkMode)),
            const Divider(),
            const SizedBox(height: 20),
            _buildTotalRow(total),
            const SizedBox(height: 32),
            _buildSectionTitle("Payment Method"),
            const SizedBox(height: 12),
            _buildPaymentMethod(order['payment_method'], isDarkMode),
            const SizedBox(height: 32),
            _buildSectionTitle("Shipping Address"),
            const SizedBox(height: 12),
            _buildShippingAddress(order['customer'], isDarkMode),
            const SizedBox(height: 48),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context, bool isDarkMode) {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading: IconButton(
        onPressed: () => Navigator.pop(context),
        icon: Icon(Icons.arrow_back, color: isDarkMode ? Colors.white : Colors.black),
      ),
      title: Text(
        "Order Detail",
        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
          fontWeight: FontWeight.bold,
          color: isDarkMode ? Colors.white : Colors.black,
        ),
      ),
      centerTitle: false,
    );
  }

  Widget _buildOrderHeader(String orderId, DateTime date) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: aaliyahPrimaryColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(TUIConstants.cardRadius),
        border: Border.all(color: aaliyahPrimaryColor.withValues(alpha: 0.2)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildHeaderColumn("Order ID", "#CWT${orderId.padLeft(4, '0')}"),
          _buildHeaderColumn("Placed On", DateFormat('dd MMM yyyy, hh:mm a').format(date), alignRight: true),
        ],
      ),
    );
  }

  Widget _buildHeaderColumn(String label, String value, {bool alignRight = false}) {
    return Column(
      crossAxisAlignment: alignRight ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18));
  }

  Widget _buildOrderItem(Map<String, dynamic> item, bool isDarkMode) {
    final double price = double.tryParse(item['price'].toString()) ?? 0.0;
    final int quantity = int.tryParse(item['quantity'].toString()) ?? 0;
    final double totalItemPrice = price * quantity;

    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Row(
        children: [
          _buildItemImage(item['image'].toString(), isDarkMode),
          const SizedBox(width: 16),
          Expanded(child: _buildItemDetails(item, price, quantity, totalItemPrice, isDarkMode)),
        ],
      ),
    );
  }

  Widget _buildItemImage(String imageUrl, bool isDarkMode) {
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        color: isDarkMode ? Colors.grey.shade900 : Colors.grey.shade100,
        borderRadius: BorderRadius.circular(TUIConstants.cardRadius),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(TUIConstants.cardRadius),
        child: imageUrl.startsWith('http')
            ? CachedNetworkImage(imageUrl: imageUrl, fit: BoxFit.cover, alignment: Alignment.topCenter)
            : Image.asset(imageUrl, fit: BoxFit.cover, alignment: Alignment.topCenter),
      ),
    );
  }

  Widget _buildItemDetails(Map<String, dynamic> item, double price, int quantity, double totalPrice, bool isDarkMode) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          item['category'] ?? "Category",
          style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
        ),
        const SizedBox(height: 4),
        Text(
          item['title'] ?? item['name'] ?? "Product Name",
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text("Rs. ${price.toStringAsFixed(0)} x $quantity", style: TextStyle(color: Colors.grey.shade600)),
            Text("Rs. ${totalPrice.toStringAsFixed(0)}", style: const TextStyle(fontWeight: FontWeight.bold, color: aaliyahPrimaryColor)),
          ],
        ),
      ],
    );
  }

  Widget _buildTotalRow(double total) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text("Total Amount", style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18)),
        Text(
          "Rs. ${total.toStringAsFixed(2)}",
          style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18, color: aaliyahPrimaryColor),
        ),
      ],
    );
  }

  Widget _buildPaymentMethod(String? method, bool isDarkMode) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _boxDecoration(isDarkMode),
      child: Row(
        children: [
          Icon(Icons.payment, color: isDarkMode ? Colors.white70 : Colors.black54),
          const SizedBox(width: 16),
          Text(method ?? "N/A", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        ],
      ),
    );
  }

  Widget _buildShippingAddress(Map<String, dynamic> customer, bool isDarkMode) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: _boxDecoration(isDarkMode),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(customer['firstName'] ?? "Customer", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 8),
          _buildInfoRow(Icons.phone_outlined, customer['phone'] ?? "N/A"),
          const SizedBox(height: 8),
          _buildInfoRow(Icons.location_on_outlined, "${customer['address']}, ${customer['city']}"),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey.shade600),
        const SizedBox(width: 8),
        Expanded(child: Text(text, style: TextStyle(color: Colors.grey.shade600, fontSize: 14))),
      ],
    );
  }

  BoxDecoration _boxDecoration(bool isDarkMode) {
    return BoxDecoration(
      color: isDarkMode ? Colors.grey.shade900 : Colors.grey.shade50,
      borderRadius: BorderRadius.circular(TUIConstants.cardRadius),
      border: Border.all(color: isDarkMode ? Colors.grey.shade800 : Colors.grey.shade200),
    );
  }
}
