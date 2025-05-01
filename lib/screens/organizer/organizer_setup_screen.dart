import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:myapp/helpers/AppConstants.dart';

class OrganizerSetupScreen extends StatefulWidget {
  const OrganizerSetupScreen({super.key});

  @override
  State<OrganizerSetupScreen> createState() => _OrganizerSetupScreenState();
}

class _OrganizerSetupScreenState extends State<OrganizerSetupScreen> {
  final _venueNameController = TextEditingController();
  final _venueLocationController = TextEditingController();
  final _venueCityController = TextEditingController();
  final _empNameController = TextEditingController();
  String? _selectedRole;
  final List<Map<String, String>> _employees = [];
  bool _isSaving = false;
  String? _error;

  void _addEmployee() {
    final name = _empNameController.text.trim();
    final role = _selectedRole;
    if (name.isEmpty || role == null) return;

    setState(() {
      _employees.add({'name': name, 'role': role});
      _empNameController.clear();
      _selectedRole = null;
    });
  }

  Future<void> _saveData() async {
    setState(() {
      _isSaving = true;
      _error = null;
    });

    try {
      final uid = FirebaseAuth.instance.currentUser!.uid;
      final venueName = _venueNameController.text.trim();
      final venueLocation = _venueLocationController.text.trim();
      final venueCity = _venueCityController.text.trim();

      if (venueName.isEmpty || venueLocation.isEmpty || venueCity.isEmpty) {
        setState(() {
          _error = "Please fill all venue details.";
          _isSaving = false;
        });
        return;
      }

      final batch = FirebaseFirestore.instance.batch();
      final orgRef = FirebaseFirestore.instance.collection('organizers').doc(uid);

      final venueRef = FirebaseFirestore.instance.collection('venues').doc();
      batch.set(venueRef, {
        'organizerId': uid,
        'name': venueName,
        'location': venueLocation,
        'city': venueCity,
        'imageUrl': '',
      });

      for (var emp in _employees) {
        final empRef = orgRef.collection('employees').doc();
        batch.set(empRef, emp);
      }

      await batch.commit();
      Navigator.pushReplacementNamed(context, '/organizer-home-screen');
    } catch (e) {
      setState(() {
        _error = e.toString();
      });
    } finally {
      setState(() {
        _isSaving = false;
      });
    }
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(30)),
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Organizer Setup'),
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
                      const Text(
                        'Venue Details',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.teal,
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _venueNameController,
                        decoration: _inputDecoration('Venue Name'),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _venueLocationController,
                        decoration: _inputDecoration('Venue Location'),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _venueCityController,
                        decoration: _inputDecoration('City'),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
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
                      const Text(
                        'Add Employees',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.teal,
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _empNameController,
                        decoration: _inputDecoration('Employee Name'),
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<String>(
                        value: _selectedRole,
                        decoration: _inputDecoration('Role'),
                        items: AppConstant.roles.map((role) {
                          return DropdownMenuItem<String>(
                            value: role,
                            child: Text(role),
                          );
                        }).toList(),
                        onChanged: (value) => setState(() => _selectedRole = value),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _addEmployee,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.teal,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                          child: const Text(
                            'Add Employee',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _employees.length,
                itemBuilder: (context, index) {
                  final emp = _employees[index];
                  return Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 2,
                    child: ListTile(
                      title: Text(emp['name'] ?? ''),
                      subtitle: Text(emp['role'] ?? ''),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () {
                          setState(() {
                            _employees.removeAt(index);
                          });
                        },
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 16),
              if (_error != null)
                Text(
                  _error!,
                  style: const TextStyle(color: Colors.red),
                ),
              const SizedBox(height: 16),
              _isSaving
                  ? const CircularProgressIndicator()
                  : SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _saveData,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text(
                    'Save and Continue',
                    style: TextStyle(color: Colors.white),
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