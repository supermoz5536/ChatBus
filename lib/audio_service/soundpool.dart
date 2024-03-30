import 'dart:typed_data';

import 'package:flutter/services.dart';
import 'package:soundpool/soundpool.dart';

class SoundPool {
  // Soundpoolインスタンスの初期化（１度だけ）
  static final Soundpool soundPool = 
    Soundpool.fromOptions(
      options: const SoundpoolOptions(
        streamType: StreamType.notification));


  static Future<int?> loadSeMatch() async{
    int? soundId = await rootBundle.load('se/match.mp3')
      .then((ByteData soundData) {
        return soundPool.load(soundData);
    });
    return soundId;
  }

  static Future<void> playSeMatch(int? id) async{
    if (id != null) {
    await soundPool.play(id);
    }
  }

  // static Future<void> playSeMessage() async{
  //   // AudioCache.instance = AudioCache(prefix: '');
  //   await player.play(AssetSource('se/message'));
  // }

}