import 'package:firebase_auth/firebase_auth.dart';


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
      final UserCredential result = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email!,
        password: password!,
      );

      // reslut.user にサインインしたアカウントの情報が含まれてるので
      // これをプロバイダーに渡す処理をここに記述できる

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


/// E-Main & PassWord認証 のメソッドです
static Future<String?>? createWithEmailAndPassword(String? email, String? password) async{
  try {
      final UserCredential result = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email!,
        password: password!,
      );

      // reslut.user にサインインしたアカウントの情報が含まれてるので
      // これをプロバイダーに渡す処理をここに記述できる

        print('createWithEmailAndPassword( ): アカウント作成成功');
        return 'success';
        
      } on FirebaseAuthException catch(e)  {

        if (e.code == 'invalid-email') {
          print('createWithEmailAndPassword( ): アカウント作成失敗 ${e.code}');
          // 無効なメールアドレスです
          return 'e0';

        } else if (e.code == 'invalid-credential') {
          print('createWithEmailAndPassword( ): アカウント作成失敗 ${e.code}');
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


}

