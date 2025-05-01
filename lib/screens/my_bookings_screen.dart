import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class MyBookingsScreen extends StatelessWidget {
  const MyBookingsScreen({super.key});

  Future<void> _payToken(String bookingId) async {
    await FirebaseFirestore.instance.collection('bookings').doc(bookingId).update({
      'status': 'token_paid',
    });
  }

  @override
  Widget build(BuildContext context) {
    final userId = FirebaseAuth.instance.currentUser!.uid;
    final bookingsRef = FirebaseFirestore.instance
        .collection('bookings')
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true);

    return Scaffold(
      appBar: AppBar(title: const Text("My Bookings")),
      body: StreamBuilder<QuerySnapshot>(
        stream: bookingsRef.snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

          final bookings = snapshot.data!.docs;
          if (bookings.isEmpty) return const Center(child: Text("No bookings found"));

          return ListView.builder(
            itemCount: bookings.length,
            itemBuilder: (context, index) {
              final booking = bookings[index];
              final status = booking['status'];
              final venue = booking['venueName'];
              final date = booking['date'];

              return Card(
                margin: const EdgeInsets.all(10),
                child: ListTile(
                  title: Text(venue),
                  subtitle: Text("Date: $date\nStatus: $status"),
                  trailing: status == 'pending'
                      ? ElevatedButton(
                    onPressed: () => _payToken(booking.id),
                    child: const Text("Pay Token"),
                  )
                      : null,
                ),
              );
            },
          );
        },
      ),
    );
  }
}
