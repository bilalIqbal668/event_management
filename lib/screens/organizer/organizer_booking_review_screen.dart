import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:myapp/screens/organizer/team_assignment_screen.dart';

import 'organizer_booking_details.dart';

class OrganizerBookingsScreen extends StatelessWidget {
  const OrganizerBookingsScreen({super.key});

  Future<void> _acceptBooking(String bookingId) async {
    await FirebaseFirestore.instance
        .collection('bookings')
        .doc(bookingId)
        .update({'status': 'in_progress'});
  }

  Future<void> _rejectBooking(String bookingId) async {
    await FirebaseFirestore.instance
        .collection('bookings')
        .doc(bookingId)
        .update({'status': 'rejected'});
  }

  Future<String> _getCustomerName(String customerId) async {
    final userDoc =
        await FirebaseFirestore.instance
            .collection('users')
            .doc(customerId)
            .get();
    return userDoc.data()?['name'] ?? 'Unknown';
  }

  @override
  Widget build(BuildContext context) {
    final organizerId = FirebaseAuth.instance.currentUser!.uid;
    final bookingsRef = FirebaseFirestore.instance
        .collection('bookings')
        .where('organizerId', isEqualTo: organizerId);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Organizer Bookings"),
        backgroundColor: Colors.lightBlue,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.lightBlue, Colors.lightBlueAccent],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: StreamBuilder<QuerySnapshot>(
          stream: bookingsRef.snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }

            final bookings = snapshot.data!.docs;

            return ListView.builder(
              itemCount: bookings.length,
              itemBuilder: (context, index) {
                final booking = bookings[index];
                final bookingId = booking.id;
                final status = booking['status'] ?? 'unknown';
                final eventType = booking['eventType'] ?? 'Event';
                final venueName = booking['venueName'] ?? 'Venue';
                final eventDate = (booking['eventDate'] as Timestamp).toDate();
                final customerId = booking['customerId'] ?? '';
                final hasTeamAssignments =
                    (booking.data() as Map<String, dynamic>).containsKey(
                      'teamAssignments',
                    ) &&
                    !(booking['teamAssignments']?.isEmpty ?? true);

                return FutureBuilder<String>(
                  future: _getCustomerName(customerId),
                  builder: (context, nameSnapshot) {
                    final customerName = nameSnapshot.data ?? 'Loading...';

                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (context) => OrganizerBookingDetailsScreen(
                                  bookingId: bookingId,
                                ),
                          ),
                        );
                      },
                      child: Card(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 4,
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                eventType,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                  color: Colors.lightBlue,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                "Customer: $customerName",
                                style: const TextStyle(
                                  fontSize: 16,
                                  color: Colors.black87,
                                ),
                              ),
                              Text(
                                "Venue: $venueName",
                                style: const TextStyle(
                                  fontSize: 16,
                                  color: Colors.black87,
                                ),
                              ),
                              Text(
                                "Date: ${DateFormat('yyyy-MM-dd').format(eventDate)}",
                                style: const TextStyle(
                                  fontSize: 16,
                                  color: Colors.black87,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                "Status: ${status.toUpperCase()}",
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: Colors.black87,
                                ),
                              ),
                              const SizedBox(height: 16),
                              if (!hasTeamAssignments &&
                                  status == 'pending') ...[
                                Row(
                                  children: [
                                    Expanded(
                                      child: ElevatedButton(
                                        onPressed:
                                            () => _acceptBooking(bookingId),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.green,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                          ),
                                        ),
                                        child: const Text("Accept"),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: ElevatedButton(
                                        onPressed:
                                            () => _rejectBooking(bookingId),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.red,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                          ),
                                        ),
                                        child: const Text("Reject"),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                              if ((status == 'token_paid' ||
                                      status == "paid_80_percent") &&
                                  !hasTeamAssignments)
                                ElevatedButton(
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder:
                                            (context) => AssignTeamScreen(
                                              bookingId: bookingId,
                                              organizerId: organizerId,
                                            ),
                                      ),
                                    );
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.lightBlue,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  child: const Text("Assign Team"),
                                ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            );
          },
        ),
      ),
    );
  }
}
