import 'package:flutter/material.dart';
import 'package:aaliyahs_collection_estore/common/widgets/loaders/expressive_progress_indicator.dart';

import 'package:aaliyahs_collection_estore/features/shop/screens/checkout/widgets/checkout_address_field.dart';
import 'package:aaliyahs_collection_estore/utils/validators/validator.dart';

class CheckoutAddressStep extends StatelessWidget {
  final TextEditingController streetController;
  final TextEditingController cityController;
  final TextEditingController provinceController;
  final TextEditingController postalCodeController;
  final TextEditingController countryController;
  final bool isLocating;
  final VoidCallback onLocateMe;
  final DateTime? selectedDate;
  final Function(DateTime) onDateSelected;
  final TimeOfDay? selectedTime;
  final Function(TimeOfDay) onTimeSelected;

  const CheckoutAddressStep({
    super.key,
    required this.streetController,
    required this.cityController,
    required this.provinceController,
    required this.postalCodeController,
    required this.countryController,
    required this.isLocating,
    required this.onLocateMe,
    required this.selectedDate,
    required this.onDateSelected,
    required this.selectedTime,
    required this.onTimeSelected,
  });

  @override
  Widget build(BuildContext context) {
    final highlightColor = Theme.of(context).colorScheme.primary;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Delivery address', // Sentence case
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 20),
          CheckoutAddressField(
            label: 'Street address', // Sentence case
            controller: streetController, 
            icon: Icons.home_rounded,
            validator: AaliyahValidator.validateRequiredField,
            textInputAction: TextInputAction.next,
          ),
          const SizedBox(height: 16),
          CheckoutAddressField(
            label: 'City', 
            controller: cityController, 
            icon: Icons.location_city_rounded,
            validator: AaliyahValidator.validateRequiredField,
            textInputAction: TextInputAction.next,
          ),
          const SizedBox(height: 16),
          CheckoutAddressField(
            label: 'Postal code', // Sentence case
            controller: postalCodeController, 
            icon: Icons.markunread_mailbox_rounded,
            validator: AaliyahValidator.validatePostalCode,
            textInputAction: TextInputAction.next,
          ),
          const SizedBox(height: 16),
          CheckoutAddressField(
            label: 'Province', 
            controller: provinceController, 
            icon: Icons.map_rounded,
            validator: AaliyahValidator.validateRequiredField,
            textInputAction: TextInputAction.done,
          ),
          const SizedBox(height: 16),
          // Country is disabled, so no action needed
          CheckoutAddressField(label: 'Country', controller: countryController, icon: Icons.flag_rounded, enabled: false),
          const SizedBox(height: 24),
          
          Text(
            'Delivery preference', 
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 16),
          _buildDatePickerField(context, highlightColor),
          const SizedBox(height: 12),
          _buildTimePickerField(context, highlightColor),
          
          const SizedBox(height: 24),
          _buildLocateButton(highlightColor),
        ],
      ),
    );
  }

  Widget _buildDatePickerField(BuildContext context, Color highlightColor) {
    final String formattedDate = selectedDate != null 
        ? '${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}'
        : 'Not selected';

    return Semantics(
      button: true,
      label: 'Preferred delivery date',
      value: formattedDate,
      hint: 'Double tap to open calendar and select a delivery date',
      child: InkWell(
        onTap: () async {
          final DateTime? picked = await showDatePicker(
            context: context,
            initialDate: selectedDate ?? DateTime.now().add(const Duration(days: 3)),
            firstDate: DateTime.now().add(const Duration(days: 2)), 
            lastDate: DateTime.now().add(const Duration(days: 30)),
            helpText: 'Select delivery date',
            confirmText: 'Continue',
            cancelText: 'Dismiss',
            fieldLabelText: 'Delivery date',
            fieldHintText: 'DD/MM/YYYY',
          );
          if (picked != null) onDateSelected(picked);
        },
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
            color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.1),
          ),
          child: Row(
            children: [
              Icon(Icons.calendar_month_rounded, color: highlightColor),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Preferred delivery date',
                      style: TextStyle(
                        fontSize: 12,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      selectedDate != null ? formattedDate : 'Select a date',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Format: DD/MM/YYYY',
                      style: TextStyle(
                        fontSize: 10,
                        color: Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.arrow_drop_down_rounded, color: Theme.of(context).colorScheme.onSurfaceVariant),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTimePickerField(BuildContext context, Color highlightColor) {
    final String formattedTime = selectedTime != null 
        ? selectedTime!.format(context)
        : 'Not selected';

    return Semantics(
      button: true,
      label: 'Preferred delivery time',
      value: formattedTime,
      hint: 'Double tap to select a preferred arrival time',
      child: InkWell(
        onTap: () async {
          final TimeOfDay? picked = await showTimePicker(
            context: context,
            initialTime: selectedTime ?? const TimeOfDay(hour: 9, minute: 0),
            helpText: 'Select arrival time',
            confirmText: 'Save',
            cancelText: 'Dismiss',
          );
          if (picked != null) onTimeSelected(picked);
        },
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
            color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.1),
          ),
          child: Row(
            children: [
              Icon(Icons.access_time_rounded, color: highlightColor),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Preferred delivery time',
                      style: TextStyle(
                        fontSize: 12,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      selectedTime != null ? formattedTime : 'Select a time',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.arrow_drop_down_rounded, color: Theme.of(context).colorScheme.onSurfaceVariant),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLocateButton(Color highlightColor) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: isLocating ? null : onLocateMe,
        icon: isLocating
            ? SizedBox(
                width: 24, 
                height: 24, 
                child: ExpressiveCircularProgressIndicator(
                  strokeWidth: 3, 
                  size: 24,
                  isWavy: true, 
                  showTrack: false,
                  color: highlightColor,
                  semanticLabel: 'Locating your current position',
                ),
              )
            : Icon(Icons.my_location_rounded, color: highlightColor),
        label: Text(
          isLocating ? 'Locating...' : 'Use current location',
          style: TextStyle(color: highlightColor),
        ),
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          side: BorderSide(color: highlightColor),
          foregroundColor: highlightColor,
        ),
      ),
    );
  }
}
