// // ignore_for_file: use_build_context_synchronously

// import 'dart:developer';

// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_firebase_demo/home.dart';

// class OTPPage extends StatefulWidget {
//   const OTPPage({super.key, required this.verificationId});
//   final String verificationId;
//   @override
//   State<OTPPage> createState() => _OTPPageState();
// }

// class _OTPPageState extends State<OTPPage> {
//   TextEditingController phoneController = TextEditingController();

//   void login() async {
//     String otp = phoneController.text.trim();
//     if (otp == "") {
//       log("Enter the details");
//     } else {
//       PhoneAuthCredential userCredential = PhoneAuthProvider.credential(
//           verificationId: widget.verificationId, smsCode: otp);
//       try {
//         UserCredential credential =
//             await FirebaseAuth.instance.signInWithCredential(userCredential);
//         if (credential.user != null) {
//           log("sign in success");

          // Navigator.popUntil(context, (route) => route.isFirst);
          // Navigator.pushReplacement(context,
          //     MaterialPageRoute(builder: (context) => const HomeScreen()));
//         }
//       } on FirebaseAuthException catch (e) {
//         log(e.code.toString());
//       }
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('OTP'),
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           crossAxisAlignment: CrossAxisAlignment.stretch,
//           children: <Widget>[
//             TextField(
//               maxLength: 6,
//               controller: phoneController,
//               decoration: const InputDecoration(
//                 labelText: 'OTP',
//               ),
//             ),
//             const SizedBox(height: 16.0),
//             const SizedBox(height: 16.0),
//             ElevatedButton(
//               onPressed: () {
//                 login();
//               },
//               child: const Text('Verify'),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
