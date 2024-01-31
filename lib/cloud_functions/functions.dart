import 'package:cloud_functions/cloud_functions.dart';
// import 'package:deepl_dart/deepl_dart.dart';

class CloudFunctions{


static Future<String> getCountryFromIP(String? ip) async {
  HttpsCallable callable = FirebaseFunctions.instance.httpsCallable('getCountryFromIP');
  final result = await callable.call(<String, dynamic>{
    'ip': ip,
  });

  return result.data['country'];
}



// 翻訳処理
static  Future<String>? translateDeepL(String message, String targetLang) async {
  print('API呼び出し開始: $message');
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
              print('API呼び出し完了: ${result.data['translations'][0]['text']}');
        final String translatedText = result.data['translations'][0]['text'];
        return translatedText;

    } catch (e){
    print('DeepL API Error: $e');
    return '翻訳失敗';
    }
}



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



}