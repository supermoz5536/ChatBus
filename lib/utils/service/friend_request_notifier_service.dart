/// ■ dmroomドキュメントから取得した変更の snapshot を、 
/// 状態管理してるList<map>型の通知オブジェクトに加えるサービスファイルを作成（
/// streamメソッドとproviderの更新）
/// 通知をリスナーする関数なので
/// 実行は、userがログインした直後がよい

import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:udemy_copy/firestore/user_firestore.dart';
import 'package:udemy_copy/model/friend_request_notification.dart';
import 'package:udemy_copy/model/user.dart';
import 'package:udemy_copy/riverpod/provider/friend__request_notifications_provider.dart';


class FriendRequestNotifierService {
  final WidgetRef ref;
  FriendRequestNotifierService(this.ref);  

  Timer? _debounceTimer; // デバウンス用のタイマー
  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _friendRequestSubscription;

  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? setupFriendRequestNotification(String? myUid) {
    print('setupFriendRequestNotification: 実行開始');
    try{
      var friendRequestStream = UserFirestore.streamFriendRequestNotification(myUid);    
      _friendRequestSubscription = friendRequestStream.listen((snapshot) async{
            // リスナー起動後、一定時間内に同じリスナー処理がない場合に限り
            // 最初のリスナーを実行する処理です。
            // 確認された場合は、確認した処理を元に再度やり直します。
            // デバウンス中(isActive == true)の場合: キャンセルして新しくバウンス開始
            // デバウンス中(isActive == null)の場合: キャンセルして再度でバウンス開始
            if (_debounceTimer?.isActive ?? false) _debounceTimer!.cancel();
              _debounceTimer = Timer(const Duration(milliseconds: 250), () async{
                if (snapshot.docs.isNotEmpty) {

                  for (var docChange in snapshot.docChanges) {
                    if (
                        // docChange.doc.data()!.containsKey('is_unread') &&
                        docChange.type == DocumentChangeType.added
                     || docChange.type == DocumentChangeType.modified
                    ) {
                      // lisner が stream から変更を取得するたびに
                      // snapshotの各々データ を List<String?>?型の
                      // notification オブジェクトの要素に追加する.
                      for (var doc in snapshot.docs) {
                        // 既読処理用のdmRoomId と
                        // UI表示用の相手の名前の取得
                        Map<String, dynamic>? docMap = doc.data();

                        print('fasfasdfas');
                        // talkuserUid の 'user_name'フィールドの値を取得
                        User? talkuserProf = await UserFirestore.fetchProfile(doc.data()['friend_uid']);
                        
                        // 状態変数に.addする要素のインスタンスを作成.
                        FriendRequestNotification? notification = FriendRequestNotification(
                          friendName: talkuserProf!.userName,
                          frienduserUid: docMap['friend_uid'],
                          requestStatus: doc.data()['request_status'],
                        );
                        print('サービス内 request_status: ${talkuserProf!.userName}');
                        print('サービス内 request_status: ${docMap['friend_uid']}');
                        print('サービス内 request_status: ${doc.data()['request_status']}');


                        // 作成したインスタンスで状態更新
                        ref.read(friendRequestNotificationsProvider.notifier).addFriendNotification(notification);
                        }
                    }
                  }
              }
          });
        });     
      return _friendRequestSubscription;   
    }catch (e){
      print('setupUnreadDMNotification( ): DMRoomIdのstream取得失敗');
      return null;
    }
  }





}

