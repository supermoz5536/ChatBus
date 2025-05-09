import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:udemy_copy/model/selected_language.dart';
import 'package:udemy_copy/riverpod/notifier/selected_language_notifier.dart';
import 'package:udemy_copy/riverpod/notifier/selected_native_language_notifire.dart';
import 'dart:ui' as ui;

/// ■ StateNotifierProviderの基本的な説明
/// meUserProvider は
/// Userオブジェクト の状態を管理するUserNotifierクラス の
/// 更新された際の、新しいインスタンスを提供（provide）する
/// return する値: consumer に提供（provide）する
/// return する値: 管理対象の状態変数
/// （notifier.dart > MeUserNotifierクラスで User型のuser変数の状態に設定している）

/// ■ 初期化について
/// ここで定義している meUserProvider は、
/// MeUserNotifier のインスタンスを生成していますが
/// これは StateNotifierProvider が初めて参照された時にのみ行われます。
/// この時点で initialUser を MeUserNotifier に渡して初期化していますが、
/// その後の consumer によるアクセスでは、MeUserNotifier が管理する現在の状態が返されます
/// つまり、状態が更新されれば、その更新された状態が consumer によって読み取られます

/// StateNotifierProvider の初期値の設定
/// SelectedLanguageのインスタンスは全てのメンバ変数の初期値がfalseなので
/// 初期値の設定は必要ない
final selectedNativeLanguageProvider = StateNotifierProvider<SelectedNativeLanguageNotifier, SelectedLanguage?>((ref) {
  String? currentLanguageCode = ui.window.locale.languageCode;
  SelectedLanguage? initialSelectedNativeLanguage = SelectedLanguage(
    // デバイス設定言語と一致する言語のパラーメーターのみTrueに設定している
    en: currentLanguageCode == 'en',
    ja: currentLanguageCode == 'ja',
    es: currentLanguageCode == 'es',
    ko: currentLanguageCode == 'ko',
    zh: currentLanguageCode == 'zh',
    zhTw: currentLanguageCode == 'zh_TW',
  );
    return SelectedNativeLanguageNotifier(initialSelectedNativeLanguage);
});






