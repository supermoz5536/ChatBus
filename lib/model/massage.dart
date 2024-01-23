import 'package:cloud_firestore/cloud_firestore.dart';

class Message {  
String message;
String messageId;
bool isMe; 
Timestamp sendTime; //Datetimeは日付を管理するための型

Message ({
 required this.message,
 required this.messageId,
 required this.isMe,
 required this.sendTime,
});
}

class HistoryMessage {  
String message;
String translatedMessage;
String messageId;
bool isMe; 
Timestamp sendTime; //Datetimeは日付を管理するための型

HistoryMessage ({
 required this.message,
 required this.translatedMessage,
 required this.messageId,
 required this.isMe,
 required this.sendTime,
});
}