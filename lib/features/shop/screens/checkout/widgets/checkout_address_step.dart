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
  

  final bool dateHasError;
  final bool timeHasError;

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
    this.dateHasError = false,
    this.timeHasError = false,
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
            'Delivery Address',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 20),
          CheckoutAddressField(
            label: 'Street Address',
            controller: streetController, 
            icon: Icons.home_rounded,
            validator: AaliyahValidator.validateStreetAddress,
            textInputAction: TextInputAction.next,
          ),
          const SizedBox(height: 16),
          CheckoutAddressField(
            label: 'City', 
            controller: cityController, 
            icon: Icons.location_city_rounded,
            validator: AaliyahValidator.validateCity,
            textInputAction: TextInputAction.next,
          ),
          const SizedBox(height: 16),
          CheckoutAddressField(
            label: 'Postal Code',
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
            validator: AaliyahValidator.validateProvince,
            textInputAction: TextInputAction.done,
          ),
          const SizedBox(height: 16),
          CheckoutAddressField(label: 'Country', controller: countryController, icon: Icons.flag_rounded, enabled: false),
          const SizedBox(height: 24),
          
          Text(
            'Delivery Preference', 
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
    final colorScheme = Theme.of(context).colorScheme;

    return Semantics(
      button: true,
      label: 'Preferred Delivery Date',
      value: formattedDate,
      hint: 'Double tap to open calendar and select a delivery date',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            onTap: () async {
              final DateTime now = DateTime.now();
              final DateTime? picked = await showDatePicker(
                context: context,
                initialDate: selectedDate ?? now,
                firstDate: now, 
                lastDate: now.add(const Duration(days: 30)),
                helpText: 'Select Delivery Date',
                confirmText: 'Continue',
                cancelText: 'Dismiss',
                fieldLabelText: 'Delivery Date',
                fieldHintText: 'DD/MM/YYYY',
              );
              if (picked != null) onDateSelected(picked);
            },
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: dateHasError ? colorScheme.error : colorScheme.outlineVariant,
                  width: dateHasError ? 2.0 : 1.0,
                ),
                color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.1),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.calendar_month_rounded, 
                    color: dateHasError ? colorScheme.error : highlightColor,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Preferred Delivery Date',
                          style: TextStyle(
                            fontSize: 12,
                            color: dateHasError ? colorScheme.error : colorScheme.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          selectedDate != null ? formattedDate : 'Select a Date',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Format: DD/MM/YYYY',
                          style: TextStyle(
                            fontSize: 10,
                            color: colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(Icons.arrow_drop_down_rounded, color: colorScheme.onSurfaceVariant),
                ],
              ),
            ),
          ),
          if (dateHasError)
            Padding(
              padding: const EdgeInsets.only(top: 6, left: 12),
              child: Text(
                'Please select Preferred Delivery Date!',
                style: TextStyle(color: colorScheme.error, fontSize: 12),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTimePickerField(BuildContext context, Color highlightColor) {
    final String formattedTime = selectedTime != null 
        ? selectedTime!.format(context)
        : 'Not selected';
    final colorScheme = Theme.of(context).colorScheme;

    return Semantics(
      button: true,
      label: 'Preferred Delivery Time',
      value: formattedTime,
      hint: 'Double tap to select a preferred arrival time',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            onTap: () async {
              final TimeOfDay nowTime = TimeOfDay.now();
              final TimeOfDay? picked = await showTimePicker(
                context: context,
                initialTime: selectedTime ?? nowTime,
                helpText: 'Select Arrival Time',
                confirmText: 'Save',
                cancelText: 'Dismiss',
              );
              
              if (picked != null) {
                // Check if selected time is in the past only if date is today
                final DateTime now = DateTime.now();
                if (selectedDate != null && 
                    selectedDate!.year == now.year && 
                    selectedDate!.month == now.month && 
                    selectedDate!.day == now.day) {
                  
                  if (picked.hour < nowTime.hour || (picked.hour == nowTime.hour && picked.minute < nowTime.minute)) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Cannot select past time for today!'))
                      );
                    }
                    return;
                  }
                }
                onTimeSelected(picked);
              }
            },
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: timeHasError ? colorScheme.error : colorScheme.outlineVariant,
                  width: timeHasError ? 2.0 : 1.0,
                ),
                color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.1),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.access_time_rounded, 
                    color: timeHasError ? colorScheme.error : highlightColor,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Preferred Delivery Time',
                          style: TextStyle(
                            fontSize: 12,
                            color: timeHasError ? colorScheme.error : colorScheme.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          selectedTime != null ? formattedTime : 'Select a Time',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: colorScheme.onSurface,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(Icons.arrow_drop_down_rounded, color: colorScheme.onSurfaceVariant),
                ],
              ),
            ),
          ),
          if (timeHasError)
            Padding(
              padding: const EdgeInsets.only(top: 6, left: 12),
              child: Text(
                'Please select Preferred Delivery Time!',
                style: TextStyle(color: colorScheme.error, fontSize: 12),
              ),
            ),
        ],
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
          isLocating ? 'Locating...' : 'Use Current Location',
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
