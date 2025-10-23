import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/stitchable_item_model.dart';
import '../models/tailor_model.dart';
import 'shirt_customization_screen.dart';
import 'quote_request_screen.dart';

class TailorDetailScreen extends StatefulWidget {
  final Tailor tailor;

  const TailorDetailScreen({super.key, required this.tailor});

  @override
  State<TailorDetailScreen> createState() => _TailorDetailScreenState();
}

class _TailorDetailScreenState extends State<TailorDetailScreen> {
  // --- This Future will hold our list of services ---
  late Future<List<StitchableItem>> servicesFuture;

  @override
  void initState() {
    super.initState();
    // --- Fetch the services when the screen loads ---
    servicesFuture = _fetchServices();
  }

  // --- A method to get the services sub-collection ---
  Future<List<StitchableItem>> _fetchServices() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('tailors')
        .doc(widget.tailor.id) // Use the tailor's ID
        .collection('services')
        .get();

    // Convert each document into a StitchableItem object
    return snapshot.docs.map((doc) => StitchableItem.fromFirestore(doc)).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          _buildSliverAppBar(context),
          _buildTailorInfo(context),
          // --- Use a FutureBuilder to display the services ---
          _buildServicesSection(),
        ],
      ),
    );
  }

  SliverAppBar _buildSliverAppBar(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 250.0,
      pinned: true,
      elevation: 2.0,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      foregroundColor: Colors.black87,
      flexibleSpace: FlexibleSpaceBar(
        title: Text(
          widget.tailor.name,
          style: const TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
        ),
        // --- CHANGED: Display the tailor's image from the URL ---
        background: Image.network(
          widget.tailor.imageUrl,
          fit: BoxFit.cover,
          // Show a loading indicator while the image loads
          loadingBuilder: (context, child, progress) {
            return progress == null ? child : const Center(child: CircularProgressIndicator());
          },
          // Show an icon if the image fails to load
          errorBuilder: (context, error, stackTrace) {
            return const Icon(Icons.person, size: 100, color: Colors.grey);
          },
        ),
      ),
    );
  }

  // (This method remains mostly the same, just uses 'widget.tailor')
  SliverToBoxAdapter _buildTailorInfo(BuildContext context) {
    // ... same as your code, just change 'tailor' to 'widget.tailor'
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.tailor.specialty, style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Theme.of(context).primaryColor)),
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(Icons.star, color: Colors.amber, size: 20),
                const SizedBox(width: 8),
                Text('${widget.tailor.rating} Stars', style: const TextStyle(fontSize: 16)),
                const Spacer(),
                const Icon(Icons.location_on, color: Colors.grey, size: 20),
                const SizedBox(width: 8),
                Text(widget.tailor.location, style: const TextStyle(fontSize: 16)),
              ],
            ),
            const Divider(height: 32, thickness: 1),
            const Text('What We Stitch', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  // --- NEW: A FutureBuilder to handle loading/error/success states ---
  Widget _buildServicesSection() {
    return FutureBuilder<List<StitchableItem>>(
      future: servicesFuture,
      builder: (context, snapshot) {
        // --- 1. Loading State ---
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SliverToBoxAdapter(
            child: Center(child: CircularProgressIndicator()),
          );
        }
        // --- 2. Error State ---
        if (snapshot.hasError) {
          return const SliverToBoxAdapter(
            child: Center(child: Text('Could not load services.')),
          );
        }
        // --- 3. No Data State ---
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const SliverToBoxAdapter(
            child: Center(child: Text('No services available for this tailor.')),
          );
        }
        // --- 4. Success State: Pass the data to the grid builder ---
        final items = snapshot.data!;
        return _buildServicesGrid(context, items);
      },
    );
  }

  // --- CHANGED: This now accepts a list of items ---
  SliverPadding _buildServicesGrid(BuildContext context, List<StitchableItem> items) {
    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      sliver: SliverGrid(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          childAspectRatio: 0.9,
        ),
        delegate: SliverChildBuilderDelegate(
              (context, index) {
            final item = items[index];
            return InkWell(
              onTap: () {
                if (item.name == 'Shirt') {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const ShirtCustomizationScreen()),
                  );
                } else {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => QuoteRequestScreen(
                        itemName: item.name,
                        // --- ADD THIS LINE ---
                        tailor: widget.tailor,
                      ),
                    ),
                  );
                }
              },
              child: Card(
                elevation: 2.0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                clipBehavior: Clip.antiAlias,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Expanded(
                      // --- Display the image for the service ---
                      // child: Image.network(
                        // item.imageUrl,
                        // fit: BoxFit.cover,
                        // errorBuilder: (context, error, stackTrace) =>
                        // const Icon(Icons.checkroom, size: 50, color: Colors.grey),
                      // ),
                    // ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        item.name,
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
          childCount: items.length,
        ),
      ),
    );
  }
}