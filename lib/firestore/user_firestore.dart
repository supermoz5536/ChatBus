import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:udemy_copy/model/user.dart';
import '../utils/shared_prefs.dart';
// import 'package:firebase_core/firebase_core.dart';
// import 'package:flutter/widgets.dart';

class UserFirestore {
  static final FirebaseFirestore _firebasefirestoreInstance = FirebaseFirestore.instance;
      //FirebaseFirestore.instanceは、FirebaseFirestoreというクラスのインスタンスを返す機能。FirebaseFirestore.instanceはライブラリで定義されたものをimportしてる
  static final _userCollection = _firebasefirestoreInstance.collection('user');
      //上行で実体化させたインスタンスは、Firestoreの具体的なデータベース情報なので、collectionの中のuserの情報を、変数_userCollectionに代入してる＝データベース連携してると考えていい


  static Future<String?> getAccount() async{                      //端末のuidでDBを検索し、一致するアカウントがあればuidを取得、なければアカウントを新規作成してそのuidを取得
         String? sharedPrefesUid = Shared_Prefes.fetchUid();      //端末保存uidの取得

         if(sharedPrefesUid == null){ //端末保存uidが「無い」場合
             print('既存の端末uid = 未登録');
                  final newDoc = await _userCollection.add({                      //DB上に新規アカウント作成
                        'matched_status': false,
                        'room_id': 'none',
                  });        
                    Shared_Prefes.setUid(newDoc.id);                              //端末のuid更新完了
                        print('アカウント作成完了');
                        print('端末のuid更新完了');
                        print('最新の端末保存uid ${newDoc.id}');          
                    return newDoc.id;                         
          }
          
          
           if(sharedPrefesUid.isNotEmpty) { //端末保存uidが「有る」場合
             print('既存の端末uid = ${sharedPrefesUid}');
         DocumentSnapshot? docIdSnapshot = await _userCollection.doc(sharedPrefesUid).get(); //SharedPrefesUidと一致するドキュメントIDを取得
                         //docIdSnapshot = 「ドキュメントのid」「fieldの各data」が格納        
   
            
                  if (docIdSnapshot.exists){             
                      print('DB上のuid = ${docIdSnapshot.id}');
                  } else {
                      print('DB上のuid = 未登録');    
                          }  
                  

      
                if(docIdSnapshot.id == sharedPrefesUid ) {                       //DB上に端末保存idと同じidがある場合 → そのまま使えばいい  
                    print('DB上に端末保存uidと一致するuid確認 ${docIdSnapshot.id}');
                    return sharedPrefesUid;                                       //fetchUid()で呼び出した端末保存uidをそのまま出力                                    ΩΩ 

                }else{                                                             //DB上に端末保存idと同じidがない場合 → 新規アカウント作成　＆　端末IDの更新
                  final newDoc = await _userCollection.add({                      //DB上に新規アカウント作成
                        'matched_status': false,
                        'room_id': 'none',
                  });        
                    Shared_Prefes.setUid(newDoc.id);                              //端末のuid更新完了
                        print('アカウント作成完了');
                        print('端末のuid更新完了');
                        print('最新の端末保存uid ${newDoc.id}');          
                    return newDoc.id;  

  }
  }
}


    //   } catch (e) {
    //   print('アカウント作成失敗 ===== &e'); // ここではエラー（例外）をどのように処理するかを定義する
    //   return null;
    // }
  


  static Future<void> createUser() async{
  final myUid = await UserFirestore.getAccount(); //ユーザー情報をpushして、DBにユーザーアカウントを作成
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



  static Future<String?> getUnmatchedUser(String? myUid) async{   
    // try {     
      QuerySnapshot<Map<String, dynamic>> querySnapshot = await _userCollection.where('matched_status', isEqualTo: false)
                                                                               .where(FieldPath.documentId, isNotEqualTo: myUid)
                                                                               .limit(4) 
                                                                               .get();
                                                                               //黄色五角形エラーが出るが問題ない（.getの取得doc数 == 0の時に表示される模様）
        
             print('matched_statusがfalseのdocId取得数 ${querySnapshot.docs.length}');   


          if(querySnapshot.docs.isEmpty){
             print('マッチング可能な相手がDB上に0人');
             return null;
            }


          if (querySnapshot.docs.isNotEmpty) {

             List<DocumentSnapshot> docs = querySnapshot.docs;
                                    docs.shuffle();

             DocumentSnapshot docSnapshotFirst = docs[0];
             print("Document[0] ID: ${docSnapshotFirst.id}");      //それ以外の場合→ First[0]のuidを返す                           
             return docSnapshotFirst.id;
             }    

             return null;
           }           


              //  if(querySnapshot.docs.length == 1 && docSnapshotFirst.id == myUid ){   //if(取得データ数１でそれが自分の場合) → nullを返す
              //     print('No matched_status false was found');
              //    return null;}

            //    if(querySnapshot.docs.length >= 2 && docSnapshotFirst.id == myUid){    //取得データ数2以上だが、First[0]が自分の場合→ Second[1]のuidを返す
            //  DocumentSnapshot docSnapshotSecond = docs[1];
            //       print("Document[1] ID: ${docSnapshotSecond.id}");                                                      
            //      return docSnapshotSecond.id;}    
  

                                                                        
                                                       
          



          // DocumentSnapshot docSnapshotFirst = querySnapshot.docs.first;
          // return docSnapshotFirst.id;

    // } catch(e) {
    //   print('matched_statusがfalseのユーザー情報の取得失敗 ===== $e');
    //   return null;
    // }



   //QuerySnapshot型について　→  https://sl.bing.net/bQeSPlCC23w                                                                     
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





  static updateDocField(String? talkuserUid, String? roomId, bool matchedStatus){
    if(talkuserUid != null){
      return _userCollection.doc(talkuserUid).update({
        'matched_status': matchedStatus,
        'room_Id': roomId,
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


//stream用に、自分のドキュメント情報の'matched_status'に snapshotsを設定
//'matched_status'の




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