import 'package:firebase_storage/firebase_storage.dart';
import 'dart:math';


class UserFirebaseStorage{

static final FirebaseStorage _firebaseStorageInstance = FirebaseStorage.instance;
static final Reference _userBucket = _firebaseStorageInstance.ref().child('user/');



static Future<String?> getProfImage () async{
 try{
    ListResult result = await _userBucket.child('profile_default/').listAll();

    int randomIndex = Random().nextInt(result.items.length);
    // .nextInt は 0から指定した数までの範囲でランダムに数を生成
    // 取得した要素数（6個）の中でランダムな数字を生成

    Reference randomImageRef = result.items[randomIndex];
    // ListResult型オブジェクトの .itemsメソッドは、参照ディレクトリ内の全ての要素のリスト
    // .items の後に [] を記述すると「リストからの特定の要素を取得」することの意味

     print('Download URL: 直前確認');
     String randomImageUrl = await randomImageRef.getDownloadURL();
     print('Download URL: $randomImageUrl');
     return randomImageUrl;

    } catch (e) {
      print('getProfImage: エラー ===== $e');
      return Future.value(null); 
    }
  }   




} 







