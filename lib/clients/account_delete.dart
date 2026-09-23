import 'dart:convert' as convert;

import 'package:fixsathi/classPack/sessions_file.dart';
import 'package:fixsathi/frontScreen/login_number.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class AccountDeletionScreen extends StatefulWidget {
  final Map<String, dynamic> userData;
  const AccountDeletionScreen({super.key, required this.userData});

  @override
  State<AccountDeletionScreen> createState() => _AccountDeletionScreenState();
}

class _AccountDeletionScreenState extends State<AccountDeletionScreen> {
  final TextEditingController _confirmationController = TextEditingController();
  bool _isDeleteButtonEnabled = false;

  Future<void> deleteID() async {
    if (widget.userData['mobileno'] == 'no') return;
    try {
      var url = Uri.https(SessionUrl().baseUrl, 'home/deleteApp');
      var response = await http.post(
        url,
        body: {
          'mobileno': widget.userData['mobileno'],
          'keyset': 'pass_key@satnam9041110310',
        },
      );
      if (!mounted) return;
      if (response.statusCode == 200) {
        final getres = convert.jsonDecode(response.body);
        return getres;
      }
    } catch (e) {
      debugPrint('Update token error: $e');
    }
  }

  @override
  void dispose() {
    _confirmationController.dispose();
    super.dispose();
  }

  void _validateInput(String value) {
    setState(() {
      // Button tabhi enable hoga jab user exact "DELETE" type karega
      _isDeleteButtonEnabled = value.trim() == "DELETE";
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Delete Account',
          style: TextStyle(color: Colors.black87),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Warning Icon & Header
              Center(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.warning_rounded,
                    size: 60,
                    color: Colors.red.shade700,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              const Center(
                child: Text(
                  'Are you absolutely sure?',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'If you Account delete then all data permanently will be deleted and not reverse account.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade600,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 32),

              // Consequences List
              Text(
                'What delete?:',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade800,
                ),
              ),
              const SizedBox(height: 12),
              _buildBulletPoint('Your profile and personal details.'),
              _buildBulletPoint('Your all purchase history & saved data.'),
              _buildBulletPoint(
                'You will not be able to open an account again using the same number next time.',
              ),
              const SizedBox(height: 32),

              // Confirmation Input
              Text(
                'Confirm & type the "DELETE"',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey.shade700,
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _confirmationController,
                onChanged: _validateInput,
                decoration: InputDecoration(
                  hintText: 'DELETE',
                  hintStyle: TextStyle(color: Colors.grey.shade400),
                  filled: true,
                  fillColor: Colors.grey.shade50,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Colors.red, width: 2),
                  ),
                ),
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(height: 40),

              // Action Buttons
              Row(
                children: [
                  // Cancel Button
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.all(6),
                        side: BorderSide(color: Colors.grey.shade300),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Cancel',
                        style: TextStyle(color: Colors.black87, fontSize: 16),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  // Delete Button
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _isDeleteButtonEnabled
                          ? () {
                              // Yahan apna backend deletion logic add karein
                              _logout(context);
                            }
                          : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red.shade700,
                        foregroundColor: Colors.white,
                        disabledBackgroundColor: Colors.red.shade100,
                        disabledForegroundColor: Colors.white,
                        padding: const EdgeInsets.all(6),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        'Delete',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBulletPoint(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '• ',
            style: TextStyle(
              fontSize: 16,
              color: Colors.red.shade700,
              fontWeight: FontWeight.bold,
            ),
          ),
          Expanded(
            child: Text(
              text,
              style: TextStyle(fontSize: 14, color: Colors.grey.shade700),
            ),
          ),
        ],
      ),
    );
  }

  Future<bool> _logout(BuildContext context) async {
    bool? exitApp = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('LogOut!'),
          content: FittedBox(
            child: Text(
              'Are you sure remove the account.',
              maxLines: 2,
              textAlign: TextAlign.center,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false);
              },
              child: const Text('No'),
            ),
            TextButton(
              onPressed: () {
                deleteID();
                SessionUrl().removeSession();
                SessionUrl().removeUserData();
                SessionUrl().removeUserAcc();
                Navigator.of(context).pop(true);
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(
                    builder: (BuildContext context) =>
                        SelectMobile(title: 'Login'),
                  ),
                );
              },
              child: const Text('Yes'),
            ),
          ],
        );
      },
    );
    return exitApp ?? false;
  }
}
