import 'package:flutter/material.dart';
import 'package:sangu/ui/auth/register.dart';

class LoginPage extends StatefulWidget {
  static const routeName  = '/login';
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool _isLoading= false;
  var _emailController;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Sangu"),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _isLoading? const CircularProgressIndicator():const SizedBox(),
            const SizedBox(height: 24,),
            Text('Sign in'),
            TextField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                hintText: 'Email',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 24,),
            MaterialButton(
              height: 40,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              onPressed: ()  async {
                setState(() {
                  _isLoading = true;
                });
                final email = _emailController.text;
                final snackbar = SnackBar(content: Text('Welcome $email'));
                ScaffoldMessenger.of(context).showSnackBar(snackbar);
              },
              child: Text('Login'),
            ),
            TextButton(onPressed: (){
              Navigator.of(context).push(MaterialPageRoute(builder: (context) {
                return const RegisterPage();
              }));
            }, child: Text('Register here'))
          ],
        ),
      ),
    );
  }
}