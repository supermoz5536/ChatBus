import 'package:audioplayers/audioplayers.dart'; 

class AudioPlayers {
  // メソッドが静的でクラスに紐づいているので
  // 変数も静的にクラスに紐付けるとアクセスできる
  static final player = AudioPlayer();


  static Future<void> playSeMatch() async{
    // AudioPlayerインスタンスがデフォルトで使用するAudioCacheのインスタンスを
    // 空の文字列('')に設定したAudioCacheオブジェクトに置き換えています。
    // 初期化時にプレフィックスを空文字列に設定することで、
    // 内部的にアセットパスを指定する際に
    // 自動的に付加される /assets のパス追加を無効にします
    // なので、手動での入力は /assets から始まるフルパスになります
    // AudioCache.instance = AudioCache(prefix: '');
    await player.play(AssetSource('se/match.mp3'));
  }

  static Future<void> playSeMessage() async{
    // AudioCache.instance = AudioCache(prefix: '');
    await player.play(AssetSource('se/message'));
  }

}