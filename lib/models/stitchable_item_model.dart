// lib/models/stitchable_item_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class StitchableItem {
  final String name;
  final String imageUrl;

  const StitchableItem({
    required this.name,
    this.imageUrl = '', // Provide a default value
  });

  // --- ADD THIS CONSTRUCTOR ---
  // This teaches the class how to be created from a Firestore document
  factory StitchableItem.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return StitchableItem(
      name: data['name'] ?? 'Unnamed Item',
      imageUrl: data['imageUrl'] ?? '',
    );
  }
}