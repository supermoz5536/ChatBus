// MatchingProgressPageへのコンストラクタ用に必要な
// 「言語フィルターの真偽値の出力結果」を管理するクラス

class SelectedLanguage{
  bool? en;
  bool? ja;
  bool? es;
  bool? ko;
  bool? zh;
  bool? zhTw;

  SelectedLanguage({
    this.en,
    this.ja,
    this.es,
    this.ko,
    this.zh,
    this.zhTw,
    });


  /// MatchingProgressPageへの画面遷移時に
  /// コンストラクタに渡すListオブジェクトのゲッター関数
  static List<String?>? getSelectedNativeLanguageTrueItem(
    SelectedLanguage? selectedNativeLanguage,
    String? currentMode
  ) {
    List<String?>? selectedNativeLanguageTrueItem = [];

    // インスタンス化したselectedLanguageオブジェクトは
    // 言語フィルターUIの真偽出力結果が格納されている
    // MatchingProgressPageへのコンストラクタ用に
    // そのうち、TrueのものだけListの配列に加えて出力する
    if (selectedNativeLanguage!.en == true) selectedNativeLanguageTrueItem.add('en'); 
    if (selectedNativeLanguage.ja == true) selectedNativeLanguageTrueItem.add('ja'); 
    if (selectedNativeLanguage.es == true) selectedNativeLanguageTrueItem.add('es'); 
    if (selectedNativeLanguage.ko == true) selectedNativeLanguageTrueItem.add('ko'); 
    if (selectedNativeLanguage.zh == true) selectedNativeLanguageTrueItem.add('zh'); 
    if (selectedNativeLanguage.zhTw == true) selectedNativeLanguageTrueItem.add('zhTw');

    if (currentMode == 'mate') {
      selectedNativeLanguageTrueItem.clear();
      selectedNativeLanguageTrueItem.add('mate');
    }
    
    return selectedNativeLanguageTrueItem;
  } 



  /// MatchingProgressPageへの画面遷移時に
  /// コンストラクタに渡すListオブジェクトのゲッター関数
  static List<String?>? getSelectedLanguageTrueItem(
    SelectedLanguage? selectedLanguage,
    String? currentMode
  ) {
    List<String?>? selectedLanguageTrueItem = [];

    // インスタンス化したselectedLanguageオブジェクトは
    // 言語フィルターUIの真偽出力結果が格納されている
    // MatchingProgressPageへのコンストラクタ用に
    // そのうち、TrueのものだけListの配列に加えて出力する
    if (selectedLanguage!.en == true) selectedLanguageTrueItem.add('en');
    if (selectedLanguage.ja == true) selectedLanguageTrueItem.add('ja'); 
    if (selectedLanguage.es == true) selectedLanguageTrueItem.add('es'); 
    if (selectedLanguage.ko == true) selectedLanguageTrueItem.add('ko'); 
    if (selectedLanguage.zh == true) selectedLanguageTrueItem.add('zh'); 
    if (selectedLanguage.zhTw == true) selectedLanguageTrueItem.add('zhTw'); 

    if (currentMode == 'teachable') {
      selectedLanguageTrueItem.clear();
      selectedLanguageTrueItem.add('teachable');
      
    } else if (currentMode == 'native') {
      selectedLanguageTrueItem.clear();
      selectedLanguageTrueItem.add('native');
    }

    return selectedLanguageTrueItem;
  } 


  /// USER型インスタンスの個別プロパティの更新用関数
  SelectedLanguage copyWith({
    bool? en,
    bool? ja,
    bool? es,
    bool? ko,
    bool? zh,
    bool? zhTw,
  }) {
    /// 「a ?? b」 「a != null」なら a の値を代入
    /// 「a ?? b」 「a == null」なら b の値を代入
    ///copyWithメソッドは、新しい値で特定のプロパティをオーバーライドしたい時に使用されます。
    ///各引数はオプショナル（任意）であり、
    ///メソッドが呼び出された時に指定されていない場合（つまりnullが渡された場合）、
    ///現在のインスタンスの値（this.プロパティ名）がそのまま新しいインスタンスに引き継がれます。

    ///例えば、userNameのみを変更したい場合には、
    ///copyWithメソッドにuserName: "新しいユーザー名"を渡して呼び出します。
    ///この時、uid, userImageUrl, statement, language, countryの各引数には何も渡されないため、
    ///これらのプロパティには現在のUserインスタンスの値が使用されます。
    ///結果として、変更されていないプロパティはそのまま残り、
    ///指定されたuserNameのみが更新された新しいUserインスタンスが生成されます。
    return SelectedLanguage(
      en: en ?? this.en,
      ja: ja ?? this.ja,
      es: es ?? this.es,
      ko: ko ?? this.ko,
      zh: zh ?? this.zh,
      zhTw: zhTw ?? this.zhTw,
    );
  }

}