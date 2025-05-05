import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:myapp/screens/organizer/team_assignment_screen.dart';

class OrganizerBookingDetailsScreen extends StatefulWidget {
  final String bookingId;

  const OrganizerBookingDetailsScreen({super.key, required this.bookingId});

  @override
  State<OrganizerBookingDetailsScreen> createState() =>
      _OrganizerBookingDetailsScreenState();
}

class _OrganizerBookingDetailsScreenState
    extends State<OrganizerBookingDetailsScreen> {
  Map<String, dynamic>? bookingData;
  String customerName = 'Loading...';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadBookingDetails();
  }

  Future<void> _loadBookingDetails() async {
    final bookingDoc = await FirebaseFirestore.instance
        .collection('bookings')
        .doc(widget.bookingId)
        .get();

    if (bookingDoc.exists) {
      final data = bookingDoc.data()!;
      bookingData = data;

      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(data['customerId'])
          .get();

      if (userDoc.exists) {
        customerName = userDoc.data()!['name'] ?? 'Unknown';
      }

      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _updateBookingStatus(String newStatus) async {
    await FirebaseFirestore.instance
        .collection('bookings')
        .doc(widget.bookingId)
        .update({'status': newStatus});

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Booking $newStatus')),
    );

    setState(() {
      bookingData!['status'] = newStatus;
    });
  }

  Future<void> _closeEvent() async {
    try {
      await FirebaseFirestore.instance
          .collection('bookings')
          .doc(widget.bookingId)
          .update({
        'status': 'closed', // Or whatever original status you want to reset to
        'closedAt': Timestamp.now(),
      });

      setState(() {
        bookingData!['status'] = 'booked';
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Event closed successfully.')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to close event.')),
      );
    }
  }

  bool _isEventTodayAndPaid80Percent() {
    if (bookingData == null) return false;

    final eventTimestamp = bookingData!['eventDate'] as Timestamp;
    final eventDate = eventTimestamp.toDate();
    final now = DateTime.now();

    final isToday = eventDate.year == now.year &&
        eventDate.month == now.month &&
        eventDate.day == now.day;

    final status = bookingData!['status'];
    return isToday && status == 'paid_80_percent';
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$label: ',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    final status = bookingData?['status'];
    final hasTeamAssignments =
        (bookingData as Map<String, dynamic>).containsKey('teamAssignments') &&
            !(bookingData?['teamAssignments']?.isEmpty ?? true);

    if (status == 'pending' || status == 'in_progress') {
      return Row(
        children: [
          Expanded(
            child: ElevatedButton(
              onPressed: () => _updateBookingStatus('accepted'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.lightBlue,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('Accept Booking'),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ElevatedButton(
              onPressed: () => _updateBookingStatus('cancelled'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('Reject Booking'),
            ),
          ),
        ],
      );
    }

    if ((status == 'token_paid' || status == 'paid_80_percent') &&
        !hasTeamAssignments) {
      return Center(
        child: ElevatedButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => AssignTeamScreen(
                  bookingId: widget.bookingId,
                  organizerId: bookingData?['organizerId'],
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
      );
    }

    return const SizedBox();
  }

  Widget _buildTeamMembers() {
    final teamMembers = bookingData?['teamAssignments'] as List?;

    if (teamMembers != null && teamMembers.isNotEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          const Text(
            'Assigned Team Members:',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 8),
          ...teamMembers.map((member) {
            return _buildDetailRow(
              member['name'] ?? 'Unknown',
              member['role'] ?? 'N/A',
            );
          }).toList(),
        ],
      );
    }
    return const SizedBox();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Booking Details'),
        backgroundColor: Colors.lightBlue,
      ),
      body: SizedBox.expand(
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.lightBlue, Colors.lightBlueAccent],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildDetailRow('Customer Name', customerName),
                    _buildDetailRow(
                        'Venue', bookingData?['venueName'] ?? 'N/A'),
                    _buildDetailRow(
                        'Event Type', bookingData?['eventType'] ?? 'N/A'),
                    _buildDetailRow(
                        'Event Date',
                        (bookingData?['eventDate'] as Timestamp)
                            .toDate()
                            .toString()
                            .split(' ')
                            .first),
                    _buildDetailRow('Attendees',
                        bookingData?['attendees'].toString() ?? 'N/A'),
                    _buildDetailRow(
                        'Decoration', bookingData?['decoration'] ?? 'N/A'),
                    _buildDetailRow(
                        'AV Setup', bookingData?['avSetup'] ?? 'N/A'),
                    _buildDetailRow(
                        'Food Menu',
                        (bookingData?['foodMenu'] as List<dynamic>)
                            .join(', ')),
                    _buildDetailRow('Status',
                        bookingData!['status'].toString().toUpperCase()),
                    const SizedBox(height: 20),
                    _buildActionButtons(),
                    _buildTeamMembers(),
                    const SizedBox(height: 20),
                    if (_isEventTodayAndPaid80Percent())
                      Center(
                        child: ElevatedButton.icon(
                          onPressed: _closeEvent,
                          icon: const Icon(Icons.event_available),
                          label: const Text('Close Event'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.lightBlue[700],
                            padding: const EdgeInsets.symmetric(
                                horizontal: 24, vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
