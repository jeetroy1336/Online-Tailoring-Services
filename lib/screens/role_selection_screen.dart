// lib/screens/role_selection_screen.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'auth_screen.dart';

class RoleSelectionScreen extends StatelessWidget {
  const RoleSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const Color backgroundColor = Color(0xFFF7F2E9);
    const Color primaryTextColor = Color(0xFF2C3A4F);
    const Color accentColor = Color(0xFFE5A12D);

    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacer(),
              Text(
                'Join TailorHub As',
                textAlign: TextAlign.center,
                style: GoogleFonts.playfairDisplay(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: primaryTextColor,
                ),
              ),
              const SizedBox(height: 40),
              _buildRoleButton(
                context,
                icon: Icons.person_outline,
                label: 'A Customer',
                role: 'user', // Pass 'user' role
                backgroundColor: primaryTextColor,
                foregroundColor: backgroundColor,
              ),
              const SizedBox(height: 20),
              _buildRoleButton(
                context,
                icon: Icons.cut_rounded,
                label: 'A Tailor',
                role: 'tailor', // Pass 'tailor' role
                backgroundColor: Colors.transparent,
                foregroundColor: primaryTextColor,
                borderColor: accentColor,
              ),
              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRoleButton(
      BuildContext context, {
        required IconData icon,
        required String label,
        required String role,
        required Color backgroundColor,
        required Color foregroundColor,
        Color? borderColor,
      }) {
    return SizedBox(
      height: 60,
      child: ElevatedButton.icon(
        onPressed: () {
          // Navigate to AuthScreen and pass the selected role
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AuthScreen(selectedRole: role),
            ),
          );
        },
        icon: Icon(icon, size: 24),
        label: Text(label, style: GoogleFonts.lato(fontSize: 18, fontWeight: FontWeight.bold)),
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
          foregroundColor: foregroundColor,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(
              color: borderColor ?? Colors.transparent,
              width: 2,
            ),
          ),
        ),
      ),
    );
  }
}