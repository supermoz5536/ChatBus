import 'package:firebase_auth/firebase_auth.dart';


class FirebaseAuthentication {


static Future<String?> getAuthAnonymousUid() async{
  try {
        final userCredential = await FirebaseAuth.instance.signInAnonymously();
        return userCredential.user?.uid;

      } catch (e) {
        print('signInAnonymously( ): 実行失敗');
        return null;
      }
}

}