// ignore_for_file: use_build_context_synchronously

import 'dart:developer';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_firebase_demo/phone_auth/phone_login.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Some TextEditingCOntrolers to store respected data
  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController ageController = TextEditingController();
  File? profilePic;

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
    String ageAtr = ageController.text.toString();
    int? age = int.tryParse(ageAtr);

    if (name != "" && email != "" && profilePic != null) {
      UploadTask uploadTask = FirebaseStorage.instance
          .ref()
          .child("profilePictures")
          .child(const Uuid().v1())
          .putFile(profilePic!);

      TaskSnapshot taskSnapshot = await uploadTask;
      String downloadUrl = await taskSnapshot.ref.getDownloadURL();

      Map<String, dynamic> userData = {
        "name": name,
        "age": age,
        "email": email,
        "profileIamge": downloadUrl,
        "sampleArray": [
          name,
          age,
          email,
        ],
      };
      FirebaseFirestore instance = FirebaseFirestore.instance;
      instance.collection("users").add(userData
          // {
          // "name": name,
          // "email": email,
          // "age": age,
          // },
          );
      nameController.clear();
      emailController.clear();
      ageController.clear();
      setState(() {
        profilePic = null;
      });
    } else {
      log("Data cannot be empty");
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
              CupertinoButton(
                onPressed: () async {
                  XFile? selectedImage = await ImagePicker().pickImage(
                    source: ImageSource.gallery,
                  );
                  if (selectedImage != null) {
                    File convertedImage = File(selectedImage.path);
                    setState(() {
                      profilePic = convertedImage;
                    });

                    log("Image Selected");
                  } else {
                    log("Image not selected");
                  }
                },
                child: CircleAvatar(
                  radius: 50,
                  backgroundImage:
                      (profilePic != null) ? FileImage(profilePic!) : null,
                  backgroundColor: Colors.grey,
                ),
              ),
              TextField(
                decoration: const InputDecoration(
                  hintText: "Name",
                ),
                controller: nameController,
              ),
              const SizedBox(
                height: 10,
              ),
              TextField(
                decoration: const InputDecoration(
                  hintText: "Email",
                ),
                controller: emailController,
              ),
              const SizedBox(
                height: 10,
              ),
              TextField(
                decoration: const InputDecoration(
                  hintText: "Age",
                ),
                controller: ageController,
              ),
              const SizedBox(
                height: 20,
              ),
              ElevatedButton(
                onPressed: () {
                  saveUser();
                },
                child: const Text("Save"),
              ),
              StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection("users")
                      // .orderBy(
                      //   "age",
                      //   descending: true,
                      // )
                      .
                      //where(
                      // "age",
                      // whereNotIn: [
                      //   22,
                      // ],
                      // )
                      snapshots(),
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
                                leading: CircleAvatar(
                                  backgroundImage:NetworkImage( userMap["profileIamge"]),
                                  backgroundColor: Colors.grey,
                                ),
                                title: Text(
                                  userMap["name"] + " (${userMap["age"]})",
                                ),
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
