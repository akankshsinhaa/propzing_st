import 'package:flutter/material.dart';
import 'package:supabase/supabase.dart';
import 'package:twilio_flutter/twilio_flutter.dart';

class PhoneVerificationScreen extends StatefulWidget {
  @override
  _PhoneVerificationScreenState createState() =>
      _PhoneVerificationScreenState();
}

class _PhoneVerificationScreenState extends State<PhoneVerificationScreen> {
  final TextEditingController phoneNumberController = TextEditingController();
  final supabase = SupabaseClient(
    'https://rfnbjppcwshvzhbpjqiz.supabase.co',
    'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InJmbmJqcHBjd3NodnpoYnBqcWl6Iiwicm9sZSI6ImFub24iLCJpYXQiOjE2OTU1NDEzMzksImV4cCI6MjAxMTExNzMzOX0.yNUpSJg3273oUR0n-yZDS4SZ7GCpHXH0ZSsBITwNywo',
  );
  final twilio = TwilioFlutter(
    accountSid: 'ACc1b4f6ab3dc2e0527330a2358d3a1d92',
    authToken: '584dc07b4309d8f9bc65f702ca6c6b59',
    twilioNumber: '+13343452930',
  );

  String verificationCode = '';

  Future<void> sendOTP() async {
    // Generate a random OTP (you may use a proper OTP library)
    final randomOTP = '123456'; // Replace with a real OTP generation method

    // Save the OTP in Supabase or your preferred database
    await supabase.from('users').upsert([
      {
        'phone_number': phoneNumberController.text,
        'otp': randomOTP,
      },
    ]).execute();

    // Send OTP via Twilio
    final message = await twilio.sendSMS(
      toNumber: phoneNumberController.text,
      messageBody: 'Your verification code is: $randomOTP',
    );

    // Store the verification code for later use
    setState(() {
      verificationCode = randomOTP;
    });

    print('OTP sent: ${message}');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Phone Number Verification'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text('Enter your phone number:'),
            TextField(
              controller: phoneNumberController,
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(
                hintText: 'Enter phone number',
              ),
            ),
            ElevatedButton(
              onPressed: sendOTP,
              child: Text('Send OTP'),
            ),
            Text('Verification Code: $verificationCode'),
          ],
        ),
      ),
    );
  }
}
