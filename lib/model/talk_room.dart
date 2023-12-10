//なぜmodelフォルダに自分の参加してる部屋の情報だけを取得する関数のためのファイルを作ったのか？

import 'package:udemy_copy/model/user.dart';

class TalkRoom {         //TalkRoomというクラスを作り
  String? roomId;         //部屋のID 多分ここにDB上に存在してる自分の部屋のIDを取得して代入する



  TalkRoom({
required this.roomId,

  });
}