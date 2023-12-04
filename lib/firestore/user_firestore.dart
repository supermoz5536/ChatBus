import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:udemy_copy/model/user.dart';
import '../utils/shared_prefs.dart';
import 'room_firestore.dart';
// import 'package:firebase_core/firebase_core.dart';
// import 'package:flutter/widgets.dart';

class UserFirestore {
  static final FirebaseFirestore _firebasefirestoreInstance = FirebaseFirestore.instance;
      //FirebaseFirestore.instanceは、FirebaseFirestoreというクラスのインスタンスを返す機能。FirebaseFirestore.instanceはライブラリで定義されたものをimportしてる
  static final _userCollection = _firebasefirestoreInstance.collection('user');
      //上行で実体化させたインスタンスは、Firestoreの具体的なデータベース情報なので、collectionの中のuserの情報を、変数_userCollectionに代入してる＝データベース連携してると考えていい


  static Future<String?> insertNewAccount() async{     //ここにユーザーを作成する処理（関数）を書く
    try {                                              // エラーを検知する記述：ここにはエラーが発生する可能性のあるコードを書く
    final newDoc = await _userCollection.add({         //時間のかかる処理なのでawaitにする //_userCollectionというfirestoreのコレクションに新しい情報を追加してる
        'name': '名無し',      //初期値に'名無し'を設定
        'image_Path': 'https://www.kewpie.co.jp/ingredients/cat_assets/img/fruits/apple/photo01.jpg'
});   
      print('アカウント作成完了');
        return newDoc.id;

      } catch (e) {
      print('アカウント作成失敗 ===== &e'); // ここではエラー（例外）をどのように処理するかを定義する
      return null;
    }
  }


  static Future<void> createUser() async{
  final myUid = await UserFirestore.insertNewAccount(); //ユーザー情報をpushして、DBにユーザーアカウントを作成
  if(myUid != null) {                     //DB上に自分のユーザーアカウントが確認できたなら・・・
    Shared_Prefes.setUid(myUid);          //setUidメソッドで実際に端末へユーザーデータを保存する
  }

}


   static Future<List<QueryDocumentSnapshot>?> fetchUsers() async{   //ここからが取得する処理の記述
  //List<QueryDocumentSnapshotはFirestoreから取得した各ドキュメントのデータを表すオブジェクト
    try {                                                            //通信が走るのでtry tatchでエラーハンドリング
    final snapshot = await _userCollection.get();
    return snapshot.docs; 
    } catch(e) {
      print('ユーザー情報の取得失敗 ===== $e');
      return null;
    }
  }

                                                                     //ここまでがログイン時のアカウントを作成する処理の記述
   static Stream<QuerySnapshot>? fetchUnmatchedUsers(){   //ここからが取得する処理の記述
  //List<QueryDocumentSnapshotはFirestoreから取得した各ドキュメントのデータを表すオブジェクト
    try {                                                            //通信が走るのでtry tatchでエラーハンドリング
    return _userCollection.where('matched_status', isEqualTo: false).limit(1).snapshots();
   
    } catch(e) {
      print('ユーザー情報の取得失敗 ===== $e');
      return null;
    }
  }


//fetchUsers()がDB上の全ユーザーデータを取得する関数なので、自分のデータだけを取得して出力する関数を作る
//「端末画面の自分のアイコンをタップすると、DBから自分のデータを取得してプロフィールページを表示する」といったアクションに利用できる関数
static Future<User?> fetchProfile(String uid) async{
  try{
String uid = Shared_Prefes.fetchUid()!;                     //端末に保存してあるユーザー情報を取得して、変数uidに代入
final snapshot = await _userCollection.doc(uid).get();     //uidと一致するデータをDBから取得して、変数myProfileに代入
User user = User(                                           //class User　のインスタンスを作る
  name: snapshot.data()!['name'],                          //以下、インスタンスの各々の変数（状態）を設定する
  ImagePath: snapshot.data()!['image_path'],               //DBから取得した自分のデータを、class Userのインスタンスに代入
  uid: uid,
);
return user;                                                //DBから取得した自分のデータを代入した、プロフィール情報を出力する

  }catch(e) {
print('自分のユーザー情報取得失敗 ----- &e');
return null;
    }
  }
}