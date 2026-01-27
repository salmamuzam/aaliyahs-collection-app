import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:aaliyahs_collection_estore/src/features/personalization/providers/address_provider.dart';
import 'package:aaliyahs_collection_estore/src/constants/ui_constants.dart';
import 'package:aaliyahs_collection_estore/src/constants/colors.dart';

class AddressesScreen extends StatelessWidget {
  const AddressesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDarkMode ? aaliyahDarkColor : const Color(0xFFF8F9FA),
      appBar: _buildAppBar(context),
      body: Consumer<AddressProvider>(
        builder: (context, provider, child) {
          final addresses = provider.addresses;
          if (addresses.isEmpty) return _buildEmptyState();

          return ListView.builder(
            padding: const EdgeInsets.all(TUIConstants.horizontalPadding),
            itemCount: addresses.length,
            itemBuilder: (context, index) => _buildAddressCard(context, addresses[index], provider, isDarkMode),
          );
        },
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      title: const Text("My Addresses", style: TextStyle(fontWeight: FontWeight.bold)),
      actions: [
        IconButton(icon: const Icon(Icons.add_rounded), onPressed: () => _showAddressDialog(context)),
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _buildEmptyState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.location_off_rounded, size: 64, color: Colors.grey),
          SizedBox(height: 16),
          Text("No saved addresses", style: TextStyle(color: Colors.grey, fontSize: 16)),
        ],
      ),
    );
  }

  Widget _buildAddressCard(BuildContext context, Map<String, dynamic> addr, AddressProvider provider, bool isDarkMode) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(TUIConstants.cardRadius),
        side: BorderSide(color: isDarkMode ? Colors.grey.shade800 : Colors.grey.shade200),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        leading: const CircleAvatar(
          backgroundColor: aaliyahPrimaryColor,
          child: Icon(Icons.location_on, color: Colors.white, size: 20),
        ),
        title: Text(addr['label'] ?? "Address", style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text("${addr['address']}, ${addr['city']}, ${addr['state']} ${addr['zip']}"),
        ),
        trailing: IconButton(
          icon: const Icon(Icons.delete_outline_rounded, color: Colors.red),
          onPressed: () => provider.deleteAddress(addr['id']),
        ),
      ),
    );
  }

  void _showAddressDialog(BuildContext context) {
    final Map<String, TextEditingController> controllers = {
      'label': TextEditingController(),
      'address': TextEditingController(),
      'city': TextEditingController(),
      'state': TextEditingController(),
      'zip': TextEditingController(),
    };

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text("Add New Address", style: TextStyle(fontWeight: FontWeight.bold)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: controllers.entries.map((e) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: TextField(
                controller: e.value,
                decoration: InputDecoration(
                  labelText: e.key[0].toUpperCase() + e.key.substring(1),
                  border: const OutlineInputBorder(),
                ),
              ),
            )).toList(),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () {
              Provider.of<AddressProvider>(context, listen: false).addAddress({
                for (var e in controllers.entries) e.key: e.value.text,
              });
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: aaliyahPrimaryColor),
            child: const Text("Save", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    ).then((_) {
      for (final controller in controllers.values) {
        controller.dispose();
      }
    });
  }
}
