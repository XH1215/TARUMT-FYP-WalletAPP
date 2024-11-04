/*
A Collaborative Creation:
CHIN KAH FUI
CHIN XUAN HONG
OLIVIA HUANG SI HAN
LIM CHU QING
*/

import 'package:firstly/services/auth/MSSQLAuthProvider.dart';
import 'package:firstly/services/auth/auth_exception.dart';
import 'package:firstly/show_error_dialog.dart';
import 'package:flutter/material.dart';

import 'dart:developer' as devtools show log;


class ChangePasswdView extends StatefulWidget {
  const ChangePasswdView({super.key});

  @override
  State<ChangePasswdView> createState() => _ChangePasswdViewState();
}

class _ChangePasswdViewState extends State<ChangePasswdView> {
  late final TextEditingController _oldPasswordController;
  late final TextEditingController _newPasswordController;
  late final TextEditingController _confirmPasswordController;

  final MSSQLAuthProvider _authProvider = MSSQLAuthProvider();

  bool _isOldPasswordVisible = false;
  bool _isNewPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;

  @override
  void initState() {
    super.initState();
    _oldPasswordController = TextEditingController();
    _newPasswordController = TextEditingController();
    _confirmPasswordController = TextEditingController();
    devtools.log("ChangePasswdView - initState called");
  }

  @override
  void dispose() {
    devtools.log("ChangePasswdView - dispose called");
    _oldPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  bool _isValidPassword(String password) {
    if (password.length < 8) {
      return false;
    }
    final RegExp passwordRegex =
        RegExp(r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@_$!%*?&#]).{8,}$');
    return passwordRegex.hasMatch(password);
  }

  Future<void> _changePassword() async {
    final oldPassword = _oldPasswordController.text;
    final newPassword = _newPasswordController.text;
    final confirmPassword = _confirmPasswordController.text;

    if (newPassword != confirmPassword) {
      await showErrorDialog(context, 'New passwords do not match');
      return;
    }

    if (!_isValidPassword(newPassword)) {
      await showErrorDialog(context,
          'Password must be at least 8 characters, contain a symbol, one uppercase letter, and one lowercase letter');
      return;
    }

    try {
      await _authProvider.initialize();

      final user = _authProvider.currentUser;
      if (user == null) {
        await showErrorDialog(context, 'User not logged in');
        return;
      }

      devtools.log("Attempting to change password for ${user.email}");

      final isValid = await _authProvider.verifyPassword(
        email: user.email,
        password: oldPassword,
      );

      if (!isValid) {
        devtools.log('Old password is incorrect');
        await showErrorDialog(context, 'Old password is incorrect');
        return;
      }

      await _authProvider.changePassword(
        email: user.email,
        oldPassword: oldPassword,
        newPassword: newPassword,
      );

      devtools.log('Password changed successfully');
      await showErrorDialog(context, 'Password changed successfully');
      Navigator.of(context).pop();
    } on GenericAuthException {
      await showErrorDialog(context, 'Password change failed');
    }
  }

  @override
  Widget build(BuildContext context) {
    devtools.log("Building ChangePasswdView Widget");
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
        title: Padding(
          padding: const EdgeInsets.only(bottom: 10.0),
          child: Text(
            'Change Password',
            style: AppWidget.headlineTextFieldStyle(),
          ),
        ),
      ),
      body: Container(
        padding: const EdgeInsets.only(top: 20.0),
        alignment: Alignment.topCenter,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            _buildTextField(
              controller: _oldPasswordController,
              labelText: 'Old Password',
              icon: Icons.lock_outline,
              isPassword: true,
              isVisible: _isOldPasswordVisible,
              toggleVisibility: () {
                setState(() {
                  _isOldPasswordVisible = !_isOldPasswordVisible;
                });
              },
            ),
            const SizedBox(height: 20.0),
            _buildTextField(
              controller: _newPasswordController,
              labelText: 'New Password',
              icon: Icons.lock_outline,
              isPassword: true,
              isVisible: _isNewPasswordVisible,
              toggleVisibility: () {
                setState(() {
                  _isNewPasswordVisible = !_isNewPasswordVisible;
                });
              },
            ),
            const SizedBox(height: 20.0),
            _buildTextField(
              controller: _confirmPasswordController,
              labelText: 'Confirm Password',
              icon: Icons.lock_outline,
              isPassword: true,
              isVisible: _isConfirmPasswordVisible,
              toggleVisibility: () {
                setState(() {
                  _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
                });
              },
            ),
            const SizedBox(height: 20.0),
            _buildButton('Save', Icons.save_outlined, _changePassword),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String labelText,
    required IconData icon,
    required bool isPassword,
    required bool isVisible,
    required VoidCallback toggleVisibility,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: TextField(
        controller: controller,
        obscureText: isPassword && !isVisible,
        style: const TextStyle(fontSize: 14),
        decoration: InputDecoration(
          labelText: labelText,
          prefixIcon: Icon(icon),
          suffixIcon: isPassword
              ? IconButton(
                  icon: Icon(
                    isVisible ? Icons.visibility : Icons.visibility_off,
                  ),
                  onPressed: toggleVisibility,
                )
              : null,
          border: const OutlineInputBorder(),
        ),
        keyboardType: TextInputType.visiblePassword,
        enableSuggestions: false,
        autocorrect: false,
      ),
    );
  }

  Widget _buildButton(String text, IconData icon, VoidCallback onPressed) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF171B63),
          padding: const EdgeInsets.symmetric(horizontal: 60.0, vertical: 15.0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
        ),
        onPressed: onPressed,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Expanded(
              child: Text(
                text,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 15.0,
                ),
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
