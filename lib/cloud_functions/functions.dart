import 'dart:html';

import 'package:cloud_functions/cloud_functions.dart';

class CloudFunctions{

static Future<void> runTransactionDB(String? myUid, String? talkuserUid, String? myRoomId) async {
  final HttpsCallable callable = FirebaseFunctions.instance.httpsCallable('runTransaction');
  // httpsCallableメソッドで、サーバーサイド関数を呼び出すためのオブジェクトを準備
  //「サーバーサイドの関数を呼び出すためのインターフェースを提供するオブジェクト」のインスタンス
  // httpsCallableクラスのインスタンス
    try{
    await callable.call(<String?, dynamic>{
      //callメソッドで、引数を渡しながら実行
      //callable.call()は、サーバーサイドの関数がエラーをスローした場合
      //そのエラーをFutureのエラーとして返す
      'myUid': myUid,
      'talkuserUid': talkuserUid,
      'myRoomId': myRoomId,
    });

    } on FirebaseFunctionsException catch (e){
      print('The function called has thrown an error: $e');
      throw FirebaseFunctionsException(
        code: 'INTERNAL',
        details: e,
        message: 'An internal error occurred: $e'
      );

    

    }
}


}