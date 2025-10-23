// lib/models/tailor_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class Tailor {
  final String id; // <-- ADD THIS
  final String name;
  final String specialty;
  final double rating;
  final String location;
  final String imageUrl;

  Tailor({
    required this.id, // <-- ADD THIS
    required this.name,
    required this.specialty,
    required this.rating,
    required this.location,
    required this.imageUrl,
  });

  // --- CHANGED: Accept a DocumentSnapshot to get the ID ---
  factory Tailor.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Tailor(
      id: doc.id, // <-- Get the document ID here
      name: data['name'] ?? 'No Name',
      specialty: data['specialty'] ?? 'No Specialty',
      rating: (data['rating'] as num?)?.toDouble() ?? 0.0,
      location: data['location'] ?? 'No Location',
      imageUrl: data['imageUrl'] ?? '',
    );
  }
}