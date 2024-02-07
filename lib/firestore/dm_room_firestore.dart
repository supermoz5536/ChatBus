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

    /// TalkuserUidを取得するための予備記述
    /// 'jointed_user'フィールドの各配列に記述されたIDを
    /// リスト型変数 userIds に各々代入する
    for(var doc in snapshot!.docs){
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
  static Future<String?> createDmRoom(String? myUid, String? talkUserUid) async {
    try {
      DocumentReference docRef = await _dMRoomCollection.add({
        'jointed_user': [myUid, talkUserUid],
        'created_time': Timestamp.now(),
      });
      return docRef.id;
    } catch (e) {
      print('ルーム作成失敗 ===== &e');
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






// 入力フィールドのメッセージ情報を
// dmroomコレクション > 任意のdmroom > messageサブコレクション
// に write する関数
  static Future<void> sendDM({required String? dMRoomId, required String? message}) async {
    try {
      // messageサブコレクション内に、messageドキュメントを新規作成する
      final messageCollection = _dMRoomCollection.doc(dMRoomId).collection('message'); 
      await messageCollection.add({
        'message': message,
        'translated_message': '',
        'sender_id': Shared_Prefes.fetchUid(),
        'send_time': Timestamp.now(),
      });

      /// messageドキュメントを作成後
      /// そのmessage内容で、last_messageフィールドを更新する
      await _dMRoomCollection.doc(dMRoomId).update({
        'last_message': message,
      });

    } catch (e) {
      print('メッセージ送信失敗 ===== $e');
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



  
}

