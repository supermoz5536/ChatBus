/// ■ dmroomドキュメントから取得した変更の snapshot を、 
/// 状態管理してるList<map>型の通知オブジェクトに加えるサービスファイルを作成（
/// streamメソッドとproviderの更新）
/// 通知をリスナーする関数なので
/// 実行は、userがログインした直後がよい

import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:udemy_copy/firestore/dm_room_firestore.dart';
import 'package:udemy_copy/firestore/user_firestore.dart';
import 'package:udemy_copy/model/dm_notification.dart';
import 'package:udemy_copy/model/user.dart';
import 'package:udemy_copy/riverpod/provider/dm_notifications_provider.dart';


class DMNotifierService {
  final WidgetRef ref;
  DMNotifierService(this.ref);  

  Timer? _debounceTimer; // デバウンス用のタイマー
  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _dMSubscription;

  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? setupUnreadDMNotification(String? myUid) {
    print('setupUnreadDMNotification: 実行開始');
    try{
      var dMStream = DMRoomFirestore.streamDMNotification(myUid);    
      _dMSubscription = dMStream.listen((snapshot) async{
            // リスナー起動後、一定時間内に同じリスナー処理がない場合に限り
            // 最初のリスナーを実行する処理です。
            // 確認された場合は、確認した処理を元に再度やり直します。
            // デバウンス中(isActive == true)の場合: キャンセルして新しくバウンス開始
            // デバウンス中(isActive == null)の場合: キャンセルして再度でバウンス開始
            if (_debounceTimer?.isActive ?? false) _debounceTimer!.cancel();
              _debounceTimer = Timer(const Duration(milliseconds: 250), () async{
                if (snapshot.docs.isNotEmpty) {
                  // Field情報の変更が確認されたdoc集合群に対して
                  // 変更項目にis_unread を含むdocだけ処理を実行する
                  // (意図しない変更で取得してしまったdataへの処理を回避)
                  // arrayUnionでFieldがトリガーされてるので
                  // フラグのトリガーは削除以外の変更である必要がある.
                  // フラグが削除されたデータが通ると当然論理エラーが起きてしまう
                  // (docChanges は変更の種類別でデータが格納されてる)
                  // print('1 DocumentChangeTypeのフィルター前のsnapshot == $snapshot');
                  for (var docChange in snapshot.docChanges) {
                    if (docChange.doc.data()!.containsKey('is_unread') 
                     && docChange.type == DocumentChangeType.added
                     || docChange.type == DocumentChangeType.modified
                    ) {
                      // lisner が stream から変更を取得するたびに
                      // DMRoomId を List<String?>?型の
                      // notification オブジェクトの要素に追加する.
                      for (var doc in snapshot.docs) {
                        // 既読処理用のdmRoomId と
                        // UI表示用の相手の名前の取得
                        String? talkuserUid;
                        String? talkuserName;
                        Map<String, dynamic>? docMap = doc.data();
                        List<dynamic>? jointedUserIdsDynamic = docMap['jointed_user'] as List<dynamic>?;
                        List<String>? jointedUserIds = jointedUserIdsDynamic?.whereType<String>().toList();

                        for (var userId in jointedUserIds!) {
                          if (userId == myUid) continue;
                              talkuserUid = userId;
                        }
                        
                        print('testtest');
                        // talkuserUid の 'user_name'フィールドの値を取得
                        User? talkuserProf = await UserFirestore.fetchProfile(talkuserUid);
                        talkuserName = talkuserProf!.userName;
                        
                        // 状態変数に.addする要素のインスタンスを作成.
                        DMNotification? notification = DMNotification(
                          talkuserName: talkuserName,
                          dMRoomId: doc.id,
                          lastMessage: doc['last_message'],
                        );

                        // 作成したインスタンスで状態更新
                        ref.read(dMNotificationsProvider.notifier).addDMNotification(notification);
                        }
                    }
                  }
              }
          });
        });     
      return _dMSubscription;   
    }catch (e){
      print('setupUnreadDMNotification( ): DMRoomIdのstream取得失敗');
      return null;
    }
  }





}

