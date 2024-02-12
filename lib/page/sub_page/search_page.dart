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
  SelectedLanguage selectedLanguage = SelectedLanguage();
  bool _checkedEn = false;
  bool? _checkedJa = false;
  bool? _checkedEs = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ListView(
          children: [

            SwitchListTile(
              title: const Text('英語'),
              value: _checkedEn,
              onChanged: (bool newValue) {
                setState(() {
                  _checkedEn = newValue;
                  selectedLanguage.en = newValue;
                });
                // print('Before $selectedLanguage');
                ref.read(selectedLanguageProvider.notifier)
                   .setSelectedLanguage(selectedLanguage);
                // print('after $selectedLanguage');
              },
            ),

            CheckboxListTile(
              title: const Text('日本語'),
              value: _checkedJa,
              onChanged: (bool? newValue) {
                setState(() {
                  _checkedJa = newValue;
                  selectedLanguage.ja = newValue;
                });
                ref.read(selectedLanguageProvider.notifier)
                   .setSelectedLanguage(selectedLanguage);
              },
            ),

            CheckboxListTile(
              title: const Text('スペイン語'),
              value: _checkedEs,
              onChanged: (bool? newValue) {
                setState(() {
                  _checkedEs = newValue;
                  selectedLanguage.es = newValue;
                });
                ref.read(selectedLanguageProvider.notifier)
                   .setSelectedLanguage(selectedLanguage);
              },
            ),

          ],
        )
      ),
      );
    }
  }