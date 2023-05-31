import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:sangu/ui/auth/login.dart';

class RegisterPage extends StatefulWidget {
  static const routeName = '/auth/register';

  const RegisterPage({Key? key}) : super(key: key);

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _auth = FirebaseAuth.instance;
  var _emailController = TextEditingController();
  var _passwordController = TextEditingController();
  var _confirmPasswordController = TextEditingController();
  bool _obscureText = true;

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
              const Padding(
                padding: EdgeInsets.only(bottom: 8.0, top: 24.0),
                child: Text('Confirm Password'),
              ),
              TextField(
                controller: _confirmPasswordController,
                keyboardType: TextInputType.text,
                obscureText: true,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(8.0)),
                  ),
                ),
              ),
              Padding(
                  padding: EdgeInsets.only(top: 24.0),
                  child: TextButton(
                    style: ButtonStyle(
                      padding: MaterialStateProperty.all<EdgeInsets>(EdgeInsets.all(16.0)),
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
                  Navigator.pushNamed(context, LoginPage.routeName);
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
      final email = _emailController.text;
      final password = _passwordController.text;
      final confirmPassword = _confirmPasswordController.text;

      if (password != confirmPassword) {
        final snackbar = SnackBar(content: Text('Password and Confirm Password not match'));
        ScaffoldMessenger.of(context).showSnackBar(snackbar);
        Navigator.of(context).pop();
        return;
      }

      await _auth.createUserWithEmailAndPassword(email: email, password: password);

      final snackbar =  SnackBar(content: Text('Register Success'));
      ScaffoldMessenger.of(context).showSnackBar(snackbar);
      Navigator.of(context).pop();
    } on Exception catch (e) {
      final snackbar = SnackBar(content: Text(e.toString()));
      ScaffoldMessenger.of(context).showSnackBar(snackbar);
      Navigator.of(context).pop();
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}

