import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:udemy_copy/analytics/custom_analytics.dart';
import 'package:udemy_copy/firebase_options.dart';
import 'package:udemy_copy/l10n/l10n.dart';
import 'package:udemy_copy/model/lounge.dart';
import 'package:udemy_copy/model/user.dart';
import 'package:udemy_copy/riverpod/provider/me_user_provider.dart';
import 'package:udemy_copy/utils/shared_prefs.dart';
import 'package:udemy_copy/page/lounge_page.dart';
import 'package:device_preview/device_preview.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';


void main() async {
  // splashの設定のために変数に格納して、メソッドの引数にしてる 
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform,);
  await Shared_Prefes.setPrefsInstance();
  CustomAnalytics.logMainIn();
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
  List<String> splittedArgument = user!.language!.split('_');
  Locale appLocale;
  Lounge? lounge = Lounge(
                     showDialogAble: false,
                     afterInitialization: false
                   );
  

  if (splittedArgument.length == 1){
    appLocale = Locale(splittedArgument[0]);
  } else {
    appLocale = Locale(splittedArgument[0], splittedArgument[1]);
  }

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
      // locale: const Locale('zh', 'TW'),
      locale: appLocale,
      localizationsDelegates: const[
        AppLocalizations.delegate, 
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: LoungePage(lounge),
    );
  }
}
