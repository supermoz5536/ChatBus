import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:udemy_copy/authentication/auth_service.dart';
import 'package:udemy_copy/cloud_functions/functions.dart';
import 'package:udemy_copy/cloud_storage/user_storage.dart';
import 'package:udemy_copy/model/user.dart';
import 'package:udemy_copy/utils/http_functions.dart';
import '../utils/shared_prefs.dart';
import 'dart:ui' as ui;

class UserFirestore {
  static final FirebaseFirestore _firebasefirestoreInstance = FirebaseFirestore.instance;
  /// FirebaseFirestore.instanceは、FirebaseFirestoreというクラスのインスタンスを返す機能。FirebaseFirestore.instanceはライブラリで定義されたものをimportしてる
  static final _userCollection = _firebasefirestoreInstance.collection('user');
  /// 上行で実体化させたインスタンスは、Firestoreの具体的なデータベース情報なので、collectionの中のuserの情報を、変数_userCollectionに代入してる＝データベース連携してると考えていい


  /// getAccountの条件分岐図
  /// 端末保存uidが「無い」場合 → 「新規作成」 or 「ログインページ」
  /// 端末保存uidが「有る」場合は、以下の条件分岐
  ///   　.getでデータに取得に「成功」した場合ば、さらに条件分岐
  ///  　　　 .getでデータに取得に「成功」した場合で、DB上に端末保存idと同じidが「ある」場合 → 「db上のidを継続使用」
  ///   　　　.getでデータに取得に「成功」した場合で、DB上に端末保存idと同じidが「ない」場合 → 「新規作成」 or 「ログインページ」
  ///  　 .getでデータに取得に「失敗」した場合 → 「新規作成」 or 「ログインページ」
  /// 補足: 地域と言語の設定情報に関して、ログイン（キャッシュが消えてる）の場合は、dbからreadして端末にsedDataする。
  static Future<Map<String, dynamic>?> getAccount() async{
  try {
        /// 端末保存uidが存在しているかを確認
        String? sharedPrefesMyUid = Shared_Prefes.fetchUid();
        // String? sharedPrefesMyUid = "dsffdaegaga";
        print('sharedPrefesMyUid == $sharedPrefesMyUid');



         /// ■ 端末保存uidが「無い」場合
         if(sharedPrefesMyUid == null || sharedPrefesMyUid.isEmpty){
            print('既存の端末uid = 未登録');

            /// 匿名認証とUidの取得
            String? authUid = await FirebaseAuthentication.getAuthAnonymousUid();

            /// 画像 言語コード 国コード(IPから) の取得
            String? userImageUrl = await UserFirebaseStorage.getProfImage();
            String? deviceLanguage = ui.window.locale.languageCode;
            String? ip = await Http.getPublicIPAddress();
            String? deviceCountry = await CloudFunctions.getCountryFromIP(ip);
            
            
              /// 新規アカウントを追加
              /// supportInitFields()で、全Fieldは初期値に設定
              await _userCollection
                .doc(authUid)
                .set(UserFirestore.supportInitFields(
                    userImageUrl: userImageUrl,
                    deviceLanguage: deviceLanguage,
                    deviceCountry: deviceCountry,
                )
              );
                    /// 端末のuid更新              
                    await Shared_Prefes.setData({
                        'myUid': authUid!,
                        'language': deviceLanguage,
                        'country': deviceCountry,              
                      });
                      print('アカウント作成完了1');
                      print('端末のuid更新完了');
                      print('最新の端末保存uid $authUid');  
                                                  
                      return {
                        'myUid': authUid,
                        'userName': 'user_name',
                        'userImageUrl': userImageUrl,
                        'statement': 'statement',
                        'language': deviceLanguage,
                        'country': deviceCountry, 
                        'native_language': '',
                        'gender': 'male',
                        'isNewUser': 'isNewUser'                   
                      };                      
         }


          
         /// ■ 端末保存uidが「有る」場合          
         if(sharedPrefesMyUid.isNotEmpty) {                                    
            print('既存の端末uid = $sharedPrefesMyUid');
            DocumentSnapshot? docIdSnapshot = await _userCollection
                                                    .doc(sharedPrefesMyUid)
                                                    .get();            /// SharedPrefesUidと一致するドキュメントIDを取得
                                                                       /// docIdSnapshot = 「ドキュメントのid」「fieldの各data」が格納                 
             /// ■ .getでデータに取得に「成功」した場合
             if (docIdSnapshot.exists) {


                 /// ■ .getでデータに取得に「成功」した上で、DB上に端末保存idと同じidが「ある」場合
                 if (docIdSnapshot.id == sharedPrefesMyUid ) {                        
                     print('DB上に端末保存uidと一致するuid確認 ${docIdSnapshot.id}');

                     /// Field情報をリフレッシュして、既存の端末Uidをそのまま使用
                     /// ① プロフimageのURLは、匿名認証IDの保存画像を引き継ぐ　「匿名認証が実装できるまでは、とりあえずランダム取得」
                     /// ② 言語は、新規作成時はデバイス設定言語 →「手動変換 & db保存」→ 継続利用でfield値を継続　「やるだけ」
                     /// ③ Field値の継続 「やるだけ」

                    String? userImageUrl = await UserFirebaseStorage.getProfImage(); // ■■■■①■■■■ 匿名認証が設定できたら修正
                    String? deviceCountry = Shared_Prefes.fetchCountry();
                    Map<String, dynamic> docData = docIdSnapshot.data() as Map<String, dynamic>;
                    
                     await _userCollection.doc(sharedPrefesMyUid).update({ 
                        'matched_status': true,                         
                        'room_id': 'none',
                        'progress_marker': true,
                        'chatting_status': true,
                        'is_lounge': true,                           
                        'created_at': FieldValue.serverTimestamp(),                                                                              
                     }); 
                       return {
                        'myUid': sharedPrefesMyUid,
                        'userName': docData['user_name'],
                        'userImageUrl': userImageUrl,
                        'statement': docData['statement'],
                        'language': docData['language'],
                        'country': deviceCountry,
                        'native_language': '',
                        'gender': docData['gender'],
                       };



                 } else {
                 /// ■ .getでデータに取得に「成功」した上で、DB上に端末保存idと同じidが「ない」場合

                     /// 匿名認証とUidの取得
                     String? authUid = await FirebaseAuthentication.getAuthAnonymousUid();

                     /// 画像 言語コード 国コード(IPから) の取得
                     String? userImageUrl = await UserFirebaseStorage.getProfImage();
                     String? deviceLanguage = ui.window.locale.languageCode;
                     String? ip = await Http.getPublicIPAddress();
                     String? deviceCountry = await CloudFunctions.getCountryFromIP(ip);

                        /// 新規アカウントを作成
                        /// supportInitFields()で、全Fieldは初期値に設定
                        await _userCollection
                          .doc(authUid)
                          .set(UserFirestore.supportInitFields(
                              userImageUrl: userImageUrl,
                              deviceLanguage: deviceLanguage,
                              deviceCountry: deviceCountry,
                           )
                        );        
                        await Shared_Prefes.setData({
                          'myUid': authUid!,
                          'language': deviceLanguage,
                          'country': deviceCountry,                             
                        });                            
                           print('アカウント作成完了2');
                           print('端末のuid更新完了');
                           print('最新の端末保存uid $authUid');    

                        return {
                        'myUid': authUid,
                        'userName': 'user_name',
                        'userImageUrl': userImageUrl,
                        'statement': 'statement',
                        'language': deviceLanguage,
                        'country': deviceCountry,
                        'native_language': '',
                        'gender': 'male',
                        'isNewUser': 'isNewUser'
                        };      
                    }


                  
            //  } else { // ■■■■■■■■■■■■■■■ この条件分岐は catch error で処理されるので必要ない可能性が高い ■■■■■■■■■■■■■■■
            //  /// ■ .getでデータに取得に「失敗」した場合
            //  /// つまり、既存の端末Uidはあるが、db上にUidが既に削除されてる場合
            //  /// 新規アカウント作成 ＆ 端末Uid更新

            //     /// 匿名認証とUidの取得
            //     String? authUid = await FirebaseAuthentication.getAuthAnonymousUid();

            //     /// 画像 言語コード 国コード(IPから) の取得
            //     String? userImageUrl = await UserFirebaseStorage.getProfImage();
            //     String? deviceLanguage = ui.window.locale.languageCode;
            //     String? ip = await Http.getPublicIPAddress();
            //     String? deviceCountry = await CloudFunctions.getCountryFromIP(ip);

            //       /// 新規アカウントを追加
            //       /// supportInitFields()で、全Fieldは初期値に設定
            //       await _userCollection
            //       .doc(authUid)
            //       .set(UserFirestore.supportInitFields(
            //           userImageUrl: userImageUrl,
            //           deviceLanguage: deviceLanguage,
            //           deviceCountry: deviceCountry,
            //        )
            //       );        
            //       await Shared_Prefes.setData({
            //         'myUid': authUid!,
            //         'language': deviceLanguage,
            //         'country': deviceCountry,                           
            //       });
            //           print('アカウント作成完了3');
            //           print('端末のuid更新完了');
            //           print('最新の端末保存uid $authUid');          
                      
            //       return {
            //             'myUid': authUid,
            //             'userName': 'user_name',
            //             'userImageUrl': userImageUrl,
            //             'statement': 'statement',
            //             'language': deviceLanguage,
            //             'country': deviceCountry,
            //             'native_language': '',
            //             'gender': 'male',
            //             'isNewUser': 'isNewUser'
            //       };
          }
         }
         return null;
         
      }catch(e){
         print('getAccount失敗 $e');
      return null;
      }
}




