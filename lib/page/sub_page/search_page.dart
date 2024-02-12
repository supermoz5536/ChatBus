import 'package:flutter/material.dart';
import 'package:udemy_copy/model/selected_language.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
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
              },
            ),

          ],
        )
      ),
      );
    }
  }