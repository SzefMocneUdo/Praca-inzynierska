import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:untitled/constants/routes.dart';
import 'package:untitled/firebase_options.dart';
import 'package:untitled/views/AddCreditCardScreen.dart';
import 'package:untitled/views/BottomMenuView.dart';
import 'package:untitled/views/CalendarView.dart';
import 'package:untitled/views/CardListView.dart';
import 'package:untitled/views/CurrenciesView.dart';
import 'package:untitled/views/GoalsView.dart';
import 'package:untitled/views/HelpView.dart';
import 'package:untitled/views/LoginView.dart';
import 'package:untitled/views/NotificationsView.dart';
import 'package:untitled/views/PrivacyAndSecurityView.dart';
import 'package:untitled/views/SettingsView.dart';
import 'package:untitled/views/RegisterView.dart';
import 'package:untitled/views/TransactionsView.dart';
import 'package:untitled/views/UpdatePasswordView.dart';
import 'package:untitled/views/VerifyEmailView.dart';



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
      transactionsRoute: (context) => Transactions(),
      currenciesRoute: (context) => CurrenciesView(),
      goalsRoute: (context) => GoalsView(),
      notificationsRoute: (context) => NotificationsView(),
      settingsRoute: (context) => SettingsView(),
      privacyAndSecurityRoute: (context) => PrivacyAndSecurityView(),
      helpRoute: (context) => HelpView(),
      updatePasswordRoute: (context) => UpdatePasswordView(),
      creditCard: (context) => AddCreditCardScreen(),
      cardsRoute: (context) => CardListView(),
      calendarRoute: (context) =>TransactionCalendar()
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


