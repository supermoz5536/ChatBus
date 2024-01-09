import 'package:flutter/material.dart';
// FlutterのMaterialデザインウィジェットライブラリをインポート。


class SlideRightRoute extends PageRouteBuilder {
// FlutterのMaterialデザインウィジェットライブラリをインポート
// メンバ変数に遷移先のページを表すWidgetを持つ
  final Widget page;

  
  SlideRightRoute({required this.page})
  // 画面遷移の関数なので、引数に遷移先ページの情報が必須

      : super(
        // Dartでは、（:）は「初期化リスト」を開始を宣言する記号
        // 初期化リストは親クラスのコンストラクタを呼び出し、初期化するためのもの
        // 継承した子クラスを作成する場合、子クラスのコンストラクタで親クラスのコンストラクタを呼び出して初期化する必要がある
        // super は「子クラス」から「親クラス」の「メソッド/コンストラクタ」の呼び出しに使用
        // 親クラス（PageRouteBuilder）のコンストラクタを呼び出すことで
        // PageRouteBuilderの機能（ページの作成と遷移アニメーションの作成）の利用ができる

        // superの()内に、親クラスのコンストラクタの引数を記述する
        // 今回その引数に対応する部分は「pageBuilder」「transitionsBuilder」

        // pageBuilder
          // (BuildContext、Animation<double>、Animation<double>の3つの引数を取る)
            // 遷移先のページ（Widget）を返す

        // transitionsBuilder
          // (BuildContext、Animation<double>、Animation<double>、Widgetの4つの引数を取る)
            // 遷移アニメーション（SlideTransition）を返す

          pageBuilder: (
          // pageBuilderは、遷移先のページを作成する関数
            BuildContext context,
            Animation<double> animation,
            Animation<double> secondaryAnimation,
          ) => page,

          transitionsBuilder: (
          // transitionsBuilderは、遷移アニメーションを作成する関数です。
            BuildContext context,
            Animation<double> animation,
            Animation<double> secondaryAnimation,
            Widget child,

          ) => SlideTransition(
               // SlideTransitionウィジェットを使用して、スライドアニメーションを作成します。            
                  position: Tween<Offset>(
                  // Tween<Offset>を使用して、スライドの開始位置と終了位置を定義します。
                  // ここでは、開始位置は画面の左端（Offset(-1, 0)）で、終了位置は画面の中央（Offset.zero）です。  
                      begin: const Offset(-1, 0),
                      // (dx, dy)の座標軸表記
                      end: Offset.zero,
                    ).animate(
                        CurvedAnimation(
                            parent: animation,
                            curve: Curves.ease,
                        ),
                      ),
                      // Animation<double>で取得したanimationオブジェクトは初期値が0に設定されており
                      // これを親（初期値）として、非線形のカーブのアニメーションを設定

            
            child: child,
            // childは、遷移先のページ（すなわち、SlideTransitionの子ウィジェット）です。
          ),
        );
}