  static Map<String, dynamic> supportInitFields({
    String? userImageUrl,
    String? deviceLanguage,
    String? deviceCountry,
  }) {
    return {
      'matched_status': true,
      'room_id': 'none',
      'progress_marker': true,
      'chatting_status': true,
      'is_lounge': true,
      'user_name': 'user_name',
      'user_image_url': userImageUrl,
      'statement': 'ああああああああああああああああああああああああああああああああああああああああああああああああああああああああああああああああああああああああ',
      'language': deviceLanguage,
      'country': deviceCountry,
      'native_language': '',
      'gender': '',
      'queried_language': '',
      'queried_gender': '',
      'created_at': FieldValue.serverTimestamp(),
    };
  }  







//   static Future<void> createUser() async{
//   final myUid = await UserFirestore.getAccount(); //ユーザー情報をpushして、DBにユーザーアカウントを作成
//   if(myUid != null) {                     //DB上に自分のユーザーアカウントが確認できたなら・・・
//     Shared_Prefes.setData(myUid);          //setUidメソッドで実際に端末へユーザーデータを保存する
//   }
// }




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



  static Future<String?> getUnmatchedUser(
    String? myUid,
    String? meGender,
    String? selectedLanguage,
    List<String?>? meNativeLanguage,
    String? selectedGender,
    ) async{   
    try {
      // print('selectedGender == $selectedGender');
      // print('meGender == $meGender');
      // print('selectedLanguage[0] == $selectedLanguage');
      // print('meNativeLanguage[0] == ${meNativeLanguage![0]}'); 
      // print('meNativeLanguage[1] == ${meNativeLanguage[1]}');      

      // 基本クエリの構築
      var query = _userCollection
                  .where('matched_status', isEqualTo: false)
                  .where('progress_marker', isEqualTo: false)
                  .where(FieldPath.documentId, isNotEqualTo: myUid)
                  .where("native_language", arrayContains: selectedLanguage)
                  .where("queried_language", whereIn: meNativeLanguage);

      // selectedGender の要素数に基づくクエリの条件分岐
        // ジェンター指定がある場合: 指定に合致するドキュメントのみ参照 (male, female)
        // ジェンター指定がない場合: 何もしない (both)
        if (selectedGender == 'male' || selectedGender == 'female') {
            query = query.where('gender', isEqualTo: selectedGender);
        }

          // クエリの実行
          QuerySnapshot<Map<String, dynamic>> querySnapshot = await query.limit(4).get();
          print('querySnapshot.docs.length == ${querySnapshot.docs.length}');   

          if (querySnapshot.docs.isEmpty) return null;
          if (querySnapshot.docs.isNotEmpty) {
          // Genderフィルターで特定の性別を指定してる人が
          // Genderフィルターにbothを指定してるユーザーからのマッチングを避ける処理
          // 「課金(性別指定)してる、かつ、同性とのマッチングを希望してる」、つまり
          // (limit)4人で埋まってなければOK → 確率的に考慮しなくて良いのでOK
              List<DocumentSnapshot> docs = querySnapshot.docs;
              List<DocumentSnapshot> filteredDocs = docs.where((doc) {
                String? filteredDoc = doc['queried_gender'];
                return filteredDoc == 'both' || filteredDoc == meGender;
                // 2つの条件のいずれかが真である場合にtrueを返し、
                // そうでない場合はfalseを返す記述です
              }).toList();
                if (filteredDocs.isNotEmpty){
                  filteredDocs.shuffle();
                  DocumentSnapshot filteredDocsFirst = filteredDocs[0];
                  print("talkuserUid: Document[0] ID: ${filteredDocsFirst.id}");
                    return filteredDocsFirst.id;
                } else {
                    return null;
                }
          }    
        return null;
        
      } catch (e) {
        print('getUnmatchedUser: ERROR == $e');
        return null;
      }
  }           






   
   static Stream<QuerySnapshot<Object>> streamUnmatchedUser(String myUid){   //ここからが取得する処理の記述
    try {                                                         
        return _userCollection.where(FieldPath.documentId, isNotEqualTo: myUid)
                              .where('matched_status', isEqualTo: false)
                              .limit(1)
                              .snapshots();                              

    } catch(e) {
        print('streamによる、matched_statusがfalseのユーザー情報の取得失敗 ===== $e');
        print('streamによる、matched_statusがfalseのユーザー情報の取得失敗 ===== テスト表示');
        return const Stream<QuerySnapshot<Object>>.empty();  // 空のストリームを返す
        
    }
  }

