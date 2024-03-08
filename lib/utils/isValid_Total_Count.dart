import 'package:udemy_copy/model/selected_language.dart';

class IsValidTotalCount {

static bool isValidTotalCount(
  bool newValue,
  SelectedLanguage? selectedLanguage,
  SelectedLanguage? selectedNativeLanguage
  ) {

    // 母国語フィルターで現在選択(True)してる数を取得する
    int currentValidSelectedNativeLanguageCount = [
      if (selectedNativeLanguage!.en ?? false) 1,
      if (selectedNativeLanguage.ja ?? false) 1,
      if (selectedNativeLanguage.es ?? false) 1,
      if (selectedNativeLanguage.ko ?? false) 1,
      if (selectedNativeLanguage.zh ?? false) 1,
      if (selectedNativeLanguage.zhTw ?? false) 1,
    ].length;

    // 言語フィルターで現在選択(True)してる数を取得する
    int currentValidSelectedLanguageCount = [
      if (selectedLanguage!.en ?? false) 1,
      if (selectedLanguage.ja ?? false) 1,
      if (selectedLanguage.es ?? false) 1,
      if (selectedLanguage.ko ?? false) 1,
      if (selectedLanguage.zh ?? false) 1,
      if (selectedLanguage.zhTw ?? false) 1,
    ].length;

    int totalSelectedCount = currentValidSelectedLanguageCount + currentValidSelectedNativeLanguageCount;

    // タップした際の処理を反映して
    // タップ後の状況に更新
    // True の場合は言語数を +1
    // false の場合は言語数を -1
    int  newTotalSelectedCount = newValue
                                  ? totalSelectedCount + 1
                                  : totalSelectedCount - 1;

    // タップした際のOn Offによって、
    // newValueがtrue場合: trueを返す
    // newValueがfalse場合: Totalで0になるのを防ぐため、
    // 変更後の値が0以外なら許可する → true
    // 変更後の値が0なら許可しない → false
    bool withinTotalRange = newValue
                      ? true
                      : newTotalSelectedCount != 0
                        ? true
                        : false;
    return withinTotalRange;
}

}