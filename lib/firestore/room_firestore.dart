import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:udemy_copy/firestore/user_firestore.dart';
import 'package:udemy_copy/model/talk_room.dart';
import 'package:udemy_copy/utils/shared_prefs.dart';
import '../model/user.dart';


class RoomFirestore {
  static final FirebaseFirestore _firebasefirestoreInstance = FirebaseFirestore.instance; //FirebaseFirestore.instanceは、FirebaseFirestoreというクラスのインスタンスを返す機能。FirebaseFirestore.instanceはライブラリで定義されたものをimportしてる
  static final _roomCollection = _firebasefirestoreInstance.collection('room');
  static final _jointRoomSnapshot = _roomCollection
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

  static Future<void> deleteRoom(String? myRoomId) async {
    try {
      await _roomCollection.doc(myRoomId).delete();
      return;
    } catch (e) {
      print('myRoomの削除失敗 ===== $e');
      return;
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



  //任意のユーザーとのトークルームのメッセージのスナップショットを取得する関数
  //つまり新しいメッセージがDBに追加されるたびに、トークルームのスナップショットが流れてくるstreamを作る
  static Stream<QuerySnapshot> fetchMessageSnapshot(String roomId) {
    // QuerySnapshotはcloudfirestoreライブラリのクラス 
    // DBへのクエリ（リクエスト）に対して、結果(snapshot)を出力するクラス
    // 取得したいルームのIDを与える必要があるので、変数roomIdとして受けれるように引数で設定

    return _roomCollection
            .doc(roomId)
            .collection('message')
            .orderBy('send_time', descending: true)
            .snapshots();
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
