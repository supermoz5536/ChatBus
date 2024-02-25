import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:udemy_copy/firestore/user_firestore.dart';
import 'package:udemy_copy/model/dm.dart';
import 'package:udemy_copy/model/user.dart';
import 'package:udemy_copy/utils/shared_prefs.dart';

class DMRoomFirestore {
  
  /// FirebaseFirestore.instanceは、FirebaseFirestoreというクラスのインスタンスを返す機能。FirebaseFirestore.instanceはライブラリで定義されたものをimportしてる
  /// .snapshots()で部屋をリアルタイムで更新するstreamができた //https://sl.bing.net/j0zROaXAUVM
  static final FirebaseFirestore _firebasefirestoreInstance = FirebaseFirestore.instance; 
  static final _dMRoomCollection = _firebasefirestoreInstance.collection('dmroom');
  // static final dMRoomSnapshot = _dMRoomCollection
  //                                .where('jointed_user', arrayContains: Shared_Prefes.fetchUid())
  //                                .snapshots(); 
      




/// DMRoomPageへ画面遷移する際の、コンストラクタの生成が目的の関数
/// dmRoomコレクションのどのドキュメントか確認する必要のため
/// アイコン情報などを表示する必要のため
/// dmRoomId, talkuserUid, を取得する必要がある
static Future<List<DMRoom>?> fetchJoinedDMRooms (String? myUid, QuerySnapshot? snapshot) async{  //この引数のsnapshotはどこで取得してるのか？
  try{
      List<DMRoom> dMRooms = [];       
      print('fetchJoinedDMRooms内のデバッグプリント: ${snapshot!.docs.length}');
    /// TalkuserUidを取得するための予備記述
    /// 'jointed_user'フィールドの各配列に記述されたIDを
    /// リスト型変数 userIds に各々代入する
    for(var doc in snapshot!.docs) {
      Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      List<dynamic> userIds = data['jointed_user'];
      late String talkuserUid; // 初期値の遅延代入宣言
      

    /// TalkuserUidを取得するための本記述
    /// 'jointed_user'には myUid か talkUserUid が配置されてるので
    /// userIdsの各要素（id）に対してループ処理で確認
    /// Id == myUid: タスクを完了して次の要素の処理に移行
    /// Id != myUid: TalkUserUid
    for(var id in userIds){                                   
      if(id == myUid) continue;                                     
      talkuserUid = id;        // 遅延的な初期値の代入
      }

     User? talkuserProfile = await UserFirestore.fetchProfile(talkuserUid);

      // talkuserProfileの取得に失敗した場合の処理を追加
      if(talkuserProfile == null) {
        print('fetchJoinedDMRooms: null, talkuserProfile取得失敗');  
        // 次のループへ移行する例を示します
        continue; 
      }

      /// 要素としてのdMRoom変数にインスタンス化した値を代入
      final dMRoom = DMRoom(
        myUid: myUid,
        talkuserUid: talkuserUid,
        dMRoomId: doc.id,
        talkuserProfile: talkuserProfile,
        lastMessage: data['last_message'],
      );

      /// List<DMRoom>型の変数 dMRooms に
      /// 配列の１要素として dMRoom を追加する。
      /// 以降、全ての配列要素に対して処理が完了するまで繰り返し
      dMRooms.add(dMRoom);
    }
      return dMRooms;

    } catch(e) {
      print('参加してるルーム情報の取得失敗 ===== $e');
      return null;
    }
}






  /// dmCollection の自分が参加しているドキュメントのみ参照する関数
  static Stream<QuerySnapshot> fetchDMSnapshot(String? myUid) {
    // print('fetchDMSnapshot: myUid == $myUid');
    return _dMRoomCollection.where(
                              'jointed_user', 
                               arrayContains: myUid)
                            .snapshots();
  }




