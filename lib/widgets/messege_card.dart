import 'package:cached_network_image/cached_network_image.dart';
import 'package:chat_messenger/api/apis.dart';
import 'package:chat_messenger/models/message.dart';
import 'package:chat_messenger/utils/utils.dart';
import 'package:chat_messenger/widgets/my_date_utils.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gallery_saver_updated/gallery_saver.dart';

class MessegeCard extends StatefulWidget {
  const MessegeCard({super.key, required this.message});

  final Message message;

  @override
  State<MessegeCard> createState() => _MessegeCardState();
}

class _MessegeCardState extends State<MessegeCard> {
  @override
  Widget build(BuildContext context) {
    bool isMe = APIs.user.uid == widget.message.fromId;
    return InkWell(
        onLongPress: () {
          _showBottomSheet(isMe, widget.message, context);
        },
        child: isMe
            ? _greenMessage(widget.message, context)
            : _blueMessage(widget.message, context));
  }
}

Widget _blueMessage(Message? message, BuildContext context) {
  // update last read message if sender and reciever are different
  if (message!.read.isEmpty) {
    APIs.updateMessageReadStatus(message);
  }

  return Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Flexible(
        child: Container(
          padding: EdgeInsets.all(MediaQuery.sizeOf(context).width * .03),
          margin: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
              color: Color.fromARGB(255, 221, 245, 255),
              border: Border.all(color: Colors.lightBlue),
              borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                  bottomRight: Radius.circular(30))),
          child: message.type == Type.text
              ?
              //show text
              Text(
                  message.msg.toString(),
                  style: const TextStyle(fontSize: 15, color: Colors.black87),
                )
              :
              //show image
              ClipRRect(
                  borderRadius: BorderRadius.circular(15),
                  child: CachedNetworkImage(
                    imageUrl: message.msg.toString(),
                    placeholder: (context, url) => const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Padding(
                        padding: EdgeInsets.all(8.0),
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    ),
                    errorWidget: (context, url, error) =>
                        const Icon(Icons.image, size: 70),
                  ),
                ),
        ),
      ),
      Padding(
        padding: const EdgeInsets.only(right: 8),
        child: Text(
          MyDateUtil.getFormattedTime(
              context: context, time: message.sent.toString()),
          style: TextStyle(fontSize: 13, color: Colors.black54),
        ),
      )
    ],
  );
}

Widget _greenMessage(Message message, BuildContext context) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Row(
        children: [
          SizedBox(
            width: 4,
          ),
          if (message.read.isNotEmpty)
            Icon(
              Icons.done_all_rounded,
              color: Colors.blue,
              size: 20,
            ),
          SizedBox(width: 2),
          Text(
            MyDateUtil.getFormattedTime(
                context: context, time: message.sent.toString()),
            style: TextStyle(fontSize: 13, color: Colors.black54),
          ),
        ],
      ),
      Flexible(
        child: Container(
          padding: EdgeInsets.all(MediaQuery.sizeOf(context).width * .03),
          margin: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
              color: Color.fromARGB(255, 218, 255, 176),
              border: Border.all(color: Colors.lightGreen),
              borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                  bottomLeft: Radius.circular(30))),
          child: message.type == Type.text
              ?
              //show text
              Text(
                  message.msg.toString(),
                  style: const TextStyle(fontSize: 15, color: Colors.black87),
                )
              :
              //show image
              ClipRRect(
                  borderRadius: BorderRadius.circular(15),
                  child: CachedNetworkImage(
                    imageUrl: message.msg.toString(),
                    placeholder: (context, url) => const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Padding(
                        padding: EdgeInsets.all(8.0),
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    ),
                    errorWidget: (context, url, error) =>
                        const Icon(Icons.image, size: 70),
                  ),
                ),
        ),
      ),
    ],
  );
}

