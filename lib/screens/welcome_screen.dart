import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
// --- CHANGED: We now navigate to the role selection screen ---
import 'role_selection_screen.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // --- Using the "Artisan Khadi & Indigo" theme for consistency ---
    const Color backgroundColor = Color(0xFFF7F2E9);
    const Color primaryTextColor = Color(0xFF2C3A4F);
    const Color accentColor = Color(0xFFE5A12D);

    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacer(),
              const Icon(
                Icons.cut_rounded,
                size: 90,
                color: accentColor,
              ),
              const SizedBox(height: 24),
              Text(
                'TailorHub',
                textAlign: TextAlign.center,
                style: GoogleFonts.playfairDisplay(
                  fontSize: 42,
                  fontWeight: FontWeight.bold,
                  color: primaryTextColor,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Crafting perfection, stitched for you.',
                textAlign: TextAlign.center,
                style: GoogleFonts.lato(
                  fontSize: 16,
                  color: primaryTextColor.withOpacity(0.7),
                ),
              ),
              const Spacer(),
              const Spacer(),
              SizedBox(
                height: 55,
                child: ElevatedButton(
                  // --- FIX: Navigate to the role selection screen ---
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const RoleSelectionScreen()),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryTextColor,
                    foregroundColor: backgroundColor,
                  ),
                  child: Text(
                    'Get Started',
                    style: GoogleFonts.lato(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Already have an account? ",
                    style: GoogleFonts.lato(color: primaryTextColor.withOpacity(0.7)),
                  ),
                  GestureDetector(
                    // --- FIX: Navigate to the role selection screen ---
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const RoleSelectionScreen()),
                    ),
                    child: Text(
                      'Login',
                      style: GoogleFonts.lato(
                        color: primaryTextColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}