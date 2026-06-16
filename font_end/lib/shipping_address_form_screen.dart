import 'package:flutter/material.dart';
import 'package:font_end/models/user_address.dart';
import 'package:font_end/services/checkout_service.dart';

class ShippingAddressFormScreen extends StatefulWidget {
  final UserAddress? addressToEdit;

  const ShippingAddressFormScreen({super.key, this.addressToEdit});

  @override
  State<ShippingAddressFormScreen> createState() => _ShippingAddressFormScreenState();
}

class _ShippingAddressFormScreenState extends State<ShippingAddressFormScreen> {
  late TextEditingController _nameController;
  late TextEditingController _addressController;
  late TextEditingController _cityController;
  late TextEditingController _stateController;
  late TextEditingController _zipCodeController;
  late TextEditingController _countryController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.addressToEdit?.fullName ?? '');
    _addressController = TextEditingController(text: widget.addressToEdit?.address ?? '');
    _cityController = TextEditingController(text: widget.addressToEdit?.city ?? '');
    _stateController = TextEditingController(text: widget.addressToEdit?.state ?? '');
    _zipCodeController = TextEditingController(text: widget.addressToEdit?.zipCode ?? '');
    _countryController = TextEditingController(text: widget.addressToEdit?.country ?? 'United States');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _zipCodeController.dispose();
    _countryController.dispose();
    super.dispose();
  }

  void _saveAddress() async {
    final newAddress = UserAddress(
      id: widget.addressToEdit?.id ?? '',
      fullName: _nameController.text,
      address: _addressController.text,
      city: _cityController.text,
      state: _stateController.text,
      zipCode: _zipCodeController.text,
      country: _countryController.text,
      isDefault: widget.addressToEdit?.isDefault ?? false,
    );

    if (widget.addressToEdit == null) {
      await checkoutService.addAddress(newAddress);
    } else {
      await checkoutService.updateAddress(newAddress.id, newAddress);
    }

    if (mounted) {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isEditing = widget.addressToEdit != null;
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          isEditing ? 'Editing Shipping Address' : 'Adding Shipping Address',
          style: const TextStyle(color: Colors.black, fontSize: 18, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildTextField(_nameController, 'Full name'),
            const SizedBox(height: 16),
            _buildTextField(_addressController, 'Address'),
            const SizedBox(height: 16),
            _buildTextField(_cityController, 'City'),
            const SizedBox(height: 16),
            _buildTextField(_stateController, 'State/Province/Region'),
            const SizedBox(height: 16),
            _buildTextField(_zipCodeController, 'Zip Code (Postal Code)'),
            const SizedBox(height: 16),
            _buildTextField(_countryController, 'Country', suffixIcon: const Icon(Icons.keyboard_arrow_right, color: Colors.grey)),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _saveAddress,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                ),
                child: const Text('SAVE ADDRESS', style: TextStyle(color: Colors.white, fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, {Widget? suffixIcon}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(4),
        boxShadow: [
          BoxShadow(color: Colors.grey.withOpacity(0.1), spreadRadius: 1, blurRadius: 5),
        ],
      ),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Colors.grey, fontSize: 12),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          suffixIcon: suffixIcon,
        ),
      ),
    );
  }
}
