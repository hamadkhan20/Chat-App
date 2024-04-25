import 'dart:developer';

import 'package:chat_messenger/api/apis.dart';
import 'package:chat_messenger/materials/image_assets.dart';
import 'package:chat_messenger/models/chat_user.dart';
import 'package:chat_messenger/utils/utils.dart';

import 'package:chat_messenger/view/profile_screen.dart';
import 'package:chat_messenger/widgets/chat_user_card.dart';

import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:flutter/cupertino.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  List<ChatUser> list = [];

  List<ChatUser> _searchlist = [];

  bool _isSearching = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    APIs.getselfInfo();

    SystemChannels.lifecycle.setMessageHandler((message) {
      log('Messange: $message');
      if (APIs.auth.currentUser != null) {
        if (message.toString().contains('resume'))
          APIs.updateActiveStatus(true);
        if (message.toString().contains('pause'))
          APIs.updateActiveStatus(false);
      }

      return Future.value(message);
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: WillPopScope(
        onWillPop: () {
          if (_isSearching) {
            setState(() {
              _isSearching = !_isSearching;
            });
            return Future.value(false);
          } else {
            return Future.value(true);
          }
        },
        child: Scaffold(
            appBar: AppBar(
              automaticallyImplyLeading: false,
              backgroundColor: Colors.white,
              centerTitle: true,
              elevation: 1,
              actions: [
                IconButton(
                  onPressed: () {
                    setState(() {
                      _isSearching = !_isSearching;
                    });
                  },
                  icon: Icon(_isSearching
                      ? CupertinoIcons.clear_circled_solid
                      : Icons.search),
                ),
                IconButton(
                    onPressed: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => ProfileScreen(
                                    user: APIs.me,
                                  )));
                    },
                    icon: Image(
                        height: 25,
                        width: 25,
                        image: AssetImage(ImageAssets.moreVert)))
              ],
              title: _isSearching
                  ? TextField(
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: 'Name... Email',
                      ),
                      autofocus: true,
                      onChanged: (val) {
                        _searchlist.clear();

                        for (var i in list) {
                          if (i.name
                                  .toLowerCase()
                                  .contains(val.toLowerCase()) ||
                              i.email
                                  .toLowerCase()
                                  .contains(val.toLowerCase())) {
                            _searchlist.add(i);
                            setState(() {
                              _searchlist;
                            });
                          }
                        }
                      },
                    )
                  : Text(
                      'Chat App',
                      style: GoogleFonts.pacifico(),
                      strutStyle: StrutStyle(fontWeight: FontWeight.bold),
                    ),
            ),
            floatingActionButton: Padding(
              padding: EdgeInsets.only(bottom: 10, left: 20),
              child: FloatingActionButton(
                onPressed: () {
                  _addChatUserDialoge(context);
                },
                child: Icon(Icons.add_comment_rounded),
              ),
            ),
            body: StreamBuilder(
                stream: APIs.getMyUsersId(),
                builder: (context, snapshot) {
                  switch (snapshot.connectionState) {
                    case ConnectionState.waiting:
                    case ConnectionState.none:
                      return const Center(child: CircularProgressIndicator());

                    case ConnectionState.active:
                    case ConnectionState.done:
                      return StreamBuilder(
                          stream: APIs.getAllUsers(
                              snapshot.data?.docs.map((e) => e.id).toList() ??
                                  []),
                          builder: (context, snapshot) {
                            switch (snapshot.connectionState) {
                              case ConnectionState.waiting:
                              case ConnectionState.none:
                                return const Center(
                                    child: CircularProgressIndicator());

                              case ConnectionState.active:
                              case ConnectionState.done:
                                final data = snapshot.data?.docs;
                                list = data!
                                    .map((e) => ChatUser.fromJson(e.data()))
                                    .toList();

                                if (list.isNotEmpty) {
                                  return ListView.builder(
                                    physics: BouncingScrollPhysics(),
                                    itemCount: _isSearching
                                        ? _searchlist.length
                                        : list.length,
                                    itemBuilder: (context, index) {
                                      return ChatUserCard(
                                          user: _isSearching
                                              ? _searchlist[index]
                                              : list[index]);
                                      //return Text('Name: ${list[index]}');
                                    },
                                  );
                                } else {
                                  return Center(
                                    child: Text(
                                      'No Connection Found',
                                      style: TextStyle(fontSize: 20),
                                    ),
                                  );
                                }
                            }
                          });
                  }
                })),
      ),
    );
  }

  void _addChatUserDialoge(BuildContext context) {
    String email = '';

    showDialog(
        context: context,
        builder: (_) => AlertDialog(
              contentPadding: const EdgeInsets.only(
                  left: 24, right: 24, top: 20, bottom: 10),

              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20)),

              //title
              title: const Row(
                children: [
                  Icon(
                    Icons.person,
                    color: Colors.blue,
                    size: 28,
                  ),
                  Text('  Add User')
                ],
              ),

              //content
              content: TextFormField(
                maxLines: null,
                onChanged: (value) => email = value,
                decoration: InputDecoration(
                    hintText: 'Email Id',
                    prefixIcon: Icon(
                      Icons.email,
                      color: Colors.blue,
                    ),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15))),
              ),

              //actions
              actions: [
                //cancel button
                MaterialButton(
                    onPressed: () {
                      //hide alert dialog
                      Navigator.pop(context);
                    },
                    child: const Text(
                      'Cancel',
                      style: TextStyle(color: Colors.blue, fontSize: 16),
                    )),

                //update button
                MaterialButton(
                    onPressed: () async {
                      //hide alert dialog
                      Navigator.pop(context);
                      if (email.isNotEmpty)
                        await APIs.addChatUser(email).then((value) {
                          if (!value) {
                            Utils.showSnackbar(context, 'User does not Exists');
                          }
                        });
                    },
                    child: const Text(
                      'Add',
                      style: TextStyle(color: Colors.blue, fontSize: 16),
                    ))
              ],
            ));
  }
}
