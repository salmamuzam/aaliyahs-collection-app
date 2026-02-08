import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:aaliyahs_collection_estore/common/widgets/images/smart_image.dart';
import 'package:aaliyahs_collection_estore/utils/constants/colors.dart';
import 'package:aaliyahs_collection_estore/utils/constants/ui_constants.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:aaliyahs_collection_estore/utils/theme/widget_themes/divider_theme.dart';
import 'package:aaliyahs_collection_estore/common/widgets/appbar/flexible_app_bars.dart';

import 'package:aaliyahs_collection_estore/data/services/pdf_service.dart';
import 'package:aaliyahs_collection_estore/common/widgets/loaders/expressive_progress_indicator.dart';

class OrderDetailScreen extends StatefulWidget {
  final Map<String, dynamic> order;
  final bool isEmbedded;

  const OrderDetailScreen({super.key, required this.order, this.isEmbedded = false});

  @override
  State<OrderDetailScreen> createState() => _OrderDetailScreenState();
}

class _OrderDetailScreenState extends State<OrderDetailScreen> {
  bool _isGeneratingPdf = false;

  Future<void> _handleDownloadInvoice() async {
    setState(() => _isGeneratingPdf = true);
    try {
      final customer = widget.order['customer'] ?? {};
      final city = customer['city'];
      final state = customer['state'] ?? customer['province'];
      
      await PdfService().generateInvoice(
        orderId: widget.order['id']?.toString() ?? '00000',
        amount: widget.order['amount']?.toString().replaceAll(RegExp(r'[^0-9.]'), '') ?? '0',
        items: widget.order['items'] ?? [],
        customerEmail: customer['email'] ?? 'customer@example.com',
        customerAddress: customer['address'],
        customerCity: city != null && state != null ? '$city, $state' : city,
        paymentMethod: widget.order['payment_method'],
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to generate invoice: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isGeneratingPdf = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final List items = widget.order['items'] ?? [];
    final double total = _parsePrice(widget.order['amount']);
    
    final DateTime orderDate = widget.order['timestamp'] != null 
        ? DateTime.fromMillisecondsSinceEpoch(widget.order['timestamp']) 
        : (widget.order['date'] != null ? DateTime.parse(widget.order['date']) : DateTime.now());

    return Scaffold(
      backgroundColor: isDarkMode ? aaliyahDarkColor : Colors.white,
      appBar: AaliyahSmallAppBar(
        title: 'Order Detail',
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back),
        ),
        backgroundColor: Colors.transparent,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Order Header Card
              _buildOrderHeader(context, widget.order['id'].toString(), orderDate),
              const SizedBox(height: 24),
              
              // Items Section
              _buildSectionTitle('Items'),
              const SizedBox(height: 12),
              Container(
                decoration: BoxDecoration(
                  color: isDarkMode ? Colors.grey.shade900 : Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: isDarkMode ? Colors.grey.shade800 : Colors.grey.shade200),
                ),
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: items.map((item) => Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: _buildOrderItem(item, isDarkMode),
                        )).toList(),
                      ),
                    ),
                    Divider(height: 1, color: isDarkMode ? Colors.grey.shade800 : Colors.grey.shade200),
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: _buildTotalRow(total, isDarkMode),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              
              // Payment Section
              _buildSectionTitle('Payment'),
              const SizedBox(height: 12),
              _buildPaymentMethod(widget.order['payment_method'], isDarkMode),
              const SizedBox(height: 24),
              
              // Shipping Section
              _buildSectionTitle('Shipping Address'),
              const SizedBox(height: 12),
              _buildShippingAddress(context, widget.order['customer'], isDarkMode),
              const SizedBox(height: 32),

