import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../customer/event_listing_screen.dart';
import 'organizer_booking_details.dart';
import 'organizer_booking_review_screen.dart';
import 'organizer_profile_screen.dart';

class OrganizerHomeScreen extends StatefulWidget {
  const OrganizerHomeScreen({super.key});

  @override
  State<OrganizerHomeScreen> createState() => _OrganizerHomeScreenState();
}

class _OrganizerHomeScreenState extends State<OrganizerHomeScreen> {
  int _currentIndex = 1;

  final List<Widget> _screens = [
    OrganizerBookingsScreen(),
    OrganizerHomeScreenContent(),
    OrganizerProfileScreen(),
  ];

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _screens),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onTabTapped,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.event),
            label: 'My Bookings',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
        selectedItemColor: Colors.lightBlue,
        unselectedItemColor: Colors.grey,
      ),
      floatingActionButton:
      _currentIndex == 1
          ? FloatingActionButton.extended(
        onPressed: () => Navigator.pushNamed(context, '/create-event'),
        icon: const Icon(Icons.add),
        label: const Text('Add Event'),
        backgroundColor: Colors.lightBlue,
      )
          : null,
    );
  }
}


class OrganizerHomeScreenContent extends StatelessWidget {
  OrganizerHomeScreenContent({super.key});

  final String uid = FirebaseAuth.instance.currentUser!.uid;

  Stream<QuerySnapshot> getOrganizerEvents() {
    return FirebaseFirestore.instance
        .collection('events')
        .where('organizerId', isEqualTo: uid)
        .snapshots();
  }

  Stream<QuerySnapshot> getOrganizerBookings() {
    return FirebaseFirestore.instance
        .collection('bookings')
        .where('organizerId', isEqualTo: uid)
        .snapshots();
  }

  Stream<QuerySnapshot> getUpcomingEvents() {
    return FirebaseFirestore.instance
        .collection('bookings')
        .where('organizerId', isEqualTo: uid)
        .where('status', whereIn: ['token_paid', 'paid_80_percent'])
        .where('eventDate', isGreaterThan: Timestamp.now())
        .orderBy('eventDate')
        .limit(3)
        .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Organizer Home"),
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
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  StreamBuilder(
                    stream: getOrganizerEvents(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return _buildStatCard('Total Events', 0);
                      }
                      return _buildStatCard(
                        'Total Events',
                        snapshot.data!.docs.length,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (context) =>
                                  EventListingScreen(
                                    organizerID: uid,
                                    isFromOrganizer: true,
                                  ),
                            ),
                          );
                        },
                      );
                    },
                  ),

                  StreamBuilder(
                    stream: getOrganizerBookings(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return _buildStatCard('Total Bookings', 0);
                      }
                      return _buildStatCard(
                        'Total Bookings',
                        snapshot.data!.docs.length,
                      );
                    },
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Text(
                'Upcoming Bookings',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: StreamBuilder(
                  stream: getUpcomingEvents(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    final bookings = snapshot.data!.docs;
                    if (bookings.isEmpty) {
                      return const Center(
                        child: Text(
                          'No upcoming events',
                          style: TextStyle(color: Colors.white),
                        ),
                      );
                    }
                    return ListView.builder(
                      itemCount: bookings.length,
                      itemBuilder: (context, index) {
                        final booking = bookings[index];
                        final eventDate =
                        (booking['eventDate'] as Timestamp).toDate();
                        final formattedDate =
                            "${eventDate.year}-${eventDate.month.toString()
                            .padLeft(2, '0')}-${eventDate.day.toString()
                            .padLeft(2, '0')}";

                        return Card(
                          margin: const EdgeInsets.symmetric(vertical: 8),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 4,
                          child: ListTile(
                            title: Text(
                              booking['venueName'] ?? 'Event',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder:
                                      (context) =>
                                      OrganizerBookingDetailsScreen(
                                        bookingId: booking.id,
                                      ),
                                ),
                              );
                            },
                            subtitle: Text(
                              'Date: $formattedDate\nStatus: ${booking['status']}',
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(String label, int count, {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                count.toString(),
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.lightBlue,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: const TextStyle(fontSize: 16, color: Colors.black87),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
