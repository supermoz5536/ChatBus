import 'package:udemy_copy/model/user.dart';

class DMRoom {         
  String? myUid;
  String? talkuserUid;
  String? dMRoomId;
  User? talkuserProfile;
  String? lastMessage;  



 DMRoom({
  required this.myUid,
  required this.talkuserUid,
  required this.dMRoomId,
  this.talkuserProfile,
  this.lastMessage,
  });
}