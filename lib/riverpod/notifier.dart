import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:udemy_copy/model/user.dart';


/// UserNotifierクラスは
/// StateNotifier<User?>を拡張しており、
/// 状態を編集するのが目的のクラスです。
class MeUserNotifier extends StateNotifier<User?> {

  /// ■　ここでの目的
  /// MeUserNotifier　クラスがインスタンス化されるときに、
  /// 初期 User オブジェクト（または null）を
  /// 状態管理の初期値として設定することです。
  /// これで、この StateNotifier が管理する状態（User オブジェクト）の
  /// 初期値を外部から設定できるようになります。
  ///
  /// ■　MeUserNotifier(User? initialUser) について 
  /// MeUserNotifier クラスのコンストラクタです。
  /// User? タイプの initialUser という名前の引数を取ります
  /// 
  /// ■ : super(initialUser); は
  /// 初期化リストと呼ばれ、
  /// このコンストラクタが呼び出される前に
  /// 親クラスのコンストラクタを呼び出し、
  /// そこに initialUser を渡します。
  /// super キーワードは親クラス（この場合は StateNotifier<User?>）を参照し、
  /// StateNotifier<User?> のコンストラクタは、
  /// state プロパティの初期値として使用される値、つまり
  /// initialUserを受け取ります。
  MeUserNotifier(User? initialUser) : super(initialUser);


/// User型の状態を管理するのが目的なので
/// 管理する状態にUser型のuserを割り当てています。
  void setUser(User? user) {
    state = user;
  }

  void clearUser() {
    state = null;
  }


  /// 以下でUser型状態変数の
  /// 6つの個別パラメーターを
  /// 設定するためのメソッドの定義をしています 
  void updateUid(String? uid) {
    if (state != null) {
      state = state!.copyWith(uid: uid);
    }
  }
  

  void updateUserName(String? userName) {
    if (state != null) {
      state = state!.copyWith(userName: userName);
    }
  }


  void updateUserImageUrl(String? userImageUrl) {
    if (state != null) {
      state = state!.copyWith(userImageUrl: userImageUrl);
    }
  }

  void updateStatement(String? statement) {
    if (state != null) {
      state = state!.copyWith(statement: statement);
    }
  }

  void updateUserLanguage(String? language) {
    if (state != null) {
      state = state!.copyWith(language: language);
    }
  }

  void updateUserCountry(String? country) {
    if (state != null) {
      state = state!.copyWith(country: country);
    }
  }


}

