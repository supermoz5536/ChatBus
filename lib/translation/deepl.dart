// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:deepl_dart/deepl_dart.dart';
// import 'package:flutter_dotenv/flutter_dotenv.dart';
// import 'package:ncmb/ncmb.dart';


// class DeepL {

// static Future<String> translateText(String text, String targetLanguage) async {
//   var url = Uri.parse('https://api-free.deepl.com/v2/translate');
//   var response = await http.post(url, body: {
//     'auth_key': 'your_api_key', // ここにDeepL APIキーを入力
//     'text': text,
//     'target_lang': targetLanguage
//   });

//   if (response.statusCode == 200) {
//     var data = json.decode(response.body);
//     return data['translations'][0]['text'];
//   } else {
//     throw Exception('Failed to translate text');
//   }
// }




//  final _translator = Translator(authKey: dotenv.env['DEEPL_AUTH_KEY']!);

//   // 翻訳処理
//   void _translate() async {
//     // 入力されたテキスト（日本語）
//     var originalText = _controller.text;
//     // DeepLの翻訳処理
//     final result =
//         await _translator.translateTextSingular(originalText, 'en-US');
//     // 結果を入れるデータストアのオブジェクト
//     final translate = NCMBObject("Translate");
//     // オブジェクトに必要なデータをセット
//     translate
//       ..set("original", originalText)
//       ..set("translate", result.text);
//     // 保存
//     translate.save();
//   }




// }


