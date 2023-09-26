import 'package:flutter/material.dart';

class VerifyOTPScreen extends StatefulWidget {
  final String phoneNumber;

  VerifyOTPScreen({required this.phoneNumber});

  @override
  _VerifyOTPScreenState createState() => _VerifyOTPScreenState();
}

class _VerifyOTPScreenState extends State<VerifyOTPScreen> {
  String otp = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Verify OTP'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Enter the OTP sent to ${widget.phoneNumber}'),
            TextField(
              keyboardType: TextInputType.number,
              onChanged: (value) {
                setState(() {
                  otp = value;
                });
              },
              decoration: InputDecoration(
                hintText: 'Enter OTP',
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Verify OTP logic goes here
              },
              child: Text('Verify OTP'),
            ),
          ],
        ),
      ),
    );
  }
}
