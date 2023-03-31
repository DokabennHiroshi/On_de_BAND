import 'package:on_de_band_demo_chat/model/user.dart';

class TalkRoom {
  //  必要なもの  ルームID,トークユーザー、最後のメッセージ
  String roomId;
  User talkUser;
  String? lastMessage;

  TalkRoom({
    required this.roomId,
    required this.talkUser,
    this.lastMessage,
  });
}