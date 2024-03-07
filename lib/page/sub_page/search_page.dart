import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:udemy_copy/model/selected_gender.dart';
import 'package:udemy_copy/model/selected_language.dart';
import 'package:udemy_copy/riverpod/provider/selected_gender_provider.dart';
import 'package:udemy_copy/riverpod/provider/selected_language_provider.dart';
import 'package:udemy_copy/riverpod/provider/selected_native_language_provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:udemy_copy/utils/isValidTotalCount.dart';


class SearchPage extends ConsumerStatefulWidget {
  const SearchPage({super.key});

  @override
  ConsumerState<SearchPage> createState() => _SearchPageState();
}
class _SearchPageState extends ConsumerState<SearchPage> {
  bool? withinRange;
  bool? withinTotalRange;

  @override
  Widget build(BuildContext context) {
    SelectedLanguage? selectedLanguage = ref.watch(selectedLanguageProvider);
    SelectedLanguage? selectedNativeLanguage = ref.watch(selectedNativeLanguageProvider);
    SelectedGender? selectedGender = ref.watch(selectedGenderProvider);
    

    
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

            const Divider(
                    color: Color.fromARGB(255, 150, 150, 150),
                    height: 0,
                    thickness: 1,
                    indent: 30,
                    endIndent: 30,
                  ),
            
            const SizedBox(height: 25),

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
                        // 両方レンジ内の場合のみ、状態変数を更新
                          withinRange = ref.read(selectedNativeLanguageProvider.notifier).isValidSelectionCount(newValue);
                          withinTotalRange = IsValidTotalCount.isValidTotalCount(
                            newValue,
                            selectedLanguage,
                            selectedNativeLanguage
                          );
                          if (withinRange == true && withinTotalRange == true) {
                            ref.read(selectedNativeLanguageProvider.notifier).updateEn(newValue);
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
                          }
                      },
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 50),

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
                    
                    // ■ 英語
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
                        selectedLanguage.en! == true
                          ? ref.read(selectedLanguageProvider.notifier).switchSelectedLanguage('none')
                          : ref.read(selectedLanguageProvider.notifier).switchSelectedLanguage('en');
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
                        }
                      },
                    ),
                    
                  ],
                ),
              ),
            ),


            const SizedBox(height: 50),


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
  }