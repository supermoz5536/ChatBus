import 'package:flutter_riverpod/flutter_riverpod.dart';

/// UserNotifierクラスは
/// StateNotifier<User?>を拡張しており、
/// 状態を編集するのが目的のクラスです。
class ModeNameNotifier extends StateNotifier<String?> {

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
  ModeNameNotifier(String? initialModeName) : super(initialModeName);

  /// User型の状態を管理するのが目的なので
  /// 管理する状態にUser型のuserを割り当てています。
  void setModeName(String? modeName) {
    state = modeName;
  }

  void clearUser() {
    state = null;
  }

  /// 翻訳先言語を更新するメソッドを定義をしています 
  void updateModeName(String? modeName) {
    if (state != null) {
      state = modeName;
    }
  }

}

