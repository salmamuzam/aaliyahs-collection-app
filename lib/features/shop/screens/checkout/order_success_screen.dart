import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:aaliyahs_collection_estore/common/widgets/navigation_menu.dart';
import 'package:aaliyahs_collection_estore/utils/theme/custom_colors.dart';
import 'package:aaliyahs_collection_estore/data/services/pdf_service.dart';
import 'package:aaliyahs_collection_estore/common/widgets/loaders/expressive_progress_indicator.dart';
import 'package:provider/provider.dart';
import 'package:aaliyahs_collection_estore/features/shop/controllers/navigation_controller.dart';

class OrderSuccessScreen extends StatefulWidget {
  final String orderAmount;
  final String orderId;
  final List<dynamic> items;
  final String email;
  final String paymentMethod;
  final String? address;
  final String? city;
  final String? state;
  final DateTime? deliveryDate;
  final TimeOfDay? deliveryTime;

  const OrderSuccessScreen({
    super.key,
    required this.orderAmount,
    required this.orderId,
    required this.items,
    required this.email,
    required this.paymentMethod,
    this.address,
    this.city,
    this.state,
    this.deliveryDate,
    this.deliveryTime,
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
        customerAddress: widget.address,
        customerCity: widget.city != null && widget.state != null ? '${widget.city}, ${widget.state}' : widget.city,
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
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              colorScheme.surface,
              colorScheme.surfaceContainerLow,
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Success Icon with Animation
              FadeInDown(
                child: Builder(
                  builder: (context) {
                    final customColors = Theme.of(context).extension<AaliyahCustomColors>();
                    final successColor = customColors?.success ?? Colors.green;
                    final successContainer = customColors?.successContainer ?? Colors.green.withValues(alpha: 0.1);

                    return Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        color: successContainer,
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Icon(
                          Icons.check_circle_rounded,
                          color: successColor,
                          size: 80,
                        ),
                      ),
                    );
                  },
                ),
              ),
              
              const SizedBox(height: 30),
              
              // Success Text
              FadeInUp(
                duration: const Duration(milliseconds: 600),
                delay: const Duration(milliseconds: 200),
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Text(
                        'Success!', 
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: colorScheme.onSurface,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 40),
                      child: Text(
                        'Your Order has been Placed!',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onSurfaceVariant,
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
                    color: colorScheme.surfaceContainer,
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
                      _buildSummaryRow(context, 'Total:', widget.orderAmount, isBold: true),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        child: Divider(color: colorScheme.outlineVariant),
                      ),
                      _buildSummaryRow(context, 'Items:', '${widget.items.length} ${widget.items.length == 1 ? 'Product' : 'Products'}'),
                      const SizedBox(height: 10),
                      _buildSummaryRow(context, 'Payment:', widget.paymentMethod),
                      const SizedBox(height: 10),
                      _buildSummaryRow(
                        context, 
                        'Date:', 
                        '${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}'
                      ),
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
                            backgroundColor: colorScheme.primary,
                            foregroundColor: colorScheme.onPrimary,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                            elevation: 0,
                          ),
                          icon: _isGeneratingPdf 
                              ? SizedBox(
                                  width: 24, 
                                  height: 24, 
                                  child: ExpressiveCircularProgressIndicator(
                                    strokeWidth: 3, 
                                    size: 24,
                                    isWavy: true, 
                                    showTrack: false,
                                    color: Theme.of(context).colorScheme.onPrimary,
                                    semanticLabel: 'Generating your order invoice',
                                  ),
                                )
                              : const Icon(Icons.download_rounded),
                          label: Text(_isGeneratingPdf ? 'Generating...' : 'Download Invoice'),
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
                          onPressed: () {
                            // Set navigation index to 1 (Shop Page) before navigating
                            Provider.of<NavigationController>(context, listen: false).setIndex(1);
                            Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(builder: (context) => const NavigationMenu()),
                              (route) => false,
                            );
                          },
                          style: OutlinedButton.styleFrom(
                            foregroundColor: colorScheme.primary,
                            side: BorderSide(color: colorScheme.outlineVariant),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                          ),
                          child: const Text('Continue Shopping', style: TextStyle(fontWeight: FontWeight.bold)),
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
    final colorScheme = Theme.of(context).colorScheme;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(
          flex: 2,
          child: Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: colorScheme.onSurfaceVariant),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const SizedBox(width: 8),
        Flexible(
          flex: 3,
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              color: colorScheme.onSurface,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
