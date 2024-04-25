import 'dart:developer';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:chat_messenger/api/apis.dart';
import 'package:chat_messenger/models/chat_user.dart';
import 'package:chat_messenger/models/message.dart';
import 'package:chat_messenger/view/view_profile_screen.dart';
import 'package:chat_messenger/widgets/messege_card.dart';
import 'package:chat_messenger/widgets/my_date_utils.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:image_picker/image_picker.dart';

class ChatScreen extends StatefulWidget {
  final ChatUser user;
  const ChatScreen({super.key, required this.user});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  List<Message> _list = [];
  final _textController = TextEditingController();
  bool _showEmoji = false, _isUploading = false;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: WillPopScope(
        onWillPop: () {
          if (_showEmoji) {
            setState(() {
              _showEmoji = !_showEmoji;
            });
            return Future.value(false);
          } else {
            return Future.value(true);
          }
        },
        child: Scaffold(
          appBar: AppBar(
            automaticallyImplyLeading: false,
            flexibleSpace: _appBar(context),
          ),
          backgroundColor: Color.fromARGB(255, 234, 248, 255),
          body: Column(
            children: [
              Expanded(
                child: StreamBuilder(
                    stream: APIs.getAllMessages(widget.user),
                    builder: (context, snapshot) {
                      switch (snapshot.connectionState) {
                        case ConnectionState.waiting:
                        case ConnectionState.none:
                          return const SizedBox();

                        case ConnectionState.active:
                        case ConnectionState.done:
                          final data = snapshot.data?.docs;
                          _list = data!
                              .map((e) => Message.fromJson(e.data()))
                              .toList();

                          if (_list.isNotEmpty) {
                            return ListView.builder(
                              reverse: true,
                              physics: BouncingScrollPhysics(),
                              itemCount: _list.length,
                              itemBuilder: (context, index) {
                                return MessegeCard(
                                  message: _list[index],
                                );
                              },
                            );
                          } else {
                            return Center(
                              child: Text(
                                'Say Hii 👋',
                                style: TextStyle(fontSize: 20),
                              ),
                            );
                          }
                      }
                    }),
              ),
              if (_isUploading)
                Align(
                    alignment: Alignment.centerRight,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 8, horizontal: 20),
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                      ),
                    )),
              _chatInput(),

              if (_showEmoji)
                SizedBox(
                  height: MediaQuery.sizeOf(context).height * .35,
                  child: EmojiPicker(
                    textEditingController: _textController,
                    config: Config(
                      emojiViewConfig: EmojiViewConfig(
                        backgroundColor: Color.fromARGB(255, 234, 248, 255),
                        columns: 8,
                      ),
                    ),
                  ),
                ),
              //show emojis on keyboard emoji button click & vice versa

              // if (_showEmoji)
              //   SizedBox(
              //     height: MediaQuery.sizeOf(context).height * .35,
              //     child: EmojiPicker(
              //       textEditingController: _textController,
              //       config: const Config(),
              //     ),
              //   ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _chatInput() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 5, vertical: 5),
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        child: Row(
          children: [
            IconButton(
                onPressed: () {
                  FocusScope.of(context).unfocus();
                  setState(() => _showEmoji = !_showEmoji);
                },
                icon: Icon(
                  Icons.emoji_emotions,
                  color: Colors.blueAccent,
                  size: 25,
                )),
            Expanded(
              child: TextField(
                controller: _textController,
                keyboardType: TextInputType.multiline,
                maxLines: null,
                onTap: () {
                  if (_showEmoji) setState(() => _showEmoji = !_showEmoji);
                },
                decoration: InputDecoration(
                    hintText: 'Type Something',
                    hintStyle: TextStyle(color: Colors.blueAccent),
                    border: InputBorder.none),
              ),
            ),
            IconButton(
                onPressed: () async {
                  final ImagePicker picker = ImagePicker();

                  // Pick an image
                  final List<XFile>? images =
                      await picker.pickMultiImage(imageQuality: 70);

                  for (var i in images!) {
                    log('Image Path: ${i.path}');
                    setState(() => _isUploading = true);
                    await APIs.sendChatImage(widget.user, File(i.path));
                    setState(() => _isUploading = false);
                  }
                },
                icon: Icon(
                  Icons.image,
                  color: Colors.blueAccent,
                  size: 26,
                )),
            IconButton(
                onPressed: () async {
                  final ImagePicker picker = ImagePicker();

                  // Pick an image
                  final XFile? image = await picker.pickImage(
                      source: ImageSource.camera, imageQuality: 70);
                  if (image != null) {
                    setState(() => _isUploading = true);

                    await APIs.sendChatImage(widget.user, File(image.path));
                    setState(() => _isUploading = false);
                  }
                },
                icon: Icon(
                  Icons.camera_alt_rounded,
                  color: Colors.blueAccent,
                  size: 26,
                )),
            MaterialButton(
              onPressed: () {
                if (_textController.text.isNotEmpty) {
                  if (_list.isEmpty) {
                    //on first message (add user to my_user collection of chat user)
                    APIs.sendFirstMessage(
                        widget.user, _textController.text, Type.text);

                    print(
                        'xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxnnnnnnnnnnnnnnnnnnnnnnxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx');
                  } else {
                    //simply send message
                    APIs.sendMessage(
                        widget.user, _textController.text, Type.text);
                    print(
                        'xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx');
                  }
                  _textController.text = '';
                }
              },
              minWidth: 0,
              padding: const EdgeInsets.only(
                  top: 10, bottom: 10, right: 5, left: 10),
              shape: const CircleBorder(),
              color: Colors.green,
              child: const Icon(Icons.send, color: Colors.white, size: 28),
            )
          ],
        ),
      ),
    );
  }

  //

  Widget _appBar(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (_) => ViewProfileScreen(user: widget.user)));
      },
      child: StreamBuilder(
          stream: APIs.getUserInfo(widget.user),
          builder: ((context, snapshot) {
            final data = snapshot.data?.docs;

            final list =
                data?.map((e) => ChatUser.fromJson(e.data())).toList() ?? [];

            return Padding(
              padding: const EdgeInsets.only(top: 24),
              child: Row(
                children: [
                  IconButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      icon: Icon(
                        Icons.arrow_back,
                        color: Colors.black54,
                      )),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(50),
                    child: CachedNetworkImage(
                      width: 50,
                      height: 50,
                      fit: BoxFit.fill,
                      imageUrl: list.isNotEmpty
                          ? list[0].image
                          : widget.user.image.toString(),
                      // placeholder: (context, url) => CircularProgressIndicator(),
                      errorWidget: (context, url, error) => CircleAvatar(
                        child: Icon(CupertinoIcons.person),
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 10,
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        list.isNotEmpty
                            ? list[0].name
                            : widget.user.name.toString(),
                        style: TextStyle(
                            fontSize: 16,
                            color: Colors.black,
                            fontWeight: FontWeight.w700),
                      ),
                      Text(
                        list.isNotEmpty
                            ? list[0].isOnline
                                ? 'Online'
                                : MyDateUtil.getLastActiveTime(
                                    context: context,
                                    lastActive: list[0].lastActive)
                            : MyDateUtil.getLastActiveTime(
                                context: context,
                                lastActive: widget.user.lastActive),
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.black54,
                        ),
                      ),
                    ],
                  )
                ],
              ),
            );
          })),
    );
  }
}
