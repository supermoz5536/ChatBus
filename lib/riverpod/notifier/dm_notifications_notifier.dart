import 'package:collection/collection.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:udemy_copy/model/dm_notification.dart';

/// UserNotifierクラスは
/// StateNotifier<User?>を拡張しており、
/// 状態を編集するのが目的のクラスです。
class DMNotificationsNotifier extends StateNotifier<List<DMNotification?>?> {

  DMNotificationsNotifier(List<DMNotification?>? initialDMNotifications) : super(initialDMNotifications);


  /// [...dMNotifications] はスプレッド演算子を使用して
  /// リスト dMNotifications の各要素を新しいリストに再構築します。
  /// つまり、再インスタンス化しているので
  /// メモリのアドレスが変更されてriverpodが
  /// 通知をキャッチし、UIの再描画を行うことができます。
  void setDMNotifications(List<DMNotification?>? dMNotifications) {
    state = [...dMNotifications!];
  }

  void clearDMNotifications() {
    state = null;
  }


  /// 既読となった通知オブジェクトを.
  /// List型の状態管理変数のプロパティから削除するメソッド
  /// removeWhereメソッド: リスト内の各要素に対して指定された条件を評価し、
  /// その条件がtrueを返す要素をリストから削除します。
  void removeDMNotification(String? tapedUnreadDMRoomId) {
    if (state != null) {
      state!.removeWhere((notification) {
        if (notification!.dMRoomId == tapedUnreadDMRoomId) {
          return true;
        } 
          return false;
      });
    }
  }

  /// 取得したdmroomの通知を追加するメソッド
  void addDMNotification(DMNotification? newNotification) {
    if (state != null && newNotification != null) {

      // 不変性の原理に従って、編集用のコピーインスタンスを用意.
      List<DMNotification?> copiedState = state!.whereType<DMNotification?>().toList();

      // リスト内の要素に同じDMRoomIdの未読通知がないか確認
      // 返り値は、「一致する要素」or「null」
      DMNotification? existingSameUserNotifcaion = copiedState.firstWhereOrNull((existingNotification) {
        return newNotification.dMRoomId == existingNotification?.dMRoomId;
      });

      // あれば、その要素のオブジェクトを上書き
      if (existingSameUserNotifcaion != null) {
        copiedState.remove(existingSameUserNotifcaion);
        copiedState.add(newNotification);

      // なければ、新しい要素を追加  
      } else {
        copiedState.add(newNotification);
      }

      // 状態のインスタンスを更新
      // riverpodが不変性の原理に従っているので
      // プロパティの更新だとcopyファイルの編集とみなされ
      // UIの際描画が行われない
      state = copiedState;
    }
  }

}

