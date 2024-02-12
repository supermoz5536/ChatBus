import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:udemy_copy/firebase_options.dart';
import 'package:udemy_copy/l10n/l10n.dart';
import 'package:udemy_copy/model/user.dart';
import 'package:udemy_copy/riverpod/provider/me_user_provider.dart';
import 'package:udemy_copy/utils/shared_prefs.dart';
import 'package:udemy_copy/page/lounge_page.dart';
import 'package:device_preview/device_preview.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';



void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform,);
  await Shared_Prefes.setPrefsInstance(); //端末へのユーザーデータ保存メソッドを使うため、それを定義してるクラス「Shared_Prefes」のインスタンスをまず生成
  // String? uid = Shared_Prefes.fetchUid(); //fetchuid()で端末にユーザー情報が保存されてるかどうか、戻り値を確認して
  // if(uid == null) await UserFirestore.createUser();  //戻り値が空、つまり保存データがなければ、createUserを実行して、DBへのアカウント情報のプッシュ、トークルーム作成、端末へのuidの保存を行う
  // // await RoomFirestore.fetchJoinedRooms();
  runApp(DevicePreview(
    enabled: !kReleaseMode,
    builder: (context) => const ProviderScope(child: MyApp()),
  ));
}

/// DevicePreview のOFFパターン
// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform,);
//   await Shared_Prefes.setPrefsInstance(); 
//   runApp(const ProviderScope(child: MyApp()),
//   );
// }





class MyApp extends ConsumerWidget {
// class MyApp extends StatelessWidget {
// Riverpod用の書き換えバックアップ
  const MyApp({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
  // Widget build(BuildContext context) {
  // Riverpod用の書き換えバックアップ  
  User? user = ref.watch(meUserProvider);
    return MaterialApp(
      /// DevicePreview の必須プロパティ
      useInheritedMediaQuery: true,
      builder: DevicePreview.appBuilder,

      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        primarySwatch: Colors.blueGrey,
        brightness: Brightness.light,
        useMaterial3: true,
      ),
      supportedLocales: L10n.all,
      // locale: const Locale('es'),
      locale: Locale(user!.language!),
      localizationsDelegates: const[
        AppLocalizations.delegate, 
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: const LoungePage(),
    );
  }
}
