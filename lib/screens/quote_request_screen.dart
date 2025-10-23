import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/tailor_model.dart'; // We need the tailor model

class QuoteRequestScreen extends StatefulWidget {
  final String itemName;
  final Tailor tailor; // We need to know which tailor this request is for

  const QuoteRequestScreen({
    super.key,
    required this.itemName,
    required this.tailor,
  });

  @override
  State<QuoteRequestScreen> createState() => _QuoteRequestScreenState();
}

class _QuoteRequestScreenState extends State<QuoteRequestScreen> {
  final _notesController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  Future<void> _submitRequest() async {
    if (!_formKey.currentState!.validate()) {
      return; // If form is not valid, do nothing.
    }
    setState(() => _isLoading = true);

    final customer = FirebaseAuth.instance.currentUser;
    if (customer == null) {
      // This should not happen if the user is logged in
      setState(() => _isLoading = false);
      return;
    }

    try {
      // Create a new document in the 'orders' collection
      await FirebaseFirestore.instance.collection('orders').add({
        'customerId': customer.uid,
        'tailorId': widget.tailor.id, // The ID of the tailor receiving the order
        'itemName': widget.itemName,
        'notes': _notesController.text.trim(),
        'status': 'Pending', // Initial status of the order
        'timestamp': FieldValue.serverTimestamp(), // The time the order was placed
      });

      if (mounted) {
        Navigator.of(context).pop(); // Go back to the previous screen
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Your request has been sent!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to send request: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Request a Quote', style: GoogleFonts.lato()),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Item: ${widget.itemName}',
                style: GoogleFonts.playfairDisplay(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              Text(
                'To: ${widget.tailor.name}',
                style: GoogleFonts.lato(fontSize: 16, color: Colors.grey.shade700),
              ),
              const SizedBox(height: 24),
              TextFormField(
                controller: _notesController,
                decoration: const InputDecoration(
                  labelText: 'Special Instructions or Measurements',
                  hintText: 'e.g., "Please add lining", "Length: 42 inches"',
                  border: OutlineInputBorder(),
                ),
                maxLines: 5,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please provide some details for the tailor.';
                  }
                  return null;
                },
              ),
              const Spacer(),
              ElevatedButton(
                onPressed: _isLoading ? null : _submitRequest,
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Send Request'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}