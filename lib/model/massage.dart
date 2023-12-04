import 'package:cloud_firestore/cloud_firestore.dart';

class Message {  //メッセージに関するクラス（テンプレート）
String message;
bool isMe; //bool型は「true,falseで判断する型」　Trueだったら私が送信　Falseだったら相手から送られてると判断するために用意
Timestamp sendTime; //Datetimeは日付を管理するための型

Message ({
 required this.message,       //requiredは、その引数が必須であることを示す、つまり、このMessageというコンストラクタ関数を呼び出したらrequiredで設定した引数を設定する必要がある
 required this.isMe,
 required this.sendTime,
});
}
