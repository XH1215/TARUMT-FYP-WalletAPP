import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:developer' as devtools show log;

class Credential2 extends StatefulWidget {
  const Credential2({super.key});

  @override
  Credential2State createState() => Credential2State();
}

class Credential2State extends State<Credential2> {
  List<Map<String, dynamic>> _certifications = [];
  List<bool> _isPublicList = []; // Track public status for each certification
  bool _isLoading = true; // Track loading state

  @override
  void initState() {
    super.initState();
    _fetchCertifications();
  }

  Future<int?> _getAccountID() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final accountID = prefs.getInt('accountID');
      return accountID;
    } catch (e) {
      devtools.log('Error retrieving accountID: $e');
      return null;
    }
  }

  Future<void> _fetchCertifications() async {
    try {
      final accountID = await _getAccountID();
      if (accountID != null) {
        final response = await http.get(
          Uri.parse(
              'http://192.168.1.9:3000/api/getCertifications?accountID=$accountID'),
        );

        if (response.statusCode == 200) {
          final Map<String, dynamic> data = json.decode(response.body);
          final List<dynamic> certifications = data['certifications'];

          if (mounted) {
            setState(() {
            _certifications = certifications
                .map((item) => item as Map<String, dynamic>)
                .toList();

            // Initialize the _isPublicList based on the actual 'isPublic' boolean value
            _isPublicList = List<bool>.generate(
                _certifications.length,
                (index) =>
                    _certifications[index]['isPublic'] ==
                    true); // Use the actual boolean value

            _isLoading = false; // Data fetched, stop loading
          });
          }
        } else {
          devtools.log(
              'Failed to load certifications. Status code: ${response.statusCode}');
          devtools.log('Response body: ${response.body}');
          setState(() {
            _isLoading = false; // Stop loading even on error
          });
        }
      }
    } catch (e) {
      devtools.log('Error fetching certifications: $e');
      setState(() {
        _isLoading = false; // Stop loading on error
      });
    }
  }

  Future<void> _updatePublicStatus(int index) async {
    try {
      final accountID = await _getAccountID();
      if (accountID != null) {
        final isPublic =
            _isPublicList[index] ? 1 : 0; // Convert bool to int (1 or 0)
        // Retrieve the CerID from the certifications data
        final cerID = _certifications[index]['CerID'];
        final certificationData =
            Map<String, dynamic>.from(_certifications[index]);
        certificationData['isPublic'] = isPublic;
        devtools.log(certificationData.toString());
        devtools.log(cerID.toString());

        if (cerID != null) {
          final response = await http.post(
            Uri.parse('http://192.168.1.9:3000/api/updateCertificationStatus'),
            headers: {'Content-Type': 'application/json'},
            body: json.encode({
              'accountID': accountID,
              'CerID': cerID, // Pass the CerID
              'isPublic': isPublic, // Pass the public status
              'certification': certificationData,
            }),
          );

          if (response.statusCode == 200) {
            devtools.log('Status updated successfully.');
          } else {
            devtools.log(
                'Failed to update status. Status code: ${response.statusCode}');
          }
        } else {
          devtools.log('CerID not found for the selected certification.');
        }
      }
    } catch (e) {
      devtools.log('Error updating public status: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Padding(
          padding: EdgeInsets.only(bottom: 10.0),
          child: Text(
            'Certification',
            style: TextStyle(
              color: Color(0xFF171B63),
              fontSize: 20.0,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _certifications.isEmpty
              ? const Center(child: Text('No Certifications Found'))
              : ListView.builder(
                  itemCount: _certifications.length,
                  itemBuilder: (context, index) {
                    final certification = _certifications[index];

                    return Container(
                      margin: const EdgeInsets.symmetric(
                          vertical: 8.0, horizontal: 16.0),
                      padding: const EdgeInsets.all(16.0),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8.0),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            spreadRadius: 2,
                            blurRadius: 5,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 10.0),
                          Text(
                            'Name: ${certification['Name'] ?? 'N/A'}',
                            style: const TextStyle(
                              fontSize: 18.0,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 15.0),
                          Text(
                            'Email: ${certification['Email'] ?? 'N/A'}',
                            style: const TextStyle(fontSize: 16.0),
                          ),
                          const SizedBox(height: 15.0),
                          Text(
                            'Certification Type: ${certification['CertificationType'] ?? 'N/A'}',
                            style: const TextStyle(fontSize: 16.0),
                          ),
                          const SizedBox(height: 15.0),
                          Text(
                            'Issuer: ${certification['Issuer'] ?? 'N/A'}',
                            style: const TextStyle(fontSize: 16.0),
                          ),
                          const SizedBox(height: 15.0),
                          Text(
                            'Description: ${certification['Description'] ?? 'N/A'}',
                            style: const TextStyle(fontSize: 16.0),
                          ),
                          const SizedBox(height: 15.0),
                          Text(
                            'CertificationAcquireDate: ${certification['CertificationAcquireDate'] ?? 'N/A'}',
                            style: const TextStyle(fontSize: 16.0),
                          ),
                          Row(
                            children: [
                              Checkbox(
                                value: _isPublicList[index],
                                onChanged: (bool? value) {
                                  setState(() {
                                    _isPublicList[index] = value ?? false;
                                  });
                                  // Update public status
                                  _updatePublicStatus(index);
                                },
                              ),
                              const Text('Public'),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                ),
    );
  }
}
