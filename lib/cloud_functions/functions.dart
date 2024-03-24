import 'package:cloud_functions/cloud_functions.dart';
// import 'package:deepl_dart/deepl_dart.dart';

class CloudFunctions{

/// Stripe APIを叩いてセッションの作成とそのセッションIDの取得を行うCloud Funtions関数の呼び出し関数
static Future<String> callCreateCheckoutSession(String? myUid) async {
  final HttpsCallable callable = FirebaseFunctions.instance.httpsCallable('createCheckoutSession');
  final HttpsCallableResult result = await callable.call({
    'uid': myUid,
  });
  return result.data;
}

/// Stripe APIを叩いてPremiumプランを解約を行うCloud Funtions関数の呼び出し関数
static Future<String?> callUpdateCancelAtPeriodEnd(String? myUid) async {
  print('2 callCancelPremium');
  print('myUid == $myUid');
  try { 
    final HttpsCallable callable = FirebaseFunctions.instance.httpsCallable('updateCancelAtPeriodEnd');
    final HttpsCallableResult result = await callable.call({
      'uid': myUid,
    });
    // レスポンスデータから'message'キーに対応する値を取得
    String message = result.data["message"];
    print("Function response message: $message");
    return message; // 'message'の値を返す

  } on FirebaseFunctionsException catch (e) {
    // Firebase Functions からのエラーをキャッチ
    print("callCancelPremium エラーコード: ${e.code}");
    print("callCancelPremium エラーメッセージ: ${e.message}");
    print("callCancelPremium 詳細: ${e.details}");
  } catch (e) {
    // その他のエラーをキャッチ
    print("callCancelPremium 予期せぬエラーが発生しました: $e");
  }
}



/// 国名を取得するCloud Functions関数の呼び出し関数です
static Future<String> getCountryFromIP(String? ip) async {
  HttpsCallable callable = FirebaseFunctions.instance.httpsCallable('getCountryFromIP');
  final result = await callable.call(<String, dynamic>{
    'ip': ip,
  });

  return result.data['country'];
}



/// DeepL APIを叩くCloud Functions関数の呼び出し関数です
static  Future<String>? translateDeepL(String? message, String? targetLang) async {
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
        return result.data['translations'][0]['text'];

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