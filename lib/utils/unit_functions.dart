import 'package:udemy_copy/cloud_functions/functions.dart';
import 'package:udemy_copy/firestore/room_firestore.dart';

class UnitFunctions {

static Future<String?> translateAndUpdate (
  String? message, 
  String? targetLang,
  String? roomId,
  String? messageId,
  ) async{
  String? translatedMessage = await CloudFunctions.translateDeepL(message, targetLang);
  await RoomFirestore.updateTranslatedMessage(roomId, messageId, translatedMessage);

  return translatedMessage;

}




}