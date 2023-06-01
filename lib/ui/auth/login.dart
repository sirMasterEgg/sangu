import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:sangu/ui/auth/register.dart';

class LoginPage extends StatefulWidget {
  static const routeName  = '/auth/logindaniel';
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _auth = FirebaseAuth.instance;

  User? user;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

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
              const Padding(
                padding: EdgeInsets.only(bottom: 8.0, top: 24.0),
                child: Text('Email'),
              ),
              TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  hintText: 'ex: jason@gmail.com',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(8.0)),
                  ),
                ),
              ),
              const Padding(
                padding: EdgeInsets.only(bottom: 8.0, top: 24.0),
                child: Text('Password'),
              ),
              TextField(
                controller: _passwordController,
                keyboardType: TextInputType.text,
                obscureText: true,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(8.0)),
                  ),
                ),
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
                    onPressed: () {
                      logIn();
                    },
                    child: Text(
                      'Login'.toUpperCase(),
                      style: const TextStyle(
                        fontSize: 16.0,
                        fontWeight: FontWeight.bold,
                      )
                    ),
                  )
              ),
              TextButton(onPressed: (){
                Navigator.pushNamed(context, RegisterPage.routeName);
              }, child: const Text(
                  'Register Here',
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

  Future logIn() async {
    final email = _emailController.text;
    final password = _passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter email and password'),
        ),
      );
      return;
    }

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

    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(email: _emailController.text, password: _passwordController.text);
      user = userCredential.user;
    } on FirebaseAuthException catch (e) {
        const snackbar = SnackBar(content: Text('Invalid credentials'));
        ScaffoldMessenger.of(context).showSnackBar(snackbar);
    } finally {
      Navigator.pop(context);
    }

  }
}