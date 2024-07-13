import 'dart:async';
import 'dart:developer';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_firebase_demo/home_screen.dart';
import 'package:flutter_firebase_demo/phone_auth/phone_login.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';

class ProfilePage extends StatefulWidget {
  final String uid;
  const ProfilePage({Key? key, required this.uid}) : super(key: key);

  @override
  ProfilePageState createState() => ProfilePageState();
}

class ProfilePageState extends State<ProfilePage> {
  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController ageController = TextEditingController();
  File? profilePic;
  bool isNameValid = true;
  String? profileImageUrl;

  final AssetImage placeholderImage =
      const AssetImage('assets/images/profile.jpg');

  Future<void> fetchUserData() async {
    try {
      DocumentSnapshot docSnapshot = await FirebaseFirestore.instance
          .collection("users")
          .doc(widget.uid)
          .get();

      if (docSnapshot.exists) {
        Map<String, dynamic> userData =
            docSnapshot.data() as Map<String, dynamic>;
        setState(() {
          nameController.text = userData['name'] ?? '';
          emailController.text = userData['email'] ?? '';
          ageController.text = userData['age']?.toString() ?? '';
          profileImageUrl = userData['profileImage'];
        });
      }
    } catch (error) {
      log("Error fetching user data: $error");
    }
  }

  void logout() async {
    // LogOut function logs out the user from the app
    await FirebaseAuth.instance.signOut();
    log("sign out success");
    // After logging out return to the login screen
    Navigator.pushReplacement(context,
        MaterialPageRoute(builder: (context) => const PhoneLoginPage()));
  }

  @override
  void initState() {
    super.initState();
    fetchUserData();
  }

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

    try {
      if (profileImageUrl != null) {
        await FirebaseStorage.instance.refFromURL(profileImageUrl!).delete();
        log("sucess deletion");
      }
    } catch (error) {
      log("Error deleting old profile picture: $error");
    }

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
      "profileImage": downloadUrl ?? profileImageUrl,
    };

    try {
      await FirebaseFirestore.instance
          .collection("users")
          .doc(widget.uid)
          .set(userData);

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => HomeScreen(currentUserUid: widget.uid),
        ),
      );
    } catch (error) {
      log("Error saving user: $error");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              const Text(
                'माझी माहिती',
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                ),
              ),
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
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: const Color.fromARGB(133, 97, 97, 97),
                      width: 3,
                    ),
                  ),
                  child: CircleAvatar(
                    radius: 50,
                    backgroundImage: profilePic != null
                        ? FileImage(profilePic!) as ImageProvider<Object>
                        : profileImageUrl != null
                            ? NetworkImage(profileImageUrl!)
                            : placeholderImage as ImageProvider<Object>,
                  ),
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
              Container(
                decoration: BoxDecoration(
                  border: Border.all(
                      width: 1,
                      color: const Color.fromARGB(217, 206, 116, 186)),
                  borderRadius: BorderRadius.circular(27),
                ),
                child: ElevatedButton(
                  onPressed: saveUser,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(125, 170, 103, 163),
                    padding: const EdgeInsets.symmetric(
                        vertical: 12, horizontal: 24),
                  ),
                  child: const Text(
                    "जतन करा",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color.fromARGB(255, 217, 0, 255),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 15),
              Container(
                decoration: BoxDecoration(
                  border: Border.all(
                      width: 1,
                      color:  Colors.red),
                  borderRadius: BorderRadius.circular(27),
                ),
                child: ElevatedButton(
                  onPressed: logout,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(107, 185, 101, 101),
                    padding: const EdgeInsets.symmetric(
                        vertical: 12, horizontal: 24),
                  ),
                  child: const Text(
                    "logout",
                    style: TextStyle(
                      fontSize: 20,
                      color: Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
