import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:udemy_copy/model/selected_gender.dart';
import 'package:udemy_copy/model/selected_language.dart';
import 'package:udemy_copy/riverpod/provider/current_gender_provider.dart';
import 'package:udemy_copy/riverpod/provider/selected_gender_provider.dart';
import 'package:udemy_copy/riverpod/provider/selected_language_provider.dart';

//
class SearchPage extends ConsumerStatefulWidget {
  const SearchPage({super.key});

  @override
  ConsumerState<SearchPage> createState() => _SearchPageState();
}
class _SearchPageState extends ConsumerState<SearchPage> {

  @override
  Widget build(BuildContext context) {
    SelectedLanguage? selectedLanguage = ref.watch(selectedLanguageProvider);
    SelectedGender? selectedGender = ref.watch(selectedGenderProvider);
    String? currentGender = ref.watch(currentGenderProvider);

    
    return Scaffold(
      body: Center(
        child: ListView(
          children: [

            const Padding(
              padding: EdgeInsets.all(20.0),
              child: Text(
                'マッチング相手の設定をして\nチャットを始めよう!',
                style: TextStyle(
                  fontSize: 25,
                  color: Color.fromARGB(255, 75, 75, 75),
                  fontWeight: FontWeight.bold)),
            ),

            const Divider(
                    color: Color.fromARGB(255, 150, 150, 150),
                    height: 0,
                    thickness: 1,
                    indent: 30,
                    endIndent: 30,
                  ),
            
            const SizedBox(height: 100),

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
                  title: const Text(
                    '言語フィルター',
                    style: TextStyle(
                      fontSize: 20,
                      color: Color.fromARGB(255, 75, 75, 75),
                      fontWeight: FontWeight.bold)),
                  subtitle: const Text('マッチングしたい人の話す言語を選択できます！'),
                  collapsedBackgroundColor:const Color.fromARGB(255, 247, 241, 254),
                  backgroundColor: const Color.fromARGB(255, 247, 241, 254),
                  children: [
              
                    SwitchListTile(
                      title: const Text(
                        '英語',
                        style: TextStyle(
                          color: Color.fromARGB(255, 102, 102, 102),
                          fontSize: 15)),
                      value: selectedLanguage!.en!,
                      onChanged: (bool newValue) {
                        setState(() {
                          // Providerの状態を最新に更新
                          ref.read(selectedLanguageProvider.notifier).updateEn(newValue);
                        });
                      },
                    ),
              
                    SwitchListTile(
                      title: const Text(
                        '日本語',
                        style: TextStyle(
                          color: Color.fromARGB(255, 102, 102, 102),
                          fontSize: 15)),
                      value: selectedLanguage.ja!,
                      onChanged: (bool newValue) {
                        setState(() {
                          // Providerの状態を最新に更新。
                          ref.read(selectedLanguageProvider.notifier).updateJa(newValue);
                        });
              
                      },
                    ),
              
                    SwitchListTile(
                      title: const Text(
                        'スペイン語',
                        style: TextStyle(
                          color: Color.fromARGB(255, 102, 102, 102),
                          fontSize: 15)),
                      value: selectedLanguage.es!,
                      onChanged: (bool newValue) {
                        setState(() {
                          // 最新値に状態変数のプロパティに代入して
                          // Providerの状態を最新に更新
                          ref.read(selectedLanguageProvider.notifier).updateEs(newValue);
                        });
                      },
                    ),
                  ],
                ),
              ),
            ),


            const SizedBox(height: 100),


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
                  title: const Text(
                    'ジェンダーフィルター',
                    style: TextStyle(
                      fontSize: 20,
                      color: Color.fromARGB(255, 75, 75, 75),
                      fontWeight: FontWeight.bold)),
                  subtitle: const Text('マッチングしたい人の性別を選択できます！'),
                  children: [
                              
                    const Divider(
                      color: Color.fromARGB(255, 214, 214, 214),
                      height: 0,
                      thickness: 0.1,
                      indent: 10,
                      endIndent: 10,
                    ),
                              
                    CheckboxListTile(
                      title: const Text(
                        '男性',
                        style: TextStyle(
                          color: Color.fromARGB(255, 102, 102, 102),
                          fontSize: 15)),
                      value: selectedGender!.male == true && currentGender == 'male'
                        ? true
                        : false,
                      onChanged: (bool? newValue) {
                        setState(() {
                          // チェックボックス切り替え用の状態変数を更新
                          // Providerの状態を最新に更新
                          ref.read(currentGenderProvider.notifier).updateCurrentGender('male');
                          ref.read(selectedGenderProvider.notifier).updateMale(newValue);
                        });
                      },
                    ),
                              
                    CheckboxListTile(
                      title: const Text(
                        '女性',
                        style: TextStyle(
                          color: Color.fromARGB(255, 102, 102, 102),
                          fontSize: 15)),
                      value: selectedGender.female == true && currentGender == 'female'
                        ? true
                        : false,
                      onChanged: (bool? newValue) {
                        setState(() {
                          // チェックボックス切り替え用の状態変数を更新
                          // Providerの状態を最新に更新
                          ref.read(currentGenderProvider.notifier).updateCurrentGender('female');
                          ref.read(selectedGenderProvider.notifier).updateFemale(newValue);
                        });
                      },
                    ),
                              
                    CheckboxListTile(
                      title: const Text(
                        '男性 & 女性',
                        style: TextStyle(
                          color: Color.fromARGB(255, 102, 102, 102),
                          fontSize: 15)),
                      value: selectedGender.both == true && currentGender == 'both'
                        ? true
                        : false,
                      onChanged: (bool? newValue) {
                        setState(() {
                          // チェックボックス切り替え用の状態変数を更新
                          // Providerの状態を最新に更新
                          ref.read(currentGenderProvider.notifier).updateCurrentGender('both');
                          ref.read(selectedGenderProvider.notifier).updateBoth(newValue);
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