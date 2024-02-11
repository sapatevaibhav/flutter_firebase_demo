// ignore_for_file: use_build_context_synchronously

import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_firebase_demo/home.dart';
import 'package:flutter_firebase_demo/phone_auth/otp_page.dart';

class PhoneLoginPage extends StatefulWidget {
  const PhoneLoginPage({super.key});

  @override
  State<PhoneLoginPage> createState() => _PhoneLoginPageState();
}

class _PhoneLoginPageState extends State<PhoneLoginPage> {
  TextEditingController phoneController = TextEditingController();

  void sendOTP() async {
    String phone = "+91${phoneController.text.trim()}";
    if (phone == "") {
      log("Enter the details");
    } else {
      try {
        await FirebaseAuth.instance.verifyPhoneNumber(
          phoneNumber: phone,
          codeSent: (verificationId, resendToken) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => OTPPage(
                  verificationId: verificationId,
                ),
              ),
            );
          },
          verificationCompleted: (credential) {},
          verificationFailed: (ex) {
            log(ex.code.toString());
          },
          codeAutoRetrievalTimeout: (verificationId) {},
          timeout: const Duration(seconds: 30),
        );
      } on FirebaseAuthException catch (e) {
        log(e.code.toString());
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            TextField(
              controller: phoneController,
              decoration: const InputDecoration(
                labelText: 'Phone',
              ),
            ),
            const SizedBox(height: 16.0),

            const SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () {
                sendOTP();
              },
              child: const Text('Send OTP'),
            ),
            // const SizedBox(height: 16.0),
            // TextButton(
            //   onPressed: () {
            //     Navigator.push(
            //       context,
            //       MaterialPageRoute(builder: (context) => const OTPPage()),
            //     );
            //   },
            //   child: const Text('Create an account'),
            // ),
          ],
        ),
      ),
    );
  }
}
