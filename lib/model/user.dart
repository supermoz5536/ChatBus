/// Riferpodで管理するために用いるUserクラス
/// LoungePageのアプリの初動時に
/// getAccount()の取得値でUSER型インスタンスを生成し
/// StateNotifireProviderの状態変数に代入

class User {  
 final String? uid;
 final String? userName;  
 final String? userImageUrl;
 final String? statement;
 final String? language;
 final String? country;
 final List<String?>? nativeLanguage;
 final String? gender;
 final String? accountStatus;
 final String? subscriptionPlan;
 



  /// コンストラクタの設定
  User({
     this.uid,
     this.userName, 
     this.userImageUrl,
     this.statement, 
     this.language,
     this.country,
     this.nativeLanguage,
     this.gender,
     this.accountStatus,
     this.subscriptionPlan
  });

  /// USER型インスタンスの個別プロパティの更新用関数
  User copyWith({
    String? uid,
    String? userName,
    String? userImageUrl,
    String? statement,
    String? language,
    String? country,
    List<String?>? nativeLanguage,
    String? gender,
    String? accountStatus,
    String? subscriptionPlan
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
      uid: uid ?? this.uid,
      userName: userName ?? this.userName,
      userImageUrl: userImageUrl ?? this.userImageUrl,
      statement: statement ?? this.statement,
      language: language ?? this.language,
      country: country ?? this.country,
      nativeLanguage: nativeLanguage ?? this.nativeLanguage,
      gender: gender ?? this.gender,
      accountStatus: accountStatus ?? this.accountStatus,
      subscriptionPlan: subscriptionPlan ?? this.subscriptionPlan,
    );
  }






}




