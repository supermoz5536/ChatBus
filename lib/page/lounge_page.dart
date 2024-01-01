import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:udemy_copy/page/matching_progress_page.dart';

class LoungePage extends StatefulWidget {
  const LoungePage({super.key});

  @override
  State<LoungePage> createState() => _LoungePageState();
}

final TextEditingController controller = TextEditingController();

class _LoungePageState extends State<LoungePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.lightBlueAccent,

      appBar: AppBar(
        title: const Text('ラウンジページ'),
      ),

      body: Stack(children: <Widget>[



      Container(),




      // ■フッター部分
      Column( // column()の縦移動で、画面1番下に配置
            mainAxisAlignment: MainAxisAlignment.end, // https://zenn.dev/wm3/articles/7332788c626b39
            children: [
              Container(
                  color: Colors.white,
                  height: 68, // フッター領域の縦幅
                  
                  child: Row(children: [
                      Expanded(child: Padding( // TextFieldウィジェットをExpandedウィジェットで横に伸長させている
                         padding: const EdgeInsets.all(8.0), // 入力フィールドの枠の大きさ

                         child: TextField( 
                                    controller: controller,               //columとrowは子要素の範囲を指定しないから, expandedで自動で範囲をしてしてやると、textfiledが範囲を理解できて表示される
                                    decoration: const InputDecoration(
                                    contentPadding: EdgeInsets.only(left: 10),
                                    border: OutlineInputBorder(),
                                    ),
                                  ),
                               )), 

                                IconButton (onPressed: () async {
                                if (context.mounted) {                                                       
                                    Navigator.push(                              //画面遷移の定型   何やってるかの説明：https://sl.bing.net/b4piEYGC70C
                                    context,                                     //1回目のcontextは、「Navigator.pushメソッドが呼び出された時点」のビルドコンテキストを参照し
                                        MaterialPageRoute(                       //新しい画面への遷移を定義(アニメーションとか遷移先の画面の設定)
                                        builder: (context) => MatchingProgressPage()         //遷移先の画面を構築する関数を指定                                                                                                              
                                        )
                                      );
                                    }                                  
                                    // 送信ボタンを押した際の処理を記述
                                    // 画面遷移
                                    // MatchingProgressPageクラスのコンストラクタの引数は、今のところ設定なし                                  
                                    controller.clear();}, // 送信ボタンを押したら、文字を消す
                                    icon: Icon(Icons.send))
                                    ],
                                  ),
                                ),

            ],
          )
 


      ],
      ),
      

      
    );
  }
}