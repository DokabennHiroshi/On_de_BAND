import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:on_de_band_demo_chat/firestore/room_firestore.dart';
import 'package:on_de_band_demo_chat/model/talk_room.dart';
import 'package:on_de_band_demo_chat/pages/setting_profile_page.dart';
import 'package:on_de_band_demo_chat/pages/talk_room_page.dart';

class TopPage extends StatefulWidget {
  const TopPage({super.key});

  @override
  State<TopPage> createState() => _TopPageState();
}

class _TopPageState extends State<TopPage> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:AppBar(
        title: const Text('chat app'),
        actions: [  //右側に増やす
          IconButton(
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(
                builder: (context) => const SettingProfilePage()
              ));
            },
            icon: const Icon(Icons.settings)
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: RoomFirestore.joinedRoomSnapshot,  //自分が参加しているルームのドキュメントが作られるとStreamBuilderが実行
        builder: (context, streamSnapshot) {
          if(streamSnapshot.hasData) {
            return FutureBuilder<List<TalkRoom>?>(
              future: RoomFirestore.fetchJoindRooms(streamSnapshot.data!),
              builder: (context, futureSnapshot) {
                if(futureSnapshot.connectionState == ConnectionState.waiting) {  //ロード中
                  return const Center(child: CircularProgressIndicator());
                } else {
                  if(futureSnapshot.hasData) {
                    List<TalkRoom> talkRooms = futureSnapshot.data!;
                    return ListView.builder(  //メイン操作画面
                      itemCount: talkRooms.length,  //トークにいるユーザーの人数
                      itemBuilder: (context, index) {
                        return InkWell(
                          onTap: () {  //押されたら画面遷移
                            // print(talkRooms[index].roomId);  //選択したルームID
                            Navigator.push(context, MaterialPageRoute(
                              builder: (context) => TalkRoomPage(talkRooms[index])
                            ));
                          },
                          child: SizedBox(  //リストを出力している
                            height: 70,
                            child: Row(  //横並び
                              children: [
                                Padding(  //指定箇所に余白
                                  padding: const EdgeInsets.symmetric(horizontal: 8.0),  //上下に同じ分の余白
                                  child: CircleAvatar(
                                    radius: 30,
                                    backgroundImage: talkRooms[index].talkUser.imagePath == null ? null : NetworkImage(talkRooms[index].talkUser.imagePath!),
                                  ),
                                ),
                                Column(  //縦並び
                                  crossAxisAlignment: CrossAxisAlignment.start,  //左寄せ
                                  mainAxisAlignment: MainAxisAlignment.center,  //縦中央寄せ
                                  children: [
                                    Text(talkRooms[index].talkUser.name, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                                    Text(talkRooms[index].lastMessage ?? '', style: TextStyle(color: Colors.grey)),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      }
                    );
                  } else {
                    return const Center(child: Text('トークルームの取得に失敗しました'));
                  }
                }
              }
            );
          } else {
            return const Center(child: CircularProgressIndicator());  //ロードマーク
          }
        }
      ),
    );
  }
}