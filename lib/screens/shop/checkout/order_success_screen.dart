import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:aaliyahs_collection_estore/screens/navigation/navigation_menu.dart';
import 'package:aaliyahs_collection_estore/util/constants/colors.dart';
import 'package:aaliyahs_collection_estore/data/services/pdf_service.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class OrderSuccessScreen extends StatefulWidget {
  final String orderAmount;
  final String orderId;
  final List<dynamic> items;
  final String email;

  const OrderSuccessScreen({
    super.key,
    required this.orderAmount,
    required this.orderId,
    required this.items,
    required this.email,
  });

  @override
  State<OrderSuccessScreen> createState() => _OrderSuccessScreenState();
}

class _OrderSuccessScreenState extends State<OrderSuccessScreen> {
  bool _isGeneratingPdf = false;

  Future<void> _handleDownloadInvoice() async {
    setState(() => _isGeneratingPdf = true);
    try {
      await PdfService().generateInvoice(
        orderId: widget.orderId,
        amount: widget.orderAmount.replaceAll(RegExp(r'[^0-9.]'), ''),
        items: widget.items,
        customerEmail: widget.email,
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to generate invoice: $e")),
        );
      }
    } finally {
      if (mounted) setState(() => _isGeneratingPdf = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: isDarkMode 
                ? [const Color(0xFF1A1A1A), aaliyahDarkColor] 
                : [const Color(0xFFF8F9FA), Colors.white],
          ),
        ),
        child: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Success Icon with Animation
              FadeInDown(
                duration: const Duration(milliseconds: 800),
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: Colors.green.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.check_circle_rounded,
                      color: Colors.green,
                      size: 80,
                    ),
                  ),
                ),
              ),
              
              const SizedBox(height: 30),
              
              // Success Text
              FadeInUp(
                duration: const Duration(milliseconds: 600),
                delay: const Duration(milliseconds: 200),
                child: Column(
                  children: [
                    Text(
                      "Order Success!",
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: isDarkMode ? Colors.white : Colors.black,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 40),
                      child: Text(
                        "Your order #${widget.orderId} has been placed successfully.",
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 40),
              
              // Order Summary Card
              FadeInUp(
                duration: const Duration(milliseconds: 600),
                delay: const Duration(milliseconds: 400),
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 30),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: isDarkMode ? Colors.grey.shade900 : Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      _buildSummaryRow(context, "Amount Paid", widget.orderAmount, isBold: true),
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 10),
                        child: Divider(),
                      ),
                      _buildSummaryRow(context, "Items", "${widget.items.length} Product(s)"),
                      const SizedBox(height: 10),
                      _buildSummaryRow(context, "Payment", "Sent Confirmation to email"),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 50),
              
              // Action Buttons
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30),
                child: Column(
                  children: [
                    // Download Invoice Button
                    FadeInUp(
                      duration: const Duration(milliseconds: 600),
                      delay: const Duration(milliseconds: 600),
                      child: SizedBox(
                        width: double.infinity,
                        height: 55,
                        child: ElevatedButton.icon(
                          onPressed: _isGeneratingPdf ? null : _handleDownloadInvoice,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: aaliyahPrimaryColor,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                            elevation: 0,
                          ),
                          icon: _isGeneratingPdf 
                              ? LoadingAnimationWidget.staggeredDotsWave(color: Colors.white, size: 20)
                              : const Icon(Icons.download_rounded),
                          label: Text(_isGeneratingPdf ? "GENERATING..." : "DOWNLOAD INVOICE"),
                        ),
                      ),
                    ),
                    const SizedBox(height: 15),
                    
                    // Back to Home Button
                    FadeInUp(
                      duration: const Duration(milliseconds: 600),
                      delay: const Duration(milliseconds: 800),
                      child: SizedBox(
                        width: double.infinity,
                        height: 55,
                        child: OutlinedButton(
                          onPressed: () => Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(builder: (context) => const NavigationMenu()),
                            (route) => false,
                          ),
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(color: isDarkMode ? Colors.grey.shade700 : Colors.grey.shade300),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                          ),
                          child: const Text("CONTINUE SHOPPING", style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryRow(BuildContext context, String label, String value, {bool isBold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey),
        ),
        Text(
          value,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black,
          ),
        ),
      ],
    );
  }
}
