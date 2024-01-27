//アカウント情報を端末に保存するために、Shared_Prefesというクラスを定義
//Shared_Prefesの目的は、端末へのUidの保存。
//_preferencesという変数を定義して
//関数「setPrefsInstance　_preferencesで、「SharedPreferences」という「データを保存するためのクラス」のインスタンスを取得して代入し
//関数「setUid」の中で、インスタンス化されたオブジェクトの「端末にデータを保存するメソッド」であるsetStringを使って、端末にUid(ユーザーID)を保存

import 'package:shared_preferences/shared_preferences.dart';


class Shared_Prefes {                     //クラスを設定　{}にメンバーの状態（属性：フィールド）＝メンバーが持つべきデータとメソッド（関数）＝アクションの定義
static SharedPreferences? _preferences;   //null許容型の_preferencesという変数を用意　SharedPreferencesはAndroidでデータを保存するためのクラスで、キーと値のペアを保存ができる



static Future<void> setPrefsInstance() async{
  if(_preferences == null) {
    _preferences = await SharedPreferences.getInstance();    //ここまでで_preferencesを定義してそこにSharedpreferrencesのインスタンスを代入するところまで完了
  }
}


 static Future<void> setData(Map<String, String> data,) async{       //実際に端末にユーザー情報を保存する関数
   data.forEach((key, value) async{
  await _preferences!.setString(key, value);       //setStringはライブラリのメソッド、端末保存のコマンド  
   });

}

//shared_Prefesに書いてあるUidの情報をとってくる関数を書く
static String? fetchUid() {       //staticなので召喚せずに召喚獣コマンド"fetchUid"が使える　出てくる演出はStringで文字だけど、何も発生しない場合（null）もありえる。
  return _preferences!.getString('myUid');  //getStringはラリブラリのメソッドで取得のコマンド //returnの結果が返ってくる＝既に端末にuidが保存されてる 返ってこない＝保存されてない　
}

static String? fetchLanguage() {       
return _preferences!.getString('language');  
}

static String? fetchCountry() {       
return _preferences!.getString('country');  
}


}

