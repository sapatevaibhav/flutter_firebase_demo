// ignore_for_file: use_build_context_synchronously

import 'dart:async';
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
  // File to store profile picture
  File? profilePic;

  void logout() async {
    // LogOut function logs out the user from the app
    await FirebaseAuth.instance.signOut();
    log("sign out success");
    // After logging out return to the login screen
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
    // Saving the user details in the FireStore
    String name = nameController.text.toString();
    String email = emailController.text.toString();
    String ageAtr = ageController.text.toString();
    // try parsing to avoid errors
    int? age = int.tryParse(ageAtr);

    if (name != "" && email != "" && profilePic != null) {
      // If nothing is empty then proceed
      UploadTask uploadTask = FirebaseStorage.instance
          // Upload image to the Firebase Storage
          .ref()
          // in the profilePictures folder
          .child("profilePictures")
          // upload using unique id
          .child(const Uuid().v1())
          .putFile(profilePic!);

      // Displaying the progress of uploading image
      StreamSubscription streamSubscription =
          uploadTask.snapshotEvents.listen((snapshot) {
        double percentage =
            snapshot.bytesTransferred / snapshot.totalBytes * 100;
        log(percentage.toString());
      });

      // Await for uploading picture
      TaskSnapshot taskSnapshot = await uploadTask;
      // Grab the dowmnload URL from that snapshot to store it in FireStore
      String downloadUrl = await taskSnapshot.ref.getDownloadURL();

      // Cancel the streamSubscription to avoid memory leak
      streamSubscription.cancel();

      Map<String, dynamic> userData = {
        // Map to store data in FireStore
        "name": name,
        "age": age,
        "email": email,
        "profileIamge": downloadUrl,
        // Sample array was created to apply filters during fetching data
        "sampleArray": [
          name,
          age,
          email,
        ],
      };
      // Create the FireStore Instance
      FirebaseFirestore instance = FirebaseFirestore.instance;
      // Add the userData to the FireStore
      instance.collection("users").add(userData
          // {
          // "name": name,
          // "email": email,
          // "age": age,
          // },
          );
      // After storing the data clear every field
      nameController.clear();
      emailController.clear();
      ageController.clear();
      setState(() {
        // To reset image refresh the app
        profilePic = null;
      });
    } else {
      // If anything is empty log it
      log("Data cannot be empty");
    }
  }

  @override
  Widget build(BuildContext context) {
    // This is what HomePage looks like
    return Scaffold(
      appBar: AppBar(
        // Title
        title: const Text('Home'),
        actions: [
          // Button to log out
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
                // Cupertino Button to pick the Image to store in profile
                onPressed: () async {
                  // After picking Image using ImagePicker it gives XFile
                  // By default image source is set to gallery
                  XFile? selectedImage = await ImagePicker().pickImage(
                    source: ImageSource.gallery,
                  );
                  if (selectedImage != null) {
                    // If selected image is not null then convery that XFile to File
                    File convertedImage = File(selectedImage.path);
                    setState(() {
                      // And store it in the File type created above
                      profilePic = convertedImage;
                    });
// TEst log to say image is selected
                    log("Image Selected");
                  } else {
                    // Else say not selected
                    log("Image not selected");
                  }
                },
                child: CircleAvatar(
                  // The circleAvatar to display the image selected
                  radius: 50,
                  backgroundImage:
                      // If background image is null then display nothing else display that image
                      (profilePic != null) ? FileImage(profilePic!) : null,
                  backgroundColor: Colors.grey,
                ),
              ),
              TextField(
                // TextField to grab name
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
                  // TextField to grab email
                  hintText: "Email",
                ),
                controller: emailController,
              ),
              const SizedBox(
                height: 10,
              ),
              TextField(
                decoration: const InputDecoration(
                  // TextField to grab age
                  hintText: "Age",
                ),
                controller: ageController,
              ),
              const SizedBox(
                height: 20,
              ),
              ElevatedButton(
                // Button to perform saving operation
                onPressed: () {
                  saveUser();
                },
                child: const Text("Save"),
              ),
              StreamBuilder<QuerySnapshot>(
                  // StreamBuilder to display the saved data in FireStore
                  stream: FirebaseFirestore.instance
                      .collection("users")
                      // Some Filters
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
                    // If the connection to the FireStore is active
                    if (snapshot.connectionState == ConnectionState.active) {
                      // And there is data in the snapshot of that FireStore
                      if (snapshot.hasData && snapshot.data != null) {
                        // then return the ListView containing the user data stored in FireStore
                        return Expanded(
                          child: ListView.builder(
                            // ItemCOunt grabbed from the snapshot data docs length
                            itemCount: snapshot.data!.docs.length,
                            itemBuilder: (context, index) {
                              Map<String, dynamic> userMap =
                                  snapshot.data!.docs[index].data()
                                      as Map<String, dynamic>;
                              return ListTile(
                                leading: CircleAvatar(
                                  // In the leading part of ListTile display the Profile Image
                                  backgroundImage:
                                      NetworkImage(userMap["profileIamge"]),
                                  backgroundColor: Colors.grey,
                                ),
                                title: Text(
                                  // As title display Name and age
                                  userMap["name"] + " (${userMap["age"]})",
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                // As subtitle display Email
                                subtitle: Text(userMap["email"]),
                                trailing: IconButton(
                                  // As trailing part diaplay delete button after clicking on it the data gets deleted from FireStore of that specific Tile
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
                        // If data is being loaded the display the indicator
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
