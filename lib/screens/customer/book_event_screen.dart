import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:myapp/helpers/AppConstants.dart';

class BookEventScreen extends StatefulWidget {
  final String eventId;
  final String organizerId;

  const BookEventScreen({super.key, required this.eventId, required this.organizerId});

  @override
  State<BookEventScreen> createState() => _BookEventScreenState();
}

class _BookEventScreenState extends State<BookEventScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _attendeesController = TextEditingController();
  final TextEditingController _decorationController = TextEditingController();
  final TextEditingController _avController = TextEditingController();

  List<String> _selectedFoodMenu = [];
  bool _isLoading = false;

  String? _venueName;
  String? _eventType;
  DateTime? _availableFrom;
  DateTime? _availableTo;
  DateTime? _selectedEventDate;


  Future<void> _fetchEventDetails() async {
    try {
      final eventDoc = await FirebaseFirestore.instance
          .collection('events')
          .doc(widget.eventId)
          .get();

      if (eventDoc.exists) {
        setState(() {
          _eventType = eventDoc['eventType'];

          // Convert the availableFrom and availableTo string to DateTime
          _availableFrom = _convertStringToDate(eventDoc['availableFrom']);
          _availableTo = _convertStringToDate(eventDoc['availableTo']);
        });

        // Fetch the associated venue name using organizerId
        final venueSnapshot = await FirebaseFirestore.instance
            .collection('venues')
            .where('organizerId', isEqualTo: widget.organizerId)
            .get();

        if (venueSnapshot.docs.isNotEmpty) {
          setState(() {
            _venueName = venueSnapshot.docs.first['name'];
          });
        }
      }
    } catch (e) {
      print("Error fetching event details: $e");
    }
  }

// Function to convert a string date (e.g., "2025-05-01") to DateTime
  DateTime _convertStringToDate(String dateString) {
    return DateFormat('yyyy-MM-dd').parse(dateString);
  }

  // Date picker for the event date
  Future<void> _selectEventDate() async {
    final DateTime initialDate = DateTime.now();
    final DateTime firstDate = _availableFrom ?? initialDate;
    final DateTime lastDate = _availableTo ?? initialDate;

    final DateTime? selectedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: firstDate,
      lastDate: lastDate,
    );

    if (selectedDate != null) {
      setState(() {
        _selectedEventDate = selectedDate;
      });
    } else {
      // Show error message if the date is not within the range
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a valid event date within the available range.')),
      );
    }
  }

  void _toggleFoodOption(String option) {
    setState(() {
      if (_selectedFoodMenu.contains(option)) {
        _selectedFoodMenu.remove(option);
      } else {
        _selectedFoodMenu.add(option);
      }
    });
  }

  Future<void> _submitBooking() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedEventDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a valid event date.')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final customerId = FirebaseAuth.instance.currentUser!.uid;
    final bookingData = {
      'customerId': customerId,
      'organizerId': widget.organizerId,
      'eventId': widget.eventId,
      'venueName': _venueName,
      'eventType': _eventType,
      'eventDate': _selectedEventDate,
      'attendees': int.parse(_attendeesController.text),
      'foodMenu': _selectedFoodMenu,
      'decoration': _decorationController.text,
      'avSetup': _avController.text,
      'status': 'pending',
      'createdAt': FieldValue.serverTimestamp(),
      'teamAssignments': [],
    };

    try {
      await FirebaseFirestore.instance.collection('bookings').add(bookingData);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Booking submitted successfully!')),
      );
      Navigator.of(context).pop(); // Go back to the previous screen
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error submitting booking')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchEventDetails();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Book Event'),
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
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: ListView(
              children: [
                // Event Date Picker
                Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 4,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Select Event Date:',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Colors.teal
,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(_selectedEventDate == null
                            ? 'No date selected'
                            : 'Selected Date: ${_selectedEventDate!.toLocal().toString().split(' ')[0]}'),
                        const SizedBox(height: 8),
                        ElevatedButton(
                          onPressed: _selectEventDate,
                          child: const Text('Pick Date'),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Number of Attendees
                Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 4,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: TextFormField(
                      controller: _attendeesController,
                      decoration: const InputDecoration(
                        labelText: 'Number of Attendees',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) =>
                      value == null || value.isEmpty ? 'Enter number of attendees' : null,
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Food Menu Options
                Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 4,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Select Food Menu:',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Colors.teal
,
                          ),
                        ),
                        const SizedBox(height: 8),
                        ...AppConstant.foodMenuOptions.map((option) => CheckboxListTile(
                          title: Text(option),
                          value: _selectedFoodMenu.contains(option),
                          onChanged: (_) => _toggleFoodOption(option),
                        )),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Decoration Preferences
                Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 4,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: TextFormField(
                      controller: _decorationController,
                      decoration: const InputDecoration(
                        labelText: 'Decoration Preferences',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // AV Setup Preferences
                Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 4,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: TextFormField(
                      controller: _avController,
                      decoration: const InputDecoration(
                        labelText: 'Audio-Visual Setup',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                ),
                // const SizedBox(height: 16),
                //
                // // Display Event Details
                // if (_venueName != null && _eventType != null && _availableFrom != null && _availableTo != null)
                //   Card(
                //     shape: RoundedRectangleBorder(
                //       borderRadius: BorderRadius.circular(12),
                //     ),
                //     elevation: 4,
                //     child: Padding(
                //       padding: const EdgeInsets.all(16.0),
                //       child: Column(
                //         crossAxisAlignment: CrossAxisAlignment.start,
                //         children: [
                //           Text('Venue: $_venueName'),
                //           Text('Event Type: $_eventType'),
                //           Text('Booking Date Range: ${_availableFrom!.toLocal().toString().split(' ')[0]} - ${_availableTo!.toLocal().toString().split(' ')[0]}'),
                //         ],
                //       ),
                //     ),
                //   ),

                const SizedBox(height: 20),

                // Submit Button
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal
,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  onPressed: _isLoading ? null : _submitBooking,
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                    'Submit Booking',
                    style: TextStyle(fontSize: 18, color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
