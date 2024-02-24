import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:udemy_copy/model/friend_notification.dart';
import 'package:udemy_copy/riverpod/notifier/friend_notifications_notifier.dart';




final friendNotificationsProvider = StateNotifierProvider<FriendNotificationsNotifier, List<FriendNotification?>?>((ref) {

  /// StateNotifierProvider の初期値の設定（初めて参照された時にのみ使用される）
  List<FriendNotification?>? initialFriendNotification = [];

  // 生成したインスタンスの保持する状態を consumer が読み取る。
  return FriendNotificationsNotifier(initialFriendNotification);
});