   static Stream<QuerySnapshot<Object>> streamHistoryCollection(String? myUid){   //ここからが取得する処理の記述
    try {                                                         
        return _userCollection.doc(myUid)
                              .collection('history')
                              .orderBy('created_at', descending: true)
                              .snapshots();                              

    } catch(e) {
        print('streamによる、Historyの参照失敗 ===== $e');
        return const Stream<QuerySnapshot<Object>>.empty();  // 空のストリームを返す
        
    }
  }


   static Stream<DocumentSnapshot<Map<String, dynamic>>> streamProfImage(String? myUid){   //ここからが取得する処理の記述
    try {                                                         
        return _userCollection.doc(myUid).snapshots();                           

    } catch(e) {
        print('streamによる、Historyの参照失敗 ===== $e');
        return const Stream<DocumentSnapshot<Map<String, dynamic>>>.empty();  // 空のストリームを返す
        
    }
  }




   static aimUserFields(String? uid) {   //ここからが取得する処理の記述
     return _userCollection.doc(uid);
     
     }
    
  




  static tUpdateField(String? talkuserUid, String? roomId, bool matchedStatus){
    if(talkuserUid != null){
      return  _userCollection.doc(talkuserUid).update({
        'matched_status': matchedStatus,
        'room_id': roomId,
      });
    }
  }
  //ユーザーコレクションから相手のドキュメントを取得
  //取得したドキュメントをマップに変換
  //該当の項目を更新




//DocumentSnapshot型について　→  https://sl.bing.net/bQeSPlCC23w
static Stream<DocumentSnapshot<Map<String, dynamic>>> streamMyDoc(String? myUid){
try {                                                         
      return _userCollection.doc(myUid).snapshots();
   
    } catch(e) {
      print('matched_statusがfalseのユーザー情報の取得失敗 ===== $e');
      return const Stream<DocumentSnapshot<Map<String, dynamic>>>.empty();  // 空のストリームを返す      

    }
  }


