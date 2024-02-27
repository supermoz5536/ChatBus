import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:math';
import 'package:path_provider/path_provider.dart';

class UserFirebaseStorage{

static final FirebaseStorage _firebaseStorageInstance = FirebaseStorage.instance;
static final Reference _userBucket = _firebaseStorageInstance.ref().child('user/');



static Future<String?> downloadAndUploadRandomProfImage(String? myUid, Reference? randomImageRef) async{
 try{
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



static Future<String?>? pickAndUploadProfImage(String? myUid) async{
 try{
      // ユーザーがデバイス上でファイルを選択できるようにします。
      // このメソッドは、選択されたファイルに関する情報を含む
      // FilePickerResult?オブジェクトを返します。
      // 画像選択して決定した瞬間に、awaitが解決されると思われます
      FilePickerResult? result = await FilePicker.platform.pickFiles(
                                   type: FileType.image,
                                 );                          
      if (result != null) {
      // if文で、ユーザーが実際にファイルを選択したかどうかを確認します。
      // nullの場合、ユーザーがピッカーをキャンセルしたことを意味します。 
  
        // result.files.singleは、選択された単一のファイルにアクセスします。
        // .path!は、選択されたファイルのファイルシステム上のパスを取得します。
        var byteData = result.files.single.bytes;
  
      // storageのmyUidの階層に、
      // ① 参照を作成して
      // ② データをアップロード
      Reference? myDirRef = _userBucket.child('$myUid/profile_image/profile_image.png');
      await myDirRef.putData(byteData!);

      // 保存した画像のURLを取得
      String? userImageUrl = await myDirRef.getDownloadURL();
      return userImageUrl;

      } else {
        // User canceled the picker
        return null;
      }
    } catch (e) {
      print('uploadCustomProfImage: エラー ===== $e');
      return null;
    }
  }




} 


