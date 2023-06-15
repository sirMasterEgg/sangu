import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:material_text_fields/material_text_fields.dart';
import 'package:sangu/helpers/firestore_manager.dart';
import 'package:sangu/ui/auth/login.dart';

class RegisterPage extends StatefulWidget {
  static const routeName = '/auth/register';

  const RegisterPage({Key? key}) : super(key: key);

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _auth = FirebaseAuth.instance;
  final _firestoreManager = FirestoreManager();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool obscureText = true;
  bool obscureTextConfirm = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("SANGU"),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Padding(
                padding: EdgeInsets.only(top: 32.0),
                child: Image(
                    image: AssetImage(
                        'assets/images/login_icon.png'
                    ),
                    height: 150
                ),
              ),
              const SizedBox(height: 24.0),
              MaterialTextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                hint: 'Email',
                labelText: 'Email',
                textInputAction: TextInputAction.next,
                prefixIcon: const Icon(Icons.email_outlined),
              ),
              const SizedBox(height: 24.0),
              MaterialTextField(
                controller: _passwordController,
                keyboardType: TextInputType.text,
                hint: 'Password',
                labelText: 'Password',
                obscureText: obscureText,
                suffixIcon: IconButton(
                  icon: Icon(
                    obscureText ? Icons.visibility : Icons.visibility_off,
                  ),
                  onPressed: () {
                    setState(() {
                      obscureText = !obscureText;
                    });
                  },
                ),
                textInputAction: TextInputAction.next,
                prefixIcon: const Icon(Icons.lock_outline),
              ),
              const SizedBox(height: 24.0),
              MaterialTextField(
                controller: _confirmPasswordController,
                keyboardType: TextInputType.text,
                hint: 'Confirm Password',
                labelText: 'Confirm Password',
                obscureText: obscureTextConfirm,
                suffixIcon: IconButton(
                  icon: Icon(
                    obscureTextConfirm ? Icons.visibility : Icons.visibility_off,
                  ),
                  onPressed: () {
                    setState(() {
                      obscureTextConfirm = !obscureTextConfirm;
                    });
                  },
                ),
                textInputAction: TextInputAction.done,
                prefixIcon: const Icon(Icons.lock_outline),
              ),
              Padding(
                  padding: const EdgeInsets.only(top: 24.0),
                  child: TextButton(
                    style: ButtonStyle(
                      padding: MaterialStateProperty.all<EdgeInsets>(const EdgeInsets.all(16.0)),
                      backgroundColor: MaterialStateProperty.all<Color>(Theme.of(context).colorScheme.primary),
                      foregroundColor: MaterialStateProperty.all<Color>(Colors.white),
                      shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                          RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.0),
                          )
                      ),
                    ),
                    onPressed: (){
                      register();
                    },
                    child: Text(
                        'Register'.toUpperCase(),
                        style: const TextStyle(
                          fontSize: 16.0,
                          fontWeight: FontWeight.bold,
                        )
                    ),
                  )
              ),
              TextButton(
                onPressed: (){
                  Navigator.of(context).pushReplacementNamed(LoginPage.routeName);
                },
                child: const Text(
                  'Login Here',
                  style: TextStyle(
                  fontSize: 16.0,
                  )
                )
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future register() async {
    final email = _emailController.text;
    final password = _passwordController.text;
    final confirmPassword = _confirmPasswordController.text;

    showDialog(
        context: context,
        builder: (context) {
          return Center(
            child: SpinKitCircle(
              size: 125,
              duration: const Duration(seconds: 2),
              itemBuilder: (BuildContext context, int index){
                final colors = [Theme.of(context).colorScheme.primary, Theme.of(context).colorScheme.secondary, Colors.white];
                final color = colors[index % colors.length];

                return DecoratedBox(
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                  ),
                );
              },
            ),
          );
        }
    );

    if (email.isEmpty || password.isEmpty || confirmPassword.isEmpty) {
      const snackbar = SnackBar(content: Text('Please enter email, password, and confirm password'));
      ScaffoldMessenger.of(context).showSnackBar(snackbar);
      Navigator.of(context).pop();
      return;
    }

    if (password != confirmPassword) {
      const snackbar = SnackBar(content: Text('Password and Confirm Password not match'));
      ScaffoldMessenger.of(context).showSnackBar(snackbar);
      Navigator.of(context).pop();
      return;
    }

    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    try {
      await _auth.createUserWithEmailAndPassword(email: email, password: password);
      _firestoreManager.updateSelectedUser(_auth.currentUser!.uid, email: _auth.currentUser!.email);
      /**
       * manual way
       * await _db.collection('users')
          .doc(_auth.currentUser!.uid)
          .set({
          'email': _auth.currentUser!.email!,
          }, SetOptions(merge: true));
       */
      const snackbar =  SnackBar(content: Text('Register Success'));
      messenger.showSnackBar(snackbar);
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        const snackbar = SnackBar(content: Text('The password provided is too weak.'));
        messenger.showSnackBar(snackbar);
        return;
      } else if (e.code == 'email-already-in-use') {
        const snackbar = SnackBar(content: Text('The account already exists for that email.'));
        messenger.showSnackBar(snackbar);
        return;
      }
    }
    finally {
      Navigator.of(context).pop();
      navigator.pushReplacementNamed(LoginPage.routeName);
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }
}

