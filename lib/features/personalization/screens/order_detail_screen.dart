import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:aaliyahs_collection_estore/common/widgets/images/smart_image.dart';
import 'package:aaliyahs_collection_estore/utils/constants/colors.dart';
import 'package:aaliyahs_collection_estore/utils/constants/ui_constants.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:accordion/accordion.dart';
import 'package:accordion/controllers.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:aaliyahs_collection_estore/utils/theme/widget_themes/text_theme.dart';
import 'package:aaliyahs_collection_estore/utils/theme/widget_themes/divider_theme.dart';
import 'package:aaliyahs_collection_estore/common/widgets/appbar/flexible_app_bars.dart';

class OrderDetailScreen extends StatelessWidget {
  final Map<String, dynamic> order;
  final bool isEmbedded;

  const OrderDetailScreen({super.key, required this.order, this.isEmbedded = false});

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
      body: CustomScrollView(
        slivers: [
          // M3 Expressive: Medium Flexible App Bar (112dp, reduced from 128dp)
          AaliyahMediumFlexibleAppBar(
            title: 'Order details',
            subtitle: "Order #${order['id']}",
            leading: IconButton(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.arrow_back),
            ),
            backgroundColor: isDarkMode ? aaliyahDarkColor : Colors.white,
          ),
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: _buildOrderHeader(context, order['id'].toString(), orderDate),
                ),
                Accordion(
                  maxOpenSections: 2,
                  headerBackgroundColorOpened: aaliyahPrimaryColor,
                  scaleWhenAnimating: true,
                  openAndCloseAnimation: true,
                  headerPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 15),
                  sectionOpeningHapticFeedback: SectionHapticFeedback.heavy,
                  sectionClosingHapticFeedback: SectionHapticFeedback.light,
                  children: [
                    AccordionSection(
                      isOpen: true,
                      leftIcon: const Icon(Icons.shopping_bag_outlined, color: Colors.white),
                      header: const Text('Items', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      headerBackgroundColor: aaliyahPrimaryColor,
                      contentBorderColor: aaliyahPrimaryColor.withValues(alpha: 0.1),
                      content: Column(
                        children: [
                          ...items.map((item) => _buildOrderItem(item, isDarkMode)),
                          AaliyahDividerTheme.fullWidthDivider(context, height: 1),
                          const SizedBox(height: 10),
                          _buildTotalRow(total),
                        ],
                      ),
                    ),
                    AccordionSection(
                      leftIcon: const Icon(Icons.location_on_outlined, color: Colors.white),
                      header: const Text('Shipping address', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      headerBackgroundColor: aaliyahSecondaryColor,
                      contentBorderColor: aaliyahSecondaryColor.withValues(alpha: 0.1),
                      content: _buildShippingAddress(context, order['customer'], isDarkMode),
                    ),
                    AccordionSection(
                      leftIcon: const Icon(Icons.payment_outlined, color: Colors.white),
                      header: const Text('Payment details', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      headerBackgroundColor: Colors.teal,
                      contentBorderColor: Colors.teal.withValues(alpha: 0.1),
                      content: _buildPaymentMethod(order['payment_method'], isDarkMode),
                    ),
                  ],
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ],
      ),
    );
  }



  Widget _buildOrderHeader(BuildContext context, String orderId, DateTime date) {
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
          _buildHeaderColumn(context, 'Order ID', orderId),
          const SizedBox(height: 12),
          _buildHeaderColumn(context, 'Placed on', DateFormat('dd MMM yyyy, hh:mm a').format(date)),
        ],
      ),
    );
  }

  Widget _buildHeaderColumn(BuildContext context, String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
        AutoSizeText(
          value, 
          style: (Theme.of(context).extension<AaliyahTypography>()?.titleSmallEmphasized ?? 
                  Theme.of(context).textTheme.titleSmall),
          maxLines: 1,
          minFontSize: 11,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
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
            ? SmartImage(imageUrl: imageUrl)
            : Image.asset(imageUrl, fit: BoxFit.cover, alignment: Alignment.topCenter),
      ),
    );
  }

  Widget _buildItemDetails(Map<String, dynamic> item, double price, int quantity, double totalPrice, bool isDarkMode) {
    final String title = item['title'] ?? item['name'] ?? 'ProductModel';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          item['CategoryModel'] ?? 'CategoryModel',
          style: TextStyle(color: Colors.grey.shade500, fontSize: 11),
        ),
        const SizedBox(height: 2),
        AutoSizeText(
          _toTitleCase(title),
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          maxLines: 2,
          minFontSize: 11,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 6),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('LKR ${price.toStringAsFixed(0)} * $quantity', 
              style: GoogleFonts.robotoMono(color: isDarkMode ? Colors.white70 : Colors.grey.shade600, fontSize: 13, fontWeight: FontWeight.w500)),
            Text('LKR ${totalPrice.toStringAsFixed(0)}', 
              style: GoogleFonts.robotoMono(fontWeight: FontWeight.bold, color: aaliyahPrimaryColor, fontSize: 14)),
          ],
        ),
      ],
    );
  }

  Widget _buildTotalRow(double total) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text('Total', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
        Text(
          'LKR ${total.toStringAsFixed(2)}',
          style: GoogleFonts.robotoMono(fontWeight: FontWeight.w900, fontSize: 18, color: aaliyahPrimaryColor),
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
          const Icon(Icons.payment_outlined, color: aaliyahPrimaryColor, size: 20),
          const SizedBox(width: 12),
          Text(method ?? 'N/A', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
        ],
      ),
    );
  }

  Widget _buildShippingAddress(BuildContext context, Map<String, dynamic> customer, bool isDarkMode) {
    final String firstName = customer['firstName'] ?? 'Customer';
    final String lastName = customer['lastName'] ?? '';
    final String email = customer['email'] ?? 'N/A';
    final String address = customer['address'] ?? 'N/A';
    final String city = customer['city'] ?? '';
    final String state = customer['state'] ?? customer['province'] ?? '';
    final String postalCode = customer['postalCode'] ?? '';
    final String country = customer['country'] ?? '';
    
    final String name = '$firstName $lastName'.trim();

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
          const SizedBox(height: 10),
          AaliyahDividerTheme.fullWidthDivider(context, height: 1),
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
                    Text('$city, $state', style: TextStyle(color: Colors.grey.shade700, fontSize: 13)),
                    if (postalCode.isNotEmpty || country.isNotEmpty)
                      Text('$postalCode $country'.trim(), style: TextStyle(color: Colors.grey.shade700, fontSize: 13)),
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



  BoxDecoration _boxDecoration(bool isDarkMode) {
    return BoxDecoration(
      color: isDarkMode ? Colors.grey.shade900 : Colors.grey.shade50,
      borderRadius: BorderRadius.circular(TUIConstants.cardRadius),
      border: Border.all(color: isDarkMode ? Colors.grey.shade800 : Colors.grey.shade200),
    );
  }
}
