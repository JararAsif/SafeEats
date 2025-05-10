import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:smdpro/Screens/FeedbackPage.dart';
import 'package:smdpro/Screens/home_screen.dart';
import 'package:smdpro/Screens/sign_in_screen.dart';
import 'package:smdpro/Screens/sign_up_screen.dart';
import 'package:smdpro/Screens/ProfileScreen.dart';
import 'package:smdpro/Screens/UploadImageScreen.dart';
import 'package:smdpro/Screens/DetectionHistory.dart';
import 'package:smdpro/Screens/HelpSupportPage.dart';
import 'package:smdpro/Screens/EditProfileScreen.dart';
import 'package:smdpro/Screens/ForgotPasswordScreen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(); // Initialize Firebase
  runApp(SafeEatsApp());
}

class SafeEatsApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'SafeEats',
      theme: ThemeData(primarySwatch: Colors.orange),
      initialRoute: '/signing', // Always route to SignInScreen first
      onGenerateRoute: (RouteSettings settings) {
        switch (settings.name) {
          case '/signing':
            return MaterialPageRoute(builder: (context) => SignInScreen());
          case '/forgotPassword':
            return MaterialPageRoute(builder: (context) => ForgotPasswordScreen());
          case '/signup':
            return MaterialPageRoute(builder: (context) => SignUpScreen());
          case '/home':
            return MaterialPageRoute(builder: (context) => HomeScreen());
          case '/profile':
            return MaterialPageRoute(builder: (context) => ProfileScreen());
          case '/editProfile':
            return MaterialPageRoute(builder: (context) => EditProfileScreen());
          case '/uploadImage':
            return MaterialPageRoute(builder: (context) => UploadImageScreen());
          case '/detectionHistory':
            return MaterialPageRoute(builder: (context) => DetectionHistory());
          case '/feedback':
            return MaterialPageRoute(builder: (context) => FeedbackPage());
          case '/helpSupport':
            return MaterialPageRoute(builder: (context) => HelpSupportPage());
          default:
            return MaterialPageRoute(
              builder: (context) => Scaffold(body: Center(child: Text("Page not found"))),
            );
        }
      },
    );
  }
}
