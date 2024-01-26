import 'package:http/http.dart' as http;
import 'dart:convert';

class Http {

static Future<String> getPublicIPAddress() async {
  final url = Uri.parse('https://api.ipify.org?format=json');
  // 指定URLからURIオブジェクトを作成
  // URLは ipify.org のAPIエンドポイント

  final response = await http.get(url);
  // http パッケージを使用して
  // 上記のURLに、HTTP GETリクエストを非同期で送信

  if (response.statusCode == 200) {
  // 結果が 200（成功）であるかを確認

    var ip = jsonDecode(response.body)['ip'];
    // HTTPレスポンスのボディ（JSON形式の文字列）を
    // Dartのオブジェクトに変換（jsonDecode）し、
    // その中の「ip キー」に対応するString型の値（IPアドレス）を取得

    return ip;
  } else {
    throw Exception('Failed to get IP Address');
  }
}

}