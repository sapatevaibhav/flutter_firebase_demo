import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_firebase_demo/home_screen.dart';
import 'package:flutter_firebase_demo/pages/profile_page.dart';

class PhoneLoginPage extends StatefulWidget {
  const PhoneLoginPage({Key? key}) : super(key: key);

  @override
  State<PhoneLoginPage> createState() => _PhoneLoginPageState();
}

class _PhoneLoginPageState extends State<PhoneLoginPage> {
  TextEditingController phoneController = TextEditingController();
  TextEditingController otpController = TextEditingController();
  bool isOTPSent = false;
  bool isOTPValid = false;
  String? verificationId;

  void sendOTP() async {
    String phone = "+91${phoneController.text.trim()}";
    if (phone == "+91") {
      log("Enter the details");
    } else {
      try {
        await FirebaseAuth.instance.verifyPhoneNumber(
          phoneNumber: phone,
          codeSent: (verificationId, resendToken) {
            setState(() {
              isOTPSent = true;
              this.verificationId = verificationId;
            });
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

  void verifyOTP() async {
    String otp = otpController.text.trim();
    if (otp.isEmpty || verificationId == null) {
      log("Enter the OTP");
    } else {
      try {
        PhoneAuthCredential credential = PhoneAuthProvider.credential(
          verificationId: verificationId!,
          smsCode: otp,
        );
        UserCredential userCredential =
            await FirebaseAuth.instance.signInWithCredential(credential);
        if (userCredential.user != null) {
          log("sign in success");
          checkProfile(userCredential.user!.uid);
        }
      } on FirebaseAuthException catch (e) {
        log(e.code.toString());
      }
    }
  }

  void checkProfile(String uid) async {
    final userDoc =
        await FirebaseFirestore.instance.collection('users').doc(uid).get();
    if (userDoc.exists) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (context) => HomeScreen(currentUserUid: uid)),
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => ProfilePage(uid: uid)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Container(
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12.0),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  const Center(
                    child: Column(
                      children: [
                        Icon(Icons.person, size: 64, color: Colors.black),
                        SizedBox(height: 8.0),
                        Text(
                          'आपले गाव',
                          style: TextStyle(
                            fontSize: 24.0,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16.0),
                  TextField(
                    controller: phoneController,
                    decoration: const InputDecoration(
                      labelText: 'फोन नंबर',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16.0),
                  ElevatedButton(
                    onPressed: sendOTP,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30.0),
                      ),
                    ),
                    child: const Text('OTP पाठवा'),
                  ),
                  const SizedBox(height: 16.0),
                  if (isOTPSent)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        TextField(
                          controller: otpController,
                          decoration: const InputDecoration(
                            labelText: 'OTP',
                            border: OutlineInputBorder(),
                          ),
                          onChanged: (value) {
                            setState(() {
                              isOTPValid = value.length == 6;
                            });
                          },
                        ),
                        const SizedBox(height: 16.0),
                        ElevatedButton(
                          onPressed: isOTPValid ? verifyOTP : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                isOTPValid ? Colors.black : Colors.grey,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30.0),
                            ),
                          ),
                          child: const Text('लॉगिन करा'),
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

void main() {
  runApp(const MaterialApp(
    home: PhoneLoginPage(),
  ));
}
