import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:udemy_copy/model/selected_gender.dart';
import 'package:udemy_copy/model/selected_language.dart';
import 'package:udemy_copy/riverpod/provider/mode_name_provider.dart';
import 'package:udemy_copy/riverpod/provider/selected_gender_provider.dart';
import 'package:udemy_copy/riverpod/provider/selected_language_provider.dart';
import 'package:udemy_copy/riverpod/provider/selected_native_language_provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:udemy_copy/utils/isValid_Total_Count.dart';
import 'package:udemy_copy/utils/isValid_search_mode.dart';


class SearchPage extends ConsumerStatefulWidget {
  const SearchPage({super.key});

  @override
  ConsumerState<SearchPage> createState() => _SearchPageState();
}
class _SearchPageState extends ConsumerState<SearchPage> {
  String? currentMode;
  bool? withinRange;
  bool? withinTotalRange;
  List<bool> isExpanded = [false, false, false, false];

  @override
  Widget build(BuildContext context) {
    SelectedLanguage? selectedLanguage = ref.watch(selectedLanguageProvider);
    SelectedLanguage? selectedNativeLanguage = ref.watch(selectedNativeLanguageProvider);
    SelectedGender? selectedGender = ref.watch(selectedGenderProvider);
    currentMode = ref.watch(modeNameProvider);
    

    
    return Scaffold(
      body: Center(
        child: ListView(
          children: [

            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Center(
                child: Text(
                  AppLocalizations.of(context)!.headerSearchPage,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 25,
                    color: Color.fromARGB(255, 75, 75, 75),
                    fontWeight: FontWeight.bold)),
              ),
            ),

            ReadHowToUse(context),

            const SizedBox(height: 25),

            const Divider(
                    color: Color.fromARGB(255, 150, 150, 150),
                    height: 0,
                    thickness: 1,
                    indent: 30,
                    endIndent: 30,
                  ),
            
            const SizedBox(height: 25),

            // ■ Current Mode Display
            Center(
              child: IntrinsicWidth(
                child: Card(
                  child: ListTile(
                    leading: const Icon(Icons.check_circle, color: Colors.lightGreen), // 選択されていることを示すアイコン
                    title: Text(
                      // 'Current Search Mode',
                      AppLocalizations.of(context)!.currentSearchModeTitle,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold
                      ),
                      ),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        // 現在有効なモード名を管理する状態変数の値によって表示名を切り替え
                        currentMode == 'mate'
                          ? AppLocalizations.of(context)!.modeNameMate
                          : currentMode == 'teachable'
                            ? AppLocalizations.of(context)!.modeNameTeachable
                            : currentMode == 'native'
                              ? AppLocalizations.of(context)!.modeNameNative
                              : AppLocalizations.of(context)!.modeNameExchange,
                         textAlign: TextAlign.center,
                         style: const TextStyle(
                          fontSize: 15,
                          color: Colors.grey
                         ),
                        ),
                    ),
                  ),
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.only(
                top: 20,
                left: 50,
                right: 50,
              ),
              child: Card(
                child: ExpansionTile(
                  // shapeプロパティを設定するとデフォルトの境界線UIの描画を避けることができる
                  shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.all(Radius.circular(0.0))),
                  // ■ 母国語パラメーター
                  title: Text(
                    AppLocalizations.of(context)!.titleSelectNativeLanguage,
                    style: const TextStyle(
                      fontSize: 20,
                      color: Color.fromARGB(255, 75, 75, 75),
                      fontWeight: FontWeight.bold)),
                  // "自分が流暢に話せる言語を3つまで選択できます！",
                  subtitle: Text(AppLocalizations.of(context)!.subTitleSelectNativeLanguage),
                  collapsedBackgroundColor:const Color.fromARGB(255, 247, 241, 254),
                  backgroundColor: const Color.fromARGB(255, 247, 241, 254),
                  children: [
              
                    // ■ 英語
                    SwitchListTile(
                      title: Text(
                        AppLocalizations.of(context)!.english,
                        style: const TextStyle(
                          color: Color.fromARGB(255, 102, 102, 102),
                          fontSize: 15)),
                      value: selectedNativeLanguage!.en!,
                      onChanged: (bool newValue) {
                        // 母国語フィルターの選択数がレンジ内かを確認
                        // 言語フィルターの選択数と総計した時もレンジないかを確認
                        // 両方レンジ内の場合のみ、
                        // 「選択管理の状態変数」と「モード表示管理の状態変数」を更新
                          withinRange = ref.read(selectedNativeLanguageProvider.notifier).isValidSelectionCount(newValue);
                          withinTotalRange = IsValidTotalCount.isValidTotalCount(
                            newValue,
                            selectedLanguage,
                            selectedNativeLanguage
                          );
                          if (withinRange == true && withinTotalRange == true) {
                            ref.read(selectedNativeLanguageProvider.notifier).updateEn(newValue);
                            currentMode = IsValidSearchMode.isValidSearchMode(selectedLanguage, selectedNativeLanguage);
                            ref.read(modeNameProvider.notifier).updateModeName(currentMode);
                          }
                      },
                    ),

                    // ■ 日本語
                    SwitchListTile(
                      title: Text(
                        AppLocalizations.of(context)!.japanese,
                        style: const TextStyle(
                          color: Color.fromARGB(255, 102, 102, 102),
                          fontSize: 15)),
                      value: selectedNativeLanguage.ja!,
                      onChanged: (bool newValue) {
                          withinRange = ref.read(selectedNativeLanguageProvider.notifier).isValidSelectionCount(newValue);
                          withinTotalRange = IsValidTotalCount.isValidTotalCount(
                            newValue,
                            selectedLanguage,
                            selectedNativeLanguage
                          );
                          if (withinRange == true && withinTotalRange == true) {
                            ref.read(selectedNativeLanguageProvider.notifier).updateJa(newValue);
                            currentMode = IsValidSearchMode.isValidSearchMode(selectedLanguage, selectedNativeLanguage);
                            ref.read(modeNameProvider.notifier).updateModeName(currentMode);
                          }      
                      },
                    ),

                    // ■ スペイン語
                    SwitchListTile(
                      title: Text(
                        AppLocalizations.of(context)!.spanish,
                        style: const TextStyle(
                          color: Color.fromARGB(255, 102, 102, 102),
                          fontSize: 15)),
                      value: selectedNativeLanguage.es!,
                      onChanged: (bool newValue) {
                          withinRange = ref.read(selectedNativeLanguageProvider.notifier).isValidSelectionCount(newValue);
                          withinTotalRange = IsValidTotalCount.isValidTotalCount(
                            newValue,
                            selectedLanguage,
                            selectedNativeLanguage
                          );
                          if (withinRange == true && withinTotalRange == true) {
                            ref.read(selectedNativeLanguageProvider.notifier).updateEs(newValue);
                            currentMode = IsValidSearchMode.isValidSearchMode(selectedLanguage, selectedNativeLanguage);
                            ref.read(modeNameProvider.notifier).updateModeName(currentMode);
                          }
                      },
                    ),

                    // ■ 韓国語
                    SwitchListTile(
                      title: Text(
                        AppLocalizations.of(context)!.korean,
                        style: const TextStyle(
                          color: Color.fromARGB(255, 102, 102, 102),
                          fontSize: 15)),
                      value: selectedNativeLanguage.ko!,
                      onChanged: (bool newValue) {
                          withinRange = ref.read(selectedNativeLanguageProvider.notifier).isValidSelectionCount(newValue);
                          withinTotalRange = IsValidTotalCount.isValidTotalCount(
                            newValue,
                            selectedLanguage,
                            selectedNativeLanguage
                          );
                          if (withinRange == true && withinTotalRange == true) {
                            ref.read(selectedNativeLanguageProvider.notifier).updateKo(newValue);
                            currentMode = IsValidSearchMode.isValidSearchMode(selectedLanguage, selectedNativeLanguage);
                            ref.read(modeNameProvider.notifier).updateModeName(currentMode);
                          }
                      },
                    ),

                    // ■ 中国語
                    SwitchListTile(
                      title: Text(
                        AppLocalizations.of(context)!.chinese,
                        style: const TextStyle(
                          color: Color.fromARGB(255, 102, 102, 102),
                          fontSize: 15)),
                      value: selectedNativeLanguage.zh!,
                      onChanged: (bool newValue) {
                          withinRange = ref.read(selectedNativeLanguageProvider.notifier).isValidSelectionCount(newValue);
                          withinTotalRange = IsValidTotalCount.isValidTotalCount(
                            newValue,
                            selectedLanguage,
                            selectedNativeLanguage
                          );
                          if (withinRange == true && withinTotalRange == true) {
                            ref.read(selectedNativeLanguageProvider.notifier).updateZh(newValue);
                            currentMode = IsValidSearchMode.isValidSearchMode(selectedLanguage, selectedNativeLanguage);
                            ref.read(modeNameProvider.notifier).updateModeName(currentMode);
                          }
                      },
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 25),

            Padding(
              padding: const EdgeInsets.only(
                left: 50,
                right: 50,
              ),
              child: Card(
                child: ExpansionTile(
                  // shapeプロパティを設定するとデフォルトの境界線UIの描画を避けることができる
                  shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.all(Radius.circular(0.0))),
                  title: Text(
                    // ■ 言語フィルター
                    AppLocalizations.of(context)!.titleLanguageFilter,
                    style: const TextStyle(
                      fontSize: 20,
                      color: Color.fromARGB(255, 75, 75, 75),
                      fontWeight: FontWeight.bold)),
                  subtitle: Text(AppLocalizations.of(context)!.subTitleLanguageFilter),
                  collapsedBackgroundColor:const Color.fromARGB(255, 247, 241, 254),
                  backgroundColor: const Color.fromARGB(255, 247, 241, 254),
                  children: [
                    
                    // ■ 英語.
                    SwitchListTile(
                      title: Text(
                        AppLocalizations.of(context)!.english,
                        style: const TextStyle(
                          color: Color.fromARGB(255, 102, 102, 102),
                          fontSize: 15)),
                      value: selectedLanguage!.en!,
                      onChanged: (bool newValue) {
                        // まず母国語フィルターの選択数と総計した時のレンジ内かを確認
                        withinTotalRange = IsValidTotalCount.isValidTotalCount(
                          newValue,
                          selectedLanguage,
                          selectedNativeLanguage
                        );
                        if (withinTotalRange == true) {
                          // レンジ内の場合は、現在選択してる言語と同じかをチェック
                          // 同じ場合：switchメソッドでTrueに更新しないので none
                          // 違う場合：switchメソッドでTrueに更新するので、該当の言語コード
                          print('newValue ${newValue}');
                          print('Before ${selectedLanguage.en}');
                          selectedLanguage.en! == true
                            ? ref.read(selectedLanguageProvider.notifier).switchSelectedLanguage('none')
                            : ref.read(selectedLanguageProvider.notifier).switchSelectedLanguage('en');
                          currentMode = IsValidSearchMode.isValidSearchMode(selectedLanguage, selectedNativeLanguage);
                          print('After ${selectedLanguage.en}');
                          ref.read(modeNameProvider.notifier).updateModeName(currentMode);
                        }
                      },
                    ),

                    // ■ 日本語
                    SwitchListTile(
                      title: Text(
                        AppLocalizations.of(context)!.japanese,
                        style: const TextStyle(
                          color: Color.fromARGB(255, 102, 102, 102),
                          fontSize: 15)),
                      value: selectedLanguage.ja!,
                      onChanged: (bool newValue) {
                        withinTotalRange = IsValidTotalCount.isValidTotalCount(
                          newValue,
                          selectedLanguage,
                          selectedNativeLanguage
                        );
                        if (withinTotalRange == true) {
                        selectedLanguage.ja! == true
                          ? ref.read(selectedLanguageProvider.notifier).switchSelectedLanguage('none')
                          : ref.read(selectedLanguageProvider.notifier).switchSelectedLanguage('ja');
                        currentMode = IsValidSearchMode.isValidSearchMode(selectedLanguage, selectedNativeLanguage);
                        ref.read(modeNameProvider.notifier).updateModeName(currentMode);
                        }
                      },
                    ),
              
                    // ■ スペイン語
                    SwitchListTile(
                      title: Text(
                        AppLocalizations.of(context)!.spanish,
                        style: const TextStyle(
                          color: Color.fromARGB(255, 102, 102, 102),
                          fontSize: 15)),
                      value: selectedLanguage.es!,
                      onChanged: (bool newValue) {
                        withinTotalRange = IsValidTotalCount.isValidTotalCount(
                          newValue,
                          selectedLanguage,
                          selectedNativeLanguage
                        );
                        if (withinTotalRange == true) {
                        selectedLanguage.es! == true
                          ? ref.read(selectedLanguageProvider.notifier).switchSelectedLanguage('none')
                          : ref.read(selectedLanguageProvider.notifier).switchSelectedLanguage('es');
                        currentMode = IsValidSearchMode.isValidSearchMode(selectedLanguage, selectedNativeLanguage);
                        ref.read(modeNameProvider.notifier).updateModeName(currentMode);
                        }
                      },
                    ),

                    // ■ 韓国語
                    SwitchListTile(
                      title: Text(
                        AppLocalizations.of(context)!.korean,
                        style: const TextStyle(
                          color: Color.fromARGB(255, 102, 102, 102),
                          fontSize: 15)),
                      value: selectedLanguage.ko!,
                      onChanged: (bool newValue) {
                        withinTotalRange = IsValidTotalCount.isValidTotalCount(
                          newValue,
                          selectedLanguage,
                          selectedNativeLanguage
                        );
                        if (withinTotalRange == true) {
                        selectedLanguage.ko! == true
                          ? ref.read(selectedLanguageProvider.notifier).switchSelectedLanguage('none')
                          : ref.read(selectedLanguageProvider.notifier).switchSelectedLanguage('ko');
                        currentMode = IsValidSearchMode.isValidSearchMode(selectedLanguage, selectedNativeLanguage);
                        ref.read(modeNameProvider.notifier).updateModeName(currentMode);
                        }
                      },
                    ),

                    // ■ 中国語
                    SwitchListTile(
                      title: Text(
                        AppLocalizations.of(context)!.chinese,
                        style: const TextStyle(
                          color: Color.fromARGB(255, 102, 102, 102),
                          fontSize: 15)),
                      value: selectedLanguage.zh!,
                      onChanged: (bool newValue) {
                        withinTotalRange = IsValidTotalCount.isValidTotalCount(
                          newValue,
                          selectedLanguage,
                          selectedNativeLanguage
                        );
                        if (withinTotalRange == true) {
                        selectedLanguage.zh! == true
                          ? ref.read(selectedLanguageProvider.notifier).switchSelectedLanguage('none')
                          : ref.read(selectedLanguageProvider.notifier).switchSelectedLanguage('zh');
                        currentMode = IsValidSearchMode.isValidSearchMode(selectedLanguage, selectedNativeLanguage);
                        ref.read(modeNameProvider.notifier).updateModeName(currentMode);
                        }
                      },
                    ),
                    
                  ],
                ),
              ),
            ),


            const SizedBox(height: 25),


            Padding(
              padding: const EdgeInsets.only(
                left: 50,
                right: 50,
              ),
              child: Card(
                child: ExpansionTile(
                  // shapeプロパティを設定するとデフォルトの境界線UIの描画を避けることができる
                  shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.all(Radius.circular(0.0))),
                  title: Text(
                    AppLocalizations.of(context)!.titleGenderFilter,
                    style: const TextStyle(
                      fontSize: 20,
                      color: Color.fromARGB(255, 75, 75, 75),
                      fontWeight: FontWeight.bold)),
                  subtitle: Text(AppLocalizations.of(context)!.subTitleGenderFilter),
                  children: [
                              
                    const Divider(
                      color: Color.fromARGB(255, 214, 214, 214),
                      height: 0,
                      thickness: 0.1,
                      indent: 10,
                      endIndent: 10,
                    ),
                              
                    CheckboxListTile(
                      title: Text(
                        AppLocalizations.of(context)!.male,
                        style: const TextStyle(
                          color: Color.fromARGB(255, 102, 102, 102),
                          fontSize: 15)),
                      value: selectedGender!.male
                      // == true && currentGender == 'male'
                      //   ? true
                      //   : false
                        ,
                      onChanged: (bool? newValue) {
                        setState(() {
                          if (newValue == true){
                          // currentGender を male に更新することで、setState()実行時に他の選択肢がfalseになる
                          // ref.read(currentGenderProvider.notifier).updateCurrentGender('male');
                          // 状態値の全3つのプロパティを更新
                          ref.read(selectedGenderProvider.notifier).switchSelectedGender('male');
                          } else if (newValue == false ){ }
                        });
                      },
                    ),
                              
                    CheckboxListTile(
                      title: Text(
                        AppLocalizations.of(context)!.female,
                        style: const TextStyle(
                          color: Color.fromARGB(255, 102, 102, 102),
                          fontSize: 15)),
                      value: selectedGender.female
                      //  == true && currentGender == 'female'
                      //   ? true
                      //   : false
                        ,
                      onChanged: (bool? newValue) {
                        setState(() {
                          if (newValue == true){
                          // currentGender を male に更新することで、setState()実行時に他の選択肢がfalseになる
                          // ref.read(currentGenderProvider.notifier).updateCurrentGender('female');
                          // 状態値の全3つのプロパティを更新
                          ref.read(selectedGenderProvider.notifier).switchSelectedGender('female');
                          } else if (newValue == false ){ }
                        });
                      },
                    ),
                              
                    CheckboxListTile(
                      title: Text(
                        AppLocalizations.of(context)!.maleAndFemale,
                        style: const TextStyle(
                          color: Color.fromARGB(255, 102, 102, 102),
                          fontSize: 15)),
                      value: selectedGender.both
                      //  == true && currentGender == 'both'
                      //   ? true
                      //   : false
                        ,
                      onChanged: (bool? newValue) {
                        setState(() {
                          if (newValue == true){
                          // currentGender を male に更新することで、setState()実行時に他の選択肢がfalseになる
                          // ref.read(currentGenderProvider.notifier).updateCurrentGender('both');
                          // 状態値の全3つのプロパティを更新
                          ref.read(selectedGenderProvider.notifier).switchSelectedGender('both');
                          } else if (newValue == false ){ }
                        });
                      },
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 100),


          ],
        )
      ),
      );
    }

  Align ReadHowToUse(BuildContext context) {
    return Align(
            alignment: Alignment.center,
            child: ElevatedButton(
              onPressed: () {
                showModalBottomSheet(
                  context: context,
                  builder: (_) {
                    return StatefulBuilder(
                      builder: (context, setState) {
                        return ListView(
                          shrinkWrap: true,
                          children: [
                             Padding(
                              padding: const EdgeInsets.only(
                                top: 30,
                                bottom: 30),
                              child: Text(
                                // "4つの検索設定オプション",
                                AppLocalizations.of(context)!.fourSearchOption,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontSize: 30
                                ),),
                            ),
                            ExpansionPanelList(   
                              expansionCallback: (int index, newIsExpanded) {
                                setState(() {
                                  isExpanded[index] = newIsExpanded;
                                });
                              },                    
                              children: [
                                                          
                                // ■ ネイティブマッチング
                                ExpansionPanel(
                                  isExpanded: isExpanded[0],
                                  headerBuilder:(context, isExpanded){
                                    return Center(
                                      child: ListTile(
                                        contentPadding: const EdgeInsets.symmetric(
                                          horizontal: 30.0), // 左側のパディングを調整
                                        leading: const Icon(Icons.search_outlined, size: 20,),
                                        title: Text(
                                          //'ネイティブモード',
                                          AppLocalizations.of(context)!.nativeMatchingTitle,
                                          textAlign: TextAlign.center,
                                          style: const TextStyle(
                                            fontSize: 15,
                                          ),
                                        ),
                                      )     
                                    );
                                  },
                                  body: Column(
                                    children: [
                                      // ■ ネイティブマッチング 1行目
                                      Padding(
                                        padding: const EdgeInsets.only(right: 8, bottom: 8),
                                        child: Row(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            const Padding(
                                              padding: EdgeInsets.only(
                                                left: 20,
                                                right: 10,
                                                ),
                                              child: Icon(Icons.done, size: 15,),
                                            ),
                                            Flexible(
                                              child: Text(
                                                //'母国語が同じユーザーを優先してマッチング',
                                                AppLocalizations.of(context)!.nativeMatchingSub1,
                                                style: const TextStyle(
                                                  fontSize: 15,
                                                ),
                                                ),
                                            ),
                                          ],
                                        ),
                                      ),

                                      // ■ ネイティブマッチング 2行目
                                      Padding(
                                        padding: const EdgeInsets.only(right: 8, bottom: 8),
                                        child: Row(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            const Padding(
                                              padding: EdgeInsets.only(
                                                left: 20,
                                                right: 10,
                                                ),
                                              child: Icon(Icons.done, size: 15,),
                                            ),
                                            Flexible(
                                              child: Text(
                                                //'母国語設定と言語フィルターで "母国語" を選択',
                                                AppLocalizations.of(context)!.nativeMatchingSub2,
                                                style: const TextStyle(
                                                  fontSize: 15,
                                                ),
                                                ),
                                            ),
                                          ],
                                        ),
                                      ),

                                      // ■ ネイティブマッチング 3行目
                                      Padding(
                                        padding: const EdgeInsets.only(right: 8, bottom: 8),
                                        child: Row(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            const Padding(
                                              padding:  EdgeInsets.only(
                                                left: 20,
                                                right: 10,
                                                ),
                                              child: Icon(Icons.done, size: 15,),
                                            ),
                                            Flexible(
                                              child: Text(
                                                //'母国語が英語の場合：英語 / 英語',
                                                AppLocalizations.of(context)!.nativeMatchingSub3,
                                                style: const TextStyle(
                                                  fontSize: 15,
                                                ),
                                                ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                            
                                // ■ クロスマッチング
                                ExpansionPanel(
                                  isExpanded: isExpanded[1],
                                  headerBuilder:(context, isExpanded){
                                    return Center(
                                      child: ListTile(
                                        contentPadding: const EdgeInsets.symmetric(
                                          horizontal: 30.0), // 左側のパディングを調整
                                        leading: const Icon(Icons.search_outlined, size: 20,),
                                        title: Text(
                                          // 'エクスチェンジモード',
                                          AppLocalizations.of(context)!.exchangeMatchingTitle,
                                          textAlign: TextAlign.center,
                                          style: const TextStyle(
                                            fontSize: 15,
                                          ),
                                        ),
                                      )     
                                    );
                                  },
                                  body: Column(
                                    children: [

                                      // ■ クロスマッチング 1行目
                                      Padding(
                                        padding: const EdgeInsets.only(right: 8, bottom: 8),
                                        child: Row(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            const Padding(
                                              padding: EdgeInsets.only(
                                                left: 20,
                                                right: 10,
                                                ),
                                              child: Icon(Icons.done, size: 15,),
                                            ),
                                            Flexible(
                                              child: Text(
                                                // '「あなたの母国語に興味があり、かつ、あなたの学びたい言語が母国語の人」とマッチング',
                                                AppLocalizations.of(context)!.exchangeMatchingSub1,
                                                style: const TextStyle(
                                                  fontSize: 15,
                                                ),
                                                ),
                                            ),
                                          ],
                                        ),
                                      ),

                                      // ■ クロスマッチング 2行目
                                      Padding(
                                        padding: const EdgeInsets.only(right: 8, bottom: 8),
                                        child: Row(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            const Padding(
                                              padding:  EdgeInsets.only(
                                                left: 20,
                                                right: 10,
                                                ),
                                              child: Icon(Icons.done, size: 15,),
                                            ),
                                            Flexible(
                                              child: Text(
                                                // '母国語設定で母国語を選択し、言語フィルターであなたの学びたい言語を選択',
                                                AppLocalizations.of(context)!.exchangeMatchingSub2,
                                                style: const TextStyle(
                                                  fontSize: 15,
                                                ),
                                                ),
                                            ),
                                          ],
                                        ),
                                      ),

                                      // ■ クロスマッチング 3行目
                                      Padding(
                                        padding: const EdgeInsets.only(right: 8, bottom: 8),
                                        child: Row(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            const Padding(
                                              padding: EdgeInsets.only(
                                                left: 20,
                                                right: 10,
                                                ),
                                              child: Icon(Icons.done, size: 15,),
                                            ),
                                            Flexible(
                                              child: Text(
                                                // '母国語が英語の場合：英語 / 中国語',
                                                AppLocalizations.of(context)!.exchangeMatchingSub3,
                                                style: const TextStyle(
                                                  fontSize: 15,
                                                ),
                                                ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                          
                                // ■ ティーチマッチング
                                ExpansionPanel(
                                  isExpanded: isExpanded[2],
                                  headerBuilder:(context, isExpanded){
                                    return  Center(
                                      child: ListTile(
                                        contentPadding: const EdgeInsets.symmetric(
                                          horizontal: 30.0), // 左側のパディングを調整
                                        leading: const Icon(Icons.search_outlined, size: 20,),
                                        title: Text(
                                          // 'ティーチャブルモード',
                                          AppLocalizations.of(context)!.teachableMatchingTitle,
                                          textAlign: TextAlign.center,
                                          style: const TextStyle(
                                            fontSize: 15,
                                          ),
                                        ),
                                      )     
                                    );
                                  },
                                  body: Column(
                                    children: [

                                      // ■ ティーチマッチング 1行目
                                      Padding(
                                        padding: const EdgeInsets.only(right: 8, bottom: 8),
                                        child: Row(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            const Padding(
                                              padding:  EdgeInsets.only(
                                                left: 20,
                                                right: 10,
                                                ),
                                              child: Icon(Icons.done, size: 15,),
                                            ),
                                            Flexible(
                                              child: Text(
                                                // 'あなたの母国語に興味がある全ての人とマッチング',
                                                AppLocalizations.of(context)!.teachableMatchingSub1,
                                                style: const TextStyle(
                                                  fontSize: 15,
                                                ),
                                                ),
                                            ),
                                          ],
                                        ),
                                      ),

                                      // ■ ティーチマッチング 2行目
                                      Padding(
                                        padding: const EdgeInsets.only(right: 8, bottom: 8),
                                        child: Row(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            const Padding(
                                              padding: EdgeInsets.only(
                                                left: 20,
                                                right: 10,
                                                ),
                                              child: Icon(Icons.done, size: 15,),
                                            ),
                                            Flexible(
                                              child: Text(
                                                // '母国語設定で母国語を選択し、言語フィルターは何も選択しない',
                                                AppLocalizations.of(context)!.teachableMatchingSub2,
                                                style: const TextStyle(
                                                  fontSize: 15,
                                                ),
                                                ),
                                            ),
                                          ],
                                        ),
                                      ),

                                      // ■ ティーチマッチング 3行目
                                      Padding(
                                        padding: const EdgeInsets.only(right: 8, bottom: 8),
                                        child: Row(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            const Padding(
                                              padding: EdgeInsets.only(
                                                left: 20,
                                                right: 10,
                                                ),
                                              child: Icon(Icons.done, size: 15,),
                                            ),
                                            Flexible(
                                              child: Text(
                                                // 'あなたの母国語が英語の場合：英語 / 選択なし',
                                                AppLocalizations.of(context)!.teachableMatchingSub3,
                                                style: const TextStyle(
                                                  fontSize: 15,
                                                ),
                                                ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                          
                                // ■ メイトマッチング
                                ExpansionPanel(
                                  isExpanded: isExpanded[3],
                                  headerBuilder:(context, isExpanded){
                                    return  Center(
                                      child: ListTile(
                                        contentPadding: const EdgeInsets.symmetric(
                                          horizontal: 30.0), // 左側のパディングを調整
                                        leading: const Icon(Icons.search_outlined, size: 20,),
                                        title: Text(
                                          // 'メイトマッチング',
                                          AppLocalizations.of(context)!.mateMatchingTitle,
                                          textAlign: TextAlign.center,
                                          style: const TextStyle(
                                            fontSize: 15,
                                          ),
                                        ),
                                      )     
                                    );
                                  },
                                  body: Column(
                                    children: [

                                      // ■ メイトマッチング 1行目
                                      Padding(
                                        padding: const EdgeInsets.only(right: 8, bottom: 8),
                                        child: Row(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            const Padding(
                                              padding: EdgeInsets.only(
                                                left: 20,
                                                right: 10,
                                                ),
                                              child: Icon(Icons.done, size: 15,),
                                            ),
                                            Flexible(
                                              child: Text(
                                                // 'あなたと同じ言語を学習してる仲間と優先的にマッチング',
                                                AppLocalizations.of(context)!.mateMatchingSub1,
                                                style: const TextStyle(
                                                  fontSize: 15,
                                                ),
                                                ),
                                            ),
                                          ],
                                        ),
                                      ),

                                      // ■ メイトマッチング 2行目
                                      Padding(
                                        padding: const EdgeInsets.only(right: 8, bottom: 8),
                                        child: Row(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            const Padding(
                                              padding: EdgeInsets.only(
                                                left: 20,
                                                right: 10,
                                                ),
                                              child: Icon(Icons.done, size: 15,),
                                            ),
                                            Flexible(
                                              child: Text(
                                                // '母国語設定は何も選択せず、言語フィルターであなたの学びたい言語を選択',
                                                AppLocalizations.of(context)!.mateMatchingSub2,
                                                style: const TextStyle(
                                                  fontSize: 15,
                                                ),
                                                ),
                                            ),
                                          ],
                                        ),
                                      ),

                                      // ■ メイトマッチング 3行目
                                      Padding(
                                        padding: const EdgeInsets.only(right: 8, bottom: 8),
                                        child: Row(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            const Padding(
                                              padding: EdgeInsets.only(
                                                left: 20,
                                                right: 10,
                                                ),
                                              child: Icon(Icons.done, size: 15,),
                                            ),
                                            Flexible(
                                              child: Text(
                                                // 'あなたの学びたい言語が中国語の場合：選択なし/ 中国語',
                                                AppLocalizations.of(context)!.mateMatchingSub3,
                                                style: const TextStyle(
                                                  fontSize: 15,
                                                ),
                                                ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                          
                              ],
                            ),
                          ],
                        );
                      }
                    ); 
                  }
                );
              },
              child: const Text('Read How to Search')
              ),
          );
  }
  }