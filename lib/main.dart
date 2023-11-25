import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:untitled/constants/routes.dart';
import 'package:untitled/firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:untitled/views/CardListView.dart';
import 'package:untitled/views/addCreditCardScreen.dart';
import 'package:untitled/views/currencies_view.dart';
import 'package:untitled/views/transactions_view.dart';
import 'package:untitled/views/help_view.dart';
import 'package:untitled/views/login_view.dart';
import 'package:untitled/views/bottom_manu_view.dart';
import 'package:untitled/views/notifications_view.dart';
import 'package:untitled/views/privacy_and_security_view.dart';
import 'package:untitled/views/profile_view.dart';
import 'package:untitled/views/register_view.dart';
import 'package:untitled/views/goals_view.dart';
import 'package:untitled/views/settings_view.dart';
import 'package:untitled/views/verify_email_view.dart';
import 'package:untitled/views/update_password_view.dart';



void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MaterialApp(
    theme: ThemeData(
      colorScheme: ColorScheme.fromSeed(seedColor: Colors.blueAccent),
      useMaterial3: true,
    ),
    home: const HomePage(),
    routes: {
      loginRoute: (context) => LoginView(),
      registerRoute: (context) => RegisterView(),
      verifyEmailRoute: (context) => VerifyEmailView(),
      mainRoute: (context) => MainView(),
      profileRoute: (context) => ProfileView(),
      transactionsRoute: (context) => Transactions(),
      currenciesRoute: (context) => CurrenciesView(),
      goalsRoute: (context) => GoalsView(),
      notificationsRoute: (context) => NotificationsView(),
      settingsRoute: (context) => SettingsView(),
      privacyAndSecurityRoute: (context) => PrivacyAndSecurityView(),
      helpRoute: (context) => HelpView(),
      updatePasswordRoute: (context) => UpdatePasswordView(),
      creditCard: (context) => AddCreditCardScreen(),
      cardsRoute: (context) => CardListView()
    },
  ));
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      builder: (context, snapshot){
        switch (snapshot.connectionState){
          case ConnectionState.done:
           final user = FirebaseAuth.instance.currentUser;
             return const LoginView();
           //}
          default:
            return const CircularProgressIndicator();
        }
      }, future: Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    ),
    );
  }
}


