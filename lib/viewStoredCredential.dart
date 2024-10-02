import 'package:firstly/services/auth/MSSQLAuthProvider.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:developer' as devtools show log;

class ViewStoredCredentialScreen extends StatefulWidget {
  const ViewStoredCredentialScreen({super.key});

  @override
  _ViewStoredCredentialScreenState createState() =>
      _ViewStoredCredentialScreenState();
}

class _ViewStoredCredentialScreenState
    extends State<ViewStoredCredentialScreen> {
  List<dynamic> storedCredentials = [];
  bool isLoading = false;
  String? noDataMessage;

  Future<void> fetchStoredCredentials() async {
    setState(() {
      isLoading = true;
      noDataMessage = null;
    });

    final MSSQLAuthProvider _authProvider = MSSQLAuthProvider();
    await _authProvider.initialize();
    final user = _authProvider.currentUser;

    if (user != null) {
      try {
        devtools.log("Fetching stored credentials... " + user.email);
        final response = await http.post(
          Uri.parse('http://172.16.20.114:4000/api/receiveExistedCredential'),
          headers: {
            'Content-Type': 'application/json',
          },
          body: json.encode({'holder': user.email}),
        );

        if (response.statusCode == 200) {
          devtools.log("Successfully fetched stored credentials.");
          final data = json.decode(response.body);
          setState(() {
            storedCredentials = data['credentials'] ?? [];
            isLoading = false;
          });
        } else if (response.statusCode == 201) {
          setState(() {
            isLoading = false;
            noDataMessage = "No credential offers found.";
          });
        } else {
          setState(() {
            isLoading = false;
            noDataMessage = "Error fetching credentials.";
          });
          devtools.log('Error fetching credentials: ${response.body}');
        }
      } catch (error) {
        setState(() {
          isLoading = false;
          noDataMessage = "Error fetching data.";
        });
        devtools.log('Error occurred: $error');
      }
    } else {
      setState(() {
        isLoading = false;
        noDataMessage = "User not found.";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        centerTitle: true,
        elevation: 0,
        title: Text('View Stored Credentials',
            style: AppWidget.headlineTextFieldStyle()),
      ),
      body: Center(
        child: isLoading
            ? const CircularProgressIndicator()
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 20),
                  const Text(
                    'Your Stored Credential Information',
                    style: TextStyle(fontSize: 18, color: Colors.black),
                  ),
                  const SizedBox(height: 20),
                  noDataMessage != null
                      ? Text(
                          noDataMessage!,
                          style:
                              const TextStyle(fontSize: 16, color: Colors.red),
                        )
                      : storedCredentials.isEmpty
                          ? ElevatedButton(
                              onPressed: fetchStoredCredentials,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF171B63),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 60.0, vertical: 15.0),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10.0),
                                ),
                              ),
                              child: const Text(
                                'Fetch Stored Credentials',
                                style: TextStyle(
                                    color: Colors.white, fontSize: 15.0),
                              ),
                            )
                          : Expanded(
                              child: ListView.builder(
                                itemCount: storedCredentials.length,
                                itemBuilder: (context, index) {
                                  final credential = storedCredentials[index];
                                  return Card(
                                    margin: const EdgeInsets.symmetric(
                                        vertical: 8.0, horizontal: 16.0),
                                    child: ListTile(
                                      title: Text(
                                          'Title: ${credential['attrs']['did']}'), // Updated line
                                      subtitle: Text(
                                        'Description:\n${credential['attrs']['description']}',
                                      ),
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

class AppWidget {
  static TextStyle headlineTextFieldStyle() {
    return const TextStyle(
        color: Color(0xFF171B63), fontSize: 20.0, fontWeight: FontWeight.bold);
  }

  static TextStyle semiBoldTextFieldStyle() {
    return const TextStyle(
        color: Color(0xFF171B63), fontSize: 16.0, fontWeight: FontWeight.w600);
  }
}
