import 'package:flutter/material.dart';
import 'package:on_de_band_demo_chat/firestore/user_firestore.dart';
import 'package:on_de_band_demo_chat/pages/top_page.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:on_de_band_demo_chat/utils/shared_prefs.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await SharedPrefs.setPrefsInstance();
  String? uid = SharedPrefs.fetchUid();
  if(uid == null) await UserFirestore.createUser();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const TopPage(),
    );
  }
}
