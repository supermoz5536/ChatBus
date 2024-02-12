import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:udemy_copy/model/selected_language.dart';
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

            CheckboxListTile(
              title: const Text('日本語'),
              value: selectedLanguage.ja,
              onChanged: (bool? newValue) {
                setState(() {
                  // Providerの状態を最新に更新。
                  ref.read(selectedLanguageProvider.notifier).updateJa(newValue);
                });

              },
            ),

            CheckboxListTile(
              title: const Text('スペイン語'),
              value: selectedLanguage.es,
              onChanged: (bool? newValue) {
                setState(() {
                  // 最新値に状態変数のプロパティに代入して
                  // Providerの状態を最新に更新
                  ref.read(selectedLanguageProvider.notifier).updateEs(newValue);
                });
              },
            ),

          ],
        )
      ),
      );
    }
  }