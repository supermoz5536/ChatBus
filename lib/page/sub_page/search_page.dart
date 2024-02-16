import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:udemy_copy/model/selected_gender.dart';
import 'package:udemy_copy/model/selected_language.dart';
import 'package:udemy_copy/riverpod/provider/current_gender_provider.dart';
import 'package:udemy_copy/riverpod/provider/selected_gender_provider.dart';
import 'package:udemy_copy/riverpod/provider/selected_language_provider.dart';
import 'package:udemy_copy/riverpod/provider/selected_native_language_provider.dart';

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
    SelectedLanguage? selectedNativeLanguage = ref.watch(selectedNativeLanguageProvider);
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
                  title: const Text(
                    '母国語の選択',
                    style: TextStyle(
                      fontSize: 20,
                      color: Color.fromARGB(255, 75, 75, 75),
                      fontWeight: FontWeight.bold)),
                  subtitle: const Text('自分が流暢に話せる言語を選択しよう！'),
                  collapsedBackgroundColor:const Color.fromARGB(255, 247, 241, 254),
                  backgroundColor: const Color.fromARGB(255, 247, 241, 254),
                  children: [
              
                    SwitchListTile(
                      title: const Text(
                        '英語',
                        style: TextStyle(
                          color: Color.fromARGB(255, 102, 102, 102),
                          fontSize: 15)),
                      value: selectedNativeLanguage!.en!,
                      onChanged: (bool newValue) {
                        setState(() {
                          // Providerの状態を最新に更新
                          ref.read(selectedNativeLanguageProvider.notifier).updateEn(newValue);
                        });
                      },
                    ),
              
                    SwitchListTile(
                      title: const Text(
                        '日本語',
                        style: TextStyle(
                          color: Color.fromARGB(255, 102, 102, 102),
                          fontSize: 15)),
                      value: selectedNativeLanguage.ja!,
                      onChanged: (bool newValue) {
                        setState(() {
                          // Providerの状態を最新に更新。
                          ref.read(selectedNativeLanguageProvider.notifier).updateJa(newValue);
                        });
              
                      },
                    ),
              
                    SwitchListTile(
                      title: const Text(
                        'スペイン語',
                        style: TextStyle(
                          color: Color.fromARGB(255, 102, 102, 102),
                          fontSize: 15)),
                      value: selectedNativeLanguage.es!,
                      onChanged: (bool newValue) {
                        setState(() {
                          // 最新値に状態変数のプロパティに代入して
                          // Providerの状態を最新に更新
                          ref.read(selectedNativeLanguageProvider.notifier).updateEs(newValue);
                        });
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
              
                    CheckboxListTile(
                      title: const Text(
                        '英語',
                        style: TextStyle(
                          color: Color.fromARGB(255, 102, 102, 102),
                          fontSize: 15)),
                      value: selectedLanguage!.en!,
                      onChanged: (bool? newValue) {
                        setState(() {
                          // Providerの状態を最新に更新
                          ref.read(selectedLanguageProvider.notifier).updateEn(newValue);
                        });
                      },
                    ),
              
                    CheckboxListTile(
                      title: const Text(
                        '日本語',
                        style: TextStyle(
                          color: Color.fromARGB(255, 102, 102, 102),
                          fontSize: 15)),
                      value: selectedLanguage.ja!,
                      onChanged: (bool? newValue) {
                        setState(() {
                          // Providerの状態を最新に更新。
                          ref.read(selectedLanguageProvider.notifier).updateJa(newValue);
                        });
              
                      },
                    ),
              
                    CheckboxListTile(
                      title: const Text(
                        'スペイン語',
                        style: TextStyle(
                          color: Color.fromARGB(255, 102, 102, 102),
                          fontSize: 15)),
                      value: selectedLanguage.es!,
                      onChanged: (bool? newValue) {
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
                          if (newValue == true){
                          // currentGender を male に更新することで、setState()実行時に他の選択肢がfalseになる
                          ref.read(currentGenderProvider.notifier).updateCurrentGender('male');
                          // 状態値の全3つのプロパティを更新
                          ref.read(selectedGenderProvider.notifier).updateMale(true);
                          ref.read(selectedGenderProvider.notifier).updateFemale(false);
                          ref.read(selectedGenderProvider.notifier).updateBoth(false);
                          } else if (newValue == false ){ }
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
                          if (newValue == true){
                          // currentGender を male に更新することで、setState()実行時に他の選択肢がfalseになる
                          ref.read(currentGenderProvider.notifier).updateCurrentGender('female');
                          // 状態値の全3つのプロパティを更新
                          ref.read(selectedGenderProvider.notifier).updateMale(false);
                          ref.read(selectedGenderProvider.notifier).updateFemale(true);
                          ref.read(selectedGenderProvider.notifier).updateBoth(false);
                          } else if (newValue == false ){ }
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
                          if (newValue == true){
                          // currentGender を male に更新することで、setState()実行時に他の選択肢がfalseになる
                          ref.read(currentGenderProvider.notifier).updateCurrentGender('both');
                          // 状態値の全3つのプロパティを更新
                          ref.read(selectedGenderProvider.notifier).updateMale(false);
                          ref.read(selectedGenderProvider.notifier).updateFemale(false);
                          ref.read(selectedGenderProvider.notifier).updateBoth(true);
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