import 'package:firstly/show_error_dialog.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:developer' as devtools show log;

class AppWidget {
  static TextStyle headlineTextFieldStyle() {
    return const TextStyle(
      color: Color(0xFF171B63),
      fontSize: 20.0,
      fontWeight: FontWeight.bold,
    );
  }

  static TextStyle semiBoldTextFieldStyle() {
    return const TextStyle(
      color: Color(0xFF171B63),
      fontSize: 16.0,
      fontWeight: FontWeight.w600,
    );
  }
}

class SoftSkillInfoPage extends StatefulWidget {
  const SoftSkillInfoPage({super.key});

  @override
  _SoftSkillInfoPageState createState() => _SoftSkillInfoPageState();
}

class _SoftSkillInfoPageState extends State<SoftSkillInfoPage> {
  List<Map<String, dynamic>> _skillEntries = [];
  List<TextEditingController> _softSkillControllers = [];
  List<TextEditingController> _descriptionControllers = [];
  List<bool> _isPublicList = [];
  List<String?> _skillNameErrors = []; //here - Track skill name error messages
  List<String?> _descriptionErrors =
      []; //here - Track description error messages
  List<int> newEntryIndexes = [];

  bool _isEditing = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _initializeSkillEntries();
    _fetchSkillData();
  }

  void _initializeSkillEntries() {
    setState(() {
      _skillEntries.clear();
      _softSkillControllers.clear();
      _descriptionControllers.clear();
      _isPublicList.clear();
      _skillNameErrors.clear();
      _descriptionErrors.clear();
      _addSkillEntry(); // Only add one set of input fields initially
    });
  }

  Future<int?> _getAccountID() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getInt('accountID');
    } catch (e) {
      devtools.log('Error retrieving accountID: $e');
      return null;
    }
  }

  Future<void> _fetchSkillData() async {
    setState(() {
      _isLoading = true;
    });

    final accountID = await _getAccountID();
    if (accountID == null) return;

    try {
      final response = await http.get(
        Uri.parse(
            'http://172.16.20.168:3000/api/getCVSkill?accountID=$accountID'),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);

        if (mounted) {
          setState(() {
            //here
            _skillEntries.clear();
            _softSkillControllers.clear();
            _descriptionControllers.clear();
            _isPublicList.clear();
            _skillNameErrors.clear();
            _descriptionErrors.clear();

            if (data.isNotEmpty) {
              for (var entry in data) {
                //here
                _skillEntries.add(entry);
                _isPublicList.add(entry['isPublic'] ?? true);
                _softSkillControllers
                    .add(TextEditingController(text: entry['SoftHighlight']));
                _descriptionControllers.add(TextEditingController(
                    text: entry['SoftDescription'] ?? ''));
                _skillNameErrors.add(null); // Initialize error tracking
                _descriptionErrors.add(null); // Initialize error tracking
              }
            }
          });
        }
      } else {
        devtools.log(
            'Failed to fetch skill data. Status code: ${response.statusCode}');
      }
    } catch (e) {
      devtools.log('Error fetching skill data: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _addSkillEntry() {
    setState(() {
      _skillEntries.add({
        'SoftID': null,
        'SoftHighlight': '',
        'SoftDescription': '',
        'isPublic': true,
      });
      _softSkillControllers.add(TextEditingController());
      _descriptionControllers.add(TextEditingController());
      _isPublicList.add(true);
      _skillNameErrors.add(null); // Initialize error tracking for the new entry
      _descriptionErrors
          .add(null); // Initialize error tracking for the new entry
    });
  }

  Future<void> _saveSkills() async {
    final accountID = await _getAccountID();
    if (accountID == null) return;
    if (!mounted) return;

    List<Map<String, dynamic>> newSkillEntries = [];
    List<Map<String, dynamic>> existingSkillEntries = [];
    newEntryIndexes.clear(); // Clear any old indexes

    Set<String> skillNamesSet = {};
    bool hasError = false; // Track validation errors

    // Reset errors dynamically
    setState(() {
      _skillNameErrors =
          List.generate(_softSkillControllers.length, (index) => null);
      _descriptionErrors =
          List.generate(_descriptionControllers.length, (index) => null);
    });

    for (int i = 0; i < _skillEntries.length; i++) {
      String currentSkillName =
          _softSkillControllers[i].text.trim().toUpperCase();
      String currentDescription =
          _descriptionControllers[i].text.trim().toUpperCase();

      // Check for duplicate skill names
      if (skillNamesSet.contains(currentSkillName)) {
        setState(() {
          _skillNameErrors[i] = 'Duplicate skill name found.';
        });
        hasError = true;
        break;
      }

      skillNamesSet.add(currentSkillName);

      // Validate fields
      if (currentSkillName.isEmpty) {
        setState(() {
          _skillNameErrors[i] = 'Skill name cannot be empty.';
        });
        hasError = true;
        break;
      }
      if (currentDescription.isEmpty) {
        setState(() {
          _descriptionErrors[i] = 'Description cannot be empty.';
        });
        hasError = true;
        break;
      }

      final entry = {
        'SoftID': _skillEntries[i]['SoftID'],
        'SoftHighlight': currentSkillName,
        'SoftDescription': currentDescription,
        'isPublic': _isPublicList[i],
      };

      if (_skillEntries[i]['SoftID'] == null) {
        newSkillEntries.add(entry);
        newEntryIndexes.add(i); // Track the index of the new entry
      } else {
        existingSkillEntries.add(entry);
      }
    }

    if (hasError) return;

    setState(() {
      _isLoading = true;
    });

    final body = jsonEncode({
      'accountID': accountID,
      'newSkillEntries': newSkillEntries,
      'existingSkillEntries': existingSkillEntries,
    });
    devtools.log("call softskill api");

    try {
      final response = await http.post(
        Uri.parse('http://172.16.20.168:3000/api/saveCVSkill'),
        headers: {'Content-Type': 'application/json'},
        body: body,
      );
      devtools.log(response.statusCode.toString());
      if (!mounted) return;
      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);

        List updatedSkills = responseData['newSkillsWithID'];

        // Make sure updatedSkills and newSkillEntries have the same length before updating
        if (updatedSkills.length == newSkillEntries.length) {
          for (int i = 0; i < newSkillEntries.length; i++) {
            _skillEntries[newEntryIndexes[i]]['SoftID'] =
                updatedSkills[i]['SoftID'];
            devtools.log(
                "Added SoftID to new entry at index: ${newEntryIndexes[i]}");
          }
        } else {
          devtools.log('Error: Mismatch between new skills and updated IDs.');
        }

        devtools.log('Skill entries saved successfully.');
        setState(() {
          _isEditing =
              false; // Only turn off editing mode if save is successful
        });
      } else {
        devtools.log(
            'Failed to save skill entries. Status code: ${response.statusCode}');
        showErrorDialog(context, 'Failed to save skill entries');
      }
    } catch (error) {
      devtools.log('Error saving skill entries: $error');
      showErrorDialog(context, 'Error saving skill entries');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _deleteSkillEntry(int index) async {
    final softID = _skillEntries[index]['SoftID'];
    if (softID != null) {
      try {
        final response = await http.post(
          Uri.parse('http://172.16.20.168:3000/api/deleteCVSkill'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({'SoftID': softID}),
        );
        final response2 = await http.post(
          Uri.parse('http://172.16.20.168:3010/api/deleteCVSkill'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({'SoftID': softID}),
        );
        if (response.statusCode == 200 && response2.statusCode == 200) {
          setState(() {
            _skillEntries.removeAt(index);
            _softSkillControllers.removeAt(index);
            _descriptionControllers.removeAt(index);
            _isPublicList.removeAt(index);
            //here
            _skillNameErrors.removeAt(index);
            _descriptionErrors.removeAt(index);

            if (_skillEntries.isEmpty) {
              _addSkillEntry(); // Ensure at least one entry remains
            }
          });
        } else {
          showErrorDialog(context, 'Failed to delete skill entry');
        }
      } catch (e) {
        showErrorDialog(context, 'Error deleting skill entry: $e');
      }
    } else {
      //here
      setState(() {
        _skillEntries.removeAt(index);
        _softSkillControllers.removeAt(index);
        _descriptionControllers.removeAt(index);
        _isPublicList.removeAt(index);
        _skillNameErrors.removeAt(index);
        _descriptionErrors.removeAt(index);

        if (_skillEntries.isEmpty) {
          _addSkillEntry(); // Ensure at least one entry remains
        }
      });
    }
  }

  void _toggleEditMode() async {
    if (_isEditing) {
      setState(() {
        _isLoading = true;
      });

      try {
        await _saveSkills();
        setState(() {
          _isEditing = true;
        });
      } catch (error) {
        devtools.log('Error saving data: $error');
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    } else {
      setState(() {
        _isEditing = true;
      });
    }
  }

  Widget _buildInputSection(BuildContext context, int index) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10.0),
      padding: const EdgeInsets.all(10.0),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey, width: 2.0),
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Skill Information ${index + 1}",
                  style: const TextStyle(
                    color: Color(0xFF171B63),
                    fontSize: 18.0,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (_isEditing)
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => _deleteSkillEntry(index),
                  ),
              ],
            ),
          ),
          _buildInputField(context, 'Skill Name', _softSkillControllers[index],
              _isEditing, _skillNameErrors[index]),
          const SizedBox(height: 15.0),
          _buildInputField(
              context,
              'Description',
              _descriptionControllers[index],
              _isEditing,
              _descriptionErrors[index]),
          const SizedBox(height: 15.0),
          if (_isEditing)
            Row(
              children: [
                Checkbox(
                  value: _isPublicList[index],
                  onChanged: (bool? value) {
                    setState(() {
                      _isPublicList[index] = value ?? true;
                    });
                  },
                ),
                const Text('Public'),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildInputField(BuildContext context, String labelText,
      TextEditingController controller, bool isEditing, String? errorMessage) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(labelText, style: AppWidget.semiBoldTextFieldStyle()),
        const SizedBox(height: 10.0),
        TextField(
          controller: controller,
          enabled: isEditing,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
          decoration: InputDecoration(
            border:
                OutlineInputBorder(borderRadius: BorderRadius.circular(10.0)),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 15.0, vertical: 15.0),
            errorText: errorMessage, // Show error text under the field
          ),
        ),
      ],
    );
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
        title: Text('Skill Information',
            style: AppWidget.headlineTextFieldStyle()),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(15.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _skillEntries.length,
                    itemBuilder: (context, index) {
                      return _buildInputSection(context, index);
                    },
                  ),
                  const SizedBox(height: 10.0),
                  if (_isEditing)
                    Align(
                      alignment: Alignment.centerRight,
                      child: ElevatedButton(
                        onPressed: _isLoading
                            ? null
                            : () {
                                setState(() {
                                  _addSkillEntry();
                                });
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF171B63),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 40.0, vertical: 15.0),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                        ),
                        child: const Text('Add More Skills',
                            style:
                                TextStyle(color: Colors.white, fontSize: 16.0)),
                      ),
                    ),
                  const SizedBox(height: 20.0),
                ],
              ),
            ),
      bottomNavigationBar: BottomAppBar(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            ElevatedButton(
              onPressed: _isLoading ? null : _toggleEditMode,
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    _isLoading ? Colors.grey : const Color(0xFF171B63),
                padding: const EdgeInsets.symmetric(
                    horizontal: 60.0, vertical: 15.0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
              ),
              child: Text(
                _isEditing ? 'Save' : 'Edit',
                style: const TextStyle(color: Colors.white, fontSize: 15.0),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
