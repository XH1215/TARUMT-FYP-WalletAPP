import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class GenerateQRPage extends StatefulWidget {
  @override
  _GenerateQRPageState createState() => _GenerateQRPageState();
}

class _GenerateQRPageState extends State<GenerateQRPage> {
  List<dynamic> qrCodes = [];
  bool isLoading = false;
  String userID = ""; // Fetch the userID from the DB when initializing the page

  @override
  void initState() {
    super.initState();
    fetchUserID();
    fetchExistingQRCodes();
  }

  // Fetch userID from the server or local DB
  Future<void> fetchUserID() async {
    // Replace with your API endpoint to fetch userID
    final response = await http.get(Uri.parse('http://10.0.2.2:3000/api/getUserID'));
    if (response.statusCode == 200) {
      setState(() {
        userID = json.decode(response.body)['userID'];
      });
    } else {
      // Handle error
      print('Error fetching user ID');
    }
  }

  // Fetch existing QR codes for the user
  Future<void> fetchExistingQRCodes() async {
    setState(() {
      isLoading = true;
    });

    final response = await http.get(Uri.parse('http://10.0.2.2:3000/api/fetchQRCodesByUserId?accountID=$userID'));

    if (response.statusCode == 200) {
      setState(() {
        qrCodes = json.decode(response.body)['qrCodes'];
        isLoading = false;
      });
    } else {
      setState(() {
        isLoading = false;
      });
      // Handle error
      print('Error fetching QR codes');
    }
  }

  // Generate a new QR code
  Future<void> generateQRCode() async {
    // Replace with your API endpoint to generate QR
    final response = await http.post(
      Uri.parse('http://10.0.2.2:3000/api/generateQRCode'),
      body: json.encode({'userID': userID}),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 201) {
      // QR generated successfully
      fetchExistingQRCodes(); // Refresh the list of existing QR codes
    } else {
      // Handle error
      print('Error generating QR code');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Generate QR'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ElevatedButton(
              onPressed: () {
                generateQRCode();
              },
              child: const Text('Generate QR'),
            ),
            const SizedBox(height: 20),
            const Text('Existing QR Codes:'),
            const SizedBox(height: 10),
            isLoading
                ? const CircularProgressIndicator()
                : qrCodes.isEmpty
                    ? const Text('No QR codes available')
                    : Expanded(
                        child: ListView.builder(
                          itemCount: qrCodes.length,
                          itemBuilder: (context, index) {
                            final qrCode = qrCodes[index];
                            return ListTile(
                              title: Text('QR Code ${index + 1}'),
                              subtitle: Text('Expires on: ${qrCode['expireDate']}'),
                              leading: Image.memory(
                                base64Decode(qrCode['qrCodeImage']),
                                width: 50,
                                height: 50,
                              ),
                            );
                          },
                        ),
                      ),
          ],
        ),
      ),
    );
  }
}
