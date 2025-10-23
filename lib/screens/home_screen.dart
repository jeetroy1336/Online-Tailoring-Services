import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/tailor_model.dart';
import '../widgets/tailor_card.dart';
import 'tailor_detail_screen.dart'; // --- ADDED: Import for navigation ---

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // --- Define the theme colors for consistency ---
    const Color primaryTextColor = Color(0xFF2C3A4F);
    const Color backgroundColor = Color(0xFFF7F2E9);

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: const Text('Available Tailors', style: TextStyle(color: primaryTextColor)),
        backgroundColor: backgroundColor,
        elevation: 0,
        iconTheme: const IconThemeData(color: primaryTextColor),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () { /* Future search functionality */ },
          ),
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () { /* Future filter functionality */ },
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('tailors').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return const Center(child: Text('Something went wrong!'));
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No tailors found.'));
          }

          final tailors = snapshot.data!.docs.map((doc) {
            // --- CRITICAL FIX: Pass the entire document snapshot 'doc' ---
            // This ensures the Tailor object gets its unique ID.
            return Tailor.fromFirestore(doc);
          }).toList();

          return ListView.builder(
            itemCount: tailors.length,
            itemBuilder: (context, index) {
              final tailor = tailors[index];
              // --- CHANGED: Wrapped TailorCard with GestureDetector for tapping ---
              return GestureDetector(
                onTap: () {
                  // Navigate to the detail screen, passing the selected tailor
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => TailorDetailScreen(tailor: tailor),
                    ),
                  );
                },
                child: TailorCard(tailor: tailor),
              );
            },
          );
        },
      ),
    );
  }
}