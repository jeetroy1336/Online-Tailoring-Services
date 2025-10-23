import 'package:flutter/material.dart';
import '../models/tailor_model.dart';
import '../screens/tailor_detail_screen.dart';

class TailorCard extends StatelessWidget {
  final Tailor tailor;

  const TailorCard({super.key, required this.tailor});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => TailorDetailScreen(tailor: tailor),
          ),
        );
      },
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        elevation: 3.0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            children: [
              // --- THIS IS THE UPDATED PART ---
              // We replaced the Placeholder with this CircleAvatar for a better look.
              CircleAvatar(
                radius: 35,
                backgroundColor: Colors.purple.shade100,
                child: const Icon(
                  Icons.person,
                  size: 40,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 16.0),
              // --- END OF UPDATED PART ---

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      tailor.name,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18.0),
                    ),
                    const SizedBox(height: 4.0),
                    Text(
                      tailor.specialty,
                      style: TextStyle(color: Colors.grey[700], fontSize: 14.0),
                    ),
                    const SizedBox(height: 8.0),
                    Row(
                      children: [
                        Icon(Icons.star, color: Colors.amber.shade600, size: 20),
                        const SizedBox(width: 4.0),
                        Text(
                          tailor.rating.toString(),
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16.0),
                        ),
                        const Spacer(),
                        Icon(Icons.location_on, color: Colors.grey.shade600, size: 16),
                        const SizedBox(width: 4.0),
                        Text(tailor.location, style: TextStyle(color: Colors.grey[800])),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}