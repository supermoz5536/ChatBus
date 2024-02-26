import 'package:firebase_storage/firebase_storage.dart';
import 'dart:math';
import 'package:path_provider/path_provider.dart';

class UserFirebaseStorage{

static final FirebaseStorage _firebaseStorageInstance = FirebaseStorage.instance;
static final Reference _userBucket = _firebaseStorageInstance.ref().child('user/');



static Future<String?> downloadAndUploadProfImage(String? myUid, Reference? randomImageRef) async{
 try{
      print('downloadAndUploadProfImage 実行開始');

      // systemバケットの'random_profile_image'階層内にある
      // ランダム指定した画像データの参照を用いてバイト(画像)データを取得
      final byteData = await randomImageRef!.getData();  

      // storageのmyUidの階層に、
      // ① 参照を作成して
      // ② 取得データをアップロード
      Reference? myDirRef = _userBucket.child('$myUid/profile_image/profile_image.png');
      await myDirRef.putData(byteData!);

      // 保存した画像のURLを取得
      String? userImageUrl = await myDirRef.getDownloadURL();
      return userImageUrl;
    } catch (e) {
      print('downloadAndUploadImage: エラー ===== $e');
      return Future.value(null); 
    }
  }   


} 







