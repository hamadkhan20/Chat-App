import 'dart:async';

import 'package:chat_messenger/auth/login_screen.dart';
import 'package:chat_messenger/materials/image_assets.dart';
import 'package:chat_messenger/view/home_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:flutter/material.dart';

import 'package:google_fonts/google_fonts.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  isLogin() {
    if (FirebaseAuth.instance.currentUser != null) {
      print('\nUser: ${FirebaseAuth.instance.currentUser}');

      Timer(Duration(seconds: 4), () {
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => HomeScreen()));
      });
    } else {
      Timer(Duration(seconds: 4), () {
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => LoginScreen()));
      });
    }
  }

  @override
  void initState() {
    super.initState();
    isLogin();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Stack(
      children: [
        Positioned(
          top: MediaQuery.sizeOf(context).height * .35,
          right: MediaQuery.sizeOf(context).width * .25,
          width: MediaQuery.sizeOf(context).width * .5,
          child: Image(image: AssetImage(ImageAssets.chatPic)),
        ),
        Positioned(
          bottom: MediaQuery.sizeOf(context).height * .15,
          width: MediaQuery.sizeOf(context).width,
          child: Center(
            child: Text(
              'Made in Pakistan with ❤️',
              style: GoogleFonts.bebasNeue(
                  textStyle: TextStyle(
                      fontSize: 25,
                      letterSpacing: .9,
                      fontWeight: FontWeight.w500)),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ],
    ));
  }
}
