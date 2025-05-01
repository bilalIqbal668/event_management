import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class OrganizerBookingReviewScreen extends StatefulWidget {
  const OrganizerBookingReviewScreen({super.key});

  @override
  State<OrganizerBookingReviewScreen> createState() => _OrganizerBookingReviewScreenState();
}

class _OrganizerBookingReviewScreenState extends State<OrganizerBookingReviewScreen> {
  final _bookingsRef = FirebaseFirestore.instance.collection('bookings');

  Future<void> _updateStatus(String docId, String status) async {
    await _bookingsRef.doc(docId).update({'status': status});
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Booking $status")));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Booking Requests")),
      body: StreamBuilder<QuerySnapshot>(
        stream: _bookingsRef.where('status', isEqualTo: 'pending').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

          final bookings = snapshot.data!.docs;

          if (bookings.isEmpty) {
            return const Center(child: Text("No pending requests"));
          }

          return ListView.builder(
            itemCount: bookings.length,
            itemBuilder: (context, index) {
              final booking = bookings[index];
              final food = booking['food'] as Map;

              return Card(
                margin: const EdgeInsets.all(10),
                child: ListTile(
                  title: Text("${booking['venueName']} - ${booking['date']}"),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Attendees: ${booking['attendees']}"),
                      Text("Food: ${food.entries.where((e) => e.value).map((e) => e.key).join(', ')}"),
                      Text("Services: ${booking['services'].length} selected"),
                    ],
                  ),
                  trailing: Wrap(
                    spacing: 8,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.check_circle, color: Colors.green),
                        onPressed: () => _updateStatus(booking.id, 'confirmed'),
                      ),
                      IconButton(
                        icon: const Icon(Icons.cancel, color: Colors.red),
                        onPressed: () => _updateStatus(booking.id, 'rejected'),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
