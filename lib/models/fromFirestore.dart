// lib/models/stitchable_item_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class StitchableItem {
  final String name;
  final String imageUrl; // <-- Add imageUrl for better UI

  const StitchableItem({required this.name, this.imageUrl = ''});

  // --- ADD THIS FACTORY CONSTRUCTOR ---
  factory StitchableItem.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return StitchableItem(
      name: data['name'] ?? 'Unnamed Item',
      imageUrl: data['imageUrl'] ?? '',
    );
  }
}