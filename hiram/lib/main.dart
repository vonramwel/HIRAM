import 'package:flutter/material.dart';
import 'package:hiram/features/listing/presentation/homepage.dart';
import 'features/auth/presentation/login_page.dart'; // Import login page
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart'; // Import generated Firebase options

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform, // Use generated options
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: LoginPage(),
    );
  }
}
