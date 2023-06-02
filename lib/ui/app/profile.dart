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

  @override
  void dispose() {
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    _oldPasswordController.dispose();
    _emailController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _emailController.text = _auth.currentUser!.email!;
    _nameController.text = _auth.currentUser!.displayName!;

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 20),
            nameWidget(),
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
            const SizedBox(height: 90),
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
                  // change name
                  if (_nameController.text != _auth.currentUser!.displayName!) {
                    await _auth.currentUser!.updateDisplayName(_nameController.text);
                    ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Successfully update the name'))
                    );
                  }

                  if (
                    _newPasswordController.text.isNotEmpty ||
                    _confirmPasswordController.text.isNotEmpty
                  ){
                    if (_newPasswordController.text != _confirmPasswordController.text){
                      ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('New password and confirm password not match'))
                      );
                      return;
                    }

                    if (_oldPasswordController.text.isEmpty){
                      ScaffoldMessenger.of(context).showSnackBar(
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

                    ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Successfully update the password'))
                    );
                    _oldPasswordController.clear();
                    _newPasswordController.clear();
                    _confirmPasswordController.clear();
                    FocusScope.of(context).unfocus();
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
