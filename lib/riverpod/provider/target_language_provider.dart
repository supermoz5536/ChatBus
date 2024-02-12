import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:udemy_copy/model/user.dart';
import 'package:udemy_copy/riverpod/notifier/me_user_notifier.dart';
import 'package:udemy_copy/riverpod/notifier/target_language_notifier.dart';



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
/// その後の consumer によるアクセスでは、MeUserNotifier が管理する現在の状態が返されます。
/// つまり、状態が更新されれば、その更新された状態が consumer によって読み取られます。
final targetLanguageProvider = StateNotifierProvider<TartgetLanguageNotifier, String?>((ref) {

    // 生成したインスタンスの保持する状態を consumer が読み取る。
  return TartgetLanguageNotifier('en');
});