              // Download Invoice Button
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: _isGeneratingPdf ? null : _handleDownloadInvoice,
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    side: BorderSide(color: aaliyahPrimaryColor.withValues(alpha: 0.5)),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  icon: _isGeneratingPdf 
                    ? const SizedBox(
                        width: 18, 
                        height: 18, 
                        child: ExpressiveCircularProgressIndicator(
                          size: 18,
                          strokeWidth: 2,
                          isWavy: true,
                        ),
                      )
                    : const Icon(Icons.download_rounded, size: 18),
                  label: Text(_isGeneratingPdf ? 'Generating...' : 'Download Invoice'),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOrderHeader(BuildContext context, String orderId, DateTime date) {
    final String paymentMethod = (widget.order['payment_method'] ?? '').toString().toLowerCase();
    final bool isPaid = paymentMethod.contains('paid') || paymentMethod.contains('stripe');
    final String status = isPaid ? 'Paid' : 'Pending';
    final Color statusColor = isPaid ? Colors.green : Colors.orangeAccent;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: aaliyahPrimaryColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(TUIConstants.cardRadius),
        border: Border.all(color: aaliyahPrimaryColor.withValues(alpha: 0.2)),
      ),
      child: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeaderColumn(context, 'Order No:', orderId),
              const SizedBox(height: 12),
              _buildHeaderColumn(context, 'Placed On', DateFormat('dd MMM yyyy, hh:mm a').format(date)),
            ],
          ),
          Positioned(
            top: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: statusColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: statusColor.withValues(alpha: 0.2)),
              ),
              child: Text(
                status,
                style: TextStyle(
                  color: statusColor,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderColumn(BuildContext context, String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
        const SizedBox(height: 4),
        AutoSizeText(
          value, 
          style: Theme.of(context).textTheme.titleSmall,
          maxLines: 1,
          minFontSize: 11,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }


  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildOrderItem(Map<String, dynamic> item, bool isDarkMode) {
    final double price = _parsePrice(item['price']);
    final int quantity = int.tryParse(item['quantity'].toString()) ?? 0;
    final double totalItemPrice = price * quantity;

    return Row(
      children: [
        _buildItemImage(item['image'].toString(), isDarkMode),
        const SizedBox(width: 16),
        Expanded(child: _buildItemDetails(item, price, quantity, totalItemPrice, isDarkMode)),
      ],
    );
  }

  Widget _buildItemImage(String imageUrl, bool isDarkMode) {
    return Container(
      width: 70,
      height: 100, // Taller aspect ratio for fashion
      decoration: BoxDecoration(
        color: isDarkMode ? Colors.grey.shade900 : Colors.grey.shade100,
        borderRadius: BorderRadius.circular(TUIConstants.cardRadius),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(TUIConstants.cardRadius),
        child: SmartImage(
          imageUrl: imageUrl, 
          width: 70,
          height: 100,
          fit: BoxFit.cover,
          alignment: Alignment.topCenter,
        ),
      ),
    );
  }

  Widget _buildItemDetails(Map<String, dynamic> item, double price, int quantity, double totalPrice, bool isDarkMode) {
    final String title = item['title'] ?? item['name'] ?? 'Product';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AutoSizeText(
          _toTitleCase(title),
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
          maxLines: 2,
          minFontSize: 11,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 2),
        Text(
          '$quantity × LKR ${price.toStringAsFixed(0)}',
          style: TextStyle(
            color: isDarkMode ? Colors.white : Colors.black,
            fontSize: 12,
            fontWeight: FontWeight.normal,
          ),
        ),
      ],
    );
  }

  Widget _buildTotalRow(double total, bool isDarkMode) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Total', 
          style: TextStyle(
            fontWeight: FontWeight.w900, 
            fontSize: 16,
            color: isDarkMode ? Colors.white : Colors.black,
          ),
        ),
        Text(
          'LKR ${total.toStringAsFixed(2)}',
          style: GoogleFonts.robotoMono(
            fontWeight: FontWeight.w900, 
            fontSize: 18, 
            color: isDarkMode ? Colors.white : aaliyahPrimaryColor,
          ),
        ),
      ],
    );
  }

  Widget _buildPaymentMethod(String? method, bool isDarkMode) {
    String cleanMethod = method ?? 'N/A';
    // Remove status in brackets (e.g., "Stripe (Paid)" -> "Stripe")
    if (cleanMethod.contains('(')) {
      cleanMethod = cleanMethod.split('(')[0].trim();
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: _boxDecoration(isDarkMode),
      child: Row(
        children: [
          const Icon(Icons.payment_outlined, color: aaliyahPrimaryColor, size: 20),
          const SizedBox(width: 12),
          Text(cleanMethod, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
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
    
    final String fullName = '$firstName $lastName'.trim();
    final Color detailsColor = isDarkMode ? Colors.white : Colors.grey.shade700;
  
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
              Text(fullName, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: isDarkMode ? Colors.white : Colors.black)),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              const Icon(Icons.email_outlined, size: 18, color: aaliyahPrimaryColor),
              const SizedBox(width: 10),
              Expanded(child: Text(email, style: TextStyle(color: detailsColor, fontSize: 13))),
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
                    if (address != 'N/A') Text(address, style: TextStyle(color: detailsColor, fontSize: 13)),
                  if (city.isNotEmpty || state.isNotEmpty)
                    Text(
                      '$city${city.isNotEmpty && state.isNotEmpty ? ", " : ""}$state', 
                      style: TextStyle(color: detailsColor, fontSize: 13),
                    ),
                  if (postalCode.isNotEmpty || country.isNotEmpty)
                    Text(
                      '$postalCode${postalCode.isNotEmpty && country.isNotEmpty ? " " : ""}$country'.trim(), 
                      style: TextStyle(color: detailsColor, fontSize: 13),
                    ),
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
