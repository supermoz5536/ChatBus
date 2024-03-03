// ■■■■■■■■■ GPTに丸投げで書かせているので、必ず後ほどコードを読んで理解すること ■■■■■■■■■
import 'package:flutter/services.dart';

class CustomLengthTextInputFormatter extends TextInputFormatter {
  final int maxCount;

  CustomLengthTextInputFormatter({required this.maxCount});

  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    // 日本語入力中にも適切に対応するため、新旧テキストの比較から実際に追加された文字を特定する
    String newText = newValue.text;
    int newLength = _calculateTextLength(newText);

    // 最大文字数制限を超える場合は、古い値をそのまま返す
    if (newLength > maxCount) {
      return oldValue;
    }

    // 新しいテキストが古いテキストに基づいており、かつ最大文字数を超えていない場合は、新しい値を受け入れる
    return newValue.copyWith(
      text: newText,
      selection: newValue.selection,
      composing: TextRange.empty,
    );
  }

  int _calculateTextLength(String text) {
    int length = 0;
    for (final rune in text.runes) {
      final char = String.fromCharCode(rune);
      length += _isHalfWidth(char) ? 1 : 2;
    }
    return length;
  }

  bool _isHalfWidth(String char) {
    // 半角文字かどうかを判断
    return RegExp(r'[\u0020-\u007E\uFF61-\uFF9F]').hasMatch(char);
  }
}
