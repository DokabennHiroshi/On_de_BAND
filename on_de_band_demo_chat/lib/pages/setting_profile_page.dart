import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:on_de_band_demo_chat/firestore/user_firestore.dart';
import 'package:on_de_band_demo_chat/model/user.dart';
import 'package:on_de_band_demo_chat/utils/shared_prefs.dart';
import 'package:image_picker/image_picker.dart';

class SettingProfilePage extends StatefulWidget {
  const SettingProfilePage({super.key});

  @override
  State<SettingProfilePage> createState() => _SettingProfilePageState();
}

class _SettingProfilePageState extends State<SettingProfilePage> {
  File? image;
  String imagePath = '';
  final ImagePicker _picker = ImagePicker();
  final TextEditingController controller = TextEditingController();

  //写真フォルダ読み取り関連
  Future<void> selectImage() async {
    // XFile? pickedImage = await _picker.pickImage(source: ImageSource.gallery);  //カメラの時は gallery => camera
    PickedFile? pickedImage = await _picker.getImage(source: ImageSource.gallery);  //安定した古いバージョン
    print(pickedImage);
    if(pickedImage == null) return;
    setState(() {
      image = File(pickedImage.path);
    });
  }

  //画像をfirebaseにアップロード
  Future<void> uploadImage() async {
    String path = image!.path.substring(image!.path.lastIndexOf('/') + 1);  //パス名を固有なものに
    final ref = FirebaseStorage.instance.ref(path);
    final storedImage = await ref.putFile(image!);  //イメージをアップロードする時は画像は存在する
    imagePath = await storedImage.ref.getDownloadURL();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('プロフィール編集'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Row(  //名前入力欄
              children: [
                const SizedBox(width: 150, child: Text('名前')),
                Expanded(child: TextField(
                  controller: controller,
                ))
              ],
            ),
            const SizedBox(height: 50),
            Row(  //画像選択欄
              children: [
                const SizedBox(width: 150, child: Text('プロフィール画像')),
                Expanded(
                  child: Container(
                    alignment: Alignment.center,
                    child: ElevatedButton(
                      onPressed: () async {
                        await selectImage();
                        uploadImage();
                      },
                      child: const Text('画像を選択')
                    ),
                  ),
                )
              ],
            ),
            const SizedBox(height: 30),
            image == null ? const SizedBox() : SizedBox(width: 200, height: 200, child: Image.file(image!, fit: BoxFit.cover)),
            const SizedBox(height: 150),
            SizedBox(  //編集完了ボタン
              width: 150,
              height: 40,
              child: ElevatedButton(
                onPressed: () async {
                  User newProfile = User(
                    name: controller.text,
                    imagePath: imagePath,
                    uid: SharedPrefs.fetchUid()!,
                  );
                  await UserFirestore.updateUser(newProfile);
                },
                child: const Text('編集'),
              ),
            )
          ],
        ),
      ),
    );
  }
}