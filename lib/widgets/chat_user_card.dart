import 'package:cached_network_image/cached_network_image.dart';
import 'package:chat_messenger/api/apis.dart';
import 'package:chat_messenger/models/chat_user.dart';
import 'package:chat_messenger/models/message.dart';
import 'package:chat_messenger/view/chat_screen.dart';
import 'package:chat_messenger/widgets/dialog/profile_dialoge.dart';
import 'package:chat_messenger/widgets/my_date_utils.dart';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ChatUserCard extends StatefulWidget {
  final ChatUser user;
  const ChatUserCard({super.key, required this.user});

  @override
  State<ChatUserCard> createState() => _ChatUserCardState();
}

class _ChatUserCardState extends State<ChatUserCard> {
  Message? _message;
  @override
  Widget build(BuildContext context) {
    print(widget.user.image.toString());
    return Card(
      elevation: 1,
      margin: EdgeInsets.symmetric(
          horizontal: MediaQuery.sizeOf(context).width * .02, vertical: 4),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: InkWell(
          onTap: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => ChatScreen(
                          user: widget.user,
                        )));
          },
          child: StreamBuilder(
              stream: APIs.getLastMessage(widget.user),
              builder: (context, snapshot) {
                final data = snapshot.data?.docs;

                final list =
                    data?.map((e) => Message.fromJson(e.data())).toList() ?? [];
                if (list.isNotEmpty) _message = list[0];

                // if (data != null && data.first.exists) {
                //   _message = Message.fromJson(data.first.data());
                // }
                return ListTile(
                    // leading: CircleAvatar(
                    //   child: Icon(CupertinoIcons.person),
                    // ),
                    // leading: Image.network(widget.user.image.toString()),

                    leading: InkWell(
                      onTap: () {
                        showDialog(
                            context: context,
                            builder: (_) => ProfileDialoge(
                                  user: widget.user,
                                ));
                      },
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(50),
                        child: CachedNetworkImage(
                          width: 50,
                          height: 50,
                          fit: BoxFit.fill,
                          imageUrl: widget.user.image.toString(),
                          // placeholder: (context, url) => CircularProgressIndicator(),
                          errorWidget: (context, url, error) => CircleAvatar(
                            child: Icon(CupertinoIcons.person),
                          ),
                        ),
                      ),
                    ),
                    title: Text(
                      widget.user.name.toString(),
                      style: TextStyle(
                          color: Colors.black, fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                        _message != null
                            ? _message!.type == Type.image
                                ? 'image'
                                : _message!.msg.toString()
                            : widget.user.about.toString(),
                        maxLines: 1),
                    // trailing: Text('12:00 PM'),
                    trailing: _message == null
                        ? null
                        : _message!.read.isEmpty &&
                                _message!.fromId != APIs.user.uid
                            ? Container(
                                height: 12,
                                width: 12,
                                decoration: BoxDecoration(
                                    color: Colors.green.shade400,
                                    borderRadius: BorderRadius.circular(10)),
                              )
                            : Text(
                                MyDateUtil.getLastMessageTime(
                                    context: context,
                                    time: _message!.sent.toString()),
                                style: TextStyle(color: Colors.black54),
                              ));
              })),
    );
  }
}
