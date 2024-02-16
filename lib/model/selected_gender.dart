// MatchingProgressPageへのコンストラクタ用に必要な
// 「言語フィルターの真偽値の出力結果」を管理するクラス

class SelectedGender{
  bool? male;
  bool? female;
  bool? both;

  SelectedGender({
    this.male,
    this.female,
    this.both,
    });


  /// MatchingProgressPageへの画面遷移時に
  /// コンストラクタに渡すListオブジェクトのゲッター関数
  static String? getSelectedGenderTrueItem(SelectedGender? selectedGender){
    String? selectedGenderTrueItem;

    // インスタンス化したselectedLanguageオブジェクトは
    // 言語フィルターUIの真偽出力結果が格納されている
    // MatchingProgressPageへのコンストラクタ用に
    // そのうち、TrueのものだけListの配列に加えて出力する
    if (selectedGender!.male == true) selectedGenderTrueItem = 'male'; 
    if (selectedGender.female == true) selectedGenderTrueItem = 'female'; 
    if (selectedGender.both == true) selectedGenderTrueItem = 'both';
      
    print('getSelectedGenderTrueItem関数内: selectedGenderTrueItem == $selectedGenderTrueItem');
    return selectedGenderTrueItem;
  } 


  /// USER型インスタンスの個別プロパティの更新用関数
  SelectedGender copyWith({
    bool? male,
    bool? female,
    bool? both,
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
    return SelectedGender(
      male: male ?? this.male,
      female: female ?? this.female,
      both: both ?? this.both,
    );
  }

}