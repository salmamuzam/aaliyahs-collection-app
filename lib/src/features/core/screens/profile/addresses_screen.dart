import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:aaliyahs_collection_estore/provider/address_provider.dart';

class AddressesScreen extends StatelessWidget {
  const AddressesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("My Addresses", style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showAddressDialog(context),
          ),
        ],
      ),
      body: Consumer<AddressProvider>(
        builder: (context, provider, child) {
          final addresses = provider.addresses;
          if (addresses.isEmpty) {
            return const Center(child: Text("No saved addresses"));
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: addresses.length,
            itemBuilder: (context, index) {
              final addr = addresses[index];
              return Card(
                child: ListTile(
                  title: Text(addr['label'] ?? "Address"),
                  subtitle: Text("${addr['address']}, ${addr['city']}, ${addr['state']} ${addr['zip']}"),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => provider.deleteAddress(addr['id']),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _showAddressDialog(BuildContext context) {
    final labelController = TextEditingController();
    final addressController = TextEditingController();
    final cityController = TextEditingController();
    final stateController = TextEditingController();
    final zipController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Add New Address"),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: labelController, decoration: const InputDecoration(labelText: "Label (e.g. Home, Work)")),
              TextField(controller: addressController, decoration: const InputDecoration(labelText: "Street Address")),
              TextField(controller: cityController, decoration: const InputDecoration(labelText: "City")),
              TextField(controller: stateController, decoration: const InputDecoration(labelText: "State")),
              TextField(controller: zipController, decoration: const InputDecoration(labelText: "Zip Code")),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          TextButton(
            onPressed: () {
              Provider.of<AddressProvider>(context, listen: false).addAddress({
                'label': labelController.text,
                'address': addressController.text,
                'city': cityController.text,
                'state': stateController.text,
                'zip': zipController.text,
              });
              Navigator.pop(context);
            },
            child: const Text("Save"),
          ),
        ],
      ),
    );
  }
}
