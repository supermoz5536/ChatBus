// ■■■■■■■■■ GPTに丸投げで書かせているので、必ず後ほどコードを読んで理解すること ■■■■■■■■■
import 'package:flutter/services.dart';

class CustomLengthTextInputFormatter extends TextInputFormatter {
  final int maxCount;

  CustomLengthTextInputFormatter({required this.maxCount});

  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    int currentLength = 0;
    StringBuffer newText = StringBuffer();

    for (final rune in newValue.text.runes) {
      final char = String.fromCharCode(rune);
      int charLength = _isHalfWidth(char) ? 1 : 2;

      if ((currentLength + charLength) > maxCount) {
        break;
      }

      currentLength += charLength;
      newText.write(char);
    }

    return TextEditingValue(
      text: newText.toString(),
      selection: TextSelection.collapsed(offset: newText.length),
    );
  }

  bool _isHalfWidth(String char) {
    // Unicodeの範囲を利用して半角文字かどうかを判断
    // ここでは、基本的なASCII範囲（U+0020からU+007E）と、半角カタカナの範囲（U+FF61からU+FF9F）を半角とみなす
    // さらに詳細な判定が必要な場合は、この条件を調整する
    return RegExp(r'[\u0020-\u007E\uFF61-\uFF9F]').hasMatch(char);
  }
}
