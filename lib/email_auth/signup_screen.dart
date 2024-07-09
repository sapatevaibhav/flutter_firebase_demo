// import 'dart:developer';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';

// class SignupPage extends StatefulWidget {
//   const SignupPage({super.key});

//   @override
//   State<SignupPage> createState() => _SignupPageState();
// }

// class _SignupPageState extends State<SignupPage> {
//   TextEditingController emailController = TextEditingController();

//   TextEditingController passwordController = TextEditingController();

//   TextEditingController passwordcController = TextEditingController();
//   void createAccount() async {
//     String email = emailController.text.trim();
//     String pass = passwordController.text.trim();
//     String passc = passwordcController.text.trim();

//     if (email == "" || pass == "" || passc == "") {
//       log("Please enter all details");
//     } else if (pass != passc) {
//       log("passwords doesn't match");
//     } else {
//       try {
//         UserCredential userCredential = await FirebaseAuth.instance
//             .createUserWithEmailAndPassword(email: email, password: pass);
//         log("Account creation success");
//         if (userCredential.user != null) {
//           Navigator.pop(context);
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
//         title: const Text('Sign Up'),
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           crossAxisAlignment: CrossAxisAlignment.stretch,
//           children: <Widget>[
//             TextField(
//               controller: emailController,
//               decoration: const InputDecoration(
//                 labelText: 'Email',
//               ),
//             ),
//             const SizedBox(height: 16.0),
//             TextField(
//               controller: passwordController,
//               obscureText: true,
//               decoration: const InputDecoration(
//                 labelText: 'Password',
//               ),
//             ),
//             const SizedBox(height: 16.0),
//             TextField(
//               controller: passwordcController,
//               obscureText: true,
//               decoration: const InputDecoration(
//                 labelText: 'Confirm Password',
//               ),
//             ),
//             const SizedBox(height: 16.0),
//             ElevatedButton(
//               onPressed: () {
//                 createAccount();
//               },
//               child: const Text('Sign Up'),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
