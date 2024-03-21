// @JS() アノテーションは、
// DartコードからJavaScriptの関数やオブジェクトにアクセスするために使用されます。
// これにより、DartからJavaScriptコードを「呼び出す」ことができます
@JS()

// library stripe; はその宣言の一意のまとまりを示す記述です
// インポートしたjsファイルに記述された
// 関数の "実体"、実際の処理部分をDart側から利用するために
// 関数名、引数、引数の型などの
// 呼び出しに必要な関数の「側」部分を
// Dart側で宣言する必要があります
library stripe;

import 'package:flutter/material.dart';
import 'package:js/js.dart';


// external: 関数本体がDartファイル内には定義されていないことを示します。
// 実装がDartの外部、例えば他の言語で書かれている場合で使用。
// Dartコンパイラに関数の実装が他の場所に存在することを伝えます。

// @anonymous: jsではクラス名を指定せずにオブジェクトを生成できるが
// Dartではそのような文法がないため、@anonymousアノテーションを宣言することで
// jsの匿名オブジェクトと同じように扱えるようになり
// js と Dart 間のやりとりがスムーズになる


/// jsファイルで定義された、決済画面へのリダイレクト関数を呼び出す関数の定義
/// APIを叩いて決済画面の受け入れ準備ができると、
/// sessionIdを受け取るので
/// それをリダイレクト関数に渡して画面遷移します
/// 記述場所は、UIロジックの画面遷移をトリガーする部分です
void redirectToCheckout(BuildContext _, String sessionId) async {
  // 公開鍵なので、ハードコードで記述しても安全
  final stripe = Stripe('プライマリキー');
  stripe.redirectToCheckout(CheckoutOptions(
      sessionId: sessionId,
  ));
}

// このクラスは、JavaScriptのStripeオブジェクトを
// Dartで扱うためのインターフェイスを定義しています
// クラス内のメソッドは external キーワードを使って宣言されてます
@JS()
class Stripe {
  // この行はStripeクラスのコンストラクタを宣言しています。
  // Stripeライブラリを初期化するために必要な
  // 「公開鍵」または「プライマリーキー」を引数として受け取ります。
  external Stripe(String key);
  // この行は、StripeクラスのredirectToCheckoutメソッドを宣言しています。
  // 決済画面へリダイレクトさせます。
  // セッションID、成功時・キャンセル時のリダイレクトURLなど、
  // チェックアウトプロセスをカスタマイズするパラメータが含まれます。
  external redirectToCheckout(CheckoutOptions options);
}

// Stripeクラス内で使用している CheckoutOptions型のモデルクラスを定義してます
// メンバ変数は、チェックアウトプロセスをカスタマイズするパラメータ群で構成されます
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

// CheckoutOptionsクラス内で使用している LineItem型のモデルクラスを定義してます
// チェックアウトプロセス中にユーザーが購入する商品の情報を表すクラスを定義します。
// メンバ変数は、購入する各商品の価格と数量を示します。
@JS()
@anonymous
class LineItem {
  external String get price;
  external int get quantity;

  external factory LineItem({String price, int quantity});
}