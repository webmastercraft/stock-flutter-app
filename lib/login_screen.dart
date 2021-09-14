import 'package:flutter/material.dart';
import 'package:flutter_login/flutter_login.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:stock/user/scanner_screen.dart';
import 'user/home.dart';
import 'admin/admin_home.dart';

const users = const {
  'dribbble@gmail.com': '12345',
  'hunter@gmail.com': 'hunter',
};

class LoginScreen extends StatefulWidget {
  @override
  AuthenticationState createState() => AuthenticationState();
}

class AuthenticationState extends State<LoginScreen> {
  Duration get loginTime => Duration(milliseconds: 2250);
  // ignore: non_constant_identifier_names
  String result_uid = "nothing";
  FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  DatabaseReference dbRef =
      FirebaseDatabase.instance.reference().child("Users");

  Future<String> registerToFb(LoginData data) {
    print('Name: ${data.name}, Password: ${data.password}');
    return Future.delayed(loginTime).then((_) {
      firebaseAuth
          .createUserWithEmailAndPassword(
              email: data.name, password: data.password)
          .then((result) {
        result_uid = result.user!.uid;
        addUser(result_uid);
      }).catchError((err) {
        showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text("Error"),
                content: Text(err.message),
                actions: [
                  TextButton(
                    child: Text("Ok"),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  )
                ],
              );
            });
      });
      return "";
    });
  }

  Future<String> logInToFb(LoginData data) {
    print('Name: ${data.name}, Password: ${data.password}');
    return Future.delayed(loginTime).then((_) {
      FirebaseAuth.instance
          .signInWithEmailAndPassword(email: data.name, password: data.password)
          .then((result) {
        result_uid = result.user!.uid;
      }).catchError((err) {
        print(err.message);
        showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text("Error"),
                content: Text(err.message),
                actions: [
                  ElevatedButton(
                    child: Text("Ok"),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  )
                ],
              );
            });
      });
      return '';
    });
  }

  Future<String> _recoverPassword(String name) {
    return Future.delayed(loginTime).then((_) {
      return "null";
    });
  }

  CollectionReference users = FirebaseFirestore.instance.collection('users');

  Future<void> addUser(String userid) {
    // Call the user's CollectionReference to add a new user
    return users
        .doc(userid)
        .set({
          'permission': "user",
        })
        .then((value) => print("User Added"))
        .catchError((error) => print("Failed to add user: $error"));
  }

  @override
  Widget build(BuildContext context) {
    return FlutterLogin(
      title: 'COMPUTSTOCK',
      logo: 'assets/images/logo3x.png',
      onLogin: logInToFb,
      onSignup: registerToFb,
      loginProviders: <LoginProvider>[
        LoginProvider(
          icon: FontAwesomeIcons.google,
          label: 'Google',
          callback: () async {
            print('start google sign in');
            await Future.delayed(loginTime);
            print('stop google sign in');
            return null;
          },
        ),
        LoginProvider(
          icon: FontAwesomeIcons.facebookF,
          label: 'Facebook',
          callback: () async {
            print('start facebook sign in');
            await Future.delayed(loginTime);
            print('stop facebook sign in');
            return null;
          },
        ),
        LoginProvider(
          icon: FontAwesomeIcons.linkedinIn,
          callback: () async {
            print('start linkdin sign in');
            await Future.delayed(loginTime);
            print('stop linkdin sign in');
            return null;
          },
        ),
        LoginProvider(
          icon: FontAwesomeIcons.githubAlt,
          callback: () async {
            print('start github sign in');
            await Future.delayed(loginTime);
            print('stop github sign in');
            return null;
          },
        ),
      ],
      onSubmitAnimationCompleted: () {
        if (result_uid != "nothing") {
          FirebaseFirestore.instance
              .collection('users')
              .doc(result_uid)
              .get()
              .then((DocumentSnapshot documentSnapshot) {
            try {
              dynamic nested = documentSnapshot.get(FieldPath(['permission']));
              if (nested == "user") {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => MyScannerScreen()),
                );
              } else {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                      builder: (context) => AdminHome(uid: result_uid)),
                );
              }
            } on StateError catch (e) {
              print('No nested field exists!');
              showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: Text("Error"),
                      content: Text('No user exists!'),
                      actions: [
                        ElevatedButton(
                          child: Text("Ok"),
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                        )
                      ],
                    );
                  });
            }
          });
        } else {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => LoginScreen()),
          );
        }
      },
      onRecoverPassword: _recoverPassword,
    );
  }
}
