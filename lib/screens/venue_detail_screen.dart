import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class VenueDetailsScreen extends StatelessWidget {
  final String venueId;

  const VenueDetailsScreen({super.key, required this.venueId});

  @override
  Widget build(BuildContext context) {
    final venueRef = FirebaseFirestore.instance.collection('venues').doc(venueId);

    return Scaffold(
      appBar: AppBar(title: const Text('Venue Details')),
      body: FutureBuilder<DocumentSnapshot>(
        future: venueRef.get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: Text('Venue not found.'));
          }

          final data = snapshot.data!.data() as Map<String, dynamic>;

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (data['imageUrl'] != null)
                  Image.network(
                    data['imageUrl'],
                    width: double.infinity,
                    height: 250,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) =>
                    const SizedBox(height: 250, child: Icon(Icons.image, size: 100)),
                  ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(data['name'] ?? '',
                          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      Text(data['location'] ?? '', style: const TextStyle(fontSize: 16)),
                      const SizedBox(height: 8),
                      Text('Type: ${data['type'] ?? 'N/A'}'),
                      const SizedBox(height: 8),
                      Text('Price: Rs ${data['price'] ?? 'N/A'}',
                          style: const TextStyle(fontSize: 16, color: Colors.green)),
                      const SizedBox(height: 16),
                      const Text('Description:',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                      const SizedBox(height: 4),
                      Text(data['description'] ?? 'No description available'),
                      const SizedBox(height: 24),
                      Center(
                        child: ElevatedButton(
                          onPressed: () {
                            // Placeholder: Replace with actual booking logic
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Booking not implemented yet')),
                            );
                          },
                          child: const Text('Book Now'),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
