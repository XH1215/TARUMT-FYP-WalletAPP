/*
A Collaborative Creation:
CHIN KAH FUI
CHIN XUAN HONG
OLIVIA HUANG SI HAN
LIM CHU QING
*/

import 'package:flutter/material.dart';
import 'preview_cv.dart'; // Import the ViewCV page
import 'qrView.dart'; // Import the QRView page

class CVPage extends StatelessWidget {
  const CVPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false, // No back button on top
        centerTitle: true,
        backgroundColor: const Color(0xFF171B63),
        title: const Padding(
          padding: EdgeInsets.only(bottom: 10.0),
          child: Text(
            'CV',
            style: TextStyle(
              color: Colors.white,
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(vertical: 20.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              // First Box: View CV
              _buildInfoBoxWithIcon(
                context,
                Icons.description, // Use a relevant built-in icon
                'View CV',
                () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => const ViewCV()),
                ),
              ),
              const SizedBox(height: 20.0), // Space between boxes

              // Second Box: View QR Code with default QR icon
              _buildInfoBoxWithIcon(
                context,
                Icons.qr_code, // Default QR icon
                'QR Code',
                () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => const qrView()),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Reusable box widget with icon, label, and navigation
  Widget _buildInfoBoxWithIcon(
      BuildContext context, IconData icon, String label, VoidCallback onTap) {
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
              child: Icon(
                icon,
                size: 45.0, // Adjust size as needed
                color: const Color(0xFF171B63),
              ),
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
