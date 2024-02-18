import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:udemy_copy/model/selected_language.dart';

/// UserNotifierクラスは
/// StateNotifier<User?>を拡張しており、
/// 状態を編集するのが目的のクラスです。
class SelectedNativeLanguageNotifier extends StateNotifier<SelectedLanguage?> {

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
  SelectedNativeLanguageNotifier(SelectedLanguage? initialSelectedNativeLanguage) : super(initialSelectedNativeLanguage);

  /// User型の状態を管理するのが目的なので
  /// 管理する状態にUser型のuserを割り当てています
  void setSelectedNativeLanguage(SelectedLanguage? selectedNativeLanguage) {
    state = selectedNativeLanguage;
  }

  void clearSelectedNativeLanguage() {
    state = null;
  }


  /// 以下はSelectedLanguage型の状態変数の
  /// 各言語のパラメーターを更新するメソッド
  void updateEn(bool? newValue) {
    if (state != null) {
      state = state!.copyWith(en: newValue);
    }
  }

  void updateJa(bool? newValue) {
    if (state != null) {
      state = state!.copyWith(ja: newValue);
    }
  }

  void updateEs(bool? newValue) {
    if (state != null) {
      state = state!.copyWith(es: newValue);
    }
  }


  void switchSelectedNativeLanguage (String? currentSelectedNativeLanguage) {
    var newState = state!.copyWith(
      en: false,
      ja: false,
      es: false,
    );

    switch(currentSelectedNativeLanguage) {
      case 'en': 
        newState = newState.copyWith(en: true);
        break;
      case 'ja': 
        newState = newState.copyWith(ja: true);
        break;
      case 'es': 
        newState = newState.copyWith(es: true);
        break;       
    } 
    state = newState;
    }



  bool isValidSelectionCount(bool newValue){

    // 現在選択(True)してる言語の数を取得する
    int currentValidSelectionCount = [
      if (state?.en ?? false) 1,
      if (state?.ja ?? false) 1,
      if (state?.es ?? false) 1,
    ].length;

    // タップした際の処理を反映して
    // タップ後の状況に更新
    // True の場合は言語数を +1
    // false の場合は言語数を -1
    int  newValidSelectionCount = newValue
                                  ? currentValidSelectionCount + 1
                                  : currentValidSelectionCount - 1;

    // タップした際のOn Offによって、
    // on(true) の場合: タップ後の計算値の値が3以下なら、処理の許可(true)を返す
    // off(false) の場合: 　　　　　　　　　 1以上なら
    bool withinRange = newValue
                      ? newValidSelectionCount <= 3
                      : newValidSelectionCount >= 1;
    return withinRange;

  }


}

