import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class AssignTeamScreen extends StatefulWidget {
  final String bookingId;
  final String organizerId;

  const AssignTeamScreen({
    super.key,
    required this.bookingId,
    required this.organizerId,
  });

  @override
  State<AssignTeamScreen> createState() => _AssignTeamScreenState();
}

class _AssignTeamScreenState extends State<AssignTeamScreen> {
  List<Map<String, dynamic>> availableTeamMembers = [];
  List<Map<String, dynamic>> assignedTeamMembers = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchTeamMembers();
  }

  Future<void> _fetchTeamMembers() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final teamSnapshot = await FirebaseFirestore.instance
          .collection('organizers')
          .doc(widget.organizerId)
          .collection('employees')
          .get();

      availableTeamMembers = teamSnapshot.docs.map((doc) {
        return {
          'name': doc['name'] as String,
          'role': doc['role'] as String,
        };
      }).toList();

      setState(() {});
    } catch (e) {
      print("Error fetching team members: $e");
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _assignTeam() async {
    if (assignedTeamMembers.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please assign at least one team member.')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      await FirebaseFirestore.instance
          .collection('bookings')
          .doc(widget.bookingId)
          .update({'teamAssignments': assignedTeamMembers});

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Team assigned successfully!')),
      );
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error assigning team.')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Assign Team'),
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
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Select Team Members to Assign:',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: ListView(
                  children: availableTeamMembers.map((member) {
                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: CheckboxListTile(
                        title: Text('${member['name']} (${member['role']})'),
                        value: assignedTeamMembers.contains(member),
                        onChanged: (isChecked) {
                          setState(() {
                            if (isChecked == true) {
                              assignedTeamMembers.add(member);
                            } else {
                              assignedTeamMembers.remove(member);
                            }
                          });
                        },
                        controlAffinity: ListTileControlAffinity.leading,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _assignTeam,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text(
                    'Assign Team',
                    style: TextStyle(fontSize: 18, color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}