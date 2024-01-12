import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:currency_picker/currency_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../constants/routes.dart';

class CustomUser {
  final String uid;
  final String email;
  final String username;
  final String hashedPassword;
  final String currency;

  CustomUser({
    required this.uid,
    required this.email,
    required this.username,
    required this.hashedPassword,
    required this.currency,
  });

  factory CustomUser.fromFirebaseUser(
      User user, String username, String currency) {
    return CustomUser(
      uid: user.uid,
      email: user.email!,
      username: username,
      hashedPassword: generateHashedPassword(user.uid, user.email!),
      currency: currency,
    );
  }

  Future<void> saveUserToFirestore() async {
    try {
      await FirebaseFirestore.instance.collection('users').doc(uid).set({
        'username': username,
        'email': email,
        'hashedPassword': hashedPassword,
        'currency': currency
      });
    } catch (e) {
      print('Error saving user to Firestore: $e');
    }
  }

  static String generateHashedPassword(String uid, String email) {
    // Implement the hash function (e.g., SHA-256) securely
    return 'hash_function_result';
  }
}

class RegisterView extends StatefulWidget {
  const RegisterView({Key? key}) : super(key: key);

  @override
  _RegisterViewState createState() => _RegisterViewState();
}

class _RegisterViewState extends State<RegisterView> {
  late final TextEditingController _username;
  late final TextEditingController _email;
  late final TextEditingController _password;
  late final TextEditingController _confirmPassword;
  String _selectedCurrency = '';

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  late final TextEditingController _currencyTextField;

  Color usernameBorderColor = Colors.grey;
  Color emailBorderColor = Colors.grey;
  Color passwordBorderColor = Colors.grey;
  Color confirmPasswordBorderColor = Colors.grey;

  Color usernameIconColor = Colors.grey;
  Color emailIconColor = Colors.grey;
  Color passwordIconColor = Colors.grey;
  Color confirmPasswordIconColor = Colors.grey;

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  List<String> _errorMessages = [];

