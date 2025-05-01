import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class EventDetailScreen extends StatefulWidget {
  final String eventId;

  const EventDetailScreen({super.key, required this.eventId});

  @override
  State<EventDetailScreen> createState() => _EventDetailScreenState();
}

class _EventDetailScreenState extends State<EventDetailScreen> {
  late DocumentSnapshot eventDetails;

  @override
  void initState() {
    super.initState();
    _fetchEventDetails();
  }

  Future<void> _fetchEventDetails() async {
    final eventRef = FirebaseFirestore.instance
        .collection('events')
        .doc(widget.eventId);
    final snapshot = await eventRef.get();

    if (snapshot.exists) {
      setState(() {
        eventDetails = snapshot;
      });
    } else {
      // Handle event not found case (optional)
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Event not found')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Event Details')),
      body:
          eventDetails == null
              ? const Center(
                child: CircularProgressIndicator(),
              ) // While data is being fetched
              : Padding(
                padding: const EdgeInsets.all(16.0),
                child: ListView(
                  children: [
                    Text(
                      eventDetails['eventType'] ?? 'Event Type not available',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text('Capacity: ${eventDetails['capacity']}'),
                    const SizedBox(height: 6),
                    Text('Cost: Rs. ${eventDetails['eventCost']}'),
                    Text('Token Payment: Rs. ${eventDetails['tokenPayment']}'),
                    Text(
                      'Available Dates: ${DateFormat('yyyy-MM-dd').format(DateTime.parse(eventDetails['availableFrom']))} - ${DateFormat('yyyy-MM-dd').format(DateTime.parse(eventDetails['availableTo']))}',
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Services Included:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 6),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children:
                          (eventDetails['services'] as List)
                              .map((service) => Text('- $service'))
                              .toList(),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Food Menu Options:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 6),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children:
                          (eventDetails['foodMenu'] as List)
                              .map((food) => Text('- $food'))
                              .toList(),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () {
                        // TODO: Handle booking logic when it's implemented
                        showDialog(
                          context: context,
                          builder: (context) {
                            return AlertDialog(
                              title: const Text(
                                'Booking functionality coming soon!',
                              ),
                              content: const Text(
                                'Booking feature will be available shortly.',
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () {
                                    Navigator.pop(context);
                                  },
                                  child: const Text('Close'),
                                ),
                              ],
                            );
                          },
                        );
                      },
                      child: const Text('Book Now'),
                    ),
                  ],
                ),
              ),
    );
  }
}
