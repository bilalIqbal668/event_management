import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class BookingDetailsScreen extends StatefulWidget {
  final Map<String, dynamic> bookingData;
  final String bookingId;

  const BookingDetailsScreen({
    super.key,
    required this.bookingData,
    required this.bookingId,
  });

  @override
  State<BookingDetailsScreen> createState() => _BookingDetailsScreenState();
}

class _BookingDetailsScreenState extends State<BookingDetailsScreen> {
  late Map<String, dynamic> bookingData;
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    bookingData = widget.bookingData;
  }

  Future<void> _cancelBooking() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Confirm Cancellation'),
            content: const Text(
              'Are you sure you want to cancel this booking? This action cannot be undone.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('No'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Yes, Cancel'),
              ),
            ],
          ),
    );

    if (confirm != true) return; // Cancel action if user says no

    setState(() => _isProcessing = true);
    try {
      await FirebaseFirestore.instance
          .collection('bookings')
          .doc(widget.bookingId)
          .update({'status': 'cancelled'});

      setState(() {
        bookingData['status'] = 'cancelled';
      });

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Booking cancelled')));
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Error cancelling booking')));
    } finally {
      setState(() => _isProcessing = false);
    }
  }

  Future<void> _payEightyPercent() async {
    setState(() => _isProcessing = true);
    try {
      final totalCost = bookingData['totalCost'] ?? 0;
      final eightyPercent = totalCost * 0.8;

      await FirebaseFirestore.instance
          .collection('bookings')
          .doc(widget.bookingId)
          .update({'status': 'paid_80_percent', 'amountPaid': eightyPercent});

      setState(() {
        bookingData['status'] = 'paid_80_percent';
        bookingData['amountPaid'] = eightyPercent;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('80% Amount Paid: PKR $eightyPercent')),
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Error making payment')));
    } finally {
      setState(() => _isProcessing = false);
    }
  }

  Widget _buildActionButtons() {
    if (bookingData['status'] == 'token_paid') {
      return Column(
        children: [
          ElevatedButton(
            onPressed: _isProcessing ? null : _cancelBooking,
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Cancel Booking'),
          ),
          const SizedBox(height: 10),
          ElevatedButton(
            onPressed: _isProcessing ? null : _payEightyPercent,
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            child: const Text('Pay 80% Amount'),
          ),
        ],
      );
    }

    return const SizedBox.shrink();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Booking Details"),
        backgroundColor: Colors.teal
,
      ),
      body: SizedBox.expand(
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.purple, Colors.pinkAccent],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 4,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildDetail("Venue", bookingData['venueName']),
                        _buildDetail("Event Type", bookingData['eventType']),
                        _buildDetail(
                          "Booking Date",
                          DateFormat('yyyy-MM-dd').format(
                            (bookingData['eventDate'] as Timestamp).toDate(),
                          ),
                        ),
                        _buildDetail(
                          "Attendees",
                          bookingData['attendees'].toString(),
                        ),
                        _buildDetail(
                          "Food Menu",
                          (bookingData['foodMenu'] as List).join(", "),
                        ),
                        _buildDetail(
                          "Decoration",
                          bookingData['decoration'] ?? 'N/A',
                        ),
                        _buildDetail(
                          "Audio-Visual",
                          bookingData['avSetup'] ?? 'N/A',
                        ),
                        _buildDetail("Status", bookingData['status']),
                        if (bookingData['amountPaid'] != null)
                          _buildDetail(
                            "Amount Paid",
                            "PKR ${bookingData['amountPaid']}",
                          ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                _buildActionButtons(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDetail(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "$label: ",
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: Colors.teal
,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 16, color: Colors.black87),
            ),
          ),
        ],
      ),
    );
  }
}
