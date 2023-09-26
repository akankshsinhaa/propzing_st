import 'package:flutter/material.dart';
import 'package:otp_send_ver/screens/verify_otp_screen.dart';

class OTPScreen extends StatefulWidget {
  @override
  _OTPScreenState createState() => _OTPScreenState();
}

class _OTPScreenState extends State<OTPScreen> {
  String phoneNumber = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Phone OTP App'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              keyboardType: TextInputType.phone,
              onChanged: (value) {
                setState(() {
                  phoneNumber = value;
                });
              },
              decoration: InputDecoration(
                hintText: 'Enter your phone number',
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Send OTP logic goes here
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (_) => VerifyOTPScreen(phoneNumber: phoneNumber),
                ));
              },
              child: Text('Send OTP'),
            ),
          ],
        ),
      ),
    );
  }
}
