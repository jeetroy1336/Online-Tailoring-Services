import 'package:flutter/material.dart';

class RoleSelector extends StatelessWidget {
  final String role;
  final ValueChanged<String> onChanged;

  const RoleSelector({super.key, required this.role, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ChoiceChip(
          label: const Text('Customer'),
          selected: role == 'Customer',
          onSelected: (_) => onChanged('Customer'),
        ),
        const SizedBox(width: 10),
        ChoiceChip(
          label: const Text('Tailor'),
          selected: role == 'Tailor',
          onSelected: (_) => onChanged('Tailor'),
        ),
      ],
    );
  }
}