  //DocumentSnapshot型について　→  https://sl.bing.net/bQeSPlCC23w
static Stream<DocumentSnapshot<Map<String, dynamic>>> streamTalkuserDoc(String? talkuserUid){
try {                                                         
      return _userCollection.doc(talkuserUid).snapshots();
   
    } catch(e) {
      print('matched_statusがfalseのユーザー情報の取得失敗 ===== $e');
      return const Stream<DocumentSnapshot<Map<String, dynamic>>>.empty();  // 空のストリームを返す      

    }
  }

/// 任意のuserUidで、そのプロフィール用のField情報を取得する関数
static Future<User?> fetchProfile(String? uid) async{
  try{
      final snapshot = await _userCollection.doc(uid).get(); 
      print('fetchProfile snapshot: $snapshot');

      User user = User(
        uid: uid,
        userName: snapshot.data()!['user_name'],
        userImageUrl: snapshot.data()!['user_image_url'],
        statement: snapshot.data()!['statement'],
        language: snapshot.data()!['language'],
        country: snapshot.data()!['country'],
      );

return user;   //DBから取得した自分のデータを代入した、プロフィール情報を出力する

  }catch(e) {
    print('ユーザー情報取得失敗 ----- $e');
    return null;
  }
}



static Future<void> retry(String? myUid, bool? shouldBreak, Function f, {int maxRetries = 500}) async {
  Random random = Random();  

  for (int i = 0; i < maxRetries; i++) {
    try { 
      if (shouldBreak == false) {
        // print('shouldBreak == false: retry関数内の処理開始');      
        return await f();

      } else if (shouldBreak == true) {
        print('shouldBreak == true: なのでretry終了');
        return;
      }


      } catch (e) {
        //関数fの実行中に例外をキャッチした場合
        //retry()では、try-catchが例外をキャッチしてもretryする仕様        

        int randomSeconds = 4333 + random.nextInt(2000);
          await Future.delayed(Duration(milliseconds: randomSeconds));  

        if (e.toString() == 'Exception: End Retry') {       
          //talkuserUidを捕捉したけど「される場合」の処理が既に始まってたら、retry終了  
          print('End Retry の例外をキャッチ');
          return;
        }        

        if (i == maxRetries - 1){ 
            print('Attempt $i failed: $e');
          rethrow;
        }
      }
  }
}
      // DocumentSnapshot documentSnapshot = await _userCollection.doc(myUid).get();
  // bool myMatchedStatus = await documentSnapshot.get('matched_status');
      // if(myMatchedStatus == false) {
      //   print('myUidの matched_status == {$myMatchedStatus}なのでretry関数内の処理開始');      
      //   return await f();

