import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:aaliyahs_collection_estore/provider/order_provider.dart';
import 'package:aaliyahs_collection_estore/provider/user_provider.dart';
import 'package:intl/intl.dart';

class OrderHistoryScreen extends StatefulWidget {
  const OrderHistoryScreen({super.key});

  @override
  State<OrderHistoryScreen> createState() => _OrderHistoryScreenState();
}

class _OrderHistoryScreenState extends State<OrderHistoryScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = Provider.of<UserProvider>(context, listen: false).user;
      if (user != null) {
        Provider.of<OrderProvider>(context, listen: false).fetchUserOrders(user.email);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("My Orders", style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: Consumer<OrderProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          final orders = provider.orders;

          if (orders.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                   Icon(Icons.shopping_bag_outlined, size: 80, color: Colors.grey.withValues(alpha: 0.5)),
                   const SizedBox(height: 16),
                   const Text("No orders yet", style: TextStyle(fontSize: 18, color: Colors.grey)),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: orders.length,
            itemBuilder: (context, index) {
              final order = orders[index];
              final date = DateTime.parse(order['date']);
              final itemsCount = (order['items'] as List).length;

              return Card(
                margin: const EdgeInsets.only(bottom: 16),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Order #${order['id'].toString().substring(1, 8)}",
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.green.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(5),
                            ),
                            child: Text(
                              order['status'] ?? "Pending",
                              style: const TextStyle(color: Colors.green, fontSize: 12),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(DateFormat('MMM dd, yyyy - hh:mm a').format(date)),
                      const Divider(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("$itemsCount items"),
                          Text(
                            "Total: Rs. ${double.parse(order['amount'].toString()).toStringAsFixed(2)}",
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        height: 60,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: (order['items'] as List).length,
                          itemBuilder: (context, itemIndex) {
                            final item = order['items'][itemIndex];
                            return Container(
                              margin: const EdgeInsets.only(right: 8),
                              width: 60,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                image: DecorationImage(
                                  image: NetworkImage(item['image']),
                                  fit: BoxFit.cover,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
