import 'package:udemy_copy/model/selected_language.dart';

class IsValidSearchMode {

static String? isValidSearchMode(
  SelectedLanguage? selectedLanguage,
  SelectedLanguage? selectedNativeLanguage
  ) {
    String? currentSearchMode;

    // 母国語設定で現在選択(True)してる言語コードを取得する
    List<String?>? selectedNativeLanguageList = SelectedLanguage.getSelectedNativeLanguageTrueItem(selectedNativeLanguage);
    // 言語フィルターで現在選択(True)してる言語コードを取得する
    List<String?>? selectedLanguageList = SelectedLanguage.getSelectedLanguageTrueItem(selectedLanguage);
    


    // 返り値からモード名を判別
    if (selectedNativeLanguageList![0] == 'mate') {
      currentSearchMode = 'mate';
    } else if (selectedLanguageList![0] == 'teachable') {
      currentSearchMode = 'teachable';
    } else if (selectedNativeLanguageList.length == 1 
            && selectedNativeLanguageList[0] == selectedLanguageList[0]) {
      currentSearchMode = 'native';
     } else {
      currentSearchMode = 'exchange';
     }


    // print('selectedNativeLanguageList == $selectedNativeLanguageList');
    // print('selectedLanguageList == $selectedLanguageList');
    return currentSearchMode;
}

}