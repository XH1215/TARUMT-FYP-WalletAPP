import 'package:firstly/services/auth/MSSQLAuthProvider.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:developer' as devtools show log;

class ConfirmationScreen extends StatefulWidget {
  const ConfirmationScreen({super.key});

  @override
  _ConfirmationScreenState createState() => _ConfirmationScreenState();
}

class _ConfirmationScreenState extends State<ConfirmationScreen> {
  List<dynamic> credentials = [];
  bool isLoading = false;
  String? noDataMessage;
  String? authToken; // Store authToken globally after fetching

  Future<void> fetchCredentials() async {
    setState(() {
      isLoading = true;
      noDataMessage = null;
    });

    final MSSQLAuthProvider authProvider = MSSQLAuthProvider();
    await authProvider.initialize();
    final user = authProvider.currentUser;

    if (user != null) {
      try {
        devtools.log("Step1: Initiating getWalletData call...");

        // Step 1: Call getWalletData API
        final walletResponse = await http.post(
          Uri.parse('http://172.16.20.168:3000/api/getWalletData'),
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
              Uri.parse('http://172.16.20.168:3000/api/getAuthToken'),
              headers: {
                'Content-Type': 'application/json',
              },
              body: json.encode({'walletID': walletID}),
            );

            if (tokenResponse.statusCode == 200) {
              final tokenData = json.decode(tokenResponse.body);
              authToken = tokenData['token']; // Store the token globally
              devtools.log("Step2: Auth token received successfully.");

              // Step 3: Call fetchCredentials API (if needed)
              devtools.log("Step3: Fetching credentials using authToken...");

              final credentialsResponse = await http.post(
                Uri.parse('http://172.16.20.168:3000/api/receiveOffer'),
                headers: {
                  'Content-Type': 'application/json',
                  'Authorization':
                      'Bearer $authToken', // Pass the auth token here
                },
                body: json.encode({'holder': user.email}),
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
                  noDataMessage = "No Pending Credentials.";
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

// Function to call storeCredential and saveCVCertification APIs
  Future<void> storeCredential(Map<String, dynamic> credential) async {
    if (authToken == null) {
      setState(() {
        noDataMessage = "Auth token not found.";
      });
      return;
    }
    final MSSQLAuthProvider authProvider = MSSQLAuthProvider();
    await authProvider.initialize();
    final user = authProvider.currentUser;
    // Extract necessary fields for saveCVCertification API
    user?.accountID.toString() ?? '0'; // Use the user's accountID
    Map<String, dynamic> credentialData = {
      'accountID': user?.accountID.toString() ?? '0', // The user's account ID
      'CerName': credential['name'] ?? 'N/A', // The name from the credential
      'CerEmail': credential['email'] ?? 'N/A', // The email from the credential
      'CerType': credential['credentialType'] ?? 'N/A', // The credential type
      'CerIssuer': credential['issuerName'] ?? 'N/A', // The issuer name
      'CerDescription': credential['description'] ?? 'N/A', // The description
      'CerAcquiredDate': credential['issueDate'] ?? 'N/A', // The issue date
      'credExId': credential['cred_ex_id'], // Send the credential exchange ID
      'jwtToken': authToken, // The JWT token
    };
    try {
      devtools.log("Calling storeCredential and saveCVCertification API...");
      final response = await http.post(
        Uri.parse('http://172.16.20.168:3000/api/storeCredential'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'credExId': credentialData['credExId'], // The credential exchange ID
          'jwtToken': authToken,
        }),
      );

      if (response.statusCode == 200) {
        devtools.log('Credential stored successfully.');
        final data = json.decode(response.body);
        devtools.log('Store Response: $data');

        setState(() {
          noDataMessage = 'Credential stored successfully.';
        });
        await fetchCredentials();
      } else {
        setState(() {
          noDataMessage = "Failed to store credential.";
        });
        devtools.log('Error storing credential: ${response.body}');
      }
      //------------------------------------------
      // Step 1: Call saveCVCertification API
      final saveToDB = await http.post(
        Uri.parse('http://172.16.20.168:3000/api/saveCVCertification'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode(credentialData),
      );

      if (saveToDB.statusCode == 200) {
        devtools.log('Certification saved successfully.');
        final saveData = json.decode(saveToDB.body);
        devtools.log('Save Response: $saveData');
      } else {
        devtools.log('Save Certification Error. Please Try Again');
        final saveData = json.decode(saveToDB.body);
        devtools.log("\nFail to Save\nResponse: ${saveData['message']}");
        noDataMessage = "Failed to save certification.";
        return;
      }

      // Step 2: Call storeCredential API to accept the credential
    } catch (error) {
      setState(() {
        noDataMessage = "Error occurred during storing credential.";
      });
      devtools.log('Error storing credential: $error');
    }
  }

  // Function to call deleteCredential API using POST method
  Future<void> deleteCredential(String credExId) async {
    if (authToken == null) {
      setState(() {
        noDataMessage = "Auth token not found.";
      });
      return;
    }

    try {
      devtools.log("Calling deleteCredential API using POST... \n$authToken");

      // Call the delete API with POST method
      final response = await http.post(
        Uri.parse('http://172.16.20.168:3000/api/deleteCredential'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode({'credExId': credExId, 'jwtToken': authToken}),
      );

      if (response.statusCode == 200) {
        devtools.log('Credential deleted successfully.');
        final data = json.decode(response.body);
        devtools.log('Delete Response: $data');

        setState(() {
          noDataMessage = 'Credential deleted successfully.';
        });

        // Refresh the page by fetching updated credentials
        await fetchCredentials();
      } else {
        setState(() {
          noDataMessage = "Failed to delete credential.";
        });
        devtools.log('Error deleting credential: ${response.body}');
      }
    } catch (error) {
      setState(() {
        noDataMessage = "Error occurred during deleting credential.";
      });
      devtools.log('Error deleting credential: $error');
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
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Pending Credentials',
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
                                        'Title: ${credential['did'] ?? 'N/A'}', // Using the 'did' key from the credential directly
                                      ),
                                      subtitle: Text(
                                        'Description:\n${credential['description'] ?? 'N/A'}', // Using the 'description' key from the credential directly
                                      ),
                                      trailing: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          ElevatedButton(
                                            onPressed: () {
                                              devtools.log(
                                                  'Received credential: ${credential['cred_ex_id']}');
                                              storeCredential(
                                                  credential); // Pass the entire credential object
                                            },
                                            child: const Text('Receive'),
                                          ),
                                          const SizedBox(width: 8.0),
                                          ElevatedButton(
                                            onPressed: () {
                                              devtools.log(
                                                  'Denied credential: ${credential['cred_ex_id']}');
                                              deleteCredential(credential[
                                                  'cred_ex_id']); // Call deleteCredential function
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
