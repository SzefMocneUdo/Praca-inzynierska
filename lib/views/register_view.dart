import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'dart:developer' as devtools show log;

import 'package:untitled/constants/routes.dart';

class RegisterView extends StatefulWidget{
  const RegisterView({Key? key}) : super(key: key);

  @override
  _RegisterViewState createState() => _RegisterViewState();
}

class _RegisterViewState extends State<RegisterView>{

  late final TextEditingController _email;
  late final TextEditingController _password;

  @override
  void initState() {
    _email = TextEditingController();
    _password = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Register'), backgroundColor: Colors.purple,),
      body: Column(
        children: [
          TextField(controller: _email,
            enableSuggestions: false,
            keyboardType: TextInputType.emailAddress,
            autocorrect: false,
            decoration: const InputDecoration(hintText: 'E-mail'),),
          TextField(controller: _password,
            obscureText: true,
            enableSuggestions: false,
            autocorrect: false,
            decoration: const InputDecoration(hintText: 'Password'),),
          TextButton(onPressed: () async{
            final email = _email.text;
            final password = _password.text;
            try{
              final userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(email: email, password: password);
              devtools.log(userCredential.toString());
              Navigator.of(context).pushNamedAndRemoveUntil(verifyEmailRoute, (route) => false);
            }
            on FirebaseAuthException catch (e){
              if (e.code == 'weak-password'){
                devtools.log('This password is too weak');
              }
              else if(e.code == 'email-already-in-use'){
                devtools.log('This email is already in use');
              }
              else if(e.code == 'invalid-email'){
                devtools.log('Invalid email entered');
              }
            }
          }, child: const Text('Sign Up'),
          ),
          TextButton(onPressed: () {
            Navigator.of(context).pushNamedAndRemoveUntil(loginRoute, (route) => false);
            }, child: const Text('Already have an account? Log in here!'),
          )
        ],
      ),
    );
  }
}