import 'package:cloud_firestore/cloud_firestore.dart';

class Message {  
String message;
String translatedMessage;
String messageId;
bool isMe; 
Timestamp sendTime; //Datetimeは日付を管理するための型
bool isDivider;

Message ({
 required this.message,
 required this.translatedMessage,
 required this.messageId,
 required this.isMe,
 required this.sendTime,
 required this.isDivider,
});
}