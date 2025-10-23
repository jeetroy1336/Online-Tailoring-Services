import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';

import 'role_selection_screen.dart'; // Import for logout navigation

class TailorDashboardScreen extends StatefulWidget {
  const TailorDashboardScreen({super.key});

  @override
  State<TailorDashboardScreen> createState() => _TailorDashboardScreenState();
}

class _TailorDashboardScreenState extends State<TailorDashboardScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // --- Theme Colors ---
  static const Color primaryTextColor = Color(0xFF2C3A4F);
  static const Color accentColor = Color(0xFFE5A12D);

  // --- State Variables ---
  final _nameController = TextEditingController();
  final _specialtyController = TextEditingController();
  final _locationController = TextEditingController();
  final _serviceNameController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadTailorProfile();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _nameController.dispose();
    _specialtyController.dispose();
    _locationController.dispose();
    _serviceNameController.dispose();
    super.dispose();
  }

  // --- Data Fetching & Saving ---
  Future<void> _loadTailorProfile() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final doc =
    await FirebaseFirestore.instance.collection('tailors').doc(user.uid).get();
    if (doc.exists && doc.data() != null) {
      final data = doc.data()!;
      _nameController.text = data['name'] ?? '';
      _specialtyController.text = data['specialty'] ?? '';
      _locationController.text = data['location'] ?? '';
    }
  }

  Future<void> _saveProfile() async {
    // This line is CRUCIAL. It checks if the form fields are valid.
    if (!_formKey.currentState!.validate()) {
      // If any field is empty, the function stops here.
      return;
    }

    setState(() => _isLoading = true);

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      setState(() => _isLoading = false);
      return;
    }

    try {
      await FirebaseFirestore.instance.collection('tailors').doc(user.uid).set({
        'name': _nameController.text.trim(),
        'specialty': _specialtyController.text.trim(),
        'location': _locationController.text.trim(),
      }, SetOptions(merge: true));

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Profile Saved!'), backgroundColor: Colors.green),
        );
      }
    } catch(e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('An error occurred: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // --- Service Management Logic ---
  Future<void> _addService() async {
    if (_serviceNameController.text.isEmpty) return;
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    await FirebaseFirestore.instance
        .collection('tailors')
        .doc(user.uid)
        .collection('services')
        .add({'name': _serviceNameController.text.trim(), 'imageUrl': ''});

    _serviceNameController.clear();
    if (mounted) Navigator.of(context).pop();
  }

  Future<void> _deleteService(String serviceId) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    await FirebaseFirestore.instance
        .collection('tailors')
        .doc(user.uid)
        .collection('services')
        .doc(serviceId)
        .delete();
  }

  // --- Order Management Logic ---
  Future<void> _updateOrderStatus(String orderId, String newStatus) async {
    await FirebaseFirestore.instance
        .collection('orders')
        .doc(orderId)
        .update({'status': newStatus});

    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('My Dashboard', style: GoogleFonts.lato()),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              if (mounted) {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (context) => const RoleSelectionScreen()),
                      (route) => false,
                );
              }
            },
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: primaryTextColor,
          unselectedLabelColor: primaryTextColor.withOpacity(0.6),
          indicatorColor: accentColor,
          indicatorWeight: 3,
          tabs: const [
            Tab(icon: Icon(Icons.person_outline), text: 'Profile'),
            Tab(icon: Icon(Icons.checkroom), text: 'Services'),
            Tab(icon: Icon(Icons.receipt_long_outlined), text: 'Orders'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildProfileTab(),
          _buildServicesTab(),
          _buildOrdersTab(),
        ],
      ),
    );
  }

  // --- UI WIDGETS ---
  Widget _buildProfileTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: _formKey, // The key that connects to our validation logic
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Icon(Icons.storefront_outlined, size: 80, color: accentColor),
            const SizedBox(height: 24),
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Shop Name'),
              validator: (value) => value!.isEmpty ? 'Please enter a name' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _specialtyController,
              decoration: const InputDecoration(labelText: 'Specialty'),
              validator: (value) => value!.isEmpty ? 'Please enter a specialty' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _locationController,
              decoration: const InputDecoration(labelText: 'Location'),
              validator: (value) => value!.isEmpty ? 'Please enter a location' : null,
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: _isLoading ? null : _saveProfile,
              child: _isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text('Save Profile'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildServicesTab() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return const Center(child: Text('Please log in.'));

    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddServiceDialog(),
        backgroundColor: accentColor,
        tooltip: 'Add Service',
        child: const Icon(Icons.add, color: primaryTextColor),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('tailors').doc(user.uid).collection('services').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No services added yet. Tap + to add one.'));
          }
          final services = snapshot.data!.docs;
          return ListView.builder(
            itemCount: services.length,
            itemBuilder: (context, index) {
              final service = services[index];
              return ListTile(
                leading: const Icon(Icons.checkroom_outlined, color: primaryTextColor),
                title: Text(service['name'], style: GoogleFonts.lato(fontWeight: FontWeight.bold)),
                trailing: IconButton(
                  icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                  onPressed: () => _deleteService(service.id),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildOrdersTab() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return const Center(child: Text('Please log in.'));

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('orders').where('tailorId', isEqualTo: user.uid).snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text('You have no incoming orders.'));
        }
        final orders = snapshot.data!.docs;
        return ListView.builder(
          itemCount: orders.length,
          itemBuilder: (context, index) {
            final order = orders[index];
            final data = order.data() as Map<String, dynamic>;
            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: ListTile(
                title: Text(data['itemName'] ?? 'No Item Name', style: GoogleFonts.lato(fontWeight: FontWeight.bold)),
                subtitle: Text('Status: ${data['status'] ?? 'Pending'}'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => _showStatusUpdateDialog(order.id, data['status']),
              ),
            );
          },
        );
      },
    );
  }

  // --- Helper Dialogs ---
  void _showAddServiceDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add New Service'),
        content: TextField(
          controller: _serviceNameController,
          autofocus: true,
          decoration: const InputDecoration(hintText: 'e.g., Blouse Stitching'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancel')),
          ElevatedButton(onPressed: _addService, child: const Text('Add')),
        ],
      ),
    );
  }

  void _showStatusUpdateDialog(String orderId, String currentStatus) {
    showDialog(
      context: context,
      builder: (context) {
        return SimpleDialog(
          title: const Text('Update Order Status'),
          children: [
            _statusOption(orderId, 'Accepted', currentStatus),
            _statusOption(orderId, 'In Progress', currentStatus),
            _statusOption(orderId, 'Completed', currentStatus),
            _statusOption(orderId, 'Declined', currentStatus),
          ],
        );
      },
    );
  }

  Widget _statusOption(String orderId, String status, String currentStatus) {
    return SimpleDialogOption(
      onPressed: () => _updateOrderStatus(orderId, status),
      child: Text(
        status,
        style: TextStyle(
          fontWeight: status == currentStatus ? FontWeight.bold : FontWeight.normal,
          color: status == currentStatus ? accentColor : primaryTextColor,
        ),
      ),
    );
  }
}