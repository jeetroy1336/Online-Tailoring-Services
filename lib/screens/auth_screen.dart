import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';

import 'home_screen.dart';
import 'tailor_dashboard_screen.dart';

class AuthScreen extends StatefulWidget {
  final String selectedRole;

  const AuthScreen({
    super.key,
    required this.selectedRole,
  });

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  static const Color backgroundColor = Color(0xFFF7F2E9);
  static const Color primaryTextColor = Color(0xFF2C3A4F);
  static const Color accentColor = Color(0xFFE5A12D);
  static const Color fieldBackgroundColor = Color(0xFFEAE5DB);

  bool _isLoading = false;
  final _loginEmailController = TextEditingController();
  final _loginPasswordController = TextEditingController();
  bool _loginObscurePassword = true;
  final _signupNameController = TextEditingController();
  final _signupEmailController = TextEditingController();
  final _signupPasswordController = TextEditingController();
  final _signupConfirmPasswordController = TextEditingController();
  bool _signupObscurePassword = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _loginEmailController.dispose();
    _loginPasswordController.dispose();
    _signupNameController.dispose();
    _signupEmailController.dispose();
    _signupPasswordController.dispose();
    _signupConfirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _signUpUser() async {
    if (_signupPasswordController.text != _signupConfirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Passwords do not match!"), backgroundColor: Colors.redAccent),
      );
      return;
    }
    setState(() => _isLoading = true);

    try {
      final UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _signupEmailController.text.trim(),
        password: _signupPasswordController.text.trim(),
      );

