import 'package:firebase_auth/firebase_auth.dart';
import 'package:udemy_copy/utils/shared_prefs.dart';


class FirebaseAuthentication {

/// 匿名認証のUid作成メソッドです
static Future<String?> getAuthAnonymousUid() async{
  try {
        final userCredential = await FirebaseAuth.instance.signInAnonymously();
        return userCredential.user?.uid;

      } catch (e) {
        print('signInAnonymously( ): 実行失敗');
        return null;
      }
}


/// E-Main & PassWord認証 のメソッドです
static Future<String?>? logInWithEmailAndPassword(String? email, String? password) async{
  try {

      // サインインの処理
      final UserCredential result = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email!,
        password: password!,
      );
      // 取得した永久アカウントのuidに端末保存uidを更新
      if(result.user != null) {
      await Shared_Prefes.setData({
          'myUid': result.user!.uid,           
        });
      }  

        print('logInWithEmailAndPassword( ): サインイン成功');
        return 'success';
        
      } on FirebaseAuthException catch(e)  {

        if (e.code == 'invalid-email') {
          print('logInWithEmailAndPassword( ): サインイン失敗 ${e.code}');
          // 無効なメールアドレスです
          return 'e0';

        } else if (e.code == 'invalid-credential') {
          print('logInWithEmailAndPassword( ): サインイン失敗 ${e.code}');
          // パスワードが間違っています
          return 'e1';

        }
          print('FirebaseAuthExceptionのその他のエラー: ${e.code}');
          return null;

      } catch (e) {
        print('その他のエラー: $e');
        return null;
      }
}


/// 永久アカウントへのアップグレードメソッドです
static Future<String?>? upgradeAccountToPermanent(String? email, String? password) async{
  try {
    // 永久アカウントにアップグレードさせるために必要な AuthCredential型 の認証オブジェクトを作成
    final credential = EmailAuthProvider.credential(email: email!, password: password!);

    // linkWithCredentialは、匿名アカウントに認証オブジェクトを渡し、
    // 永久アカウントにアップグレードする
    final userCredential = await FirebaseAuth.instance.currentUser?.linkWithCredential(credential);

    // ■ UserProviderの該当プロパティをanonymousに状態更新をここで記述

        print('upgradeAccountToPermanent: 永久アカウントにアップグレード成功');
        return 'success';
        
      } on FirebaseAuthException catch (e) {
        switch (e.code) {
          case "invalid-email":
            return 'e0';
          default:
            print("upgradeAccountToPermanent: デバッグプリントに設定していないエラーコード $e");
        }
      }


        
      // } on FirebaseAuthException catch(e)  {

      //   if (e.code == 'invalid-email') {
      //     print('createWithEmailAndPassword( ): アカウント作成失敗 ${e.code}');
      //     // 無効なメールアドレスです
      //     return 'e0';

      //   } else if (e.code == 'invalid-credential') {
      //     print('createWithEmailAndPassword( ): アカウント作成失敗 ${e.code}');
      //     // パスワードが間違っています
      //     return 'e1';

      //   }
      //     print('FirebaseAuthExceptionのその他のエラー: ${e.code}');
      //     return null;

      // } catch (e) {
      //   print('その他のエラー: $e');
      //   return null;
      // }
}


}

