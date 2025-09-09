import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:note_ai/models/note_model.dart';
import 'package:note_ai/screen/QANoteScreen.dart';
import 'package:note_ai/screen/edit_list_note_screen.dart';
import 'package:note_ai/screen/edit_qna_note_screen.dart';
import 'package:note_ai/screen/edit_secure_note_screen.dart';
import 'package:note_ai/screen/edit_text_note_screen.dart';
import 'package:note_ai/screen/home_screen.dart';
import 'package:note_ai/screen/login_screen.dart';
import 'package:note_ai/screen/select_note_type_screen.dart';
import 'package:note_ai/screen/text_note_screen.dart';
import 'package:note_ai/screen/list_note_screen.dart';
import 'package:note_ai/screen/secure_note_screen.dart';
import 'package:note_ai/screen/splash_screen.dart';
import 'package:note_ai/screen/view_list_note_screen.dart';
import 'package:note_ai/screen/view_qna_note_screen.dart';
import 'package:note_ai/screen/view_secure_note_screen.dart';
import 'package:note_ai/screen/view_text_note_screen.dart';

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
      debugShowCheckedModeBanner: false,
      title: 'Note AI',
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.deepPurple,
      ),
      home: const SplashScreen(),
      routes: {
        '/home': (context) => const HomeScreen(),
        '/login': (context) => const LoginScreen(),
        '/selectNoteType': (context) => const SelectNoteTypeScreen(),
        '/textNote': (context) => const TextNoteScreen(),
        '/listNote': (context) => const ListNoteScreen(),
        '/qaNote': (context) => const QANoteScreen(),
        '/secureNote': (context) => SecureNoteScreen(),

        '/editTextNote': (context) {
          final note = ModalRoute.of(context)!.settings.arguments as NoteModel;
          return EditTextNoteScreen(note: note);
        },
        '/editListNote': (context) {
          final note = ModalRoute.of(context)!.settings.arguments as NoteModel;
          return EditListNoteScreen(note: note);
        },
        '/editQnaNote': (context) {
          final note = ModalRoute.of(context)!.settings.arguments as NoteModel;
          return EditQANoteScreen(note: note);
        },
        '/editSecureNote': (context) {
          final note = ModalRoute.of(context)!.settings.arguments as NoteModel;
          return EditSecureNoteScreen(note: note);
        },

        '/viewTextNote': (context) {
          return ViewTextNoteScreen();
        },
        '/viewListNote': (context) {
          return ViewChecklistNoteScreen();
        },
        '/viewQnaNote': (context) {
          return ViewQANoteScreen();
        },
        '/viewSecureNote': (context) {
          return ViewSecureNoteScreen();
        },

      },
    );
  }
}

class ViewListNoteScreen {
}
