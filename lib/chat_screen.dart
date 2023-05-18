import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flash_chat/constants.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

late User loggedInUser;

class ChatScreen extends StatefulWidget {
  @override
  _ChatScreenState createState() => _ChatScreenState();

  static const String id = 'chat_screen';

}

class _ChatScreenState extends State<ChatScreen> {

  final messageTextController = TextEditingController();

  final _auth = FirebaseAuth.instance;
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  late String messageText;

  void getCurrentUser(){
    final user = _auth.currentUser;
    if(user!=null){
      loggedInUser = user;
      print(loggedInUser.email);
    }
  }

  void getMessages() async {
    final message = await firestore.collection('messages').get();
    for (var messageData in message.docs){
      print(messageData.data());
    }
  }

  void messagesStream() async {
    await for (var snapshot in firestore.collection('messages').snapshots()){
      for( var message in snapshot.docs){
        print(message.data());
      }
    }
  }


  @override
  void initState() {
    getCurrentUser();
    super.initState();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // resizeToAvoidBottomInset: false,
      appBar: AppBar(
        leading: null,
        actions: <Widget>[
          IconButton(
              icon: Icon(Icons.close),
              onPressed: () {
                _auth.signOut();
                Navigator.pop(context);
              }),
        ],
        title: Text('⚡️Chat'),
        backgroundColor: Colors.lightBlueAccent,
      ),
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[

            StreamBuilder(

              stream: firestore.collection('messages').orderBy('timestamp').snapshots(),
              builder: (context, snapshot){
                List<MessageBubble> messageWidgets = [];
                if(snapshot.hasData){
                  final messages = snapshot.data?.docs.reversed;

                  for (var message in messages!){
                    final MessageText = message.data()['text'];
                    final MessageSender = message.data()['sender'];

                    final currentUser = loggedInUser.email;

                    final messageWidget = MessageBubble(
                        MessageSender: MessageSender,
                        MessageText: MessageText,
                        isMe: currentUser == MessageSender
                    );
                    messageWidgets.add(messageWidget);
                  }
                }
                return Expanded(
                  child: ListView(
                    reverse: true,
                    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 20),
                    children: messageWidgets
                  ),
                );
              },
            ),

            Container(
              decoration: kMessageContainerDecoration,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Expanded(
                    child: TextField(
                      controller: messageTextController,
                      onChanged: (value) {
                        messageText = value;
                      },
                      decoration: kMessageTextFieldDecoration,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      messageTextController.clear();
                       firestore.collection('messages').add({
                         'sender' : loggedInUser.email,
                         'text' : messageText,
                         'timestamp': FieldValue.serverTimestamp(),
                       });
                    },
                    child: Text(
                      'Send',
                      style: kSendButtonTextStyle,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class MessageBubble extends StatelessWidget {
  
  MessageBubble({required this.MessageSender, required this.MessageText, required this.isMe });

  final String MessageText;
  final String MessageSender;
  bool isMe;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(10),
      child: Column(
        crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Text(
            '$MessageSender',
          style: TextStyle(
            fontSize: 12,
            color: Colors.black45,
          ),
          ),
          Material(
          elevation: 5,
          borderRadius: isMe ? BorderRadius.only(topLeft: Radius.circular(30),
              bottomLeft: Radius.circular(30),
              bottomRight: Radius.circular(30)) : BorderRadius.only( bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30), topRight: Radius.circular(30))
          ,
          color: isMe ? Colors.lightBlueAccent : Colors.white,
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
            child: Text(
              '$MessageText',
              style: TextStyle(
                fontSize: 15,
                color: isMe ? Colors.white : Colors.black54,
              ),
            ),
          ),
        )
      ],
      ),
    );
  }
}
