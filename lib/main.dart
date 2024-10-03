import 'package:firstly/services/auth/MSSQLAuthProvider.dart';
import 'package:firstly/signup.dart';
import 'package:firstly/welcome.dart';
import 'package:flutter/material.dart';
import 'account.dart';
import 'self_credential_page1.dart';
import 'credentialbtn.dart';
import 'credential2.dart';
import 'routes.dart';
import 'profile_info.dart';
import 'education_info.dart';
import 'work_info.dart';
import 'softskill_info.dart';
import 'cvpage.dart';
// Import your login page

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      routes: {
        '/': (context) =>
            const HomePage(), // Start with HomePage to check login
        profileInfoRoute: (context) => const ProfileInfoPage(),
        educationInfoRoute: (context) => const EducationInfoPage(),
        workInfoRoute: (context) => const WorkInfoPage(),
        qualiInfoRoute: (context) => const Credential2(),
        softSkillInfoRoute: (context) => const SoftSkillInfoPage(),
        welcomeRoute: (context) =>
            const WelcomePage(), // Ensure login route is defined
        '/signup': (context) => const SignUpPage(),
        '/homePage': (context) => const HomePage(),
      },
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  HomePageState createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  int _selectedIndex = 0;
  bool _isLoggedIn = false; // Track login status
  final MSSQLAuthProvider _authProvider =
      MSSQLAuthProvider(); // MSSQLAuthProvider instance

  static final List<Widget> _pages = <Widget>[
    const SelfCredentialPage1(),
    const ReceiveCre(),
    const CVPage(),
    const Account(),
  ];

  @override
  void initState() {
    super.initState();
    _checkLoginStatus(); // Check login on widget initialization
  }

  void _checkLoginStatus() async {
    // Initialize MSSQLAuthProvider and check if user is logged in
    await _authProvider.initialize();
    final user = _authProvider.currentUser;

    // If user is null or not logged in, redirect to login
    if (user == null || user.email.isEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.of(context).pushNamedAndRemoveUntil(
          welcomeRoute,
          (route) => false,
        );
      });
    } else {
      setState(() {
        _isLoggedIn = true;
      });
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Show nothing until login status is determined
    if (!_isLoggedIn) {
      return const Center(child: CircularProgressIndicator());
    }

    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedIndex,
        items: const [
          BottomNavigationBarItem(
            label: 'Wallet',
            icon: Icon(Icons.account_balance_wallet),
          ),
          BottomNavigationBarItem(
            label: 'Certification',
            icon: Icon(Icons.badge),
          ),
          BottomNavigationBarItem(
            label: 'CV',
            icon: Icon(Icons.assignment),
          ),
          BottomNavigationBarItem(
            label: 'Account',
            icon: Icon(Icons.account_circle),
          ),
        ],
        onTap: _onItemTapped,
      ),
    );
  }
}
