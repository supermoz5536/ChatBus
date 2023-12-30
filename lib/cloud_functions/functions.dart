import 'package:cloud_functions/cloud_functions.dart';

class CloudFunctions{

static void runTransactionDB(String myUid, String talkuserUid, String myRoomId) async {
  final HttpsCallable callable = FirebaseFunctions.instance.httpsCallable('runTransaction');
  // httpsCallableメソッドで、サーバーサイド関数を呼び出すためのオブジェクトを準備
  //「サーバーサイドの関数を呼び出すためのインターフェースを提供するオブジェクト」のインスタンス
  // httpsCallableクラスのインスタンス

  await callable.call(<String, dynamic>{
    //callメソッドで、引数を渡しながら実行
    'myUid': myUid,
    'talkuserUid': talkuserUid,
    'myRoomId': myRoomId,
  });
}


}