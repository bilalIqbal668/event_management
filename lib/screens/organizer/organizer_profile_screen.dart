import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:myapp/helpers/AppConstants.dart';

class OrganizerProfileScreen extends StatefulWidget {
  const OrganizerProfileScreen({super.key});

  @override
  State<OrganizerProfileScreen> createState() => _OrganizerProfileScreenState();
}

class _OrganizerProfileScreenState extends State<OrganizerProfileScreen> {
  final _venueNameController = TextEditingController();
  final _venueLocationController = TextEditingController();
  final _venueCityController = TextEditingController();
  final _employeeNameController = TextEditingController();
  String _selectedRole = 'Photographer';

  List<Map<String, dynamic>> _employees = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadOrganizerDetails();
  }

  Future<void> _loadOrganizerDetails() async {
    final uid = FirebaseAuth.instance.currentUser!.uid;

    try {
      final venueQuery =
          await FirebaseFirestore.instance
              .collection('venues')
              .where('organizerId', isEqualTo: uid)
              .limit(1)
              .get();

      if (venueQuery.docs.isNotEmpty) {
        final venueData = venueQuery.docs.first.data();
        _venueNameController.text = venueData['name'] ?? '';
        _venueLocationController.text = venueData['location'] ?? '';
        _venueCityController.text = venueData['city'] ?? '';
      }

      final empSnapshot =
          await FirebaseFirestore.instance
              .collection('organizers')
              .doc(uid)
              .collection('employees')
              .get();

      _employees =
          empSnapshot.docs.map((doc) => {'id': doc.id, ...doc.data()}).toList();
    } catch (e) {
      debugPrint('Error loading organizer profile: $e');
    }

    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _updateProfile() async {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    final venueQuery =
        await FirebaseFirestore.instance
            .collection('venues')
            .where('organizerId', isEqualTo: uid)
            .limit(1)
            .get();

    if (venueQuery.docs.isEmpty) return;

    final venueId = venueQuery.docs.first.id;

    await FirebaseFirestore.instance.collection('venues').doc(venueId).update({
      'name': _venueNameController.text.trim(),
      'location': _venueLocationController.text.trim(),
      'city': _venueCityController.text.trim(),
    });

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Profile updated')));
  }

  Future<void> _addEmployee() async {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    final name = _employeeNameController.text.trim();

    if (name.isEmpty) return;

    final docRef = await FirebaseFirestore.instance
        .collection('organizers')
        .doc(uid)
        .collection('employees')
        .add({'name': name, 'role': _selectedRole});

    setState(() {
      _employees.add({'id': docRef.id, 'name': name, 'role': _selectedRole});
      _employeeNameController.clear();
    });
  }

  Future<void> _deleteEmployee(String id) async {
    final uid = FirebaseAuth.instance.currentUser!.uid;

    await FirebaseFirestore.instance
        .collection('organizers')
        .doc(uid)
        .collection('employees')
        .doc(id)
        .delete();

    setState(() {
      _employees.removeWhere((emp) => emp['id'] == id);
    });
  }

  void _logout() async {
    await FirebaseAuth.instance.signOut();
    if (context.mounted) {
      Navigator.pushNamedAndRemoveUntil(context, '/signin', (_) => false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Organizer Profile'),
        backgroundColor: Colors.teal
,
        actions: [
          IconButton(icon: const Icon(Icons.logout), onPressed: _logout),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.purple, Colors.pinkAccent],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child:
            _isLoading
                ? const Center(child: CircularProgressIndicator())
                : SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Venue Details',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _venueNameController,
                        decoration: InputDecoration(
                          labelText: 'Venue Name',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          filled: true,
                          fillColor: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _venueLocationController,
                        decoration: InputDecoration(
                          labelText: 'Venue Location',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          filled: true,
                          fillColor: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _venueCityController,
                        decoration: InputDecoration(
                          labelText: 'Venue City',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          filled: true,
                          fillColor: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Your Email (not editable):',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        user?.email ?? '',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const Divider(height: 32, color: Colors.white),

                      /// EMPLOYEES SECTION
                      const Text(
                        'Employees',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 8),
                      for (var emp in _employees)
                        Card(
                          margin: const EdgeInsets.symmetric(vertical: 4),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: ListTile(
                            title: Text(emp['name'] ?? ''),
                            subtitle: Text(emp['role'] ?? ''),
                            trailing: IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => _deleteEmployee(emp['id']),
                            ),
                          ),
                        ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _employeeNameController,
                        decoration: InputDecoration(
                          labelText: 'New Employee Name',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          filled: true,
                          fillColor: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<String>(
                        value: _selectedRole,
                        decoration: InputDecoration(
                          labelText: 'Role',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          filled: true,
                          fillColor: Colors.white,
                        ),
                        items:
                            AppConstant.roles
                                .map(
                                  (role) => DropdownMenuItem(
                                    value: role,
                                    child: Text(role),
                                  ),
                                )
                                .toList(),
                        onChanged: (value) {
                          if (value != null) {
                            setState(() {
                              _selectedRole = value;
                            });
                          }
                        },
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _addEmployee,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.teal
,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text('Add Employee'),
                        ),
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _updateProfile,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.teal
,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text('Update Profile'),
                        ),
                      ),
                    ],
                  ),
                ),
      ),
    );
  }
}
