import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:udemy_copy/authentication/auth_service.dart';
import 'package:udemy_copy/model/lounge.dart';
import 'package:udemy_copy/page/lounge_page.dart';


// Lottieを使ったログインスクリーン
// アニメーション素材は以下のサイトから取得できる。
// https://lottiefiles.com/
// pubspec.yamlに以下を追加
// lottie: ^1.2.1
class LogInPage extends StatefulWidget {
  const LogInPage({Key? key}) : super(key: key);

  @override
  _LogInPageState createState() => _LogInPageState();
}

class _LogInPageState extends State<LogInPage> {
  String email = '';
  String password = '';
  bool hidePassword = true;

    SnackBar customSnackBar(String? errorResult) {
    return SnackBar(
      duration: const Duration(milliseconds: 2500),
      behavior: SnackBarBehavior.floating,
      margin: const EdgeInsets.all(30),
      content: SizedBox(
        height: 100,
        child: Row(
          children: [
            const Padding(
              padding: EdgeInsets.only(left: 5, right: 20),
                child: Icon(
                  Icons.error_outline_outlined,
                  color: Colors.white,),
            ),
            Flexible(
              child: Padding(
                padding: const EdgeInsets.only(right: 10),
                child:
                  Text(
                    errorResult == 'e0'
                      ? AppLocalizations.of(context)!.notFoundEmailAdress
                      : errorResult == 'e1'
                        ? AppLocalizations.of(context)!.emptyPassword
                        : AppLocalizations.of(context)!.wrongPasword,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: Colors.white,
                  ),),
              ),
            ),
          ],
        ),
      ),
      backgroundColor:const Color.fromARGB(255, 94, 94, 94),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Image.asset('assets/header.png'),
      ),

      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 36),
        child: Center(
          child: Column(
            children: [

              Text(
                AppLocalizations.of(context)!.welcomeBack,
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),

              // Lottie.asset('assets/signup.json'),

              Image.asset('assets/signup.png'),

              // ■ E-Mailアドレス入力欄
              TextFormField(
                decoration: InputDecoration(
                  icon: const Icon(Icons.mail),
                  hintText: 'sample@chatbus.net',
                  labelText: AppLocalizations.of(context)!.emailAdress,
                ),
                onChanged: (String value) {
                  setState(() {
                    email = value;
                  });
                },
              ),

              // ■ パスワード入力欄
              TextFormField(
                obscureText: hidePassword,
                decoration: InputDecoration(
                  icon: const Icon(Icons.lock),
                  labelText: AppLocalizations.of(context)!.password,
                  suffixIcon: IconButton(
                    icon: Icon(
                      hidePassword ? Icons.visibility_off : Icons.visibility,
                    ),
                    onPressed: () {
                      setState(() {
                        hidePassword = !hidePassword;
                      });
                    },
                  ),
                ),
                onChanged: (String value) {
                  setState(() {
                    password = value;
                  });
                },
              ),

              const SizedBox(height: 15),

              // ■ ログインボタン
              ElevatedButton(
                onPressed: () async{
                  String? result = await FirebaseAuthentication.logInWithEmailAndPassword(
                    email,
                    password,
                  );
                  if (result == 'success') {
                    if (context.mounted) {
                      Lounge? lounge = Lounge(showDialogAble: false);
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              LoungePage(lounge)
                        ),
                        (_) => false);
                    }
                  } else {
                    if (context.mounted){
                     ScaffoldMessenger.of(context).showSnackBar(customSnackBar(result));
                     }
                  }
                },
                child: Text(AppLocalizations.of(context)!.login),
              ),

              const SizedBox(height: 15),

              // ■ LoungePageへの画面遷移部分
              RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: AppLocalizations.of(context)!.startAnonymously,
                      style: const TextStyle(
                        color: Color.fromARGB(255, 27, 26, 26)
                      )),
                    const WidgetSpan(child: SizedBox(width: 4)),
                    // カスケード記法（..）を使用
                    // = が挟まっているのは
                    // TapGestureRecognizerクラスに onTap プロパティがあるので
                    // その値として応答関数を代入してる
                    TextSpan(
                      text: AppLocalizations.of(context)!.getStarted,
                      style: const TextStyle(
                        color: Colors.deepPurple
                      ),
                      recognizer: TapGestureRecognizer()
                        ..onTap = () {
                          if (context.mounted) {
                            Lounge? lounge = Lounge(showDialogAble: true);
                            Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                   LoungePage(lounge)
                              ),
                              (_) => false);
                          }
                        }
                    ),
                  ]
                )
              ),
            ],
          ),
        ),
      ),
    );
  }
}

