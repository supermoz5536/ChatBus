import 'package:cloud_functions/cloud_functions.dart';
// import 'package:deepl_dart/deepl_dart.dart';

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
    // ignore: unused_catch_stack
    } on FirebaseFunctionsException catch (e, stackTrace) {
      throw FirebaseFunctionsException(
        code: 'トランザクション内部エラー',
        message: 'message: $e',
        // stackTrace: stackTrace,
      );
    }
}



// 翻訳処理
static  Future<String>? translateDeepL(String message, String targetLang) async {
  final HttpsCallable callable = FirebaseFunctions.instance.httpsCallable('translateDeepL');
    try {
      final HttpsCallableResult result = await callable.call(<String?, dynamic>{
        //callメソッドで、引数を渡しながら実行
        //callable.call()は、サーバーサイドの関数がエラーをスローした場合
        //そのエラーをFutureのエラーとして返す
        'text': message,
        'target_lang': targetLang,
      });
        // result.data に翻訳結果が含まれています
        final String translatedText = result.data['translations'][0]['text'];
        return translatedText;

    } catch (e){
    print('DeepL API Error: $e');
    return '翻訳失敗';
    }
}



}