  /// DM用のトークルーム作成関数
  static Future<String?> createDMRoom(String? myUid, String? talkUserUid) async {
    try {
      DocumentReference docRef = await _dMRoomCollection.add({
        'jointed_user': [myUid, talkUserUid],
        'created_time': Timestamp.now(),
        'last_message': '',
        'is_unread': [],
      });
      return docRef.id;
    } catch (e) {
      print('ルーム作成失敗 ===== $e');
      return null;
    }
  }




  /// myUidと相手のUidでjoinedされたdmroomのID取得関数
  static Future<String?> getDMRoomId(String? myUid, String? talkuserUid) async{
    try {
       QuerySnapshot querySnapshot = await _dMRoomCollection
                                            .where('jointed_user', arrayContains: myUid)
                                            .get();
        
        for(var doc in querySnapshot.docs) {
          List jointedUser = doc['jointed_user'];
          /// db上に相手との dmroom が「ある」場合
          /// dmroomId を返す
          if (jointedUser.contains(talkuserUid)) {
            return doc.id;
          } 
        }

          /// db上に相手との dmroom が「ない」場合
          /// null を返す
            return null;
      
    } catch(e) {
      print('getDMRoomId関数の実行失敗');
      return null;
    }
  }



  /// myUidと相手のUidでjoinedされたdmroomを削除
  static Future<void> deleteDMRoom(String? dMRoomId) async{
    try {
       await _dMRoomCollection.doc(dMRoomId).delete();
      
    } catch(e) {
      print('deleteDMRoom: 実行失敗');
      return null;
    }
  }






  /// 'is_unread'Fieldの配列に、
  /// myUidを含むDMRoomIdを参照するメソッド
  static Stream<QuerySnapshot<Map<String, dynamic>>> streamDMNotification(String? myUid) {
    try {
      var stream = _dMRoomCollection.where('is_unread', arrayContains: myUid)
                                    .snapshots();

      print('Stream Query: $stream');

      return stream;
    } catch(e) {
      print('streamDMNotification関数の取得失敗 == $e');
      return const Stream<QuerySnapshot<Map<String, dynamic>>>.empty();
    }
  }





// 入力フィールドのメッセージ情報を
// dmroomコレクション > 任意のdmroom > messageサブコレクション
// に write する関数
  static Future<void> sendDM({
    required String? dMRoomId,
    required String? message,
    required String? talkuserUid,
    }) async {
    try {
      // messageサブコレクション内に、messageドキュメントを新規作成する
      final messageCollection = _dMRoomCollection
                                .doc(dMRoomId)
                                .collection('message'); 

      await messageCollection.add({
        'message': message,
        'translated_message': '',
        'sender_id': Shared_Prefes.fetchUid(),
        'send_time': Timestamp.now(),
        'is_divider': false,
      });
      
      /// messageドキュメントを作成後
      /// ①そのmessage内容で、last_messageフィールドを更新
      /// ②相手に未読フラグをstreamさせるために
      /// 'is_read'Filed の配列に talkuserUid を加える
      await _dMRoomCollection.doc(dMRoomId).update({
        'last_message': message,
        'is_unread': FieldValue.arrayUnion([talkuserUid]),
      });
    } catch (e) {
      print('メッセージ送信失敗 ===== $e');
    }
  }
  

// ■■■■■■■■■■ sendDM の batch 処理施行版 ■■■■■■■■■■
// // 入力フィールドのメッセージ情報を
// // dmroomコレクション > 任意のdmroom > messageサブコレクション
// // に write する関数
//   static Future<void> sendDM({
//     required String? dMRoomId,
//     required String? message,
//     required String? talkuserUid,
//     }) async {
//     try {
//       // batchメソッドの宣言
//       final batch = FirebaseFirestore.instance.batch();

//       // messageサブコレクション内に、messageドキュメントを新規作成する
//       DocumentReference newMessageRef = _dMRoomCollection
//                                             .doc(dMRoomId)
//                                             .collection('message')
//                                             .doc();
//       // 新しいメッセージドキュメントをバッチに追加
//       // batchメソッドを設定
//       // 参照先： newMessageRef
//       // 書き込み内容： 各Field値
//       batch.set(newMessageRef, {
//         'message': message,
//         'translated_message': '',
//         'sender_id': Shared_Prefes.fetchUid(),
//         'send_time': Timestamp.now(),
//         'is_divider': false,
//       });

//       /// DMRoomドキュメントの更新（last_messageとis_unreadフィールド）
//       // messageサブコレクション内に、messageドキュメントを新規作成する
//       DocumentReference dMRoomRef = _dMRoomCollection
//                                     .doc(dMRoomId);
//       // 親であるdMRoomドキュメントをバッチに追加
//       // batchメソッドを設定
//       // 参照先：dMRoomRef
//       // 書き込み内容：各Filed値
//       batch.update(dMRoomRef, {
//         'last_message': message,
//         'is_unread': FieldValue.arrayUnion([talkuserUid]),
//       });

//       // セットした batch をコミット。
//       await batch.commit();

//     } catch (e) {
//       print('メッセージ送信失敗 ===== $e');
//     }
//   }






