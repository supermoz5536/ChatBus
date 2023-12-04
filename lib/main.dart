import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:udemy_copy/firebase_options.dart';
import 'package:udemy_copy/firestore/user_firestore.dart';
import 'package:udemy_copy/page/top_page.dart';
import 'package:udemy_copy/page/wait_room_page.dart';
import 'package:udemy_copy/utils/shared_prefs.dart';


void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );  
  await Shared_Prefes.setPrefsInstance();  //端末へのユーザーデータ保存メソッドを使うため、それを定義してるクラス「Shared_Prefes」のインスタンスをまず生成
  String? uid = Shared_Prefes.fetchUid(); //fetchuid()で端末にユーザー情報が保存されてるかどうか、戻り値を確認して
  if(uid == null) await Userfirestore.createUser();  //戻り値が空、つまり保存データがなければ、createUserを実行して、DBへのアカウント情報のプッシュ、トークルーム作成、端末へのuidの保存を行う
  // await RoomFirestore.fetchJoinedRooms();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const WaitRoomPage(),
    );
  }
}

