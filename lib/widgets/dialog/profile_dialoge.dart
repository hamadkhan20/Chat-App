import 'package:cached_network_image/cached_network_image.dart';
import 'package:chat_messenger/models/chat_user.dart';
import 'package:chat_messenger/view/view_profile_screen.dart';
import 'package:flutter/cupertino.dart';

import 'package:flutter/material.dart';

class ProfileDialoge extends StatelessWidget {
  const ProfileDialoge({super.key, required this.user});

  final ChatUser user;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.white.withOpacity(.9),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      content: SizedBox(
        height: MediaQuery.sizeOf(context).height * .35,
        width: MediaQuery.sizeOf(context).width * .35,
        child: Stack(
          children: [
            Text(
              user.name,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            Center(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(
                    MediaQuery.sizeOf(context).height * .25),
                child: CachedNetworkImage(
                  width: MediaQuery.sizeOf(context).height * .5,
                  fit: BoxFit.fill,
                  imageUrl: user.image,
                  errorWidget: (context, url, error) => CircleAvatar(
                    child: Icon(CupertinoIcons.person),
                  ),
                ),
              ),
            ),
            Align(
                alignment: Alignment.topRight,
                child: InkWell(
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => ViewProfileScreen(user: user)));
                  },
                  child: Icon(
                    Icons.info_outline,
                    color: Colors.blue,
                  ),
                ))
          ],
        ),
      ),
    );
  }
}
