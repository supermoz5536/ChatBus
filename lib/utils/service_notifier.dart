import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:udemy_copy/firestore/user_firestore.dart';
import 'package:udemy_copy/riverpod/provider/me_user_provider.dart';

class ServiceNotifier {
  final WidgetRef ref;

  ServiceNotifier(this.ref);

  /// アプリ内設定言語の切り替え時に
  /// 状態更新とdbへの書き込みを連携して行うメソッド
  Future<void> changeLanguage(String? newLanguageCode) async {
    // ユーザーIDの取得
    // Notifierを通じてユーザーの状態を更新
    // Firestoreのユーザー情報も更新
    final String? uid = ref.read(meUserProvider)!.uid; 
    ref.read(meUserProvider.notifier).updateUserLanguage(newLanguageCode);
    await UserFirestore.updateLanguage(uid, newLanguageCode);
  }



}