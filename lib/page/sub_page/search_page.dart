import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:udemy_copy/model/selected_language.dart';
import 'package:udemy_copy/riverpod/provider/current_gender_provider.dart';
import 'package:udemy_copy/riverpod/provider/selected_language_provider.dart';


class SearchPage extends ConsumerStatefulWidget {
  const SearchPage({super.key});

  @override
  ConsumerState<SearchPage> createState() => _SearchPageState();
}
class _SearchPageState extends ConsumerState<SearchPage> {

  @override
  Widget build(BuildContext context) {
    SelectedLanguage? selectedLanguage = ref.watch(selectedLanguageProvider);
    String? currentGender = ref.watch(currentGenderProvider);
    
    return Scaffold(
      body: Center(
        child: ListView(
          children: [

            SwitchListTile(
              title: const Text('英語'),
              value: selectedLanguage!.en!,
              onChanged: (bool newValue) {
                setState(() {
                  // Providerの状態を最新に更新
                  ref.read(selectedLanguageProvider.notifier).updateEn(newValue);
                });
              },
            ),

            SwitchListTile(
              title: const Text('日本語'),
              value: selectedLanguage.ja!,
              onChanged: (bool newValue) {
                setState(() {
                  // Providerの状態を最新に更新。
                  ref.read(selectedLanguageProvider.notifier).updateJa(newValue);
                });

              },
            ),

            SwitchListTile(
              title: const Text('スペイン語'),
              value: selectedLanguage.es!,
              onChanged: (bool newValue) {
                setState(() {
                  // 最新値に状態変数のプロパティに代入して
                  // Providerの状態を最新に更新
                  ref.read(selectedLanguageProvider.notifier).updateEs(newValue);
                });
              },
            ),


            CheckboxListTile(
              title: const Text('男性'),
              value: currentGender == 'male'
                ? true
                : false,
              onChanged: (bool? newValue) {
                setState(() {
                  // 最新値に状態変数のプロパティに代入して
                  // Providerの状態を最新に更新
                  ref.read(currentGenderProvider.notifier).updateCurrentGender('male');
                });
              },
            ),

            CheckboxListTile(
              title: const Text('女性'),
              value: currentGender == 'female'
                ? true
                : false,
              onChanged: (bool? newValue) {
                setState(() {
                  // 最新値に状態変数のプロパティに代入して
                  // Providerの状態を最新に更新
                  ref.read(currentGenderProvider.notifier).updateCurrentGender('female');
                });
              },
            ),

            CheckboxListTile(
              title: const Text('男性 & 女性'),
              value: currentGender == 'both'
                ? true
                : false,
              onChanged: (bool? newValue) {
                setState(() {
                  // 最新値に状態変数のプロパティに代入して
                  // Providerの状態を最新に更新
                  ref.read(currentGenderProvider.notifier).updateCurrentGender('both');
                });
              },
            ),



          ],
        )
      ),
      );
    }
  }