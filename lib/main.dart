import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
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
            primary: Color(0xFF1F2128),
            secondary: Color(0xFFDFF169),
          ),
          fontFamily: 'SofiaPro'
        ),
        initialRoute: LoginPage.routeName,
        routes: {
          LoginPage.routeName : (context) => const LoginPage(),
          RegisterPage.routeName : (context) => const RegisterPage(),
        }
    );
  }
}
