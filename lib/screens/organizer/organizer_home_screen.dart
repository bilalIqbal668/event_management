import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class OrganizerHomeScreen extends StatelessWidget {
  OrganizerHomeScreen({super.key});

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
        .collection('events')
        .where('organizerId', isEqualTo: uid)
        .where('date', isGreaterThan: DateTime.now().toIso8601String())
        .orderBy('date')
        .limit(3)
        .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Organizer Home'),
        backgroundColor: Colors.teal,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.teal, Colors.tealAccent],
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
                      return _buildStatCard('Total Events', snapshot.data!.docs.length);
                    },
                  ),
                  StreamBuilder(
                    stream: getOrganizerBookings(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return _buildStatCard('Total Bookings', 0);
                      }
                      return _buildStatCard('Total Bookings', snapshot.data!.docs.length);
                    },
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Text(
                'Upcoming Events',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: StreamBuilder(
                  stream: getUpcomingEvents(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    final events = snapshot.data!.docs;
                    if (events.isEmpty) {
                      return const Center(
                        child: Text(
                          'No upcoming events',
                          style: TextStyle(color: Colors.white),
                        ),
                      );
                    }
                    return ListView.builder(
                      itemCount: events.length,
                      itemBuilder: (context, index) {
                        final event = events[index];
                        return Card(
                          margin: const EdgeInsets.symmetric(vertical: 8),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 4,
                          child: ListTile(
                            title: Text(
                              event['title'] ?? 'Event',
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            subtitle: Text(event['date'] ?? ''),
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
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 1,
        onTap: (index) {
          if (index == 0) {
            Navigator.pushNamed(context, '/organizer-bookings');
          } else if (index == 2) {
            Navigator.pushNamed(context, '/organizer-profile');
          }
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.event), label: 'My Bookings'),
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
        selectedItemColor: Colors.teal,
        unselectedItemColor: Colors.grey,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.pushNamed(context, '/create-event'),
        icon: const Icon(Icons.add),
        label: const Text('Add Event'),
        backgroundColor: Colors.teal,
      ),
    );
  }

  Widget _buildStatCard(String label, int count) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              count.toString(),
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.teal),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(fontSize: 16, color: Colors.black87),
            ),
          ],
        ),
      ),
    );
  }
}