import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:on_de_band_demo_chat/firestore/room_firestore.dart';
import 'package:on_de_band_demo_chat/model/user.dart';
import 'package:on_de_band_demo_chat/utils/shared_prefs.dart';

class UserFirestore {
  static final FirebaseFirestore _firebaseFirestoreInstance = FirebaseFirestore.instance;
  static final _userCollection = _firebaseFirestoreInstance.collection('user');

  static Future<String?> insertNewAccount() async {
    try {
      final newDoc =  await _userCollection.add({  //処理に時間がかかるので await
        'name': '名無し',
        'image_path': 'https://blog.logrocket.com/wp-content/uploads/2021/05/intro-dart-flutter-feature.png',
      });

      print('アカウント作成完了');
      return newDoc.id;
    } catch(e) {
      print('アカウント作成失敗 ===== $e');
      return null;
    }
  }

  static Future<void> createUser() async {
    final myUid = await insertNewAccount();  //新しくユーザーを作成
    if(myUid != null) {
      await RoomFirestore.createRoom(myUid);  //部屋作成
      await SharedPrefs.setUid(myUid);  //端末保存
    }
  }

  //ユーザーの取得
  static Future<List<QueryDocumentSnapshot>?> fetchUsers() async {
    try {
      final snapshot = await _userCollection.get();
      // snapshot.docs.forEach((doc) {
      //   print('ドキュメントID: ${doc.id} --------- 名前: ${doc.data()['name']}');
      // });
      return snapshot.docs;
    } catch(e) {
      print('ユーザー情報の取得失敗 ===== $e');
      return null;
    }
  }

  //ユーザーの更新
  static Future<void> updateUser(User newProfile) async {
    try {
      await _userCollection.doc(newProfile.uid).update({
        'name': newProfile.name,
        'image_path': newProfile.imagePath,
      });
    } catch (e) {
      print('ユーザー情報の更新失敗 ===== $e');
    }
  }

  //ユーザー情報を取得
  static Future<User?> fetchProfile(String uid) async {
    try {
      // String uid = SharedPrefs.fetchUid()!;  //端末にuidの情報がある時のみの'！'
      final snapshot = await _userCollection.doc(uid).get();
      User user = User(
        name: snapshot.data()!['name'],
        imagePath: snapshot.data()!['image_path'],
        uid: uid,
      );

      return user;
    } catch (e) {
      print('自分のユーザー情報の取得失敗 ----- $e');
      return null;
    }
  }
}