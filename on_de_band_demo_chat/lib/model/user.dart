class User {
  //  必要なもの  ユーザー名、固有ID、プロフィール画像URL、ラストメッセージ
  String name;
  String uid;
  String? imagePath;

  User({
    required this.name,  // required 必須事項
    required this.uid,
    this.imagePath,
  });
}