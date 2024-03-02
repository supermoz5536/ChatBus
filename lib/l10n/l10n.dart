import 'package:flutter/material.dart';

/// 多言語翻訳可能な言語のバリエーション
/// main.dartの該当プロパティへ一括に設定できる
class L10n {
  static final all = {
    const Locale('en'),
    const Locale('ja'),
    const Locale('es'),
    const Locale('ko'),
    const Locale.fromSubtags(
      languageCode: 'zh',
      scriptCode: 'Hant',
      ),
    const Locale.fromSubtags(
      languageCode: 'zh',
      scriptCode: 'Hans'
    ),
  };
}