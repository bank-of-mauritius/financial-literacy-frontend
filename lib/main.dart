import 'package:financial_literacy_frontend/screens/bank_map_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:financial_literacy_frontend/providers/auth_provider.dart';
import 'package:financial_literacy_frontend/providers/quiz_provider.dart';
import 'package:financial_literacy_frontend/providers/chatbot_provider.dart';
import 'package:financial_literacy_frontend/screens/welcome_screen.dart';
import 'package:financial_literacy_frontend/screens/home_screen.dart';
import 'package:financial_literacy_frontend/screens/quiz_screen.dart';
import 'package:financial_literacy_frontend/screens/profile_screen.dart';
import 'package:financial_literacy_frontend/styles/global_styles.dart';

void main() {
  runApp(const FinancialLiteracyApp());
}

class FinancialLiteracyApp extends StatelessWidget {
  const FinancialLiteracyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()..loadStoredAuth()),
        ChangeNotifierProvider(create: (_) => QuizProvider()),
        ChangeNotifierProvider(create: (_) => ChatbotProvider()),
      ],
      child: MaterialApp(
        title: 'Financial Literacy',
        theme: globalTheme,
        initialRoute: '/splash',
        routes: {
          '/splash': (context) => const WelcomeScreen(),
          '/home': (context) => const HomeScreen(),
          '/quiz': (context) => const QuizScreen(),
          '/profile': (context) => const ProfileScreen(),
          '/bank-map': (context) => const BankMapScreen(),
        },
      ),
    );
  }
}