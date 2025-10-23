import 'package:flutter/material.dart';

class CustomTextField extends StatelessWidget {
  final String label;
  final bool obscure;
  final Widget? suffixIcon;

  // --- ADDED: controller parameter ---
  final TextEditingController? controller;

  const CustomTextField({
    super.key,
    required this.label,
    this.obscure = false,
    this.suffixIcon,

    // --- ADDED: controller in constructor ---
    this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextField(
        // --- ADDED: controller in TextField ---
        controller: controller,
        obscureText: obscure,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
          suffixIcon: suffixIcon,
        ),
      ),
    );
  }
}