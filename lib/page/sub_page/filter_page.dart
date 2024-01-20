import 'package:flutter/material.dart';

class FilterPage extends StatefulWidget {
  const FilterPage({super.key});

  @override
  State<FilterPage> createState() => _FilterPageState();
}

class _FilterPageState extends State<FilterPage> {
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