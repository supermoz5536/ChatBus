// MatchingProgressPageへのコンストラクタ用に必要な
// 「言語フィルターの真偽値の出力結果」を管理するクラス

class SelectedLanguage{
  bool? en = false;
  bool? ja = false;
  bool? es = false;

  /// MatchingProgressPageへの画面遷移時に
  /// コンストラクタに渡すListオブジェクトのゲッター関数
  static List<String?>? getSelectedLanguageList(SelectedLanguage? selectedLanguage){
    List<String?>? selectedLanguageList = [];

    // インスタンス化したselectedLanguageオブジェクトは
    // 言語フィルターUIの真偽出力結果が格納されている
    // MatchingProgressPageへのコンストラクタ用に
    // そのうち、TrueのものだけListの配列に加えて出力する
    if (selectedLanguage!.en == true) selectedLanguageList.add('en'); 
    if (selectedLanguage.ja == true) selectedLanguageList.add('ja'); 
    if (selectedLanguage.es == true) selectedLanguageList.add('es'); 

    
    return selectedLanguageList;
  } 


}