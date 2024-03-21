@JS()
library stripe;

import 'package:flutter/material.dart';
import 'package:js/js.dart';

void redirectToCheckout(BuildContext _, String sessionId) async {
  // 公開鍵なので、ハードコードで記述しても安全
  final stripe = Stripe('プライマリキー');
  stripe.redirectToCheckout(CheckoutOptions(
      sessionId: sessionId,
  ));
}

@JS()
class Stripe {
  external Stripe(String key);
  external redirectToCheckout(CheckoutOptions options);
}

@JS()
@anonymous
class CheckoutOptions {
  external String get mode;
  external String get sessionId;
  external String get successUrl;
  external String get cancelUrl;

  external factory CheckoutOptions({
    List<LineItem> lineItems,
    List<String> paymentMethodTypes,
    String mode,
    String successUrl,
    String cancelUrl,
    String sessionId,
  });
}

@JS()
@anonymous
class LineItem {
  external String get price;
  external int get quantity;

  external factory LineItem({String price, int quantity});
}