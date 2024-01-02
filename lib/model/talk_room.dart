//なぜmodelフォルダに自分の参加してる部屋の情報だけを取得する関数のためのファイルを作ったのか？


class TalkRoom {         //TalkRoomというクラスを作り
  String? myUid;
  String? talkuserUid;
  String? roomId;         //部屋のID 多分ここにDB上に存在してる自分の部屋のIDを取得して代入する



  TalkRoom({
required this.roomId,

  });
}