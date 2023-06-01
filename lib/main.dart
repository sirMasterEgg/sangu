import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:sangu/ui/app/app.dart';
import 'package:sangu/ui/app/profile.dart';
import 'package:sangu/ui/app/home.dart';
import 'package:sangu/ui/auth/login.dart';
import 'package:sangu/ui/auth/register.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSwatch().copyWith(
            primary: const Color(0xFF1F2128),
            secondary: const Color(0xFFDFF169),
            onSecondary: const Color(0xFFAEBDC2),
          ),
          fontFamily: 'SofiaPro'
        ),
        initialRoute: LoginPage.routeName,
        routes: {
          LoginPage.routeName : (context) => const LoginPage(),
          RegisterPage.routeName : (context) => const RegisterPage(),
          AppPage.routeName : (context) => const AppPage(),
        }
    );
  }
}
