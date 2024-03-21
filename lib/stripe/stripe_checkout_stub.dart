// stripe_checkout_stub.dartは、
// Flutter web用に定義されたredirectToCheckout関数が
// Webではない状況でコンパイルされた際のエラーハンドリング用の
// スタブです。

import 'package:flutter/material.dart';

void redirectToCheckout(BuildContext context, String sessionId) =>
    throw UnsupportedError('ERROR: Web用のredirectToCheckout関数が、Webでない環境で使用されようとしてます');