import 'package:udemy_copy/cloud_functions/functions.dart';
import 'package:udemy_copy/firestore/dm_room_firestore.dart';
import 'package:udemy_copy/firestore/room_firestore.dart';

class UnitFunctions {

static Future<void> translateAndUpdateRoom (
  String? message, 
  String? targetLang,
  String? roomId,
  String? messageId,
  ) async{
  String? translatedMessage = await CloudFunctions.translateDeepL(message, targetLang);
  await RoomFirestore.updateTranslatedMessageForRoom(roomId, messageId, translatedMessage);
}


static Future<void> translateAndUpdateDMRoom (
  String? message, 
  String? targetLang,
  String? roomId,
  String? messageId,
  ) async{
  String? translatedMessage = await CloudFunctions.translateDeepL(message, targetLang);
  await DMRoomFirestore.updateTranslatedMessageForDMRoom(roomId, messageId, translatedMessage);
}





}