import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:myapp/helpers/AppConstants.dart';
import 'event_detail_screen.dart';

class EventListingScreen extends StatefulWidget {
  final String? organizerID;
  final bool isFromOrganizer;

  const EventListingScreen({
    super.key,
    this.organizerID,
    this.isFromOrganizer = false,
  });

  @override
  State<EventListingScreen> createState() => _EventListingScreenState();
}

class _EventListingScreenState extends State<EventListingScreen> {
  final TextEditingController _capacityController = TextEditingController();
  DateTimeRange? _selectedDateRange;
  String? _selectedEventType;

  List<DocumentSnapshot> _events = [];
  List<DocumentSnapshot> _filteredEvents = [];

  @override
  void initState() {
    super.initState();
    _fetchEvents();
  }

  Future<void> _fetchEvents() async {
    final eventCollection = FirebaseFirestore.instance.collection('events');
    QuerySnapshot snapshot;

    if (!widget.isFromOrganizer && widget.organizerID != null) {
      // Show all events created by the organizer
      snapshot =
          await eventCollection
              .where('organizerId', isEqualTo: widget.organizerID)
              .get();

      setState(() {
        _events = snapshot.docs;
        _filteredEvents = _events;
      });
    } else if (widget.isFromOrganizer) {
      // Show all events created by the organizer
      snapshot =
          await eventCollection
              .where('organizerId', isEqualTo: widget.organizerID)
              .get();

      setState(() {
        _events = snapshot.docs;
        _filteredEvents = _events;
      });
    } else {
      // Customer: filter out booked events
      final eventSnapshot = await eventCollection.get();

      // Fetch bookings with blocked statuses
      final bookingSnapshot =
          await FirebaseFirestore.instance
              .collection('bookings')
              .where('status', whereIn: ['token_paid', 'paid_80_percent'])
              .get();

      final blockedEventIds =
          bookingSnapshot.docs.map((doc) => doc['eventId'] as String).toSet();

      final availableEvents =
          eventSnapshot.docs.where((event) {
            return !blockedEventIds.contains(event.id);
          }).toList();

      setState(() {
        _events = availableEvents;
        _filteredEvents = _events;
      });
    }
  }

  void _filterEvents() {
    List<DocumentSnapshot> filtered = _events;

    if (_capacityController.text.isNotEmpty) {
      int capacity = int.tryParse(_capacityController.text.trim()) ?? 0;
      filtered = filtered.where((e) => e['capacity'] >= capacity).toList();
    }

    if (_selectedEventType != null) {
      filtered =
          filtered.where((e) => e['eventType'] == _selectedEventType).toList();
    }

    if (_selectedDateRange != null) {
      filtered =
          filtered.where((e) {
            DateTime from = DateTime.parse(e['availableFrom']);
            DateTime to = DateTime.parse(e['availableTo']);
            return to.isAfter(_selectedDateRange!.start) &&
                from.isBefore(_selectedDateRange!.end);
          }).toList();
    }

    setState(() {
      _filteredEvents = filtered;
    });
  }

  void _selectDateRange() async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2023),
      lastDate: DateTime(2026),
      initialDateRange: _selectedDateRange,
    );

    if (picked != null) {
      setState(() => _selectedDateRange = picked);
      _filterEvents();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isFromOrganizer ? 'My Events' : 'Available Events'),
        backgroundColor: Colors.teal
,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.purple, Colors.pinkAccent],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (!widget.isFromOrganizer) ...[
                TextField(
                  controller: _capacityController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Minimum Capacity',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onChanged: (_) => _filterEvents(),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  decoration: InputDecoration(
                    labelText: 'Event Type',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  value: _selectedEventType,
                  items:
                      AppConstant.eventTypes.map((type) {
                        return DropdownMenuItem(value: type, child: Text(type));
                      }).toList(),
                  onChanged: (val) {
                    setState(() => _selectedEventType = val);
                    _filterEvents();
                  },
                ),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: _selectDateRange,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal
,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('Select Available Date Range'),
                ),
                const SizedBox(height: 12),
              ],
              _filteredEvents.isEmpty
                  ? const Expanded(
                    child: Center(
                      child: Text(
                        'No events found',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  )
                  : Expanded(
                    child: ListView.builder(
                      itemCount: _filteredEvents.length,
                      itemBuilder: (context, index) {
                        final event = _filteredEvents[index];
                        return GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (context) =>
                                        EventDetailScreen(eventId: event.id),
                              ),
                            );
                          },
                          child: Card(
                            margin: const EdgeInsets.symmetric(vertical: 8),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 4,
                            child: Padding(
                              padding: const EdgeInsets.all(12),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    event['eventType'],
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.teal
,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text('Capacity: ${event['capacity']}'),
                                  Text('Cost: Rs. ${event['eventCost']}'),
                                  Text('Token: Rs. ${event['tokenPayment']}'),
                                  Text(
                                    'Dates: ${event['availableFrom'].substring(0, 10)} - ${event['availableTo'].substring(0, 10)}',
                                  ),
                                ],
                              ),
                            ),
                          ),
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
}
