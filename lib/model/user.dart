class User {  //ユーザーというオブジェクトに関するテンプレート
String name;  //文字を入れることのできる "name" というラベルを貼った箱
String uid;   
String? ImagePath;   //?をつけるとnull（変数に何も入れなくてもOK）を許容

//コンストラクタの定義＝実際にユーザーに具体的な値を入れて実体化するときに行われる処理を書いてく
User({
  required this.name, //名前(namae)は必ず必要(require)なので定義
  required this.uid, //名前(uid)は必ず必要(require)なので定義
  required this.ImagePath, //pf画像(ImagePath)は必ずしも必要じゃない(not require)なのでnull
});
}
