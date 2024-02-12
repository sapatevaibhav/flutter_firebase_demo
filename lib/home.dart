// ignore_for_file: use_build_context_synchronously

import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_firebase_demo/phone_auth/phone_login.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();

  void logout() async {
    await FirebaseAuth.instance.signOut();
    log("sogn out success");
    Navigator.popUntil(context, (route) => route.isFirst);
    Navigator.pushReplacement(context,
        MaterialPageRoute(builder: (context) => const PhoneLoginPage()));
  }

  // void getData() async {
  //   FirebaseFirestore _instance = FirebaseFirestore.instance;
  /////////////////////////////////////////
  /// Fetching data                     ///
  /////////////////////////////////////////

  // QuerySnapshot snapshot =
  //     await FirebaseFirestore.instance.collection("users").get();
  // for (var element in snapshot.docs) {
  //   log(element.data().toString());
  // }
  // DocumentSnapshot documentSnapshot = await FirebaseFirestore.instance
  //     .collection("users")
  //     .doc("8tEPTAarWy5mHMlunYGH")
  //     .get();
  // log(documentSnapshot.data().toString());

  //////////////////////////////////////////
  /// Writing data                       ///
  /////////////////////////////////////////

  // Map<String, dynamic> newUserData = {
  //   "name": "sapaaate",
  //   "email": "sappu@gmail.com"
  // };
  // await _instance.collection("users").add(newUserData); // default unique ID
  // await _instance.collection("users").doc("myID").set(newUserData); // If ID not present creates new one else updates the data.

  //////////////////////////////////////////
  /// Updating data                      ///
  /////////////////////////////////////////

  // await _instance.collection("users").doc("myID").update({"email":"@email.com"});

  //////////////////////////////////////////
  /// Deleting data                      ///
  /////////////////////////////////////////

  // await _instance.collection("users").doc("myID").delete();
  // }

  void saveUser() async {
    String name = nameController.text.toString();
    String email = emailController.text.toString();

    if (name != "" || email != "") {
      FirebaseFirestore instance = FirebaseFirestore.instance;
      instance.collection("users").add({"name": name, "email": email});
      nameController.clear();
      emailController.clear();
    } else {
      log("data cannot be empty");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
        actions: [
          IconButton(
            icon: const Icon(Icons.exit_to_app_outlined),
            onPressed: () {
              logout();
            },
          )
        ],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(15),
          child: Column(
            children: [
              TextField(
                decoration: const InputDecoration(
                  hintText: "Name",
                ),
                controller: nameController,
              ),
              TextField(
                decoration: const InputDecoration(
                  hintText: "Email",
                ),
                controller: emailController,
              ),
              const SizedBox(
                height: 20,
              ),
              ElevatedButton(
                onPressed: () {
                  saveUser();
                },
                child: const Text("data"),
              ),
              StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection("users")
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.active) {
                      if (snapshot.hasData && snapshot.data != null) {
                        return Expanded(
                          child: ListView.builder(
                            itemCount: snapshot.data!.docs.length,
                            itemBuilder: (context, index) {
                              Map<String, dynamic> userMap =
                                  snapshot.data!.docs[index].data()
                                      as Map<String, dynamic>;
                              return ListTile(
                                title: Text(userMap["name"]),
                                subtitle: Text(userMap["email"]),
                                trailing: IconButton(
                                  onPressed: () {
                                    String userId =
                                        snapshot.data!.docs[index].id;
                                    FirebaseFirestore.instance
                                        .collection('users')
                                        .doc(userId)
                                        .delete();
                                  },
                                  icon: const Icon(Icons.delete),
                                ),
                              );
                            },
                          ),
                        );
                      } else {
                        return const Text("No data");
                      }
                    } else {
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    }
                  })
            ],
          ),
        ),
      ),
    );
  }
}
