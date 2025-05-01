import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 2), () async {
      final user = FirebaseAuth.instance.currentUser;

      if (user != null) {
        try {
          // Fetch user data from Firestore to check the role
          final userDoc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();

          if (userDoc.exists && userDoc.data() != null && userDoc.data()!.containsKey('role')) {
            final role = userDoc['role'];

            // Navigate based on user role
            if (role == 'Organizer') {
              Navigator.pushReplacementNamed(context, '/organizer-home-screen');
            } else {
              Navigator.pushReplacementNamed(context, '/customer-home-screen');
            }
          } else {
            Navigator.pushReplacementNamed(context, '/signin');  // Fallback to sign-in if no role
          }
        } catch (e) {
          print("Error fetching user data: $e");
          Navigator.pushReplacementNamed(context, '/signin');  // Error handling fallback
        }
      } else {
        Navigator.pushReplacementNamed(context, '/signin');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}

