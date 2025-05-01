import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:myapp/helpers/AppConstants.dart';

class CreateEventScreen extends StatefulWidget {
  const CreateEventScreen({super.key});

  @override
  State<CreateEventScreen> createState() => _CreateEventScreenState();
}

class _CreateEventScreenState extends State<CreateEventScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _capacityController = TextEditingController();
  final TextEditingController _tokenPaymentController = TextEditingController();
  final TextEditingController _eventCostController = TextEditingController();

  DateTime? _fromDate;
  DateTime? _toDate;

  String? _selectedEventType;



  List<String> _selectedServices = [];
  List<String> _selectedFoodMenu = [];

  Future<void> _selectDate({required bool isFrom}) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2024),
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      setState(() {
        if (isFrom) {
          _fromDate = picked;
        } else {
          _toDate = picked;
        }
      });
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate() ||
        _selectedEventType == null ||
        _fromDate == null ||
        _toDate == null ||
        _selectedServices.isEmpty ||
        _selectedFoodMenu.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please complete all required fields')),
      );
      return;
    }

    final uid = FirebaseAuth.instance.currentUser!.uid;
    final eventRef = FirebaseFirestore.instance.collection('events').doc();

    await eventRef.set({
      'organizerId': uid,
      'eventType': _selectedEventType,
      'capacity': int.parse(_capacityController.text.trim()),
      'availableFrom': _fromDate!.toIso8601String(),
      'availableTo': _toDate!.toIso8601String(),
      'services': _selectedServices,
      'foodMenu': _selectedFoodMenu,
      'tokenPayment': int.parse(_tokenPaymentController.text.trim()),
      'eventCost': int.parse(_eventCostController.text.trim()),
      'createdAt': DateTime.now().toIso8601String(),
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Event created successfully!')),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create Event')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              DropdownButtonFormField<String>(
                value: _selectedEventType,
                hint: const Text('Select Event Type'),
                items: AppConstant.eventTypes.map((type) {
                  return DropdownMenuItem(
                    value: type,
                    child: Text(type),
                  );
                }).toList(),
                onChanged: (value) => setState(() => _selectedEventType = value),
                validator: (value) => value == null ? 'Required' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _capacityController,
                decoration: const InputDecoration(labelText: 'Capacity'),
                keyboardType: TextInputType.number,
                validator: (value) => value!.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => _selectDate(isFrom: true),
                      child: Text(_fromDate == null
                          ? 'Select From Date'
                          : 'From: ${DateFormat('yyyy-MM-dd').format(_fromDate!)}'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => _selectDate(isFrom: false),
                      child: Text(_toDate == null
                          ? 'Select To Date'
                          : 'To: ${DateFormat('yyyy-MM-dd').format(_toDate!)}'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Text('Select Services', style: TextStyle(fontWeight: FontWeight.bold)),
              ...AppConstant.availableServices.map((service) => CheckboxListTile(
                title: Text(service),
                value: _selectedServices.contains(service),
                onChanged: (selected) {
                  setState(() {
                    if (selected == true) {
                      _selectedServices.add(service);
                    } else {
                      _selectedServices.remove(service);
                    }
                  });
                },
              )),
              const SizedBox(height: 16),
              const Text('Select Food Menu', style: TextStyle(fontWeight: FontWeight.bold)),
              ...AppConstant.foodMenuOptions.map((item) => CheckboxListTile(
                title: Text(item),
                value: _selectedFoodMenu.contains(item),
                onChanged: (selected) {
                  setState(() {
                    if (selected == true) {
                      _selectedFoodMenu.add(item);
                    } else {
                      _selectedFoodMenu.remove(item);
                    }
                  });
                },
              )),
              const SizedBox(height: 12),
              TextFormField(
                controller: _tokenPaymentController,
                decoration: const InputDecoration(labelText: 'Token Payment (PKR)'),
                keyboardType: TextInputType.number,
                validator: (value) => value!.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _eventCostController,
                decoration: const InputDecoration(labelText: 'Event Cost (PKR)'),
                keyboardType: TextInputType.number,
                validator: (value) => value!.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _submit,
                child: const Text('Create Event'),
              )
            ],
          ),
        ),
      ),
    );
  }
}
