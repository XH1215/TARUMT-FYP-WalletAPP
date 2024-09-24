import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert'; // For JSON decoding
import 'package:http/http.dart' as http; // For making HTTP requests
import 'dart:developer' as devtools show log;
import 'generate_qr.dart';

class ViewCV extends StatefulWidget {
  const ViewCV({super.key});

  @override
  _ViewCVState createState() => _ViewCVState();
}

class _ViewCVState extends State<ViewCV> {
  Map<String, dynamic>? _cvData; // To hold the CV data
  bool _isLoading = true; // To show a loading spinner while fetching data
  String? _errorMessage; // To store any error messages

  @override
  void initState() {
    super.initState();
    _fetchCVData(); // Fetch data when the page is initialized
  }

  // Fetch CV data from the backend
  Future<void> _fetchCVData() async {
    final accountID = await _getAccountID();
    if (accountID == null) {
      setState(() {
        _errorMessage = "Failed to retrieve account ID.";
        _isLoading = false;
      });
      return;
    }

    try {
      final response = await http.post(
        Uri.parse('http://10.0.2.2:3000/api/showDetails'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(
            {'accountID': accountID}), // Send accountID to the backend
      );

      if (response.statusCode == 200) {
        setState(() {
          _cvData = jsonDecode(response.body); // Parse the JSON response
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = "Failed to fetch CV details.";
          _isLoading = false;
        });
      }
    } catch (error) {
      setState(() {
        _errorMessage = "Error fetching data: $error";
        _isLoading = false;
      });
      devtools.log('Error fetching CV data: $error');
    }
  }

  // Get accountID from SharedPreferences
  Future<int?> _getAccountID() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getInt('accountID');
    } catch (e) {
      devtools.log('Error retrieving accountID: $e');
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text('View CV'),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator()) // Show loading spinner
          : _errorMessage != null
              ? Center(
                  child: Text(
                      _errorMessage!)) // Show error message if there is one
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSectionTitle(Icons.person, 'Profile Information'),
                      _buildProfileSection(_cvData!['profile']),
                      _buildSectionTitle(Icons.school, 'Education Information'),
                      _cvData!['education'] != null
                          ? _buildEducationSection(_cvData!['education'])
                          : const Text("No education information available."),
                      _buildSectionTitle(Icons.work, 'Work Experience'),
                      _cvData!['workExperience'] != null
                          ? _buildWorkSection(_cvData!['workExperience'])
                          : const Text("No work experience available."),
                      _buildSectionTitle(Icons.lightbulb, 'Skills'),
                      _cvData!['skills'] != null
                          ? _buildSoftSkillsSection(_cvData!['skills'])
                          : const Text("No skills information available."),
                      _buildSectionTitle(Icons.star, 'Certifications'),
                      _cvData!['certifications'] != null
                          ? _buildCertificationSection(
                              _cvData!['certifications'])
                          : const Text(
                              "No certification information available."),
                      const SizedBox(height: 20), // Add some spacing
                      ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => GenerateQRPage(),
                      ),
                    );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF171B63),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 60.0, vertical: 15.0),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                        ),
                        child: const Text(
                          'Generate QR', // Change this text as needed
                          style: TextStyle(color: Colors.white, fontSize: 15.0),
                        ),
                      ),
                    ],
                  ),
                ),
    );
  }

  // Build section title widget
  Widget _buildSectionTitle(IconData icon, String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Row(
        children: [
          Icon(icon, color: Colors.blue),
          const SizedBox(width: 8.0),
          Text(
            title,
            style: const TextStyle(
              fontSize: 18.0,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  // Display profile information
  Widget _buildProfileSection(Map<String, dynamic>? profile) {
    if (profile == null) return const SizedBox.shrink();

    return Column(
      children: [
        if (profile['profile_image_path'] != null)
          Image.memory(
            base64Decode(profile[
                'profile_image_path']), // Decode the base64 photo if available
            width: 100,
            height: 100,
          ),
        _buildInfoBox([
          'Name: ${profile['name']}', // Name field from the backend
          'Age: ${profile['age']}', // Age field from the backend
          'Email: ${profile['email']}', // Email_Address is mapped to 'email'
          'Phone: ${profile['phone']}', // Mobile_Number is mapped to 'phone'
          'Address: ${profile['address']}', // Address field from the backend
          'Description: ${profile['description']}', // Description field from the backend
        ]),
      ],
    );
  }

  // Display education information
  Widget _buildEducationSection(List<dynamic> education) {
    return Column(
      children: education.map((edu) {
        return _buildInfoBox([
          'Level: ${edu['level']}',
          'Field of Study: ${edu['field_of_study']}',
          'Institute Name: ${edu['institute_name']}',
          'Country: ${edu['institute_country']}',
          'City: ${edu['institute_city']}',
          'Start Date: ${edu['start_date']}',
          'End Date: ${edu['end_date']}',
        ]);
      }).toList(),
    );
  }

  // Display work experience information
  Widget _buildWorkSection(List<dynamic> workExperience) {
    return Column(
      children: workExperience.map((work) {
        return _buildInfoBox([
          'Job Title: ${work['job_title']}',
          'Company: ${work['company_name']}',
          'Industry: ${work['industry']}',
          'Country: ${work['country']}',
          'State: ${work['state']}',
          'City: ${work['city']}',
          'Description: ${work['description']}',
          'Start Date: ${work['start_date']}',
          'End Date: ${work['end_date']}',
        ]);
      }).toList(),
    );
  }

  // Display skills information
  Widget _buildSoftSkillsSection(List<dynamic> softSkills) {
    return Column(
      children: softSkills.map((skill) {
        return _buildInfoBox([
          'Skill: ${skill['skill']}',
          'Description: ${skill['description']}',
        ]);
      }).toList(),
    );
  }

  // Display certifications information
  Widget _buildCertificationSection(List<dynamic> certifications) {
    if (certifications.isEmpty) {
      return const Text("No public certifications available.");
    }

    return Column(
      children: certifications.map((cert) {
        return _buildInfoBox([
          'Title: ${cert['name']}', // Using the correct key for CerName
          'Email: ${cert['email']}', // Adding the email field
          'Type: ${cert['type']}', // Adding the type field
          'Issuer: ${cert['issuer']}', // Using the correct key for CerIssuer
          'Description: ${cert['description']}', // Using the correct key for CerDescription
          'Acquired Date: ${cert['acquiredDate']}', // Using the correct key for acquiredDate
        ]);
      }).toList(),
    );
  }

  // Helper function to create a box of information
  Widget _buildInfoBox(List<String> info) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10.0),
      padding: const EdgeInsets.all(20.0),
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10.0),
        border: Border.all(color: Colors.grey, width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: info.map((line) {
          return Text(
            line,
            style: const TextStyle(
              fontSize: 16.0,
              fontWeight: FontWeight.w600,
            ),
          );
        }).toList(),
      ),
    );
  }
}
