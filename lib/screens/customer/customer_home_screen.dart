import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'event_listing_screen.dart';

class CustomerHomeScreen extends StatefulWidget {
  const CustomerHomeScreen({super.key});

  @override
  State<CustomerHomeScreen> createState() => _CustomerHomeScreenState();
}

class _CustomerHomeScreenState extends State<CustomerHomeScreen> {
  final TextEditingController _searchController = TextEditingController();
  final List<String> _eventTypes = ['Wedding', 'Birthday', 'Corporate Meeting', 'Concert', 'Other'];
  String? _selectedEventType;
  DateTimeRange? _eventDateRange;
  DateTimeRange? _venueDateRange;

  int _currentIndex = 1;

  List<DocumentSnapshot> _venues = [];
  List<DocumentSnapshot> _filteredVenues = [];
  List<DocumentSnapshot> _events = [];
  List<DocumentSnapshot> _filteredEvents = [];

  @override
  void initState() {
    super.initState();
    _fetchVenues();
    _fetchEvents();
  }

  Future<void> _fetchVenues() async {
    final venueCollection = FirebaseFirestore.instance.collection('venues');
    final snapshot = await venueCollection.get();
    setState(() {
      _venues = snapshot.docs;
      _filteredVenues = _venues;
    });
  }

  Future<void> _fetchEvents() async {
    final eventCollection = FirebaseFirestore.instance.collection('events');
    final snapshot = await eventCollection.get();
    setState(() {
      _events = snapshot.docs;
      _filteredEvents = _events;
    });
  }

  void _filterVenues() {
    String searchText = _searchController.text.toLowerCase();
    List<DocumentSnapshot> filteredList = _venues;

    if (searchText.isNotEmpty) {
      filteredList = filteredList.where((venue) {
        var name = venue['name'].toLowerCase();
        var location = venue['location'].toLowerCase();
        return name.contains(searchText) || location.contains(searchText);
      }).toList();
    }

    if (_venueDateRange != null) {
      // Handle venue date filtering if needed
    }

    setState(() {
      _filteredVenues = filteredList;
    });
  }

  void _filterEvents() {
    List<DocumentSnapshot> filteredList = _events;

    if (_selectedEventType != null) {
      filteredList = filteredList.where((event) {
        return event['eventType'] == _selectedEventType;
      }).toList();
    }

    if (_eventDateRange != null) {
      filteredList = filteredList.where((event) {
        DateTime from = DateTime.parse(event['availableFrom']);
        DateTime to = DateTime.parse(event['availableTo']);
        return from.isBefore(_eventDateRange!.end) &&
            to.isAfter(_eventDateRange!.start);
      }).toList();
    }

    setState(() {
      _filteredEvents = filteredList;
    });
  }

  void _selectEventDateRange() async {
    final DateTimeRange? pickedRange = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2023),
      lastDate: DateTime(2026),
    );
    if (pickedRange != null) {
      setState(() {
        _eventDateRange = pickedRange;
      });
      _filterEvents();
    }
  }


  @override
  Widget build(BuildContext context) {
    final screens = [
      EventListingScreen(),
      _buildHomeView(),
      _buildMyBookingsView(),
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Customer Home')),
      body: screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        items: const [

          BottomNavigationBarItem(icon: Icon(Icons.event), label: 'Events'),
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Venues'),
          BottomNavigationBarItem(icon: Icon(Icons.book), label: 'My Bookings'),
        ],
        onTap: (index) {
          setState(() => _currentIndex = index);
        },
      ),
    );
  }

  Widget _buildHomeView() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Search by Venue or Location',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onChanged: (value) => _filterVenues(),
          ),
          const SizedBox(height: 16),
          const Align(
            alignment: Alignment.centerLeft,
            child: Text('Available Venues',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          ),
          const SizedBox(height: 8),
          _filteredVenues.isEmpty
              ? const Expanded(child: Center(child: Text('No venues found')))
              : Expanded(
            child: ListView.builder(
              itemCount: _filteredVenues.length,
              itemBuilder: (context, index) {
                final venue = _filteredVenues[index];
                return _buildListCard(
                  organizerID: venue['organizerId'],
                  title: 'Venue ${venue['name']}',
                  subtitle: 'Location: ${venue['location']} ${venue['city']}',
                );
              },
            ),
          ),
        ],
      ),
    );
  }


  Widget _buildListCard({required String organizerID ,required String title, required String subtitle}) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => EventListingScreen(
              organizerID: organizerID,
            ),
          ),
        );
      },
      child: Card(
        margin: const EdgeInsets.symmetric(vertical: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 4,
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            children: [
              const Icon(Icons.event, size: 40, color: Colors.grey),
              const SizedBox(width: 16),
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(title,
                      style:
                      const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text(subtitle, style: const TextStyle(color: Colors.grey)),
                ]),
              ),
              const Icon(Icons.arrow_forward_ios, size: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMyBookingsView() {
    return const Center(child: Text('My Bookings will be shown here'));
  }
}
