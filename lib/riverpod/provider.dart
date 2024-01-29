/// Providerを定義するファイル
/// 状態管理したい値を、Providerの中に定義する

import 'package:flutter_riverpod/flutter_riverpod.dart';



/// Providerの実装 と グローバル変数(状態)の宣言
/// return される返り値が、管理対象の状態変数
/// main.dartでprovider.dartをimportすることで、このグローバル変数はmain.dartで呼び出し可能になる。
/// 呼び出しの記述サンプル：ref.read(languageCodeProvider)
/// 状態値の更新場所は、lounge_page.dart > initState()
final languageCodeProvider = StateProvider<String>((ref) {
  return 'es';
});

