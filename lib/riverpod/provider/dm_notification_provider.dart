import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:udemy_copy/model/dm_notification.dart';
import 'package:udemy_copy/riverpod/notifier/dm_notification_notifier.dart';


final dMNotificationProvider = StateNotifierProvider<DMNotificationNotifier, DMNotification?>((ref) {

  /// StateNotifierProvider の初期値の設定（初めて参照された時にのみ使用される）
  DMNotification? initialDMNotification= DMNotification(    
    notification: null,
  );

  // 生成したインスタンスの保持する状態を consumer が読み取る。
  return DMNotificationNotifier(initialDMNotification);
});






