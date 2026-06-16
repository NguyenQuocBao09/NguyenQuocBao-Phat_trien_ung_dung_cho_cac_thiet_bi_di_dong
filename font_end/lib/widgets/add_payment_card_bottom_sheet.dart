import 'package:flutter/material.dart';
import 'package:font_end/models/payment_card.dart';
import 'package:font_end/services/checkout_service.dart';

class AddPaymentCardBottomSheet extends StatefulWidget {
  const AddPaymentCardBottomSheet({super.key});

  @override
  State<AddPaymentCardBottomSheet> createState() => _AddPaymentCardBottomSheetState();
}

class _AddPaymentCardBottomSheetState extends State<AddPaymentCardBottomSheet> {
  final _nameController = TextEditingController();
  final _numberController = TextEditingController();
  final _expiryController = TextEditingController();
  final _cvvController = TextEditingController();
  bool _isDefault = false;

  void _addCard() async {
    final card = PaymentCard(
      id: '',
      cardHolderName: _nameController.text,
      cardNumber: _numberController.text,
      expiryDate: _expiryController.text,
      brand: _numberController.text.startsWith('4') ? 'Visa' : 'Mastercard', // Simple mock logic
      isDefault: _isDefault,
    );
    await checkoutService.addPaymentCard(card);
    if (mounted) {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFFF9F9F9),
        borderRadius: BorderRadius.only(topLeft: Radius.circular(24), topRight: Radius.circular(24)),
      ),
      padding: const EdgeInsets.all(24),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(width: 60, height: 4, decoration: BoxDecoration(color: Colors.grey.shade400, borderRadius: BorderRadius.circular(2))),
            const SizedBox(height: 16),
            const Text('Add new card', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 24),
            _buildTextField(_nameController, 'Name on card'),
            const SizedBox(height: 16),
            _buildTextField(_numberController, 'Card number', keyboardType: TextInputType.number),
            const SizedBox(height: 16),
            _buildTextField(_expiryController, 'Expire Date', keyboardType: TextInputType.datetime),
            const SizedBox(height: 16),
            _buildTextField(_cvvController, 'CVV', keyboardType: TextInputType.number),
            const SizedBox(height: 16),
            Row(
              children: [
                Checkbox(
                  value: _isDefault,
                  onChanged: (val) => setState(() => _isDefault = val ?? false),
                  activeColor: Colors.black,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                ),
                const Text('Set as default payment method'),
              ],
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _addCard,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                ),
                child: const Text('ADD CARD', style: TextStyle(color: Colors.white, fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String hint, {TextInputType keyboardType = TextInputType.text}) {
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
        keyboardType: keyboardType,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: Colors.grey, fontSize: 14),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
      ),
    );
  }
}
