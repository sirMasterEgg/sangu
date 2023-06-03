import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
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
  var _passwordVisible = true;
  var _confirmPasswordVisible = true;
  var _oldPasswordVisible = true;
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _oldPasswordController = TextEditingController();
  final _emailController = TextEditingController();
  final _nameController = TextEditingController();
  final _usernameController = TextEditingController();
  final _db = FirebaseFirestore.instance;
  Timestamp? _timeStampUsername;
  String? _displayName;

  @override
  void dispose() {
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    _oldPasswordController.dispose();
    _emailController.dispose();
    _nameController.dispose();
    _usernameController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final results = await _db.collection('users')
        .where('email', isEqualTo: _auth.currentUser!.email!)
        .limit(1)
        .get();

    _emailController.text = _auth.currentUser!.email!;

    if(results.docs.isEmpty){
      return;
    }

    final data = results.docs.first.data();
    _usernameController.text = data['username'] ?? '';
    _nameController.text = data['display_name'] ?? '';
    setState(() {
      _timeStampUsername = data['username_created_at'];
      _displayName = data['display_name'];
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 5),
            nameWidget(),
            const SizedBox(height: 20),
            usernameWidget(),
            const SizedBox(height: 5),
            const Text('* Username can only be changed once'),
            const SizedBox(height: 20),
            emailWidget(),
            const SizedBox(height: 20),
            passwordWidget(
                controller: _newPasswordController,
                hint: 'New Password',
                label: 'New Password',
                obscureText: _passwordVisible,
                onPressed: (){
                  setState(() {
                    _passwordVisible = !_passwordVisible;
                  });
                }
            ),
            const SizedBox(height: 20),
            passwordWidget(
                controller: _confirmPasswordController,
                hint: 'New Confirm Password',
                label: 'New Confirm Password',
                obscureText: _confirmPasswordVisible,
                onPressed: (){
                  setState(() {
                    _confirmPasswordVisible = !_confirmPasswordVisible;
                  });
                }
            ),
            const SizedBox(height: 20),
            passwordWidget(
                controller: _oldPasswordController,
                hint: 'Old Password',
                label: 'Old Password',
                obscureText: _oldPasswordVisible,
                onPressed: (){
                  setState(() {
                    _oldPasswordVisible = !_oldPasswordVisible;
                  });
                }
            ),
            const SizedBox(height: 5),
            const Text('* Old password only for change password'),
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
                  final messenger = ScaffoldMessenger.of(context);
                  final focus = FocusScope.of(context);

                  if (_timeStampUsername == null && _usernameController.text.isNotEmpty){
                    final registeredUsername = await _db.collection('users')
                        .where('username', isEqualTo: _usernameController.text)
                        .limit(1)
                        .get();

                    if (registeredUsername.docs.isNotEmpty){
                      messenger.showSnackBar(
                          const SnackBar(content: Text('Username already registered'))
                      );
                      focus.requestFocus(FocusNode());
                      return;
                    }

                    await _db.collection('users')
                        .doc(_auth.currentUser!.uid)
                        .set({
                      'email': _auth.currentUser!.email!,
                      'username': _usernameController.text,
                      'username_created_at': DateTime.now()
                    }, SetOptions(merge: true));
                    setState(() {
                      _timeStampUsername = Timestamp.now();
                    });
                    messenger.showSnackBar(
                        const SnackBar(content: Text('Successfully update the username'))
                    );
                  }

                  // change name
                  String name = _displayName ?? '';
                  if (_nameController.text != name) {
                    await _db.collection('users')
                        .doc(_auth.currentUser!.uid)
                        .set({
                      'email': _auth.currentUser!.email!,
                      'display_name': _nameController.text,
                    }, SetOptions(merge: true));
                    messenger.showSnackBar(
                        const SnackBar(content: Text('Successfully update the name'))
                    );
                  }

                  if (
                    _newPasswordController.text.isNotEmpty ||
                    _confirmPasswordController.text.isNotEmpty
                  ){
                    if (_newPasswordController.text != _confirmPasswordController.text){
                      messenger.showSnackBar(
                          const SnackBar(content: Text('New password and confirm password not match'))
                      );
                      return;
                    }

                    if (_oldPasswordController.text.isEmpty){
                      messenger.showSnackBar(
                          const SnackBar(content: Text('Old password is required'))
                      );
                      return;
                    }

                    try {
                      await _auth.currentUser!.reauthenticateWithCredential(
                          EmailAuthProvider.credential(
                              email: _emailController.text,
                              password: _oldPasswordController.text
                          )
                      );
                      await _auth.currentUser!.updatePassword(_newPasswordController.text);
                    } catch (e) {
                      print(e.toString());
                    }

                    messenger.showSnackBar(
                        const SnackBar(content: Text('Successfully update the password'))
                    );
                    _oldPasswordController.clear();
                    _newPasswordController.clear();
                    _confirmPasswordController.clear();
                    focus.unfocus();
                    return;
                  }

                },
                child: const Padding(
                  padding: EdgeInsets.all(10.0),
                  child: Text('Save'),
                )
            ),
            const SizedBox(height: 5),
            TextButton(
                style: ButtonStyle(
                  shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                  ),
                  foregroundColor: MaterialStateProperty.all<Color>(Colors.white),
                  backgroundColor: MaterialStateProperty.all<Color>(Colors.red.shade800),
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
            ),
          ]
        ),
      ),
    );
  }

  Widget emailWidget () {
    return MaterialTextField(
      controller: _emailController,
      keyboardType: TextInputType.emailAddress,
      hint: 'Email',
      labelText: 'Email',
      textInputAction: TextInputAction.done,
      enabled: false,
      prefixIcon: const Icon(Icons.email_outlined),
    );
  }

  Widget nameWidget (){
    return MaterialTextField(
      controller: _nameController,
      keyboardType: TextInputType.text,
      hint: 'Name',
      labelText: 'Name',
      textInputAction: TextInputAction.done,
      prefixIcon: const Icon(Icons.person_outline),
    );
  }

  Widget usernameWidget (){
    return MaterialTextField(
      controller: _usernameController,
      keyboardType: TextInputType.text,
      hint: 'Username',
      enabled: _timeStampUsername == null,
      labelText: 'Username',
      textInputAction: TextInputAction.done,
      prefixIcon: const Icon(Icons.alternate_email),
    );
  }

  Widget passwordWidget({
        controller = TextEditingController,
        hint = String,
        label = String,
        obscureText = bool,
        onPressed = VoidCallback
      }) {
    return MaterialTextField(
      controller: controller,
      keyboardType: TextInputType.text,
      hint: hint,
      labelText: label,
      obscureText: obscureText,
      suffixIcon: IconButton(
        icon: Icon(
          obscureText ? Icons.visibility : Icons.visibility_off,
        ),
        onPressed: onPressed,
      ),
      textInputAction: TextInputAction.done,
      prefixIcon: const Icon(Icons.lock_outline),
    );
  }
}
