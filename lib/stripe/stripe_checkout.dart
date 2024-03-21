// Flutter Web用の決済画面へのリダイレクト関数である
// redirectToCheckout関数のインポート先のファイルを
// プラットフォーム別でスイッチさせる責務のファイルです。
// Flutter Webの場合は（正常）: stripe_checkout_web.dartをimportします
// それ以外の場合は（エラー）: stripe_checkout_stub.dartをimportしてエラーをスローします

import 'package:flutter/material.dart';

import 'stripe_checkout_stub.dart'
    if (dart.library.js) 'stripe_checkout_web.dart' as impl;

void redirectToCheckout(BuildContext context, String sessionId) =>
    impl.redirectToCheckout(context, sessionId);