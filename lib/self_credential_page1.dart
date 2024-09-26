import 'package:firstly/education_info.dart';
import 'package:firstly/profile_info.dart';
import 'package:firstly/softskill_info.dart';
import 'package:firstly/work_info.dart';
import 'package:flutter/material.dart';
import 'credential2.dart';

class SelfCredentialPage1 extends StatelessWidget {
  const SelfCredentialPage1({super.key});

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
            'Wallet',
            style: TextStyle(
              color: Colors.white,
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        // Make the content scrollable
        padding: const EdgeInsets.symmetric(vertical: 20.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              // Using Icon
              _buildInfoBox(
                context,
                icon: const Icon(Icons.person,
                    size: 50.0, color: Color(0xFF171B63)), // Pass Icon
                label: 'Profile',
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (BuildContext context) {
                      return const ProfileInfoPage(); // Navigate to ProfileInfoPage
                    },
                  ),
                ),
              ),
              const SizedBox(height: 20.0), // Space between boxes

              // Using Image for Education
              _buildInfoBox(
                context,
                icon: const Icon(Icons.school,
                    size: 50.0, color: Color(0xFF171B63)), // Pass Icon
                label: 'Education',
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (BuildContext context) {
                      return const EducationInfoPage(); // Navigate to EducationPage
                    },
                  ),
                ),
              ),

              const SizedBox(height: 20.0), // Space between boxes

              // Using Image for Certification
              _buildInfoBox(
                context,
                icon: const Icon(Icons.star,
                    size: 50.0, color: Color(0xFF171B63)), // Pass Icon
                label: 'Certification',
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (BuildContext context) {
                      return const Credential2(); // Navigate to QualificationsPage
                    },
                  ),
                ),
              ),

              const SizedBox(height: 20.0), // Space between boxes

              // Using Image for Work Experience
              _buildInfoBox(
                context,
                icon: const Icon(Icons.work, size: 50.0, color: Color(0xFF171B63)),
                label: 'Work Experience',
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (BuildContext context) {
                      return const WorkInfoPage(); // Navigate to WorkExperiencePage
                    },
                  ),
                ),
              ),

              const SizedBox(height: 20.0), // Space between boxes

              // Using Image for Soft Skill
              _buildInfoBox(
                context,
                icon:
                    const Icon(Icons.lightbulb, size: 50.0, color: Color(0xFF171B63)),
                label: 'Soft Skill',
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (BuildContext context) {
                      return const SoftSkillInfoPage(); // Navigate to SoftSkillPage
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Modify _buildInfoBox to accept either icon or image
  Widget _buildInfoBox(
    BuildContext context, {
    Icon? icon, // Optional icon parameter
    String? imagePath, // Optional image path parameter
    required String label, // Label for the box
    required VoidCallback onTap, // Callback for navigation
  }) {
    // Get the screen width using MediaQuery
    double screenWidth = MediaQuery.of(context).size.width;

    return Container(
      width: screenWidth * 0.9, // Set width to 90% of the screen width
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
              child: icon != null
                  ? icon // Show the icon if provided
                  : Image.asset(
                      imagePath!, // Show the image if icon is not provided
                      width: 45.0, // Adjust width as needed
                      height: 45.0, // Adjust height as needed
                    ),
            ),
            const SizedBox(width: 20.0), // Space between image/icon and text
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
