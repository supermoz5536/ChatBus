import 'package:flutter/material.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
    body: Center(
      child: Column(

        children: <Widget>[
      
        const Spacer(),
        
        SizedBox(
          height: 50,
          width: 150,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color.fromARGB(255, 167, 167, 167)
            ),
            onPressed: (){},
            child: const Text('男女フィルター')
          ),
        ),
      
        const Spacer(),
      
        SizedBox(
          height: 50,
          width: 150,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color.fromARGB(255, 167, 167, 167)
            ),
            onPressed: (){},
            child: const Text('国別フィルター')
          ),
        ),
      
        const Spacer(),      
      
        SizedBox(
          height: 50,
          width: 150,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color.fromARGB(255, 167, 167, 167)
            ),
            onPressed: (){},
            child: const Text('翻訳プラン選択')
          ),
        ),
      
        const Spacer(),
      
      ],
      ),
    ),


    );
  }
}