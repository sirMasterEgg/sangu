import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:material_text_fields/theme/material_text_field_theme.dart';
import 'package:sangu/ui/app/app.dart';
import 'package:sangu/ui/app/create/add_user.dart';
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
          fontFamily: 'SofiaPro',
          inputDecorationTheme: FilledOrOutlinedTextTheme(
            radius: 8,
            contentPadding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
            errorStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
            fillColor: Colors.white,
            prefixIconColor: const Color(0xFF1F2128),
            enabledColor: Colors.grey,
            focusedColor: const Color(0xFF1F2128),
            floatingLabelStyle: const TextStyle(color: Color(0xFF1F2128)),
            width: 1.5,
            labelStyle: const TextStyle(fontSize: 16, color: Color(0xFF1F2128)),
          )
        ),
        initialRoute: LoginPage.routeName,
        routes: {
          LoginPage.routeName : (context) => const LoginPage(),
          RegisterPage.routeName : (context) => const RegisterPage(),
          AppPage.routeName : (context) => const AppPage(),
          AddUserPage.routeName : (context) => const AddUserPage(),
        }
    );
  }
}
