import 'package:flutter/material.dart';

class FriendListPage extends StatefulWidget {
  const FriendListPage({super.key});

  @override
  State<FriendListPage> createState() => _FriendListPageState();
}

class _FriendListPageState extends State<FriendListPage> {
  @override
  Widget build(BuildContext context) {
   return Scaffold(
    body: Center(
      child: Column(
        
        children: <Widget>[
      
        const Spacer(),
        
        SizedBox(
          height: 50,
          width: 200,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.lightGreenAccent
            ),
            onPressed: (){},
            child: const Text('友達1')
          ),
        ),
      
        const Spacer(),
      
        SizedBox(
          height: 50,
          width: 200,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.lightGreenAccent
            ),
            onPressed: (){},
            child: const Text('友達2')
          ),
        ),
      
        const Spacer(),      
      
        SizedBox(
          height: 50,
          width: 200,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.lightGreenAccent
            ),
            onPressed: (){},
            child: const Text('友達3')
          ),
        ),
      
        const Spacer(),
      
      ],
      ),
    ),


    );
  }
}