import 'package:flutter/material.dart';
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
        colorScheme: const ColorScheme(
          brightness: Brightness.light,
          primary: Color(0xFF2B2B2B), // Charcoal
          onPrimary: Colors.white,
          secondary: Color(0xFFB3B3B3), // Medium Gray
          onSecondary: Colors.white,
          background: Colors.white,
          onBackground: Color(0xFF2B2B2B),
          surface: Color.fromARGB(255, 255, 255, 255), // Light Gray
          onSurface: Color(0xFF2B2B2B),
          error: Colors.red,
          onError: Colors.white,
        ),
        useMaterial3: true,
      ),
      debugShowCheckedModeBanner: false,
      home: LoginPage(),
    );
  }
}
