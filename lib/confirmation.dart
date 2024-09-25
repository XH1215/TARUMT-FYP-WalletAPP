import 'package:flutter/material.dart';

class Credential extends StatefulWidget {
  const Credential({super.key});

  @override
  _CredentialState createState() => _CredentialState();
}

class _CredentialState extends State<Credential> {
  // Track the expanded state of the row
  bool isExpanded = false;

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
            'Confirmation',
            style: TextStyle(
              color: Colors.white,
            ),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 20.0),
        child: Center(
          child: ListView(
            children: [
              GestureDetector(
                onTap: () {
                  setState(() {
                    isExpanded = !isExpanded; // Toggle expanded state
                  });
                },
                child: Container(
                  constraints: BoxConstraints(
                    maxWidth: MediaQuery.of(context).size.width * 0.7, // Adjusted to 80% for smaller width
                  ),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Colors.grey,
                      width: 2.0,
                    ),
                    borderRadius: BorderRadius.circular(10.0),
                    color: Colors.transparent,
                  ),
                  child: Column(
                    children: [
                      SizedBox(
                        height: 100.0,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(10.0),
                              child: Icon(
                                Icons.verified,
                                size: 50.0,
                                color: const Color(0xFF171B63),
                              ),
                            ),
                            const SizedBox(width: 20.0),
                            const Expanded( // Makes text take available space
                              child: Text(
                                'Confirmation for Credential',
                                style: TextStyle(
                                  fontSize: 20.0,
                                  color: Color(0xFF171B63),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (isExpanded) ...[ // Show additional details when expanded
                        Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: Column(
                            children: [
                              const Text(
                                'Details about the credential...',
                                style: TextStyle(fontSize: 16.0),
                              ),
                              const SizedBox(height: 10.0),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                children: [
                                  ElevatedButton(
                                    onPressed: () {
                                      // Handle receive action
                                    },
                                    child: const Text('Receive'),
                                  ),
                                  ElevatedButton(
                                    onPressed: () {
                                      // Handle deny action
                                    },
                                    child: const Text('Deny'),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
