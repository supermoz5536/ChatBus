import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:udemy_copy/model/dm_notification.dart';

/// UserNotifierクラスは
/// StateNotifier<User?>を拡張しており、
/// 状態を編集するのが目的のクラスです。
class DMNotificationNotifier extends StateNotifier<DMNotification?> {

  DMNotificationNotifier(DMNotification? initialDMNotification) : super(initialDMNotification);

  /// User型の状態を管理するのが目的なので
  /// 管理する状態にUser型のuserを割り当てています
  void setDMNotification(DMNotification? dMNotification) {
    state = dMNotification;
  }

  void clearDMNotification() {
    state = null;
  }


  /// 既読となった通知オブジェクトを
  /// List型の状態管理変数のプロパティから削除するメソッド
  void removeDMNotificationProperty(String? dMRoomId) {
    if (state != null) {
      state!.notification!.remove(dMRoomId);
    }
  }

  /// 取得したdmroomの通知を追加するメソッド
  void updateDMNotification(String? dMRoomId) {
    if (state != null) {
      state!.notification!.add(dMRoomId);
    }
  }

}

