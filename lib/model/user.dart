/// Riferpodで管理するために用いるUserクラス
/// LoungePageのアプリの初動時に
/// getAccount()の取得値でUSER型インスタンスを生成し
/// StateNotifireProviderの状態変数に代入

class User {  
 final String? myUid;
 final String? userName;  
 final String? userImageUrl;
 final String? statement;
 final String? language;
 final String? country;


  /// コンストラクタの設定
  User({
     this.myUid,
     this.userName, 
     this.userImageUrl,
     this.statement, 
     this.language,
     this.country,
  });

  /// USER型インスタンスの個別プロパティの更新用関数
  User copyWith({
    String? myUid,
    String? userName,
    String? userImageUrl,
    String? statement,
    String? language,
    String? country,
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
    return User(
      myUid: myUid ?? this.myUid,
      userName: userName ?? this.userName,
      userImageUrl: userImageUrl ?? this.userImageUrl,
      statement: statement ?? this.statement,
      language: language ?? this.language,
      country: country ?? this.country,
    );
  }






}




