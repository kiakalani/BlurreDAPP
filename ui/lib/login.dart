import 'package:flutter/material.dart';
import 'package:ui/auth.dart';
import 'package:ui/location.dart';
import 'package:ui/main.dart';
import 'package:ui/sock.dart';
import 'signup.dart';


class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  LoginPageState createState() => LoginPageState();
}

class LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  // Password visibility
  bool _passwordVisible = false;

  @override
  Widget build(BuildContext context) {
    double fieldWidth = MyApp.getFieldWidth(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Login'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Email field
              setEmailField(fieldWidth),
              const SizedBox(height: 20),

              // Password field
              setPasswordField(fieldWidth),
              const SizedBox(height: 20),

              // Login button
              _setLoginButton(fieldWidth),

              // Create account
              _createAccount(fieldWidth)
            ],
          ),
        ),
      ),
    );
  }

  // Password field
  Widget setPasswordField(double fieldWidth) {
    return 
      SizedBox(
        width: fieldWidth, 
        child: TextFormField(
          controller: _passwordController,
          obscureText: !_passwordVisible,
          decoration: InputDecoration(
            labelText: 'Password',
            border: const OutlineInputBorder(),
            suffixIcon: IconButton(
              icon: Icon(
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
          ),
        ),
      );
  }

  // Login button
  Widget _setLoginButton(double fieldWidth) {
    return       
      ElevatedButton(
        onPressed: () {
          Authorization().postRequest("/auth/signin/", {
            "email": _emailController.text,
            "password": _passwordController.text
          }).then((resp) => {
            if (resp.statusCode == 200) {
                SocketIO('http://localhost:3001'),
                LocationService().update_location(),
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => const HomePage()))
            }
          });
        },
        child: const Text(
          'Login',
          style: TextStyle(
            fontSize: 18,
          ),
        ),
      );
  }

  // Create Account filed
  Widget _createAccount(double fieldWidth) {
    return      
      TextButton(
        onPressed: () => Navigator.push(context,
            MaterialPageRoute(builder: (_) => const SignupPage())),
        child: const Text('Create your account'),
      );
  }

  // Email field
  Widget setEmailField(double fieldWidth) {
    return 
      SizedBox(
        width: fieldWidth,
        child: TextField(
          controller:
              _emailController, 
          decoration: const InputDecoration(
            labelText: 'Email',
            border: OutlineInputBorder(),
          ),
          keyboardType: TextInputType.emailAddress,
        ),
      );
  }
}