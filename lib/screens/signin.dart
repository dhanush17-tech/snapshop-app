import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_signin_button/flutter_signin_button.dart';
import 'package:hack_princeton/screens/chat.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;

class SignupScreen extends StatefulWidget {
  @override
  _SignupScreenState createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final TextEditingController genderController = TextEditingController();
  final TextEditingController ageController = TextEditingController();
  late File imageFile;

  @override
  void initState() {
    super.initState();
    imageFile = File("");
  }

  @override
  void dispose() {
    genderController.dispose();
    ageController.dispose();
    super.dispose();
  }

  Future<UserCredential> signInWithGoogle() async {
    // Trigger the authentication flow
    final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

    // Obtain the auth details from the request
    final GoogleSignInAuthentication? googleAuth =
        await googleUser?.authentication;

    // Create a new credential
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth?.accessToken,
      idToken: googleAuth?.idToken,
    );

    // Once signed in, return the UserCredential
    return await FirebaseAuth.instance.signInWithCredential(credential);
  }

  Future<void> _handleSignIn(BuildContext context) async {
    try {
      final UserCredential userCredential = await signInWithGoogle();
      if (userCredential.additionalUserInfo!.isNewUser) {
        // ignore: use_build_context_synchronously
        showDialog<void>(
          context: context,
          barrierDismissible: false, // User must tap button to close dialog
          builder: (BuildContext context) {
            return StatefulBuilder(
              builder: (context, state1) {
                return AlertDialog(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                  title: Text(
                    'Just a few more info...',
                    style: Theme.of(context).textTheme.headlineLarge,
                  ),
                  content: SingleChildScrollView(
                    child: ListBody(
                      children: <Widget>[
                        TextField(
                          controller: genderController,
                          decoration: InputDecoration(
                            labelText: 'Gender',
                          ),
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        GestureDetector(
                          onTap: () async {
                            final pickedFile = await ImagePicker()
                                .pickImage(source: ImageSource.gallery);
                            if (pickedFile != null && this.mounted) {
                              state1(() {
                                imageFile = File(pickedFile.path);
                              });
                            }
                          },
                          child: Container(
                            height: 150,
                            width: double.infinity,
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                color: Colors.grey.withOpacity(0.5)),
                            child: imageFile.path == ""
                                ? Center(
                                    child: Icon(Icons.add_a_photo),
                                  )
                                : Image.file(imageFile),
                          ),
                        ),
                      ],
                    ),
                  ),
                  actions: <Widget>[
                    TextButton(
                        child: Text('Submit'),
                        onPressed: () async {
                          try {
                            var dio = Dio();
                            FormData formData = FormData.fromMap({
                              'name': userCredential.user!.displayName,
                              'email': userCredential.user!.email,
                              'gender': genderController.text,
                              'age': ageController.text,
                              'image': await MultipartFile.fromFile(
                                imageFile.path,
                                filename:
                                    'image.jpg', // Change the filename as needed
                              ),
                            });

                            var response = await dio.post(
                              "https://hackprinceton-dhravya.up.railway.app/new_user",
                              data: formData,
                            );

                            if (response.statusCode == 200) {
                              Navigator.of(context).pop();
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (c) => ChatPage()));
                            }
                          } catch (e) {
                            print(e);
                          }
                        }),
                  ],
                );
              },
            );
          },
        );
      } else {
        Navigator.push(context, MaterialPageRoute(builder: (c) => ChatPage()));
      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Sign in failed'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).backgroundColor,
      body: Center(
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Image.asset(
            "assets/logo.png",
            fit: BoxFit.cover,
            scale: 2,
          ),
          SizedBox(
            height: 0,
          ),
          Text(
            "SnapShop",
            style: Theme.of(context)
                .textTheme
                .headlineLarge!
                .copyWith(fontSize: 30),
          ),
          SizedBox(
            height: 50,
          ),
          Container(
            width: 230,
            height: 40,
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(7), color: Colors.white),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                SizedBox(
                  width: 20,
                ),
                Image.asset(
                  "assets/google.png",
                  scale: 7,
                ),
                SizedBox(
                  width: 15,
                ),
                GestureDetector(
                  onTap: () => _handleSignIn(context),
                  child: Center(
                      child: Text(
                    "Sign in with Google",
                    style: GoogleFonts.poppins(
                        fontSize: 15, fontWeight: FontWeight.w500),
                  )),
                ),
              ],
            ),
          ),
        ]),
      ),
    );
  }
}
