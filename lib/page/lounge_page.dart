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
// TextEditingConttrolloerはTextFieldで使うテキスト入力を管理するクラス
bool isInputEmpty = true;
bool? isDisabled;

class _LoungePageState extends State<LoungePage> {
  
@override                   
  void initState() {        
    super.initState();      
      // 追加機能の記述部分であることの明示
      // 関数の呼び出し（initStateはFlutter標準メソッド）
      // 親クラスの初期化処理　
      //「親クラス＝Stateクラス＝_WaitRoomPageState」のinitStateメソッドの呼び出し
      // initState()は、Widget作成時にflutterから自動的に一度だけ呼び出されます。
      // このメソッド内で、widgetが必要とする初期設定やデータの初期化を行うことが一般的
      // initState()とは　https://sl.bing.net/ivIFfFUd6Vo 
        isDisabled = false;   
  }       


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

                      // ■「チャット開始」ボタン
                      Container(child:
                        ElevatedButton( 
                            onPressed: isDisabled! ? null : () async{ 
                             setState(() {
                               isDisabled = true;
                               // 二重タップ防止                                 
                               // trueにして、タップをブロック
                             });

                              await Future.delayed(
                              const Duration(milliseconds: 50), //無効にする時間
                             );

                              if (context.mounted) { 
                                  Navigator.pushAndRemoveUntil (context,                              //画面遷移の定型   何やってるかの説明：https://sl.bing.net/b4piEYGC70C                                                                      //1回目のcontextは、「Navigator.pushメソッドが呼び出された時点」のビルドコンテキストを参照し
                                    MaterialPageRoute(builder: (context) => const MatchingProgressPage()),    //遷移先の画面を構築する関数を指定                                                                                                              
                                    (_) => false                               
                                  );
                              }
                              //   setState(() {
                              //     isDisabled = false;
                              //     //入力のタップを解除
                              // });
                           },
                            child: const Text("チャット開始"),
                           )
                         ),

                      // ■入力フィールド
                      Expanded(child: Padding( // TextFieldウィジェットをExpandedウィジェットで横に伸長させている
                         padding: const EdgeInsets.all(8.0), // 入力フィールドの枠の大きさ

                         child: TextField(               
                                    controller: controller,          // columとrowは子要素の範囲を指定しないから, expandedで自動で範囲をしてしてやると、textfiledが範囲を理解できて表示される
                                    onChanged: (value){              // TextFiledの値(value)を引数
                                                setState(() {        // valueに変化があったら、応答関数で状態を更新
                                                isInputEmpty = value.isEmpty;  // isEmptyメソッドは、bool値を返す
                                                });
                                    },
                                    decoration: const InputDecoration(
                                    filled: true,
                                    fillColor: Color.fromARGB(255, 244, 241, 241),
                                    contentPadding: EdgeInsets.only(left: 10),
                                    border: InputBorder.none,                                  
                                    ),
                                  ),
                               )), 

                      //■送信アイコン
                      IconButton (onPressed: () {                                                              
                                  controller.clear(); // 送信すると文字を消す
                                  }, 
                                  icon: Icon(Icons.send,
                                  color: isInputEmpty? Colors.grey : Colors.blue,
                                  ))
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