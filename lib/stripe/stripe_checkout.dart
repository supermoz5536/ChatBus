// Flutter Web用の決済画面へのリダイレクト関数である
// redirectToCheckout関数のインポート先のファイルを
// プラットフォーム別でスイッチさせる責務のファイルです。
// Flutter Webの場合は（正常）: stripe_checkout_web.dartをimportします
// それ以外の場合は（エラー）: stripe_checkout_stub.dartをimportしてエラーをスローします

import 'package:flutter/material.dart';

import 'stripe_checkout_stub.dart'
    if (dart.library.js) 'stripe_checkout_web.dart' as impl;

class StripeCheckout{
  
  static void redirectToCheckout(BuildContext context, String sessionId) {
    print('1 redirectToCheckout');
    print('1.1 sessionID == $sessionId');
       impl.StripeCheckoutWebStub.redirectToCheckout(context, sessionId);
    print('4 redirectToCheckout');
  }

}

