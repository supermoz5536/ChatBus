import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:udemy_copy/riverpod/notifier/plan_window_able_notifier.dart';

final planWindowAbleProvider = StateNotifierProvider<PlanWindowAbleNotifier, bool?>((ref) {
  bool? initialValue = false;

    // 初期Userオブジェクト使って MeUserNotifier() を初期化してインスタンスを生成
    // 生成したインスタンスの保持する状態を consumer が読み取る。
  return PlanWindowAbleNotifier(initialValue);
});






