import 'package:firstly/services/auth/MSSQLAuthProvider.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:developer' as devtools show log;

class FetchConfirmation extends StatefulWidget {
  const FetchConfirmation({super.key});

  @override
  _FetchConfirmationState createState() => _FetchConfirmationState();
}

class _FetchConfirmationState extends State<FetchConfirmation> {
  List<dynamic> credentials = [];
  bool isLoading = false;
  String? noDataMessage;
  Future<void> fetchCredentials() async {
    setState(() {
      isLoading = true;
      noDataMessage = null;
    });

    final MSSQLAuthProvider _authProvider = MSSQLAuthProvider();
    await _authProvider.initialize();
    final user = _authProvider.currentUser;

    if (user != null) {
      try {
        devtools.log("Step1: Initiating getWalletData call...");

        // Step 1: Call getWalletData API
        final walletResponse = await http.post(
          Uri.parse('http://10.0.2.2:3000/api/getWalletData'),
          headers: {
            'Content-Type': 'application/json',
          },
          body: json.encode({'email': user.email}),
        );

        if (walletResponse.statusCode == 200) {
          devtools.log("Step1.1: getWalletData successful.");

          final walletData = json.decode(walletResponse.body);
          devtools.log("Step1.2: Wallet data decoded.");
          devtools.log('Wallet Data: ${walletData.toString()}');

          // Ensure 'wallet' exists and then extract 'wallet_id'
          if (walletData.containsKey('wallet') &&
              walletData['wallet'].containsKey('wallet_id')) {
            final String walletID =
                walletData['wallet']['wallet_id'].toString();
            devtools.log("Wallet ID: $walletID");

            // Step 2: Call getAuthToken API using the retrieved walletID
            devtools.log("Step2: Initiating getAuthToken call...");

            final tokenResponse = await http.post(
              Uri.parse('http://10.0.2.2:3000/api/getAuthToken'),
              headers: {
                'Content-Type': 'application/json',
              },
              body: json.encode({'walletID': walletID}),
            );

            if (tokenResponse.statusCode == 200) {
              final tokenData = json.decode(tokenResponse.body);
              final authToken = tokenData['token'];
              devtools.log("Step2: Auth token received successfully.");

              // Step 3: Call fetchCredentials API (if needed)
              devtools.log("Step3: Fetching credentials using authToken...");

              final credentialsResponse = await http.post(
                Uri.parse('http://localhost:3000/api/receiveOffer'),
                headers: {
                  'Content-Type': 'application/json',
                  'Authorization':
                      'Bearer $authToken', // Pass the auth token here
                },
                body: json.encode({'holderEmail': user.email}),
              );

              if (credentialsResponse.statusCode == 200) {
                final data = json.decode(credentialsResponse.body);
                setState(() {
                  credentials = data['credentials'] ?? [];
                  isLoading = false;
                });
                devtools.log("Step3: Credentials fetched successfully.");
              } else {
                setState(() {
                  isLoading = false;
                  noDataMessage = "Error fetching credentials.";
                });
                devtools.log(
                    'Error fetching credentials: ${credentialsResponse.body}');
              }
            } else {
              setState(() {
                isLoading = false;
                noDataMessage = "Error retrieving auth token.";
              });
              devtools
                  .log('Error retrieving auth token: ${tokenResponse.body}');
            }
          } else {
            setState(() {
              isLoading = false;
              noDataMessage = "Invalid wallet data structure.";
            });
            devtools
                .log('Invalid wallet data structure: ${walletData.toString()}');
          }
        } else {
          setState(() {
            isLoading = false;
            noDataMessage = "Error fetching wallet data.";
          });
          devtools.log('Error fetching wallet data: ${walletResponse.body}');
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

  Future<void> storeCredential(String credentialId) async {
    // Logic to store the credential
    print('Storing credential with ID: $credentialId');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        centerTitle: true,
        backgroundColor: const Color(0xFF171B63),
        title: const Text(
          'Confirm Credentials',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: Center(
        child: isLoading
            ? const CircularProgressIndicator()
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 20),
                  const Text(
                    'Your Credential Information',
                    style: TextStyle(fontSize: 18, color: Colors.black),
                  ),
                  const SizedBox(height: 20),
                  noDataMessage != null
                      ? Text(
                          noDataMessage!,
                          style:
                              const TextStyle(fontSize: 16, color: Colors.red),
                        )
                      : credentials.isEmpty
                          ? ElevatedButton(
                              onPressed: fetchCredentials,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF171B63),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 60.0, vertical: 15.0),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10.0),
                                ),
                              ),
                              child: const Text(
                                'Fetch Credentials',
                                style: TextStyle(
                                    color: Colors.white, fontSize: 15.0),
                              ),
                            )
                          : Expanded(
                              child: ListView.builder(
                                itemCount: credentials.length,
                                itemBuilder: (context, index) {
                                  final credential = credentials[index];
                                  return Card(
                                    margin: const EdgeInsets.symmetric(
                                        vertical: 8.0, horizontal: 16.0),
                                    child: ListTile(
                                      title: Text(
                                          'Title: ${credential['attrs']['did']}'), // Updated line
                                      subtitle: Text(
                                        'Description:\n${credential['attrs']['description']}',
                                      ),
                                      trailing: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          ElevatedButton(
                                            onPressed: () {
                                              storeCredential(credential['id']);
                                              print(
                                                  'Received credential: ${credential['referent']}');
                                            },
                                            child: const Text('Receive'),
                                          ),
                                          const SizedBox(width: 8.0),
                                          ElevatedButton(
                                            onPressed: () {
                                              print(
                                                  'Denied credential: ${credential['referent']}');
                                            },
                                            child: const Text('Deny'),
                                          ),
                                        ],
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
