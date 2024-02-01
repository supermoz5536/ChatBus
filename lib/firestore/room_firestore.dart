import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:udemy_copy/firestore/user_firestore.dart';
import 'package:udemy_copy/model/talk_room.dart';
import 'package:udemy_copy/utils/shared_prefs.dart';
import '../model/user.dart';


class RoomFirestore {
  static final FirebaseFirestore _firebasefirestoreInstance = FirebaseFirestore
      .instance; //FirebaseFirestore.instanceは、FirebaseFirestoreというクラスのインスタンスを返す機能。FirebaseFirestore.instanceはライブラリで定義されたものをimportしてる
  static final _roomCollection = _firebasefirestoreInstance.collection('room');
  static final jointRoomSnapshot = _roomCollection
      .where('jointed_user', arrayContains: Shared_Prefes.fetchUid())
      .snapshots(); //.snapshots()で部屋をリアルタイムで更新するstreamができた //https://sl.bing.net/j0zROaXAUVM

  static Future<String?> createRoom(String? myUid, String? talkUserUid) async {
    //AさんとBさんがすでにuserにいて、Cさんが作成されたら、A-C B-Cの部屋を作る
    try {
      DocumentReference docRef = await _roomCollection.add({
        'jointed_user': [myUid, 'none'],
        'created time': Timestamp.now(),
      });
      return docRef.id;
    } catch (e) {
      print('ルーム作成失敗 ===== &e');
      return null;
    }
  }

  static Future<void> updateRoom(String? myRoomId, String? talkUserUid) async {
    try {
      await _roomCollection.doc(myRoomId).update({
        'jointed_user': FieldValue.arrayRemove(['none']),
      });
      await _roomCollection.doc(myRoomId).update({
        'jointed_user': FieldValue.arrayUnion([talkUserUid]),
      });
    } catch (e) {
      print('doc(myRoomId)の[1]、noneをtalkuserUidに更新失敗 ===== $e');
    }
  }

  static Future<String?> deleteRoom(String? myRoomId) async {
    try {
      await _roomCollection.doc(myRoomId).delete();
      return null;
    } catch (e) {
      print('myRoomの削除失敗 ===== $e');
      return null;
    }
  }

  static Future<String?> getRoomMember(String? myUid, String? roomId) async {
    // print('getRoomMember関数の実行確認');
    try {
      // ■■■■■■■■■■■■■■■■■■論理エラー頻出ポイント■■■■■■■■■■■■■■■■■■■■■■
      DocumentSnapshot docSnapshot = await _roomCollection.doc(roomId).get();
      // ■■■■■■■■■■■■■■■■■■論理エラー頻出ポイント■■■■■■■■■■■■■■■■■■■■■■

      if (docSnapshot.exists) {
        Map<String, dynamic> data = docSnapshot.data() as Map<String, dynamic>;
        List<String> jointedUser = List<String>.from(data['jointed_user']);
        // .fromメソッド：dynamicListの各要素がString型として新しいリストstringListにコピーされるので安全
        // asメソッド： 元のリストの型を強制的に変更 → 元のリストの型があってない場合エラーになる可能性

        String roomMemberUid = jointedUser.firstWhere((user) => user != myUid);
        // print('getRoomMember関数で取得したtalkuerUid == $roomMemberUid');
        // firstWhereメソッドで、jointedUserリストの中でuserがmyUidと一致しない最初の要素を返す
        return roomMemberUid;
      }
      return null;
    } catch (e) {
      print('roomMemberUidの取得失敗 ===== $e');
      return null;
    }
  }

//自分の参加してるルームの情報だけを取得する関数
// static Future<List<TalkRoom>?> fetchJoinedRooms(QuerySnapshot snapshot) async{  //この引数のsnapshotはどこで取得してるのか？
//   try{
//     String myUid = Shared_Prefes.fetchUid()!;               //自分の所属してるルームがある時だけ(!)取得 //fetchUid()は端末に保存してあるユーザーIDを取得
// List<TalkRoom> talkRooms = []; //List<○○型> 変数 = [] ○型の新しい空のリストを作成し、それを変数に代入してる　https://terupro.net/flutter-dart-grammar-list

// for(var doc in snapshot.docs){
//                         //snapshotは、自分が参加してるトークルームの情報、そのドキュメント情報を変数docに順々に代入してく
//   Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
//   List<dynamic> userIds = data['jointed_user'];    //順々に代入された各doc(各トークルーム情報)から'Joined_user_ids'というDB上のフィールドのデータを取得し、それをuserIdsというリストに格納
//   late String talkUserUid;                                  //初期化に大入地が用意できてないので、lateを設定して、後で代入処理をプログラミング
//   for(var id in userIds){                                   //userIdsの各要素（id）に対してループを開始　ローラー作戦でチェック
// if(id == myUid) continue;                                     //idが端末に保存してある自分のID、つまり myUidと一致する場合は、何も処理をしない=return
// talkUserUid = id;                                           //一致しない場合は相手のユーザーidで talkUserUidに代入、ここ部分のためのlate
// }
//   User? talkUser = await UserFirestore.fetchProfile(talkUserUid);     //相手のUserIdがわかったので、それを元に相手のユーザー情報を取得
//   if(talkUser == null) return null;
//   final talkRoom = TalkRoom(             //インスタンス変数を代入して、個々のTalkRoomをインスタンス化
//     roomId: doc.id,

//     );
//   talkRooms.add(talkRoom);
// }
// print(talkRooms.length);

//     return talkRooms;
//   } catch(e) {
// print('参加してるルーム情報の取得失敗 ===== $e');
// return null;
//   }
// }

//任意のユーザーとのトークルームのメッセージのスナップショットを取得する関数
//つまり新しいメッセージがDBに追加されるたびに、トークルームのスナップショットが流れてくるstreamを作る
  static Stream<QuerySnapshot> fetchMessageSnapshot(String roomId) {
    //QuerySnapshotはcloudfirestoreライブラリのクラス //DBへのクエリ（リクエスト）に対して、結果(snapshot)を出力するクラス
    //取得したいルームのIDを与える必要があるので、変数roomIdとして受けれるように引数で設定

    return _roomCollection
        .doc(roomId)
        .collection('message')
        .orderBy('send_time', descending: true)
        .snapshots();
    //DB上の、roomのcollectionから、ID指定した任意のルームの、messageのcollectionへのstreamができた。
    //orderBy()の用法について　https://sl.bing.net/GxKL2wdx1g
  }

//入力フィールドのメッセージ情報を、Firestore上のroomにpushする関数
  static Future<void> sendMessage({required String roomId, required String message}) async {
    try {
      final messageCollection = _roomCollection.doc(roomId).collection('message'); 
      await messageCollection.add({
        'message': message,
        'translated_message': '',
        'sender_id': Shared_Prefes.fetchUid(),
        'send_time': Timestamp.now(),
      });

      await _roomCollection.doc(roomId).update({
        'lastMessage': message,
      });
    } catch (e) {
      print('メッセージ送信失敗 ===== $e');
    }
  }


  static Future<void> updateTranslatedMessage(String? roomId, String? messageId, String? translatedMessage) async {
    try {
      final messageDoc = _roomCollection.doc(roomId).collection('message').doc(messageId); 
      await messageDoc.update({
        'translated_message': translatedMessage
      });
    } catch (e) {
      print('メッセージ送信失敗 ===== $e');
    }
  }



}