      if (userCredential.user != null) {
        await FirebaseFirestore.instance.collection('users').doc(userCredential.user!.uid).set({
          'role': widget.selectedRole,
          'email': _signupEmailController.text.trim(),
        });

        // --- FIX: Check if widget is still mounted ---
        if (mounted) _redirectUser(widget.selectedRole);
      }
    } on FirebaseAuthException catch (e) {
      // --- FIX: Check if widget is still mounted ---
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message ?? "An error occurred")));
      }
    } finally {
      // --- FIX: Check if widget is still mounted ---
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _loginUser() async {
    setState(() => _isLoading = true);
    try {
      final UserCredential userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _loginEmailController.text.trim(),
        password: _loginPasswordController.text.trim(),
      );

      if (userCredential.user != null) {
        final doc = await FirebaseFirestore.instance.collection('users').doc(userCredential.user!.uid).get();
        final role = doc.data()?['role'] ?? 'user';

        // --- FIX: Check if widget is still mounted ---
        if (mounted) _redirectUser(role);
      }
    } on FirebaseAuthException catch (e) {
      // --- FIX: Check if widget is still mounted ---
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message ?? "An error occurred")));
      }
    } finally {
      // --- FIX: Check if widget is still mounted ---
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _redirectUser(String role) {
    if (!mounted) return;

    if (role == 'tailor') {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const TailorDashboardScreen()),
            (route) => false,
      );
    } else {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const HomeScreen()),
            (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: primaryTextColor),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              children: [
                Text(
                  'Welcome',
                  style: GoogleFonts.playfairDisplay(
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    color: primaryTextColor,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Enter your details to continue',
                  style: GoogleFonts.lato(
                    fontSize: 16,
                    color: primaryTextColor.withOpacity(0.7),
                  ),
                ),
                const SizedBox(height: 30),
                TabBar(
                  controller: _tabController,
                  labelStyle: GoogleFonts.lato(fontWeight: FontWeight.bold, fontSize: 16),
                  labelColor: primaryTextColor,
                  unselectedLabelColor: primaryTextColor.withOpacity(0.5),
                  indicator: const DashedUnderlineTabIndicator(color: accentColor, strokeWidth: 3.0),
                  tabs: const [Tab(text: 'Login'), Tab(text: 'Sign Up')],
                ),
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.6,
                  child: TabBarView(
                    controller: _tabController,
                    children: [_buildLoginTab(), _buildSignupTab()],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLoginTab() {
    return Padding(
      padding: const EdgeInsets.only(top: 24.0),
      child: Column(
        children: [
          _buildTextField(controller: _loginEmailController, label: 'Email', icon: Icons.email_outlined),
          const SizedBox(height: 16),
          _buildTextField(
            controller: _loginPasswordController,
            label: 'Password',
            icon: Icons.lock_outline,
            isObscure: _loginObscurePassword,
            suffixIcon: IconButton(
              icon: Icon(_loginObscurePassword ? Icons.visibility_off : Icons.visibility, color: primaryTextColor.withOpacity(0.6)),
              onPressed: () => setState(() => _loginObscurePassword = !_loginObscurePassword),
            ),
          ),
          const SizedBox(height: 32),
          _buildAuthButton(label: 'Login', onPressed: _loginUser),
        ],
      ),
    );
  }

  Widget _buildSignupTab() {
    return Padding(
      padding: const EdgeInsets.only(top: 24.0),
      child: Column(
        children: [
          _buildTextField(controller: _signupNameController, label: 'Full Name', icon: Icons.person_outline),
          const SizedBox(height: 16),
          _buildTextField(controller: _signupEmailController, label: 'Email', icon: Icons.email_outlined),
          const SizedBox(height: 16),
          _buildTextField(
            controller: _signupPasswordController,
            label: 'Password',
            icon: Icons.lock_outline,
            isObscure: _signupObscurePassword,
            suffixIcon: IconButton(
              icon: Icon(_signupObscurePassword ? Icons.visibility_off : Icons.visibility, color: primaryTextColor.withOpacity(0.6)),
              onPressed: () => setState(() => _signupObscurePassword = !_signupObscurePassword),
            ),
          ),
          const SizedBox(height: 16),
          _buildTextField(controller: _signupConfirmPasswordController, label: 'Confirm Password', icon: Icons.lock_person_outlined, isObscure: true),
          const SizedBox(height: 32),
          _buildAuthButton(label: 'Create Account', onPressed: _signUpUser),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool isObscure = false,
    Widget? suffixIcon,
  }) {
    return TextField(
      controller: controller,
      obscureText: isObscure,
      style: GoogleFonts.lato(color: primaryTextColor, fontWeight: FontWeight.w600),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: GoogleFonts.lato(color: primaryTextColor.withOpacity(0.6)),
        prefixIcon: Icon(icon, color: primaryTextColor.withOpacity(0.6)),
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: fieldBackgroundColor,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: accentColor, width: 2),
        ),
      ),
    );
  }

  Widget _buildAuthButton({required String label, required VoidCallback onPressed}) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: _isLoading ? null : onPressed,
        child: _isLoading
            ? const CircularProgressIndicator(color: backgroundColor)
            : Text(label),
      ),
    );
  }
}

// Custom TabBar Indicator Class
class DashedUnderlineTabIndicator extends Decoration {
  final Color color;
  final double strokeWidth;

  const DashedUnderlineTabIndicator({
    this.color = Colors.black,
    this.strokeWidth = 2.0,
  });

  @override
  BoxPainter createBoxPainter([VoidCallback? onChanged]) {
    return _DashedUnderlinePainter(color: color, strokeWidth: strokeWidth);
  }
}

class _DashedUnderlinePainter extends BoxPainter {
  final Color color;
  final double strokeWidth;

  _DashedUnderlinePainter({
    required this.color,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Offset offset, ImageConfiguration configuration) {
    final Rect rect = offset & configuration.size!;
    final Paint paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    const double dashWidth = 5.0;
    const double dashSpace = 4.0;
    double startX = rect.bottomLeft.dx;
    final double y = rect.bottomLeft.dy - strokeWidth / 2;

    while (startX < rect.bottomRight.dx) {
      canvas.drawLine(Offset(startX, y), Offset(startX + dashWidth, y), paint);
      startX += dashWidth + dashSpace;
    }
  }
}