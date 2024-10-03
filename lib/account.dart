import 'package:firstly/services/auth/MSSQLAuthProvider.dart';
import 'package:flutter/material.dart';
import 'view_profile.dart';
import 'welcome.dart';
import 'change_passwd.dart';
import 'dart:developer' as devtools show log;

class Account extends StatefulWidget {
  const Account({super.key});

  @override
  _AccountState createState() => _AccountState();
}

class _AccountState extends State<Account> {
  bool _isLoggingOut = false; // To track the loading state during logout

  Future<void> _logOut() async {
    try {
      setState(() {
        _isLoggingOut = true; // Start loading
      });

      final MSSQLAuthProvider authProvider = MSSQLAuthProvider();
      await authProvider.logout();
    } catch (e) {
      devtools.log('Logout Error: $e');
      throw Exception('Failed to log out');
    } finally {
      setState(() {
        _isLoggingOut = false; // Stop loading
      });
    }
  }

  Future<bool> showLogOutDialog(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Logout'),
          content: const Text('Are You Sure You Want To Logout?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false);
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(true);
              },
              child: const Text('Logout'),
            ),
          ],
        );
      },
    ).then((value) => value ?? false);
  }

  void showLogoutSuccessDialog() {
    // Avoid using context here directly after async operations
    Future.delayed(Duration.zero, () {
      if (mounted) {
        showDialog<void>(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: const Text('Logged Out'),
              content: const Text('You have successfully logged out.'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('OK'),
                ),
              ],
            );
          },
        );
      }
    });
  }

  void _handleLogout() async {
    bool shouldLogOut = await showLogOutDialog(context);
    if (shouldLogOut) {
      // Perform the logout operation
      await _logOut();

      // Now, after logout, navigate and show success message
      if (mounted) {
        // Navigate to the WelcomePage before showing success dialog
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => const WelcomePage(),
          ),
        );

        // Show the success dialog after navigation
        showLogoutSuccessDialog();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        centerTitle: true,
        backgroundColor: const Color(0xFF171B63),
        title: const Padding(
          padding: EdgeInsets.only(bottom: 10.0),
          child: Text(
            'Account',
            style: TextStyle(
              color: Colors.white,
            ),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 20.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              // Using Icon for View Profile
              _buildInfoBoxWithIcon(
                context,
                const Icon(Icons.person, size: 50.0, color: Color(0xFF171B63)),
                'Account Profile',
                () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ViewProfile()),
                ),
              ),
              const SizedBox(height: 20.0), // Space between boxes
              _buildInfoBoxWithIcon(
                context,
                const Icon(Icons.vpn_key, size: 50.0, color: Color(0xFF171B63)),
                'Change Password',
                () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const ChangePasswdView()),
                ),
              ),
              const SizedBox(height: 20.0), // Space between boxes
              // Using Icon for Logout
              _buildInfoBoxWithIcon(
                context,
                const Icon(Icons.logout, size: 50.0, color: Color(0xFF171B63)),
                'Logout',
                _handleLogout, // Safely handle logout and context navigation
              ),

              if (_isLoggingOut) // Show loading indicator while logging out
                const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: CircularProgressIndicator(),
                ),
            ],
          ),
        ),
      ),
    );
  }

  // Reusable box widget with icon, label, and navigation
  Widget _buildInfoBoxWithIcon(
    BuildContext context,
    Icon icon, // Icon instead of Image
    String label,
    VoidCallback onTap,
  ) {
    double screenWidth = MediaQuery.of(context).size.width; // Get screen width

    return Container(
      width: screenWidth * 0.9, // Set width to 90% of screen width
      height: 90.0,
      decoration: BoxDecoration(
        border: Border.all(
          color: Colors.grey,
          width: 2.0,
        ),
        borderRadius: BorderRadius.circular(10.0),
        color: Colors.transparent,
      ),
      child: InkWell(
        onTap: onTap,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: icon, // Show the Icon
            ),
            const SizedBox(width: 20.0), // Space between icon and text
            Text(
              label,
              style: const TextStyle(
                fontSize: 20.0,
                color: Color(0xFF171B63),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
