import 'package:cloud_firestore/cloud_firestore.dart';

class Message {
  //  必要なもの  メッセージ、誰が送ったか、送受信日時、
  String message;
  bool isMe;
  Timestamp sendTime;

  Message({
    required this.message,  // required 必須事項
    required this.isMe,
    required this.sendTime,
  });
}