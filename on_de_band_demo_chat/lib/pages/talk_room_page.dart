import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:on_de_band_demo_chat/firestore/room_firestore.dart';
import 'package:on_de_band_demo_chat/model/message.dart';
import 'package:on_de_band_demo_chat/model/talk_room.dart';
import 'package:on_de_band_demo_chat/utils/shared_prefs.dart';
import 'package:intl/intl.dart' as intel;  //頭に印を付けないと使えないようにする

class TalkRoomPage extends StatefulWidget {
  final TalkRoom talkRoom;
  const TalkRoomPage(this.talkRoom, {super.key});  //他のスクリプトから値を受け取って格納

  @override
  State<TalkRoomPage> createState() => _TalkRoomPageState();
}

class _TalkRoomPageState extends State<TalkRoomPage> {

  final TextEditingController controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.lightBlueAccent,
      appBar: AppBar(
        title: Text(widget.talkRoom.talkUser.name),  // widget.name とすることで TalkRoomPage の変数を使用可能
      ),
      body: Stack(
        // alignment: Alignment.bottomCenter,  //最終的な下寄せを行うためにコメントアウト
        children: [
          StreamBuilder<QuerySnapshot>(
            stream: RoomFirestore.fetchMessageSnapshot(widget.talkRoom.roomId),
            builder: (context, snapshot) {
              if(snapshot.hasData) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 60),
                  child: ListView.builder(
                    physics: const RangeMaintainingScrollPhysics(),  //画面幅を超えるリストの要素が表示されればスクロール可能になる
                    shrinkWrap: true,  //リストの要素数幅分にコンパクト化
                    reverse: true,  //リストが下に追加されていくように
                    itemCount: snapshot.data!.docs.length,
                    itemBuilder: (context, index) {
                      final doc = snapshot.data!.docs[index];
                      final Map<String, dynamic> data = doc.data() as Map<String, dynamic>;  //型変換
                      final Message message = Message(
                        message: data['message'],
                        isMe: SharedPrefs.fetchUid() == data['sender_id'],  //自分のIDとmessageの送信者のIDが一致するか
                        sendTime: data['send_time'],
                      );
                      return Padding(
                        padding: EdgeInsets.only(top: 10, left: 10, right: 10, bottom: index == 0 ? 20 : 0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          textDirection: message.isMe ? TextDirection.rtl : TextDirection.ltr,  //自分は右寄せ、その他は左寄せ
                          children: [
                            Container(
                              constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.65),  //表示範囲を画面幅の指定割合までに設定
                              decoration: BoxDecoration(
                                color: message.isMe ? Colors.green : Colors.white,
                                borderRadius: BorderRadius.circular(15),
                              ),
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                              child: Text(message.message)),
                            Text(intel.DateFormat('HH:mm').format(message.sendTime.toDate())),   // // DateTime 型を文字列に変換    pubspec.yaml/cupertino_icons: ^1.0.2 の下に intl: any を記述
                          ],
                        ),
                      );
                    }
                  ),
                );
              } else {
                return const Center(child: Text('メッセージがありません'));
              }
            }
          ),
          Column(
            // mainAxisSize: MainAxisSize.min,  //下寄せ
            mainAxisAlignment: MainAxisAlignment.end,  //最終的な下寄せ
            children: [
              Container(
                color: Colors.white,
                height: 60,
                child: Row(  //入力欄、送信ボタン類
                  children: [
                   Expanded(child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: TextField(
                        controller: controller,  //入力された文字列を取得
                        decoration: const InputDecoration(
                          contentPadding: EdgeInsets.only(left: 10),
                          border: OutlineInputBorder()
                        ),
                      ),
                    )),
                    IconButton(
                      onPressed: () async {
                        // print(controller.text);
                        await RoomFirestore.sendMessage(
                          roomId: widget.talkRoom.roomId,
                          message: controller.text,
                        );
                        controller.clear();  //入力欄の文字列をクリア
                      },
                      icon: const Icon(Icons.send)
                    )
                  ],
                ),
              ),
              Container(  //ホームに戻る時に干渉しないようにする余白
                color: Colors.white,
                height: MediaQuery.of(context).padding.bottom,
              ),
            ],
          )
        ],
      ),
    );
  }
}