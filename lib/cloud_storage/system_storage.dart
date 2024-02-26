import 'package:firebase_storage/firebase_storage.dart';
import 'dart:math';
import 'package:path_provider/path_provider.dart';

class SystemFirebaseStorage{

static final FirebaseStorage _firebaseStorageInstance = FirebaseStorage.instance;
static final Reference _systemBucket = _firebaseStorageInstance.ref().child('system/');



static Future<Reference?> fetchRandomProfImage () async{
 try{
    ListResult result = await _systemBucket.child('random_profile_image/').listAll();

    int randomIndex = Random().nextInt(result.items.length);
    // .nextInt は 0から指定した数までの範囲でランダムに数を生成
    // 取得した要素数（6個）の中でランダムな数字を生成.

    Reference randomImageRef = result.items[randomIndex];
    // ListResult型オブジェクトの .itemsメソッドは、参照ディレクトリ内の全ての要素のリスト
    // .items の後に [] を記述すると「リストからの特定の要素を取得」することの意味
    print(randomImageRef);

    return randomImageRef;

    } catch (e) {
      print('getProfImage: エラー ===== $e');
      return Future.value(null); 
    }
  }   



} 







