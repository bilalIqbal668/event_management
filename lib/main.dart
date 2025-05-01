import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:myapp/screens/my_bookings_screen.dart';
import 'package:myapp/screens/organizer/create_event_screen.dart';
import 'package:myapp/screens/organizer/organizer_booking_review_screen.dart';
import 'package:myapp/screens/organizer/organizer_home_screen.dart';
import 'package:myapp/screens/organizer/organizer_profile_screen.dart';
import 'package:myapp/screens/organizer/organizer_setup_screen.dart';
import 'package:myapp/screens/signup_screen.dart';
import 'package:myapp/screens/venue_detail_screen.dart';
import 'package:myapp/screens/customer/customer_home_screen.dart';

import 'screens/forgot_password_screen.dart';
import 'screens/signin_screen.dart';
import 'screens/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Event Booking',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.cyan),
      home: const SplashScreen(),
      routes: {

        //auth screens
        '/signin': (_) => const SignInScreen(),
        '/forgot-password': (_) => const ForgotPasswordScreen(),
        '/signup': (_) => const SignUpScreen(),

        //organizer screens

        //add employees and venue details screen
        '/organizer-setup': (_) => const OrganizerSetupScreen(),
        '/organizer-bookings': (_) => const OrganizerBookingReviewScreen(),
        '/organizer-home-screen': (_) => OrganizerHomeScreen(),
        '/customer-home-screen': (_) => const CustomerHomeScreen(),
        '/create-event': (_) => const CreateEventScreen(),
        '/organizer-profile': (_) => const OrganizerProfileScreen(),


        //customer screens
        '/venue-details': (context) {
          final venueId = ModalRoute.of(context)!.settings.arguments as String;
          return VenueDetailsScreen(venueId: venueId);
        },
        '/customer-bookings': (_) => const MyBookingsScreen(),

      },
    );
  }
}
