import 'dart:async';
import 'dart:math';

import "package:flutter/material.dart";
import 'package:flutter/services.dart';
import 'package:maps/google_maps.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:animated_background/animated_background.dart';
//import 'package:maps/homepage.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  runApp(GoogleSignin());
}

class GoogleSignin extends StatefulWidget {
  GoogleSignin({Key? key}) : super(key: key);

  @override
  State<GoogleSignin> createState() => _GoogleSigninState();
}

class _GoogleSigninState extends State<GoogleSignin> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: SignInScreen(),
    );
  }
}

class SignInScreen extends StatefulWidget {
  const SignInScreen({Key? key}) : super(key: key);

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen>
    with TickerProviderStateMixin {
  Color color_r = Color.fromARGB(255, 255, 177, 74);
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: () async {
          // Timer.periodic(Duration(seconds: 1), (timer) async {
          //   color_r =
          //       Colors.primaries[Random().nextInt(Colors.primaries.length)];
          //   setState(() {
          //     color_r;
          //   });
          // });

          SystemNavigator.pop();
          return false;
        },
        child: Scaffold(
          appBar: AppBar(
            title: Text('POTHOLE MAPPING'),
            backgroundColor: Color.fromARGB(0, 0, 0, 0),
            automaticallyImplyLeading: false,
          ),
          backgroundColor: Colors.black,
          body: AnimatedBackground(
            behaviour: RandomParticleBehaviour(
                options: ParticleOptions(
                    particleCount: 30,
                    spawnMaxRadius: 70,
                    spawnMinRadius: 30,
                    spawnMinSpeed: 11,
                    spawnMaxSpeed: 15,
                    baseColor: color_r)),
            vsync: this,
            child: Container(
              // color: Color.fromARGB(62, 0, 0, 0),

              alignment: Alignment.center,
              child: TextButton(
                  onPressed: () async {
                    await signInWithGoogle();
                    setState(() {});
                    FirebaseAuth.instance
                        .authStateChanges()
                        .listen((User? user) {
                      if (user != null) {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => Google_maps()));
                      }
                    });
                  },
                  style: TextButton.styleFrom(backgroundColor: Colors.white),
                  child: Text("Sign in with google")),
            ),
          ),
          // floatingActionButton: FloatingActionButton(
          //   onPressed: () => Navigator.push(
          //       context, MaterialPageRoute(builder: (context) => Google_maps())),
          //   child: Icon(Icons.map),
          //   backgroundColor: Colors.blue,
          // ),
        ));
  }

  Color getcolor() {
    return Colors.primaries[Random().nextInt(Colors.primaries.length)];
  }
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
