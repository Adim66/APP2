import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_2/auth/login.dart';
import 'package:flutter_application_2/auth/signup.dart';
import 'package:flutter_application_2/modelandview/admin/addproduct.dart';
import 'package:flutter_application_2/modelandview/admin/adminadd.dart';
import 'package:flutter_application_2/modelandview/admin/adminhome.dart';
import 'package:flutter_application_2/modelandview/admin/anlysisscreen.dart';
import 'package:flutter_application_2/modelandview/client/adminclient.dart';
import 'package:flutter_application_2/modelandview/clientanddist/admindest.dart';
import 'package:flutter_application_2/modelandview/profils/profil.dart';
import 'package:flutter_application_2/modelandview/projects/produits.dart';
import 'package:flutter_application_2/modelandview/workers/staff.dart';
import 'package:provider/provider.dart';

Future main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
      options: const FirebaseOptions(
          apiKey: "AIzaSyDGeKQ9Bd7EHv_bTaRzDhPMvHr_mqbJfdE",
          appId: "1:843185362555:android:dfdb3a49189bb2352274de",
          messagingSenderId: "843185362555",
          projectId: "flutter-application-2-5c5a1",
          storageBucket: "flutter-application-2-5c5a1.appspot.com"));

  runApp(ChangeNotifierProvider(
      create: (context) => PoductsManager(), child: MyApp()));
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      if (user == null) {
        print('User is currently signed out!');
      } else {
        print('User is signed in!');
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const LoginPage(),
      routes: {
        "login": (context) => const LoginPage(),
        "register": (context) => const Signup(),
        "Admin": (context) => const AdminHome(),
        "addProduct": (context) => AddScreen(),
        "AdminClient": (context) => Adminclient(),
        "addproject": (context) => AdminAddProject(),
        "profil": (context) => Profil(),
        "staff": (context) => StaffScreen(),
        "adminAnalys": (context) => StatisticsPage(),
        "admindest": (context) => DistributorMainHomePage(),
      },
    );
  }
}
