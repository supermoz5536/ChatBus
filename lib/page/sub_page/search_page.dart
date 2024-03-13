import 'dart:math';

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
  int? isButtonOn;
  bool? withinRange;
  bool? withinTotalRange;
  List<bool> isExpanded = [false, false, false, false];

  
  SnackBar customSnackBar() {
    return const SnackBar(
      duration: Duration(milliseconds: 2500),
      behavior: SnackBarBehavior.floating,
      margin: EdgeInsets.all(30),
      content: SizedBox(
        height: 70,
        child: Row(
          children: [
            Padding(
              padding: EdgeInsets.only(left: 5, right: 20),
                child: Icon(
                  Icons.error_outline_outlined,
                  color: Colors.white,),
            ),
            Flexible(
              child: Padding(
                padding: EdgeInsets.only(right: 10),
                child: Text(
                  '母国語設定と言語フィルターで、同じ言語を同時に選択することはできません。',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: Colors.white,
                  ),),
              ),
            ),
          ],
        ),
      ),
      backgroundColor:Color.fromARGB(255, 94, 94, 94),
    );
  }


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


            // ■ current Mode Display
            Padding(
              padding: const EdgeInsets.only(
                top: 20,
                left: 15,
                right: 15,
              ),
              child: Card(
                child: ExpansionTile(
                  leading: const Icon(
                    Icons.check_circle,
                    color: Colors.lightGreen),
                  // shapeプロパティを設定するとデフォルトの境界線UIの描画を避けることができる
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(0.0))),                    
                  title: Center(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 3.5),
                      child: Text(
                        AppLocalizations.of(context)!.currentSearchModeTitle,
                        style: const TextStyle(
                          fontSize: 18,
                          color: Color.fromARGB(255, 75, 75, 75),
                          fontWeight: FontWeight.bold)),
                    ),
                  ),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 7),
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
                        fontSize: 16,
                        color: Colors.grey
                      ),
                      ),
                  ),
                  collapsedBackgroundColor:const Color.fromARGB(255, 247, 241, 254),
                  backgroundColor: const Color.fromARGB(255, 247, 241, 254),
                  children: [
                    const Divider(
                      color: Color.fromARGB(255, 214, 214, 214),
                      height: 0,
                      thickness: 0.1,
                      indent: 10,
                      endIndent: 10,
                    ),
                    // ■ Mode Switch Buttons
                    Padding(
                      padding: const EdgeInsets.only(
                        top: 10,
                        bottom: 10
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                      
                          Padding(
                            padding: const EdgeInsets.only(
                              left: 5,
                              right: 5
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                              ElevatedButton(
                                style: ButtonStyle(
                                  backgroundColor: currentMode == 'native'
                                    ? MaterialStateProperty.all(Colors.redAccent)
                                    : MaterialStateProperty.all(Colors.lightBlueAccent),
                                  padding: MaterialStateProperty.all(const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 6,
                                  )),
                                  minimumSize: MaterialStateProperty.all(
                                    const Size(32, 16),)
                                ),
                                onPressed: () {
                                  ref.read(modeNameProvider.notifier).updateModeName('native');
                                  setState(() {
                                    currentMode == 'native';
                                  });
                                  },
                                child: Text(
                                  AppLocalizations.of(context)!.modeNameNative,
                                style: const TextStyle(
                                  color: Colors.white
                                ))),
                                        
                              const SizedBox(height: 20),
                              
                                        
                              ElevatedButton(
                                style: ButtonStyle(
                                  backgroundColor: currentMode == 'exchange'
                                    ? MaterialStateProperty.all(Colors.redAccent)
                                    : MaterialStateProperty.all(Colors.lightBlueAccent),
                                  padding: MaterialStateProperty.all(const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 6,
                                  )),
                                  minimumSize: MaterialStateProperty.all(
                                    const Size(32, 16),)
                                ),
                                onPressed: () {
                                  ref.read(modeNameProvider.notifier).updateModeName('exchange');
                                  setState(() {
                                    currentMode == 'exchange';
                                  });
                                  },
                                child: Text(
                                  AppLocalizations.of(context)!.modeNameExchange,
                                  style: const TextStyle(
                                    color: Colors.white
                                  ))),
                              ],
                            ),
                          ),
            
                          Padding(
                            padding: const EdgeInsets.only(
                              left: 5,
                              right: 5
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                        
                              ElevatedButton(
                                style: ButtonStyle(
                                  backgroundColor: currentMode == 'mate'
                                    ? MaterialStateProperty.all(Colors.redAccent)
                                    : MaterialStateProperty.all(Colors.lightBlueAccent),
                                  padding: MaterialStateProperty.all(const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 6,
                                  )),
                                  minimumSize: MaterialStateProperty.all(
                                    const Size(32, 16),)
                                ),
                                onPressed: () {
                                  ref.read(modeNameProvider.notifier).updateModeName('mate');
                                  setState(() {
                                    currentMode == 'mate';
                                  });
                                },
                                child: Text(
                                  AppLocalizations.of(context)!.modeNameMate,
                                  style: const TextStyle(
                                    color: Colors.white
                                  ))),

                              const SizedBox(height: 20),

                              ElevatedButton(
                                style: ButtonStyle(
                                  backgroundColor: currentMode == 'teachable'
                                    ? MaterialStateProperty.all(Colors.redAccent)
                                    : MaterialStateProperty.all(Colors.lightBlueAccent),
                                  padding: MaterialStateProperty.all(const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 6,
                                  )),
                                  minimumSize: MaterialStateProperty.all(
                                    const Size(32, 16),)
                                ),
                                onPressed: () {
                                  ref.read(modeNameProvider.notifier).updateModeName('teachable');
                                  setState(() {
                                    currentMode == 'teachable';
                                  });
                                },
                                child: Text(
                                  AppLocalizations.of(context)!.modeNameTeachable,
                                  style: const TextStyle(
                                    color: Colors.white
                                  ))),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // ■ 母国語設定
            Padding(
              padding: const EdgeInsets.only(
                top: 20,
                left: 50,
                right: 50,
              ),
              child: Card(
                child: ExpansionTile(
                  leading: const Icon(
                    Icons.record_voice_over_outlined,
                    color: Colors.grey,
                    size: 30,
                  ),
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
                  subtitle: Text(
                    AppLocalizations.of(context)!.subTitleSelectNativeLanguage,
                    style: const TextStyle(
                    color: Colors.grey,
                    )),
                  collapsedBackgroundColor:const Color.fromARGB(255, 247, 241, 254),
                  backgroundColor: const Color.fromARGB(255, 247, 241, 254),
                  children: [
                    const Divider(
                      color: Color.fromARGB(255, 214, 214, 214),
                      height: 0,
                      thickness: 0.1,
                      indent: 10,
                      endIndent: 10,
                    ),
              
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
                          if (withinRange == true) {
                            if(newValue == true && selectedLanguage!.en == true ) {
                              ScaffoldMessenger.of(context).showSnackBar(customSnackBar());
                            } else {
                            ref.read(selectedNativeLanguageProvider.notifier).updateEn(newValue);
                            }
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
                          if (withinRange == true) {
                            if(newValue == true && selectedLanguage!.ja == true ) {
                              ScaffoldMessenger.of(context).showSnackBar(customSnackBar());
                            } else {
                            ref.read(selectedNativeLanguageProvider.notifier).updateJa(newValue);
                            }
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
                          if (withinRange == true) {
                            if(newValue == true && selectedLanguage!.es == true ) {
                              ScaffoldMessenger.of(context).showSnackBar(customSnackBar());
                            } else {
                            ref.read(selectedNativeLanguageProvider.notifier).updateEs(newValue);
                            }
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
                          if (withinRange == true) {
                            if(newValue == true && selectedLanguage!.ko == true ) {
                              ScaffoldMessenger.of(context).showSnackBar(customSnackBar());
                            } else {
                            ref.read(selectedNativeLanguageProvider.notifier).updateKo(newValue);
                            }
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
                          if (withinRange == true) {
                            if(newValue == true && selectedLanguage!.zh == true ) {
                              ScaffoldMessenger.of(context).showSnackBar(customSnackBar());
                            } else {
                            ref.read(selectedNativeLanguageProvider.notifier).updateZh(newValue);
                            }
                          }
                      },
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 25),

            // ■ 言語フィルター
            Padding(
              padding: const EdgeInsets.only(
                left: 50,
                right: 50,
              ),
              child: Card(
                child: ExpansionTile(
                  leading: const Icon(
                    Icons.transcribe_outlined,
                    color: Colors.grey,
                    size: 30,
                  ),
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
                  subtitle: Text(
                    AppLocalizations.of(context)!.subTitleLanguageFilter,
                    style: const TextStyle(
                      color: Colors.grey
                    ),),
                  collapsedBackgroundColor:const Color.fromARGB(255, 247, 241, 254),
                  backgroundColor: const Color.fromARGB(255, 247, 241, 254),
                  children: [
                    const Divider(
                      color: Color.fromARGB(255, 214, 214, 214),
                      height: 0,
                      thickness: 0.1,
                      indent: 10,
                      endIndent: 10,
                    ),
                    
                    // ■ 英語.
                    SwitchListTile(
                      title: Text(
                        AppLocalizations.of(context)!.english,
                        style: const TextStyle(
                          color: Color.fromARGB(255, 102, 102, 102),
                          fontSize: 15)),
                      value: selectedLanguage!.en!,
                      onChanged: (bool newValue) {
                        if(newValue == true && selectedNativeLanguage.en == true ) {
                          ScaffoldMessenger.of(context).showSnackBar(customSnackBar());
                        } else {
                          ref.read(selectedLanguageProvider.notifier).switchSelectedLanguage('en');
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
                       if(newValue == true && selectedNativeLanguage.ja == true ) {
                          ScaffoldMessenger.of(context).showSnackBar(customSnackBar());
                        } else {
                          ref.read(selectedLanguageProvider.notifier).switchSelectedLanguage('ja');
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
                       if(newValue == true && selectedNativeLanguage.es == true ) {
                          ScaffoldMessenger.of(context).showSnackBar(customSnackBar());
                        } else {
                          ref.read(selectedLanguageProvider.notifier).switchSelectedLanguage('es');
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
                       if(newValue == true && selectedNativeLanguage.ko == true ) {
                          ScaffoldMessenger.of(context).showSnackBar(customSnackBar());
                        } else {
                          ref.read(selectedLanguageProvider.notifier).switchSelectedLanguage('ko');
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
                       if(newValue == true && selectedNativeLanguage.zh == true ) {
                          ScaffoldMessenger.of(context).showSnackBar(customSnackBar());
                        } else {
                          ref.read(selectedLanguageProvider.notifier).switchSelectedLanguage('zh');
                        }
                      },
                    ),
                  ],
                ),
              ),
            ),


            const SizedBox(height: 25),

            // ■ ジェンダーフィルター
            Padding(
              padding: const EdgeInsets.only(
                left: 50,
                right: 50,
              ),
              child: Card(
                child: ExpansionTile(
                  leading: const Icon(
                    Icons.wc_outlined,
                    color: Colors.grey,
                    size: 30,
                  ),
                  // shapeプロパティを設定するとデフォルトの境界線UIの描画を避けることができる
                  shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.all(Radius.circular(0.0))),
                  title: Text(
                    AppLocalizations.of(context)!.titleGenderFilter,
                    style: const TextStyle(
                      fontSize: 20,
                      color: Color.fromARGB(255, 75, 75, 75),
                      fontWeight: FontWeight.bold)),
                  subtitle: Text(
                    AppLocalizations.of(context)!.subTitleGenderFilter,
                    style: const TextStyle(
                      color: Colors.grey
                    ),),
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
                              elevation: 2,
                              animationDuration: const Duration(milliseconds: 500),
                              expandedHeaderPadding: const EdgeInsets.all(8),
                              expansionCallback: (int index, newIsExpanded) {
                                setState(() {
                                  isExpanded[index] = newIsExpanded;
                                });
                              },                    
                              children: [
                                                          
                                // ■ ネイティブマッチング
                                ExpansionPanel(
                                  canTapOnHeader: true,
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
                                            fontSize: 20,
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
                                              child: Icon(
                                                Icons.check,
                                                size: 15,
                                                color: Color.fromARGB(255, 144, 144, 144),
                                              ),
                                            ),
                                            Flexible(
                                              child: Text(
                                                //'母国語が同じユーザーを優先してマッチング',
                                                AppLocalizations.of(context)!.nativeMatchingSub1,
                                                style: const TextStyle(
                                                  color: Color.fromARGB(255, 144, 144, 144),
                                                  fontSize: 15,
                                                ),
                                                ),
                                            ),
                                          ],
                                        ),
                                      ),

                                      // // ■ ネイティブマッチング 2行目
                                      // Padding(
                                      //   padding: const EdgeInsets.only(right: 8, bottom: 8),
                                      //   child: Row(
                                      //     crossAxisAlignment: CrossAxisAlignment.start,
                                      //     children: [
                                      //       const Padding(
                                      //         padding: EdgeInsets.only(
                                      //           left: 20,
                                      //           right: 10,
                                      //           ),
                                      //         child: Icon(
                                      //           Icons.check,
                                      //           size: 15,
                                      //           color: Color.fromARGB(255, 144, 144, 144),
                                      //         ),
                                      //       ),
                                      //       Flexible(
                                      //         child: Text(
                                      //           //'母国語設定と言語フィルターで "母国語" を選択',
                                      //           AppLocalizations.of(context)!.nativeMatchingSub2,
                                      //           style: const TextStyle(
                                      //             color: Color.fromARGB(255, 144, 144, 144),
                                      //             fontSize: 15,
                                      //           ),
                                      //           ),
                                      //       ),
                                      //     ],
                                      //   ),
                                      // ),

                                      // // ■ ネイティブマッチング 3行目
                                      // Padding(
                                      //   padding: const EdgeInsets.only(right: 8, bottom: 25),
                                      //   child: Row(
                                      //     crossAxisAlignment: CrossAxisAlignment.start,
                                      //     children: [
                                      //       const Padding(
                                      //         padding:  EdgeInsets.only(
                                      //           left: 20,
                                      //           right: 10,
                                      //           ),
                                      //         child: Icon(
                                      //           Icons.check,
                                      //           size: 15,
                                      //           color: Color.fromARGB(255, 144, 144, 144),
                                      //         ),
                                      //       ),
                                      //       Flexible(
                                      //         child: Text(
                                      //           //'母国語が英語の場合：英語 / 英語',
                                      //           AppLocalizations.of(context)!.nativeMatchingSub3,
                                      //           style: const TextStyle(
                                      //             color: Color.fromARGB(255, 144, 144, 144),
                                      //             fontSize: 15,
                                      //           ),
                                      //           ),
                                      //       ),
                                      //     ],
                                      //   ),
                                      // ),
                                    ],
                                  ),
                                ),
                            
                                // ■ クロスマッチング
                                ExpansionPanel(
                                  canTapOnHeader: true,
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
                                            fontSize: 20,
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
                                              child: Icon(
                                                Icons.done,
                                                size: 15,
                                                color: Color.fromARGB(255, 144, 144, 144),
                                              ),
                                            ),
                                            Flexible(
                                              child: Text(
                                                // '「あなたの母国語に興味があり、かつ、あなたの学びたい言語が母国語の人」とマッチング',
                                                AppLocalizations.of(context)!.exchangeMatchingSub1,
                                                style: const TextStyle(
                                                  color: Color.fromARGB(255, 144, 144, 144),
                                                  fontSize: 15,
                                                ),
                                                ),
                                            ),
                                          ],
                                        ),
                                      ),

                                      // // ■ クロスマッチング 2行目
                                      // Padding(
                                      //   padding: const EdgeInsets.only(right: 8, bottom: 8),
                                      //   child: Row(
                                      //     crossAxisAlignment: CrossAxisAlignment.start,
                                      //     children: [
                                      //       const Padding(
                                      //         padding:  EdgeInsets.only(
                                      //           left: 20,
                                      //           right: 10,
                                      //           ),
                                      //         child: Icon(
                                      //           Icons.done,
                                      //           size: 15,
                                      //           color: Color.fromARGB(255, 144, 144, 144),
                                      //         ),
                                      //       ),
                                      //       Flexible(
                                      //         child: Text(
                                      //           // '母国語設定で母国語を選択し、言語フィルターであなたの学びたい言語を選択',
                                      //           AppLocalizations.of(context)!.exchangeMatchingSub2,
                                      //           style: const TextStyle(
                                      //             color: Color.fromARGB(255, 144, 144, 144),
                                      //             fontSize: 15,
                                      //           ),
                                      //           ),
                                      //       ),
                                      //     ],
                                      //   ),
                                      // ),

                                      // // ■ クロスマッチング 3行目
                                      // Padding(
                                      //   padding: const EdgeInsets.only(right: 8, bottom: 25),
                                      //   child: Row(
                                      //     crossAxisAlignment: CrossAxisAlignment.start,
                                      //     children: [
                                      //       const Padding(
                                      //         padding: EdgeInsets.only(
                                      //           left: 20,
                                      //           right: 10,
                                      //           ),
                                      //         child: Icon(
                                      //           Icons.done,
                                      //           size: 15,
                                      //           color: Color.fromARGB(255, 144, 144, 144),
                                      //         ),
                                      //       ),
                                      //       Flexible(
                                      //         child: Text(
                                      //           // '母国語が英語の場合：英語 / 中国語',
                                      //           AppLocalizations.of(context)!.exchangeMatchingSub3,
                                      //           style: const TextStyle(
                                      //             color: Color.fromARGB(255, 144, 144, 144),
                                      //             fontSize: 15,
                                      //           ),
                                      //           ),
                                      //       ),
                                      //     ],
                                      //   ),
                                      // ),
                                    ],
                                  ),
                                ),
                                          
                                // ■ ティーチマッチング
                                ExpansionPanel(
                                  canTapOnHeader: true,
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
                                            fontSize: 20,
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
                                              child: Icon(
                                                Icons.check,
                                                size: 15,
                                                color: Color.fromARGB(255, 144, 144, 144),
                                              ),
                                            ),
                                            Flexible(
                                              child: Text(
                                                // 'あなたの母国語に興味がある全ての人とマッチング',
                                                AppLocalizations.of(context)!.teachableMatchingSub1,
                                                style: const TextStyle(
                                                  color: Color.fromARGB(255, 144, 144, 144),
                                                  fontSize: 15,
                                                ),
                                                ),
                                            ),
                                          ],
                                        ),
                                      ),

                                      // // ■ ティーチマッチング 2行目
                                      // Padding(
                                      //   padding: const EdgeInsets.only(right: 8, bottom: 8),
                                      //   child: Row(
                                      //     crossAxisAlignment: CrossAxisAlignment.start,
                                      //     children: [
                                      //       const Padding(
                                      //         padding: EdgeInsets.only(
                                      //           left: 20,
                                      //           right: 10,
                                      //           ),
                                      //         child: Icon(
                                      //           Icons.check,
                                      //           size: 15,
                                      //           color: Color.fromARGB(255, 144, 144, 144),
                                      //         ),
                                      //       ),
                                      //       Flexible(
                                      //         child: Text(
                                      //           // '母国語設定で母国語を選択し、言語フィルターは何も選択しない',
                                      //           AppLocalizations.of(context)!.teachableMatchingSub2,
                                      //           style: const TextStyle(
                                      //             color: Color.fromARGB(255, 144, 144, 144),
                                      //             fontSize: 15,
                                      //           ),
                                      //           ),
                                      //       ),
                                      //     ],
                                      //   ),
                                      // ),

                                      // // ■ ティーチマッチング 3行目
                                      // Padding(
                                      //   padding: const EdgeInsets.only(right: 8, bottom: 25),
                                      //   child: Row(
                                      //     crossAxisAlignment: CrossAxisAlignment.start,
                                      //     children: [
                                      //       const Padding(
                                      //         padding: EdgeInsets.only(
                                      //           left: 20,
                                      //           right: 10,
                                      //           ),
                                      //         child: Icon(
                                      //           Icons.check,
                                      //           size: 15,
                                      //           color: Color.fromARGB(255, 144, 144, 144),
                                      //         ),
                                      //       ),
                                      //       Flexible(
                                      //         child: Text(
                                      //           // 'あなたの母国語が英語の場合：英語 / 選択なし',
                                      //           AppLocalizations.of(context)!.teachableMatchingSub3,
                                      //           style: const TextStyle(
                                      //             color: Color.fromARGB(255, 144, 144, 144),
                                      //             fontSize: 15,
                                      //           ),
                                      //           ),
                                      //       ),
                                      //     ],
                                      //   ),
                                      // ),
                                    ],
                                  ),
                                ),
                                          
                                // ■ メイトマッチング
                                ExpansionPanel(
                                  canTapOnHeader: true,
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
                                            fontSize: 20,
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
                                              child: Icon(
                                                Icons.check,
                                                size: 15,
                                                color: Color.fromARGB(255, 144, 144, 144),
                                              ),
                                            ),
                                            Flexible(
                                              child: Text(
                                                // 'あなたと同じ言語を学習してる仲間と優先的にマッチング',
                                                AppLocalizations.of(context)!.mateMatchingSub1,
                                                style: const TextStyle(
                                                  color: Color.fromARGB(255, 144, 144, 144),
                                                  fontSize: 15,
                                                ),
                                                ),
                                            ),
                                          ],
                                        ),
                                      ),

                                      // // ■ メイトマッチング 2行目
                                      // Padding(
                                      //   padding: const EdgeInsets.only(right: 8, bottom: 8),
                                      //   child: Row(
                                      //     crossAxisAlignment: CrossAxisAlignment.start,
                                      //     children: [
                                      //       const Padding(
                                      //         padding: EdgeInsets.only(
                                      //           left: 20,
                                      //           right: 10,
                                      //           ),
                                      //         child: Icon(
                                      //           Icons.check,
                                      //           size: 15,
                                      //           color: Color.fromARGB(255, 144, 144, 144),
                                      //         ),
                                      //       ),
                                      //       Flexible(
                                      //         child: Text(
                                      //           // '母国語設定は何も選択せず、言語フィルターであなたの学びたい言語を選択',
                                      //           AppLocalizations.of(context)!.mateMatchingSub2,
                                      //           style: const TextStyle(
                                      //             color: Color.fromARGB(255, 144, 144, 144),
                                      //             fontSize: 15,
                                      //           ),
                                      //           ),
                                      //       ),
                                      //     ],
                                      //   ),
                                      // ),

                                      // // ■ メイトマッチング 3行目
                                      // Padding(
                                      //   padding: const EdgeInsets.only(right: 8, bottom: 25),
                                      //   child: Row(
                                      //     crossAxisAlignment: CrossAxisAlignment.start,
                                      //     children: [
                                      //       const Padding(
                                      //         padding: EdgeInsets.only(
                                      //           left: 20,
                                      //           right: 10,
                                      //           ),
                                      //         child: Icon(
                                      //           Icons.check,
                                      //           size: 15,
                                      //           color: Color.fromARGB(255, 144, 144, 144),
                                      //         ),
                                      //       ),
                                      //       Flexible(
                                      //         child: Text(
                                      //           // 'あなたの学びたい言語が中国語の場合：選択なし/ 中国語',
                                      //           AppLocalizations.of(context)!.mateMatchingSub3,
                                      //           style: const TextStyle(
                                      //             color: Color.fromARGB(255, 144, 144, 144),
                                      //             fontSize: 15,
                                      //           ),
                                      //           ),
                                      //       ),
                                      //     ],
                                      //   ),
                                      // ),
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
              child: Text(AppLocalizations.of(context)!.readHowToSearch)
              ),
          );
  }
  }