      // } else if(myMatchedStatus == true) {
      //   print('myUidの matched_status == {$myMatchedStatus}なのでretry終了');
      //   break;
      // }






static updateProgressMarker(String? uid, bool progressStatus) async{
        await _userCollection.doc(uid).update({'progress_marker': progressStatus});     
}


static updateMatchedStatus(String? uid, bool matchedStatus) async{
        await _userCollection.doc(uid).update({'matched_status': matchedStatus});     
}


static Future<void> updateChattingStatus(String? uid, bool chattingStatus) async{
      return await _userCollection.doc(uid).update({'chatting_status': chattingStatus});     
}


static Future<void> updateIsLounge(String? uid, bool isLounge) async{
      return await _userCollection.doc(uid).update({'is_lounge': isLounge});     
}


static Future<void> updateLanguage(String? uid, String? language) async{
      return await _userCollection.doc(uid).update({'language': language});     
}

static Future<void> updateGender(String? uid, String? gender) async{
      return await _userCollection.doc(uid).update({'gender': gender});     
}

static checkMyProgressMarker(String? myUid,) async{
 DocumentSnapshot docMyUid = await _userCollection.doc(myUid).get();     
      return docMyUid['progress_marker'];
}

static Future<void> initForMatching (
  String? myUid,
  String? selectedLanguage,
  List<String?>? selectedNativeLanguageList,
  String? selectedGender,


  ) async{

      await _userCollection.doc(myUid).update({
         'matched_status': false,
         'room_id': 'none',
         'progress_marker': false,
         'chatting_status': true,
         'is_lounge': false,
         'native_language': selectedNativeLanguageList,
         'queried_language': selectedLanguage,
         'queried_gender': selectedGender
        }); 
      return ;    
  
}


static Future<void> updateHistory (String? myUid, String? talkuserUid, String? roomId) async{
       DocumentSnapshot docSnapshot = await _userCollection.doc(talkuserUid).get();
       String name = docSnapshot['user_name'];
       String profileImage = docSnapshot['user_image_url'];

      await _userCollection.doc(myUid).collection('history').add({
          'user_name': name,
          'user_image_url': profileImage,
          'talkuser_id': talkuserUid,
          'room_id': roomId,           
          'created_at': FieldValue.serverTimestamp(),          
      });
}


