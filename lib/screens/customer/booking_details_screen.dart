import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class BookingDetailsScreen extends StatelessWidget {
  final Map<String, dynamic> bookingData;

  const BookingDetailsScreen({super.key, required this.bookingData});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Booking Details"),
        backgroundColor: Colors.teal,
      ),
      body: SizedBox.expand(
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.teal, Colors.tealAccent],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Card(
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
                      DateFormat('yyyy-MM-dd')
                          .format((bookingData['eventDate'] as Timestamp).toDate()),
                    ),
                    _buildDetail("Attendees", bookingData['attendees'].toString()),
                    _buildDetail(
                      "Food Menu",
                      (bookingData['foodMenu'] as List).join(", "),
                    ),
                    _buildDetail("Decoration", bookingData['decoration'] ?? 'N/A'),
                    _buildDetail("Audio-Visual", bookingData['avSetup'] ?? 'N/A'),
                    _buildDetail("Status", bookingData['status']),
                  ],
                ),
              ),
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
              color: Colors.teal,
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