import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:material_text_fields/material_text_fields.dart';

import '../auth/login.dart';


class ProfilePage extends StatefulWidget {

  const ProfilePage({Key? key}) : super(key: key);

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _auth = FirebaseAuth.instance;
  bool _passwordVisible = true;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 20),
          MaterialTextField(
            controller: TextEditingController(text: _auth.currentUser!.email),
            keyboardType: TextInputType.emailAddress,
            hint: 'Email',
            labelText: 'Email',
            textInputAction: TextInputAction.next,
            prefixIcon: const Icon(Icons.email_outlined),
          ),
          const SizedBox(height: 20),
          MaterialTextField(
            controller: TextEditingController(),
            keyboardType: TextInputType.emailAddress,
            hint: 'Password',
            labelText: 'New Password',
            obscureText: _passwordVisible,
            suffixIcon: IconButton(
              icon: Icon(
                // Based on passwordVisible state choose the icon
                _passwordVisible
                    ? Icons.visibility
                    : Icons.visibility_off,
              ),
              onPressed: () {
                setState(() {
                  _passwordVisible = !_passwordVisible;
                });
              },
            ),
            textInputAction: TextInputAction.next,
            prefixIcon: const Icon(Icons.email_outlined),
          ),
          const SizedBox(height: 20),
          TextButton(
              style: ButtonStyle(
                shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                ),
                foregroundColor: MaterialStateProperty.all<Color>(Colors.white),
                backgroundColor: MaterialStateProperty.all<Color>(Theme.of(context).colorScheme.primary),
                overlayColor: MaterialStateProperty.resolveWith<Color?>(
                      (Set<MaterialState> states) {
                    if (states.contains(MaterialState.hovered)) {
                      return Theme.of(context).colorScheme.primary.withOpacity(0.04);
                    }
                    if (states.contains(MaterialState.focused) || states.contains(MaterialState.pressed)) {
                      return Theme.of(context).colorScheme.primary.withOpacity(0.12);
                    }
                    return null;
                  },
                ),
              ),
              onPressed: () async {
                await _auth.signOut();
                Navigator.pushNamedAndRemoveUntil(context, LoginPage.routeName, (route) => false);
              },
              child: const Padding(
                padding: EdgeInsets.all(10.0),
                child: Text('Logout'),
              )
          )
        ]
      ),
    );
  }
}
