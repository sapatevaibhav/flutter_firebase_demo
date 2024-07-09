// ignore_for_file: use_build_context_synchronously

import 'dart:async';
import 'dart:developer';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_firebase_demo/home.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';

class ProfilePage extends StatefulWidget {
  final String uid;
  const ProfilePage({Key? key, required this.uid}) : super(key: key);

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController ageController = TextEditingController();
  File? profilePic;
  bool isNameValid = true;

  void saveUser() async {
    String name = nameController.text.trim();
    String email = emailController.text.trim();
    String ageStr = ageController.text.trim();
    int? age = int.tryParse(ageStr);

    if (name.isEmpty) {
      setState(() {
        isNameValid = false;
      });
      return;
    }

    String? downloadUrl;
    if (profilePic != null) {
      UploadTask uploadTask = FirebaseStorage.instance
          .ref()
          .child("profilePictures")
          .child(const Uuid().v1())
          .putFile(profilePic!);

      StreamSubscription streamSubscription =
          uploadTask.snapshotEvents.listen((snapshot) {
        double percentage =
            snapshot.bytesTransferred / snapshot.totalBytes * 100;
        log(percentage.toString());
      });

      TaskSnapshot taskSnapshot = await uploadTask;
      downloadUrl = await taskSnapshot.ref.getDownloadURL();
      streamSubscription.cancel();
    }

    Map<String, dynamic> userData = {
      "name": name,
      "age": age,
      "email": email,
      "profileImage": downloadUrl,
    };

    FirebaseFirestore.instance.collection("users").doc(widget.uid).set(userData);

    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const HomeScreen()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('प्रोफाइल माहिती'),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
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
              const SizedBox(height: 16),
              TextField(
                controller: nameController,
                decoration: InputDecoration(
                  labelText: "नाव",
                  border: const OutlineInputBorder(),
                  errorText: isNameValid ? null : "नाव आवश्यक आहे",
                ),
                onChanged: (value) {
                  if (value.trim().isEmpty) {
                    setState(() {
                      isNameValid = false;
                    });
                  } else {
                    setState(() {
                      isNameValid = true;
                    });
                  }
                },
              ),
              const SizedBox(height: 16),
              TextField(
                controller: emailController,
                decoration: const InputDecoration(
                  labelText: "ईमेल (पर्यायी)",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: ageController,
                decoration: const InputDecoration(
                  labelText: "वय (पर्यायी)",
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: saveUser,
                child: const Text("जतन करा"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
