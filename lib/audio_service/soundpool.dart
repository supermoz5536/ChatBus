import 'dart:typed_data';

import 'package:flutter/services.dart';
import 'package:soundpool/soundpool.dart';

class SoundPool {
  // シングルトンとして Soundpoolインスタンス の初期化
  static final Soundpool soundPool = 
    Soundpool.fromOptions(
      options: const SoundpoolOptions(
        streamType: StreamType.notification));


  /// MatchingProgressPageでの事前の音声データのロード
  static Future<int?> loadSeMatch() async{
    int? soundId = await rootBundle.load('se/match.mp3')
      .then((ByteData soundData) {
        return soundPool.load(soundData);
    });
    return soundId;
  }

  /// MatchingProgressPageでの画面遷移時の音声再生
  static Future<void> playSeMatch(int? id) async{
    if (id != null) {
    await soundPool.play(id);
    }
  }


  /// MatchingProgressPageでの事前の音声データのロード
  static Future<int?> loadSeMessage() async{
    int? soundId = await rootBundle.load('se/message.mp3')
      .then((ByteData soundData) {
        return soundPool.load(soundData);
    });
    return soundId;
  }

  /// MatchingProgressPageでの画面遷移時の音声再生
  static Future<void> playSeMessage(int? id) async{
    if (id != null) {
    await soundPool.play(id);
    }
  }


}