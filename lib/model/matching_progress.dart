import 'package:udemy_copy/model/selected_language.dart';

class MatchingProgress {         
  String? myUid;
  String? selectedGener;
  List<String?>? selectedLanguage;
  List<String?>? selectedNativeLanguage;


 MatchingProgress({
  required this.myUid,
  required this.selectedGener,
  required this.selectedLanguage,
  required this.selectedNativeLanguage,
  });
}