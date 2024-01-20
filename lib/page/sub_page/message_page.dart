import 'package:flutter/material.dart';

class MessagePage extends StatefulWidget {
  const MessagePage({super.key});

  @override
  State<MessagePage> createState() => _MessagePageState();
}

class _MessagePageState extends State<MessagePage> {
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
              backgroundColor: Colors.lightBlueAccent
            ),
            onPressed: (){},
            child: const Text('友達1からのメッセージ')
          ),
        ),
      
        const Spacer(),
      
        SizedBox(
          height: 50,
          width: 200,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.lightBlueAccent
            ),
            onPressed: (){},
            child: const Text('友達2からのメッセージ')
          ),
        ),
      
        const Spacer(),      
      
        SizedBox(
          height: 50,
          width: 200,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.lightBlueAccent
            ),
            onPressed: (){},
            child: const Text('友達3からのメッセージ')
          ),
        ),
      
        const Spacer(),
      
      ],
      ),
    ),


    );
  }
}