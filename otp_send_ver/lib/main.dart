import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import 'dart:math';
import 'package:flutter_svg/flutter_svg.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primaryColor: Colors.blue,
        hintColor: Colors.blueAccent,
      ),
      home: HomeScreen(),
    );
  }
}

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Propzing'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            SvgPicture.network(
              'https://propzing.com/static/media/logo.36ee5f61be9da07ee3a92413e28e8227.svg',
              height: 120,
            ),
            SizedBox(height: 20),
            Text(
              'Realize now\nDigitize, Manage & Monetize your property on the go.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 20),
            Expanded(
              child: Container(),
            ),
            FloatingActionButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => OtpVerificationScreen(),
                  ),
                );
              },
              child: Icon(Icons.arrow_forward),
            ),
          ],
        ),
      ),
    );
  }
}

class OtpVerificationScreen extends StatefulWidget {
  @override
  _OtpVerificationScreenState createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends State<OtpVerificationScreen> {
  final TextEditingController phoneNumberController = TextEditingController();
  final TextEditingController otpController = TextEditingController();
  String sentOtp = '';
  final supabaseApiKey =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InJmbmJqcHBjd3NodnpoYnBqcWl6Iiwicm9sZSI6ImFub24iLCJpYXQiOjE2OTU1NDEzMzksImV4cCI6MjAxMTExNzMzOX0.yNUpSJg3273oUR0n-yZDS4SZ7GCpHXH0ZSsBITwNywo';
  final supabaseUrl = 'https://rfnbjppcwshvzhbpjqiz.supabase.co';
  final twilioAccountSid = 'ACc1b4f6ab3dc2e0527330a2358d3a1d92';
  final twilioAuthToken = '584dc07b4309d8f9bc65f702ca6c6b59';
  final twilioPhoneNumber = '+13343452930';

  @override
  void dispose() {
    phoneNumberController.dispose();
    otpController.dispose();
    super.dispose();
  }

  String generateOTP() {
    final random = Random();
    return (100000 + random.nextInt(900000)).toString();
  }

  Future<bool> sendOTP(String message, String recipient, String accountSid,
      String authToken, String fromPhoneNumber) async {
    try {
      final response = await http.post(
        Uri.parse(
            'https://api.twilio.com/2010-04-01/Accounts/$accountSid/Messages.json'),
        headers: <String, String>{
          'Authorization':
              'Basic ' + base64Encode(utf8.encode('$accountSid:$authToken')),
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: <String, String>{
          'Body': message,
          'To': recipient,
          'From': fromPhoneNumber,
        },
      );

      if (response.statusCode == 201) {
        return true;
      } else {
        return false;
      }
    } catch (e) {
      print('Error sending OTP: $e');
      return false;
    }
  }

  Future<http.Response?> storeOTPInSupabase(
      String phone, String otp, String apiKey, String supabaseUrl) async {
    try {
      final response = await http.post(
        Uri.parse('$supabaseUrl/rpc/store_otp'),
        headers: <String, String>{
          'apikey': apiKey,
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'phone': phone,
          'otp': otp,
        }),
      );

      return response;
    } catch (e) {
      print('Error storing OTP in Supabase: $e');
      return null;
    }
  }

  void verifyOtp(String enteredOtp) {
    if (sentOtp == enteredOtp) {
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: Text('Success'),
          content: Text('OTP Verified Successfully!'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('OK'),
            ),
          ],
        ),
      );
    } else {
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: Text('Error'),
          content: Text('Invalid OTP. Please try again.'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('OK'),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('OTP Verification'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            TextField(
              controller: phoneNumberController,
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(
                hintText: 'Enter Phone Number',
              ),
            ),
            SizedBox(height: 20),
            TextField(
              controller: otpController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                hintText: 'Enter OTP',
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                final phoneNumber = phoneNumberController.text.trim();
                final otp = generateOTP();
                final message = 'Your OTP is: $otp';

                final sentSuccessfully = await sendOTP(
                  message,
                  phoneNumber,
                  twilioAccountSid,
                  twilioAuthToken,
                  twilioPhoneNumber,
                );

                if (sentSuccessfully) {
                  print('OTP sent successfully to $phoneNumber');
                  sentOtp = otp;
                  final supabaseResponse = await storeOTPInSupabase(
                    phoneNumber,
                    otp,
                    supabaseApiKey,
                    supabaseUrl,
                  );

                  if (supabaseResponse?.statusCode == 200) {
                    print('OTP stored in Supabase successfully');
                  } else {
                    print('Failed to store OTP in Supabase');
                  }
                } else {
                  print('Failed to send OTP');
                }
              },
              child: Text('Send OTP'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                final enteredOtp = otpController.text.trim();
                verifyOtp(enteredOtp);
              },
              child: Text('Verify OTP'),
            ),
            Expanded(
              child: Container(),
            ),
          ],
        ),
      ),
    );
  }
}
