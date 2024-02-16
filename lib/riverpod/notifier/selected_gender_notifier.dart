import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:udemy_copy/model/selected_gender.dart';

/// UserNotifierクラスは
/// StateNotifier<User?>を拡張しており、
/// 状態を編集するのが目的のクラスです。
class SelectedGenderNotifier extends StateNotifier<SelectedGender?> {

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
  SelectedGenderNotifier(SelectedGender? initialSelectedGender) : super(initialSelectedGender);

  /// User型の状態を管理するのが目的なので
  /// 管理する状態にUser型のuserを割り当てています。
  void setSelectedGender(SelectedGender? selectedGender) {
    state = selectedGender;
  }

  void clearSelectedGender() {
    state = null;
  }

  /// 選択されたジェンダーを更新するメソッドを定義をしています 
  void updateSelectedGender(SelectedGender? selectedGender) {
    if (state != null) {
      state = selectedGender;
    }
  }


  void updateMale(bool? newValue) {
    if (state != null) {
      state = state!.copyWith(male: newValue);
    }
  }

  void updateFemale(bool? newValue) {
    if (state != null) {
      state = state!.copyWith(female: newValue);
    }
  }

  void updateBoth(bool? newValue) {
    if (state != null) {
      state = state!.copyWith(both: newValue);
    }
  }


  void switchSelectedGender (String currentSelectedGender) {
    var newState = state!.copyWith(
      male: false,
      female: false,
      both: false,
    );

    switch(currentSelectedGender) {
      case 'male': 
        newState = newState.copyWith(male: true);
        break;
      case 'female': 
        newState = newState.copyWith(female: true);
        break;
      case 'both': 
        newState = newState.copyWith(both: true);
        break;       
    } 
    state = newState;
    }
  


}

