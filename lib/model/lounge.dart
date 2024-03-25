/// コンストラクタ生成用クラス

class Lounge{
  // LogInPageとmain.dartからのLougePageへの遷移する際に
  // showDialogの表示を適切にスイッチするためのフラグ用の変数
  // LogInPage(永久アカウントログイン成功) → LoungePage の場合に
  // showDialogを表示させないために利用するので
  // 他のコンストラクタ生成では false がデフォルト値
  bool? showDialogAble;
  // LogInPageとmain.dartを除いたLougePageへの遷移を判断するためのフラグ用変数
  bool? afterInitialization;

Lounge({
  required this.showDialogAble,
  required this.afterInitialization,
});
}