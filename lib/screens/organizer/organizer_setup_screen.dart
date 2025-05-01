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

      // Save venue
      final venueRef = FirebaseFirestore.instance.collection('venues').doc();
      batch.set(venueRef, {
        'organizerId': uid,
        'name': venueName,
        'location': venueLocation,
        'city': venueCity,
        'imageUrl': '',
      });

      // Save employees
      for (var emp in _employees) {
        final empRef = orgRef.collection('employees').doc();
        batch.set(empRef, emp);
      }

      await batch.commit();
      Navigator.pushReplacementNamed(context, '//organizer-home-screen');
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Organizer Setup')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Text('Venue Details', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            TextField(
              controller: _venueNameController,
              decoration: const InputDecoration(labelText: 'Venue Name'),
            ),
            TextField(
              controller: _venueLocationController,
              decoration: const InputDecoration(labelText: 'Venue Location'),
            ),
            TextField(
              controller: _venueCityController,
              decoration: const InputDecoration(labelText: 'City'),
            ),
            const SizedBox(height: 24),
            const Divider(),
            const Text('Add Employees', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            TextField(
              controller: _empNameController,
              decoration: const InputDecoration(labelText: 'Employee Name'),
            ),
            DropdownButtonFormField<String>(
              value: _selectedRole,
              decoration: const InputDecoration(labelText: 'Role'),
              items: AppConstant.roles.map((role) {
                return DropdownMenuItem<String>(
                  value: role,
                  child: Text(role),
                );
              }).toList(),
              onChanged: (value) => setState(() => _selectedRole = value),
            ),
            const SizedBox(height: 8),
            ElevatedButton(onPressed: _addEmployee, child: const Text('Add Employee')),
            const SizedBox(height: 16),
            ListView.builder(
              shrinkWrap: true,
              itemCount: _employees.length,
              itemBuilder: (context, index) {
                final emp = _employees[index];
                return ListTile(
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
                );
              },
            ),
            const SizedBox(height: 16),
            if (_error != null)
              Text(_error!, style: const TextStyle(color: Colors.red)),
            _isSaving
                ? const CircularProgressIndicator()
                : ElevatedButton(
              onPressed: _saveData,
              child: const Text('Save and Continue'),
            )
          ],
        ),
      ),
    );
  }
}
