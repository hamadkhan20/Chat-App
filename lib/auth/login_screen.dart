import 'dart:math';

import 'package:chat_messenger/api/apis.dart';
import 'package:chat_messenger/materials/image_assets.dart';
import 'package:chat_messenger/utils/utils.dart';
import 'package:chat_messenger/view/home_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'package:google_fonts/google_fonts.dart';
import 'package:google_sign_in/google_sign_in.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _isAnimate = false;

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 500), () {
      setState(() {
        _isAnimate = true;
      });
    });
  }

  _handleGoogleBtnClick() {
    Utils.showProgressBar(context);
    _signInWithGoogle().then((User) async {
      Navigator.pop(context);
      if (User != null) {
        print('\nUser: ${User.user}');
        print('\nUserAdditionalInfo: ${User.additionalUserInfo}');

        if ((await APIs.userExits())) {
          Navigator.push(
              context, MaterialPageRoute(builder: (context) => HomeScreen()));
        } else {
          await APIs.createUser().then((value) {
            Navigator.push(
                context, MaterialPageRoute(builder: (context) => HomeScreen()));
          });
        }
      }
    });
  }

  Future<UserCredential?> _signInWithGoogle() async {
    try {
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
    } catch (e) {
      log('\n_signInWithGoogle: $e' as num);
      Utils.showSnackbar(context, 'Something went wrong(check Internet)');
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Stack(
      children: [
        AnimatedPositioned(
          top: MediaQuery.sizeOf(context).height * .15,
          right: _isAnimate
              ? MediaQuery.sizeOf(context).width * .25
              : -MediaQuery.sizeOf(context).width * .5,
          width: MediaQuery.sizeOf(context).width * .5,
          duration: Duration(seconds: 1),
          child: Image(image: AssetImage(ImageAssets.chatPic)),
        ),
        Positioned(
          top: MediaQuery.sizeOf(context).height * .50,
          left: MediaQuery.sizeOf(context).width * .25,
          width: MediaQuery.sizeOf(context).width * .5,
          child: Text(
            'Welcome to chat App',
            style: GoogleFonts.pacifico(textStyle: TextStyle(fontSize: 22)),
            textAlign: TextAlign.center,
          ),
        ),
        Positioned(
          bottom: MediaQuery.sizeOf(context).height * .25,
          left: MediaQuery.sizeOf(context).width * .09,
          width: MediaQuery.sizeOf(context).width * .8,
          height: MediaQuery.sizeOf(context).width * .12,
          child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  shape: StadiumBorder(),
                  elevation: 1),
              onPressed: () {
                _handleGoogleBtnClick();
              },
              icon: Image.asset(
                  height: 25, width: 25, 'assets/images/google.png'),
              label: RichText(
                  text: TextSpan(
                      style: TextStyle(color: Colors.black, fontSize: 18),
                      children: [
                    TextSpan(text: 'Login with'),
                    TextSpan(
                        text: ' Google',
                        style: TextStyle(fontWeight: FontWeight.w500)),
                  ]))),
        )
      ],
    ));
  }
}
