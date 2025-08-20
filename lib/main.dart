import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:note_ai/screen/QANoteScreen.dart';
import 'package:note_ai/screen/home_screen.dart';
import 'package:note_ai/screen/login_screen.dart';
import 'package:note_ai/screen/select_note_type_screen.dart';
import 'package:note_ai/screen/text_note_screen.dart';
import 'package:note_ai/screen/list_note_screen.dart';
import 'package:note_ai/screen/secure_note_screen.dart';

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
      title: 'Note AI',
      routes: {
        '/selectNoteType': (context) => const SelectNoteTypeScreen(),
        '/textNote': (context) => const TextNoteScreen(),
        '/listNote': (context) => const ListNoteScreen(),
        '/qaNote': (context) => const QANoteScreen(),
        '/secureNote': (context) => SecureNoteScreen(),
      },
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.deepPurple,
      ),
      home: AuthGate(),
    );
  }
}

class AuthGate extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        } else if (snapshot.hasData) {
          return const HomeScreen();
        } else {
          return const LoginScreen();
        }
      },
    );
  }
}