  @override
  void initState() {
    _username = TextEditingController();
    _email = TextEditingController();
    _password = TextEditingController();
    _confirmPassword = TextEditingController();
    _currencyTextField = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _username.dispose();
    _email.dispose();
    _password.dispose();
    _confirmPassword.dispose();
    _currencyTextField.dispose();
    super.dispose();
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    required bool isPassword,
    required IconData iconData,
    required Function(String) validator,
    required bool obscureText,
    required Function() onTap,
    Function()? onTapIcon,
    required Color borderColor,
    required Color iconColor,
  }) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
      child: TextFormField(
        controller: controller,
        obscureText: obscureText,
        enableSuggestions: false,
        autocorrect: false,
        decoration: InputDecoration(
          hintText: hintText,
          prefixIcon: Icon(
            iconData,
            color: iconColor,
          ),
          suffixIcon: isPassword
              ? IconButton(
                  icon: Icon(
                    obscureText ? Icons.visibility : Icons.visibility_off,
                    color: Colors.grey,
                  ),
                  onPressed: onTapIcon ?? () {},
                )
              : null,
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(25.0),
            borderSide: BorderSide(color: borderColor, width: 2.0),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(25.0),
            borderSide: BorderSide(color: borderColor),
          ),
        ),
        style: TextStyle(color: Colors.black),
        validator: (value) => validator(value!),
        onTap: () {
          setState(() {
            if (controller == _username) {
              usernameBorderColor = Colors.blue;
              emailBorderColor = Colors.grey;
              passwordBorderColor = Colors.grey;
              confirmPasswordBorderColor = Colors.grey;
              usernameIconColor = Colors.blue;
              emailIconColor = Colors.grey;
              passwordIconColor = Colors.grey;
              confirmPasswordIconColor = Colors.grey;
            }
            else if (controller == _email) {
              usernameBorderColor = Colors.grey;
              emailBorderColor = Colors.blue;
              passwordBorderColor = Colors.grey;
              confirmPasswordBorderColor = Colors.grey;
              usernameIconColor = Colors.grey;
              emailIconColor = Colors.blue;
              passwordIconColor = Colors.grey;
              confirmPasswordIconColor = Colors.grey;
            } else if (controller == _password) {
              usernameBorderColor = Colors.grey;
              emailBorderColor = Colors.grey;
              passwordBorderColor = Colors.blue;
              confirmPasswordBorderColor = Colors.grey;
              usernameIconColor = Colors.grey;
              emailIconColor = Colors.grey;
              passwordIconColor = Colors.blue;
              confirmPasswordIconColor = Colors.grey;
            } else if (controller == _confirmPassword) {
              usernameBorderColor = Colors.grey;
              emailBorderColor = Colors.grey;
              passwordBorderColor = Colors.grey;
              confirmPasswordBorderColor = Colors.blue;
              usernameIconColor = Colors.grey;
              emailIconColor = Colors.grey;
              passwordIconColor = Colors.grey;
              confirmPasswordIconColor = Colors.blue;
            }
          });
        },
      ),
    );
  }

  void _showRequirementsDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Registration Requirements'),
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('- Minimum 10 characters required for username'),
              Text('- Only letters and digits allowed for username'),
              Text('- Valid email format'),
              Text('- Minimum 8 characters required for password'),
              Text(
                  '- Password must contain at least one digit, one special character, and one uppercase letter'),
              Text('- Passwords must match'),
            ],
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void _showEmailVerificationDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Verify Email'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'To complete the registration process, verify your email address.',
              ),
              SizedBox(height: 5.0),
              ElevatedButton(
                onPressed: () async {
                  User? user = FirebaseAuth.instance.currentUser;
                  if (user != null && !user.emailVerified) {
                    // Navigator.of(context).pop(); // Zamknij obecny AlertDialog
                    await user.sendEmailVerification();
                    _showEmailSentDialog();
                  }
                },
                child: Text('Send Verification Email'),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showEmailSentDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Verification Email Sent'),
          content:
              Text('A verification email has been sent. Check your inbox.'),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void _showErrorDialog(List<String> errorMessages) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Registration Error'),
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children:
                errorMessages.map((message) => Text('- $message')).toList(),
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void _openCurrencyPicker() {
    showCurrencyPicker(
      context: context,
      showFlag: true,
      showCurrencyName: true,
      showCurrencyCode: true,
      onSelect: (Currency currency) {
        setState(() {
          _selectedCurrency = currency.name;
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:
          AppBar(title: const Text('Register'), backgroundColor: Colors.white),
      body: SingleChildScrollView(
        child: Center(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 200,
                  height: 200,
                  decoration: BoxDecoration(
                    image: const DecorationImage(
                      image: AssetImage('lib/assets/ic_logo.png'),
                      fit: BoxFit.cover,
                    ),
                    borderRadius: BorderRadius.circular(0.0),
                    border: Border.all(color: Colors.white, width: 2.0),
                  ),
                ),
                _buildTextField(
                  controller: _username,
                  hintText: 'Username',
                  isPassword: false,
                  iconData: Icons.person,
                  validator: (value) {
                    if (value.length < 10) {
                      _errorMessages
                          .add('Minimum 10 characters required for username');
                    } else if (!RegExp(r'^[a-zA-Z0-9]+$').hasMatch(value)) {
                      _errorMessages
                          .add('Only letters and digits allowed for username');
                    }
                    return null;
                  },
                  obscureText: false,
                  onTap: () {},
                  borderColor: usernameBorderColor,
                  iconColor: usernameIconColor,
                  onTapIcon: () {},
                ),
                SizedBox(height: 10.0),
                _buildTextField(
                  controller: _email,
                  hintText: 'E-mail',
                  isPassword: false,
                  iconData: Icons.email,
                  validator: (value) {
                    if (!RegExp(r'^[a-zA-Z0-9.]+@[a-zA-Z0-9]+\.[a-zA-Z]+')
                        .hasMatch(value)) {
                      _errorMessages.add('Invalid email format');
                    }
                    return null;
                  },
                  obscureText: false,
                  onTap: () {},
                  borderColor: emailBorderColor,
                  iconColor: emailIconColor,
                ),
                SizedBox(height: 10.0),
                _buildTextField(
                  controller: _password,
                  hintText: 'Password',
                  isPassword: true,
                  iconData: Icons.lock,
                  validator: (value) {
                    if (value.length < 8) {
                      _errorMessages
                          .add('Minimum 8 characters required for password');
                    } else if (!RegExp(
                            r'^(?=.*[0-9])(?=.*[!@#$%^&*(),.?":{}|<>])(?=.*[A-Z]).*$')
                        .hasMatch(value)) {
                      _errorMessages.add(
                          'Password must contain at least one digit, one special character, and one uppercase letter');
                    }
                    return null;
                  },
                  obscureText: _obscurePassword,
                  onTap: () {},
                  onTapIcon: () {
                    setState(() {
                      _obscurePassword = !_obscurePassword;
                    });
                  },
                  borderColor: passwordBorderColor,
                  iconColor: passwordIconColor,
                ),
                SizedBox(height: 10.0),
                _buildTextField(
                  controller: _confirmPassword,
                  hintText: 'Confirm Password',
                  isPassword: true,
                  iconData: Icons.lock,
                  validator: (value) {
                    if (value.isEmpty) {
                      _errorMessages
                          .add('Please enter the password confirmation');
                    }
                    return null;
                  },
                  obscureText: _obscureConfirmPassword,
                  onTap: () {},
                  onTapIcon: () {
                    setState(() {
                      _obscureConfirmPassword = !_obscureConfirmPassword;
                    }); // Dodanie wywołania CurrencyPicker
                  },
                  borderColor: confirmPasswordBorderColor,
                  iconColor: confirmPasswordIconColor,
                ),
                SizedBox(height: 10.0),
                Container(
                  margin:
                      EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
                  child: TextFormField(
                    controller: _currencyTextField,
                    readOnly: true,
                    decoration: InputDecoration(
                      hintText: _selectedCurrency.isNotEmpty
                          ? _selectedCurrency
                          : 'Currency',
                      prefixIcon: Icon(
                        Icons.attach_money,
                        color: Colors.grey,
                      ),
                      suffixIcon: IconButton(
                        icon: Icon(
                          Icons.arrow_drop_down,
                          color: Colors.grey,
                        ),
                        onPressed: () {
                          _openCurrencyPicker(); // Wywołanie funkcji otwierającej CurrencyPicker
                        },
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25.0),
                        borderSide: BorderSide(color: Colors.grey, width: 2.0),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25.0),
                        borderSide: BorderSide(color: Colors.grey),
                      ),
                    ),
                    style: TextStyle(color: Colors.black),
                  ),
                ),
                ElevatedButton(
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      final username = _username.text;
                      final email = _email.text;
                      final password = _password.text;
                      final confirmPassword = _confirmPassword.text;

                      try {
                        if (password != confirmPassword) {
                          _errorMessages.add('Passwords do not match');
                          _showErrorDialog(_errorMessages);
                          _errorMessages = [];
                          return;
                        }
                        if (_selectedCurrency.isEmpty) {
                          _errorMessages
                              .add('You have to choose main currency');
                          _showErrorDialog(_errorMessages);
                          _errorMessages = [];
                          return;
                        }

                        // Kontynuuj rejestrację
                        final userCredential = await FirebaseAuth.instance
                            .createUserWithEmailAndPassword(
                          email: email,
                          password: password,
                        );

                        // Twórz obiekt użytkownika i zapisuj do Firestore
                        final customUser = CustomUser.fromFirebaseUser(
                            userCredential.user!, username, _selectedCurrency);
                        await customUser.saveUserToFirestore();

                        // Wysyłaj email weryfikacyjny
                        await userCredential.user?.sendEmailVerification();
                        _showEmailVerificationDialog();
                      } on FirebaseAuthException catch (e) {
                        _errorMessages.add(e.message ??
                            'An error occurred during registration');
                        _showErrorDialog(_errorMessages);
                        _errorMessages = [];
                      }
                    }
                  },
                  child: const Text('Sign Up'),
                ),
                SizedBox(height: 10.0),
                TextButton(
                  onPressed: () {
                    Navigator.of(context)
                        .pushNamedAndRemoveUntil(loginRoute, (route) => false);
                  },
                  child: const Text('Already have an account? Log in here!'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
