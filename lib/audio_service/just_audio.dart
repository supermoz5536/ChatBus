// import 'package:just_audio/just_audio.dart';

// class JustAudio {
//   // シングルトンとして just_audioのインスタンス を初期化
// static final player = AudioPlayer();

//   static Future<void> setSeMatch() async{
//     // AudioSource オブジェクトを作成
//     AudioSource source =  AudioSource.asset("se/match.mp3");
//     // AudioSource を AudioPlayer に設定
//     await player.setAudioSource(source);
//   }


//   /// MatchingProgressPageでの画面遷移時の音声再生
//   static Future<void> playSeMatch() async{
//     // １番目[0]のトラックの
//     // 開始点を0:00に指定
//     // await player.seek(Duration.zero, index: 0);
//     // 音声を再生
//     await player.play();
//     }
  


// }


//   // // 複数の音声ファイルをリスト化して参照管理
//   // static final playlist = ConcatenatingAudioSource(children: [
//   //   AudioSource.asset("se/match.mp3"),
//   //   AudioSource.asset("se/message.mp3"),
//   // ]);



//   // // 複数の音声ファイルをリスト化して参照管理
//   // static final playlist = ConcatenatingAudioSource(children: [
//   //   AudioSource.uri(Uri.parse('asset:///se/match.mp3')),
//   //   AudioSource.uri(Uri.parse('asset:///se/message.mp3')),
//   // ]);



//   // static Future<void> setSeMatch() async{
//   //   await player.setAudioSource(AudioSource.uri(Uri.parse('asset:///se/match.mp3')),
//   //    initialPosition: Duration.zero, preload: true);
//   // }




//   // // 複数の音声ファイルをリスト化して参照管理
//   // static final playlist = ConcatenatingAudioSource(children: [
//   //   AudioSource.uri(Uri.parse('assets/se/match.mp3')),
//   //   AudioSource.uri(Uri.parse('assets/se/message.mp3')),
//   // ]);


//     // // 起動時に、全ての音声ファイルをロード
//   // static Future<void> loadAllAudio() async {
//   //   await player.setAudioSource(playlist);
//   // }



//   // /// TalkRoomPageで音声再生
//   // static Future<void> playSeMessage() async{
//   //   await player.seek(Duration.zero, index: 1);
//   //   await player.play();
//   //   }