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
    final double total = _parsePrice(order['amount']);
    
    final DateTime orderDate = order['timestamp'] != null 
        ? DateTime.fromMillisecondsSinceEpoch(order['timestamp']) 
        : (order['date'] != null ? DateTime.parse(order['date']) : DateTime.now());

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
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: aaliyahPrimaryColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(TUIConstants.cardRadius),
        border: Border.all(color: aaliyahPrimaryColor.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeaderColumn("Order ID", orderId),
          const SizedBox(height: 12),
          _buildHeaderColumn("Placed On", DateFormat('dd MMM yyyy, hh:mm a').format(date)),
        ],
      ),
    );
  }

  Widget _buildHeaderColumn(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
        Text(
          value, 
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18));
  }

  Widget _buildOrderItem(Map<String, dynamic> item, bool isDarkMode) {
    final double price = _parsePrice(item['price']);
    final int quantity = int.tryParse(item['quantity'].toString()) ?? 0;
    final double totalItemPrice = price * quantity;

    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
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
      width: 70,
      height: 70,
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
    final String title = item['title'] ?? item['name'] ?? "Product";
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          item['category'] ?? "Category",
          style: TextStyle(color: Colors.grey.shade500, fontSize: 11),
        ),
        const SizedBox(height: 2),
        Text(
          _toTitleCase(title),
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 6),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text("LKR ${price.toStringAsFixed(0)} * $quantity", style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
            Text("LKR ${totalPrice.toStringAsFixed(0)}", style: const TextStyle(fontWeight: FontWeight.bold, color: aaliyahPrimaryColor, fontSize: 14)),
          ],
        ),
      ],
    );
  }

  Widget _buildTotalRow(double total) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text("Total Amount", style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
        Text(
          "LKR ${total.toStringAsFixed(2)}",
          style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18, color: aaliyahPrimaryColor),
        ),
      ],
    );
  }

  Widget _buildPaymentMethod(String? method, bool isDarkMode) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: _boxDecoration(isDarkMode),
      child: Row(
        children: [
          Icon(Icons.payment_outlined, color: aaliyahPrimaryColor, size: 20),
          const SizedBox(width: 12),
          Text(method ?? "N/A", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
        ],
      ),
    );
  }

  Widget _buildShippingAddress(Map<String, dynamic> customer, bool isDarkMode) {
    final String firstName = customer['firstName'] ?? "Customer";
    final String lastName = customer['lastName'] ?? "";
    final String email = customer['email'] ?? "N/A";
    final String address = customer['address'] ?? "N/A";
    final String city = customer['city'] ?? "";
    final String state = customer['state'] ?? customer['province'] ?? "";
    final String postalCode = customer['postalCode'] ?? "";
    final String country = customer['country'] ?? "";
    
    final String name = "$firstName $lastName".trim();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: _boxDecoration(isDarkMode),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.person_outline, size: 18, color: aaliyahPrimaryColor),
              const SizedBox(width: 10),
              Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              const Icon(Icons.email_outlined, size: 18, color: aaliyahPrimaryColor),
              const SizedBox(width: 10),
              Expanded(child: Text(email, style: TextStyle(color: Colors.grey.shade700, fontSize: 13))),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(height: 1),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.location_on_outlined, size: 18, color: aaliyahPrimaryColor),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(address, style: TextStyle(color: Colors.grey.shade700, fontSize: 13)),
                    Text("$city, $state", style: TextStyle(color: Colors.grey.shade700, fontSize: 13)),
                    if (postalCode.isNotEmpty || country.isNotEmpty)
                      Text("$postalCode $country".trim(), style: TextStyle(color: Colors.grey.shade700, fontSize: 13)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _toTitleCase(String text) {
    if (text.isEmpty) return text;
    return text.split(' ').map((word) {
      if (word.isEmpty) return word;
      return word[0].toUpperCase() + word.substring(1).toLowerCase();
    }).join(' ');
  }

  double _parsePrice(dynamic value) {
    if (value == null) return 0.0;
    String priceStr = value.toString().replaceAll(',', '');
    // Remove characters that are not digits or decimal point
    priceStr = priceStr.replaceAll(RegExp(r'[^0-9.]'), '');
    return double.tryParse(priceStr) ?? 0.0;
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey.shade600),
        const SizedBox(width: 8),
        Expanded(child: Text(text, style: TextStyle(color: Colors.grey.shade600, fontSize: 13))),
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
