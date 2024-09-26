import 'package:flutter/material.dart';
import 'view_profile.dart';
import 'welcome.dart';

class Account extends StatelessWidget {
  const Account({super.key});

  Future<void> _logOut(BuildContext context) async {
    try {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const WelcomePage()),
      );
    } catch (e) {
      print('Logout Error: $e');
      throw Exception('Failed to log out');
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
                Navigator.of(context).pop(true);
              },
              child: const Text('Logout'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false);
              },
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    ).then((value) => value ?? false);
  }

  void showLogoutSuccessDialog(BuildContext context) {
    Future.delayed(Duration.zero, () {
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
    });
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

              // Using Icon for Change Password
              _buildInfoBoxWithIcon(
                context,
                const Icon(Icons.lock, size: 50.0, color: Color(0xFF171B63)),
                'Change Password',
                () {
                  // Handle change password functionality here
                },
              ),
              const SizedBox(height: 20.0), // Space between boxes

              // Using Icon for Logout
              _buildInfoBoxWithIcon(
                context,
                const Icon(Icons.logout, size: 50.0, color: Color(0xFF171B63)),
                'Logout',
                () async {
                  bool shouldLogOut = await showLogOutDialog(context);
                  if (shouldLogOut) {
                    await _logOut(context);
                    showLogoutSuccessDialog(context);
                  }
                },
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