// bottom sheet for modifying message details
void _showBottomSheet(bool isMe, Message message, BuildContext context) {
  showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20), topRight: Radius.circular(20))),
      builder: (_) {
        return ListView(
          shrinkWrap: true,
          children: [
            //black divider
            Container(
              height: 4,
              margin: EdgeInsets.symmetric(
                  vertical: MediaQuery.sizeOf(context).height * .015,
                  horizontal: MediaQuery.sizeOf(context).width * .4),
              decoration: BoxDecoration(
                  color: Colors.grey, borderRadius: BorderRadius.circular(8)),
            ),

            message.type == Type.text
                ?
                //copy option
                _OptionItem(
                    icon: const Icon(Icons.copy_all_rounded,
                        color: Colors.blue, size: 26),
                    name: 'Copy Text',
                    onTap: () async {
                      await Clipboard.setData(ClipboardData(text: message.msg))
                          .then((value) {
                        //for hiding bottom sheet
                        Navigator.pop(context);

                        Utils.showSnackbar(context, 'Text Copied!');
                      });
                    })
                :
                //save option
                _OptionItem(
                    icon: const Icon(Icons.download_rounded,
                        color: Colors.blue, size: 26),
                    name: 'Save Image',
                    onTap: () async {
                      try {
                        print('Image Url: $message.msg}');
                        await GallerySaver.saveImage(message.msg,
                                albumName: 'We Chat')
                            .then((success) {
                          //for hiding bottom sheet
                          Navigator.pop(context);
                          if (success != null && success) {
                            Utils.showSnackbar(
                                context, 'Image Successfully Saved!');
                          }
                        });
                      } catch (e) {
                        print('ErrorWhileSavingImg: $e');
                      }
                    }),

            //separator or divider
            if (isMe)
              Divider(
                color: Colors.black54,
                endIndent: MediaQuery.sizeOf(context).width * .04,
                indent: MediaQuery.sizeOf(context).width * .04,
              ),

            //edit option
            if (message.type == Type.text && isMe)
              _OptionItem(
                  icon: const Icon(Icons.edit, color: Colors.blue, size: 26),
                  name: 'Edit Message',
                  onTap: () {
                    //for hiding bottom sheet
                    Navigator.pop(context);

                    _showMessageUpdateDialog(message, context);
                  }),

            //delete option
            if (isMe)
              _OptionItem(
                  icon: const Icon(Icons.delete_forever,
                      color: Colors.red, size: 26),
                  name: 'Delete Message',
                  onTap: () async {
                    await APIs.deleteMessage(message).then((value) {
                      //for hiding bottom sheet
                      Navigator.pop(context);
                    });
                  }),

            //separator or divider
            Divider(
              color: Colors.black54,
              endIndent: MediaQuery.sizeOf(context).width * .04,
              indent: MediaQuery.sizeOf(context).width * .04,
            ),

            //sent time
            _OptionItem(
                icon: const Icon(Icons.remove_red_eye, color: Colors.blue),
                name:
                    'Sent At: ${MyDateUtil.getMessageTime(context: context, time: message.sent)}',
                onTap: () {}),

            //read time
            _OptionItem(
                icon: const Icon(Icons.remove_red_eye, color: Colors.green),
                name: message.read.isEmpty
                    ? 'Read At: Not seen yet'
                    : 'Read At: ${MyDateUtil.getMessageTime(context: context, time: message.read)}',
                onTap: () {}),
          ],
        );
      });
}

//dialog for updating message content

//custom options card (for copy, edit, delete, etc.)
class _OptionItem extends StatelessWidget {
  final Icon icon;
  final String name;
  final VoidCallback onTap;

  const _OptionItem(
      {required this.icon, required this.name, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
        onTap: () => onTap(),
        child: Padding(
          padding: EdgeInsets.only(
              left: MediaQuery.sizeOf(context).height * .05,
              top: MediaQuery.sizeOf(context).height * .015,
              bottom: MediaQuery.sizeOf(context).height * .015),
          child: Row(children: [
            icon,
            Flexible(
                child: Text('    $name',
                    style: const TextStyle(
                        fontSize: 15,
                        color: Colors.black54,
                        letterSpacing: 0.5)))
          ]),
        ));
  }
}

//dialog for updating message content
void _showMessageUpdateDialog(Message message, BuildContext context) {
  String updatedMsg = message.msg;

  showDialog(
      context: context,
      builder: (_) => AlertDialog(
            contentPadding:
                const EdgeInsets.only(left: 24, right: 24, top: 20, bottom: 10),

            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),

            //title
            title: const Row(
              children: [
                Icon(
                  Icons.message,
                  color: Colors.blue,
                  size: 28,
                ),
                Text(' Update Message')
              ],
            ),

            //content
            content: TextFormField(
              initialValue: updatedMsg,
              maxLines: null,
              onChanged: (value) => updatedMsg = value,
              decoration: InputDecoration(
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
                  onPressed: () {
                    //hide alert dialog
                    Navigator.pop(context);
                    APIs.updateMessage(message, updatedMsg);
                  },
                  child: const Text(
                    'Update',
                    style: TextStyle(color: Colors.blue, fontSize: 16),
                  ))
            ],
          ));
}