  /// 自分の未読フラグを解除するために
  /// 'is_read'Filed の配列から
  /// myUidを削除します。
  static Future<void> removeIsReadElement(String? dMroomId, String? myUid) async{
    try{
      await _dMRoomCollection.doc(dMroomId).update({
        'is_unread': FieldValue.arrayRemove([myUid]),
      });
    } catch (e){
      print('removeIsReadElement: DM通知のフラグ削除失敗');
    }
  }



  /// 任意のdMRoomドキュメントのmessage更新を取得するstream
  static Stream<QuerySnapshot> streamDM(String dMRoomId) {
    return _dMRoomCollection
            .doc(dMRoomId)
            .collection('message')
            .orderBy('send_time', descending: true)
            .snapshots();
  }






/// addMessagesDMRoom()から取得したmessage情報を
/// dmroomコレクション > dmroomドキュメント > messageコレクションに
/// .addする関数です
static addMessagesDMRoom(String? dMRoomId, QuerySnapshot? roomMessages) async{

   // batchメソッドの宣言
   final batch = FirebaseFirestore.instance.batch();
   // batchの参照先を格納した変数を定義
  
  // QuerySnapshot型のメッセージの集合データを、
  // 個別の doc(=message) ごとにMap型にデータ内容を整理
  for (final messageDoc in roomMessages!.docs) {  
    Map<String, dynamic> messageData = messageDoc.data() as Map<String, dynamic>;
    // batchメソッドを設定
    // 参照先：newMessageDocRef
    // 書き込み内容：messageData

    // 参照は定義するたびに個別のドキュメントIDを生成するので
    // for(){}の内外でそれぞれ設定する必要があります。
    final newMessageDocRef = _dMRoomCollection
                        .doc(dMRoomId)
                        .collection('message')
                        .doc(); 


    batch.set(newMessageDocRef, messageData);
  }

    //最新のメッセージとして、区切りメッセージの追加
    Map<String, dynamic> dividerMessageData = {
                                                'message': '-------ここから新しいメッセージ------',
                                                'translated_message': '', 
                                                'sender_id': Shared_Prefes.fetchUid(),
                                                'send_time': Timestamp.now(),
                                                'is_divider': true,
                                                };
    final newMessageDocRef = _dMRoomCollection
                        .doc(dMRoomId)
                        .collection('message')
                        .doc(); 
    batch.set(newMessageDocRef, dividerMessageData);

  // POINT: batchメソッドでは
  // 「参照先」「書き込み内容」を
  // for(){}内で.setするだけで、
  // 参照先への追加操作がバッチされます。
  await batch.commit();
}




  static Future<void> updateTranslatedMessageForDMRoom(String? roomId, String? messageId, String? translatedMessage) async {
    try {
      final messageDoc = _dMRoomCollection.doc(roomId).collection('message').doc(messageId); 
      await messageDoc.update({
        'translated_message': translatedMessage
      });
    } catch (e) {
      print('メッセージ送信失敗 ===== $e');
    }
  }



  
}

