import 'package:ffw_photospaces/services/authentication_service.dart';
import 'package:flutter/material.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  TextEditingController emailInputController = TextEditingController();
  TextEditingController passwordInputController = TextEditingController();

  @override
  Widget build(BuildContext context) {

    return Scaffold(
        body: Center(
          child: SizedBox(
            width: double.infinity,
            height: 400,
            child: Padding(
              padding: const EdgeInsets.all(46.0),
              child: Form(
                child: Column(
                  children: <Widget>[
                    TextFormField(
                      controller: emailInputController,
                      decoration: const InputDecoration(
                          labelText: 'Email',
                          icon: Icon(Icons.account_circle_rounded)),
                    ),
                    TextFormField(
                      controller: passwordInputController,
                      obscureText: true,
                      decoration: const InputDecoration(
                          labelText: 'Password', icon: Icon(Icons.lock)),
                    ),
                    const Spacer(),
                    ElevatedButton(
                        onPressed: () {
                          AuthenticationService().login(emailInputController.text, passwordInputController.text).then((value) => value == true ? Navigator.pushNamed(context, '/mockHomeScreen') : null);
                        },
                        child: const Text('Log in')
                    )
                  ],
                ),
              ),
            ),
          ),
        ));
  }
}