  static Stream<QuerySnapshot> friendSnapshot(String? myUid) {
  /// QuerySnapshot は Firestore ライブラリのクラス
  /// DBへのクエリ（リクエスト）に対して、結果(snapshot)を出力するクラス
  /// orderBy()の用法について　https://sl.bing.net/GxKL2wdx1g    
    return _userCollection
            .doc(myUid)
            .collection('friend')
            // .orderBy('num', descending: true)
            .snapshots();
  }




static Future<void> setFriendUid(String? targetUid, String? setUid, User userData) async {
    try {
      await _userCollection.doc(targetUid)
                           .collection('friend')
                           .doc(setUid)
                           .set({
                            'user_name': userData.userName,
                            'user_image_url': userData.userImageUrl,
                            'statement': userData.statement,
                           });
      return;
    } catch (e) {
      print('friendUidの削除失敗 ===== $e');
      return;
    }
  }



  static Future<void> deleteFriendUid(String? targetUid, String? deleteUid) async {
    try {
      await _userCollection.doc(targetUid)
                           .collection('friend')
                           .doc(deleteUid)
                           .delete();
      return;
    } catch (e) {
      print('friendUidの削除失敗 ===== $e');
      return;
    }
  }


  /// uidが既にフレンド登録済みかを確認する関数です
  static Future<bool> checkExistFriendUid(String? myUid, String? talkuserUid) async {
    try {
      final DocumentSnapshot documentSnapshot =  await _userCollection.doc(myUid)
                                                        .collection('friend')
                                                        .doc(talkuserUid)
                                                        .get();
        print('checkExistFriendUid == ${documentSnapshot.exists}');

      return documentSnapshot.exists;
    } catch (e) {
      print('checkExistFriendUid: 実行失敗 ===== $e');
      return false;
    }
  }

  /// uidが既にフレンドリクエスト中かを確認する関数です
  static Future<bool> checkExistFriendRequest(String? myUid, String? talkuserUid) async {
    try {
      final DocumentSnapshot documentSnapshot =  await _userCollection.doc(myUid)
                                                        .collection('friend_request')
                                                        .doc(talkuserUid)
                                                        .get();
        print('checkExistFriendRequestId == ${documentSnapshot.exists}');

      return documentSnapshot.exists;
    } catch (e) {
      print('checkExistFriendRequest: 実行失敗 ===== $e');
      return false;
    }
  }



static Future<void> setFriendRequestToFriend(String? talkuserUid, String? myUid) async {
    try {
      await _userCollection.doc(talkuserUid)
                           .collection('friend_request')
                           .doc(myUid)
                           .set({
                             'friend_uid': myUid,
                             'request_status': 'pending',
                           });

      return;
    } catch (e) {
      print('setFriendRequestToFriend: requestドキュメント作成失敗 ===== $e');
      return;
    }
  }

  static Future<void> setFriendRequestToMe(String? myUid, String? talkuserUid) async {
    try {
      await _userCollection.doc(myUid)
                           .collection('friend_request')
                           .doc(talkuserUid)
                           .set({
                             'friend_uid': talkuserUid,
                             'request_status': 'waiting',
                           });

      return;
    } catch (e) {
      print('setFriendRequestToFriend: requestドキュメント作成失敗 ===== $e');
      return;
    }
  }
  

}

