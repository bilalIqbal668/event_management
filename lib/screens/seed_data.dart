import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await seedFirestoreData();
  print('✅ Seeding complete');
}

Future<void> seedFirestoreData() async {
  final firestore = FirebaseFirestore.instance;

  final venues = [
    {
      'name': 'Pearl Continental Hotel',
      'type': 'Wedding',
      'location': 'Karachi',
      'capacity': 500,
      'price': 100000,
      'availableDates': ['2025-05-10', '2025-05-15', '2025-06-01'],
      'imageUrl': 'https://via.placeholder.com/150'
    },
    {
      'name': 'Lahore Marquee',
      'type': 'Birthday',
      'location': 'Lahore',
      'capacity': 200,
      'price': 30000,
      'availableDates': ['2025-05-12', '2025-05-18'],
      'imageUrl': 'https://via.placeholder.com/150'
    },
    {
      'name': 'Islamabad Convention Center',
      'type': 'Corporate',
      'location': 'Islamabad',
      'capacity': 300,
      'price': 50000,
      'availableDates': ['2025-05-14', '2025-05-20'],
      'imageUrl': 'https://via.placeholder.com/150'
    },
    {
      'name': 'Karachi Beach Resort',
      'type': 'Beach Party',
      'location': 'Karachi',
      'capacity': 150,
      'price': 35000,
      'availableDates': ['2025-05-20', '2025-05-25'],
      'imageUrl': 'https://via.placeholder.com/150'
    },
    {
      'name': 'The Royal Palm Lahore',
      'type': 'Wedding',
      'location': 'Lahore',
      'capacity': 400,
      'price': 80000,
      'availableDates': ['2025-05-05', '2025-05-15'],
      'imageUrl': 'https://via.placeholder.com/150'
    }
  ];

  for (var venue in venues) {
    await firestore.collection('venues').add(venue);
  }

  final services = [
    {
      'name': 'Pakistani Buffet Catering',
      'type': 'Food',
      'price': 1500,
      'description': 'Traditional Pakistani buffet (biryani, kebabs, naan, etc.)'
    },
    {
      'name': 'Luxury Floral Decoration',
      'type': 'Decor',
      'price': 25000,
      'description': 'Luxury flower arrangements, lighting, stage design'
    },
    {
      'name': 'LED Sound System',
      'type': 'AV',
      'price': 10000,
      'description': 'High-quality sound system with LED lights for stage setup'
    },
    {
      'name': 'DJ and Entertainment',
      'type': 'Entertainment',
      'price': 20000,
      'description': 'Professional DJ and entertainment for weddings and parties'
    },
    {
      'name': 'Traditional Mehndi Decor',
      'type': 'Decor',
      'price': 12000,
      'description': 'Mehndi setup with traditional decorations and lighting'
    }
  ];

  for (var service in services) {
    await firestore.collection('services').add(service);
  }
}
