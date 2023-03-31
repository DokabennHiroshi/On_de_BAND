import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:on_de_band_demo_chat/firestore/user_firestore.dart';
import 'package:on_de_band_demo_chat/model/talk_room.dart';
import 'package:on_de_band_demo_chat/model/user.dart';
import 'package:on_de_band_demo_chat/utils/shared_prefs.dart';

class RoomFirestore {
  static final FirebaseFirestore _firebaseFirestoreInstance = FirebaseFirestore.instance;
  static final _roomCollection = _firebaseFirestoreInstance.collection('room');
  static final joinedRoomSnapshot = _roomCollection.where('joined_user_ids', arrayContains: SharedPrefs.fetchUid()).snapshots();

  //アカウント作成時に自分以外とのトークルーム作成
  static Future<void> createRoom(String myUid) async {
    try {
      final docs = await UserFirestore.fetchUsers();
      if(docs == null) return;
      docs.forEach((doc) async {
        if(doc.id == myUid) return;
        await _roomCollection.add({
          'joined_user_ids': [doc.id, myUid],  //トークルームの参加メンバー
          'created_time': Timestamp.now(),  //作られた時の時刻
        });
      });
    } catch(error) {
      print('ルームを作成失敗 ===== $error');
    }
  }

  //自分が参加しているルームを取得
  static Future<List<TalkRoom>?> fetchJoindRooms(QuerySnapshot snapshot) async {
    try {
      String myUid = SharedPrefs.fetchUid()!;
      // final snapshot = await _roomCollection.where('joined_user_ids', arrayContains: myUid).get();
      List<TalkRoom> talkRooms = [];
      for(var doc in snapshot.docs) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        List<dynamic> userIds = data['joined_user_ids'];
        late String talkUserUid;
        for(var id in userIds) {  //ルームの相手のIDを取得
          if(id == myUid) continue;
          talkUserUid = id;
        }
        User? talkUser = await UserFirestore.fetchProfile(talkUserUid);
        if(talkUser == null) return null;
        final talkRoom = TalkRoom(
          roomId: doc.id,
          talkUser: talkUser,
          lastMessage: data['last_message']
        );
        talkRooms.add(talkRoom);
      }

      return talkRooms;
    } catch (e) {
      print('参加しているルームの取得失敗 ===== $e');
      return null;
    }
  }

  //ルームコレクションmessageのスナップショットを取得
  static Stream<QuerySnapshot> fetchMessageSnapshot(String roomId) {
    return _roomCollection.doc(roomId).collection('message').orderBy('send_time', descending: true).snapshots();  // orderBy('send_time', descending: true)  新しいメッセージが下に来るように調整
  }

  //メッセージコレクションにドキュメントを追加
  static Future<void> sendMessage({required String roomId, required String message}) async {
    try {
      final messageCollection = _roomCollection.doc(roomId).collection('message');
      await messageCollection.add({
        'message': message,
        'sender_id': SharedPrefs.fetchUid(),
        'send_time': Timestamp.now(),
      });

      //最後のメッセージを更新
      await _roomCollection.doc(roomId).update({
        'last_message': message,
      });
    } catch (e) {
      print('メッセージの送信失敗 ===== $e');
    }
  }
}