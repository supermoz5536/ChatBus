import 'package:flutter/material.dart';
import 'package:udemy_copy/firestore/user_firestore.dart';
import 'package:udemy_copy/model/matching_progress.dart';
import 'package:udemy_copy/page/matching_progress_page.dart';

class LoungePage extends StatefulWidget {
  const LoungePage({super.key});

  @override
  State<LoungePage> createState() => _LoungePageState();
}

final TextEditingController controller = TextEditingController();
// TextEditingConttrolloerはTextFieldで使うテキスト入力を管理するクラス
bool isInputEmpty = true;
String? myUid;
bool? isDisabled;
MatchingProgress? matchingProgress;
var _overlayController1st = OverlayPortalController();
var _overlayController2nd = OverlayPortalController();

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

    // 起動時に1度行うmyUidを確認する処理
     UserFirestore.getAccount()                       // 自分のユーザー情報をDBへ書き込み
                  .then((getUid) async{          // .then(引数){コールバック関数}で、親クラス(=initState)の非同期処理が完了したときに実行するサブの関数を定義
                     myUid = getUid;                     // 状態変数myUidに、非同期処理の結果（uid）を設定           
                     matchingProgress = MatchingProgress(myUid: myUid); 
                       print('wait_room_page.dartの初期取得myUid = $myUid');                               
                   });
     
     




  }       


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.lightBlueAccent,

      appBar: AppBar(
        title: const Text('ラウンジページ'),
        actions: <Widget>[


          // ■ リクエスト通知ボタン
          OverlayPortal(
            controller: _overlayController1st, 
            overlayChildBuilder: (BuildContext context){
             return  Stack(
               children: [
                 GestureDetector(
                 // Stack()最下層の全領域がスコープの範囲
                   onTap: (){
                      _overlayController1st.toggle();
                   },
                   child: Container(color: Colors.transparent),
                 ),
                   
                 const Positioned(
                   top: 70,
                   left: 55,
                   height: 140,
                   width: 400,
                   child: 
                      Card(
                        elevation: 20,                              
                        color:Color.fromARGB(255, 156, 156, 156),
                        child:
                          Padding(
                            padding: EdgeInsets.all(10.0),
                            child: 
                              Column(
                                mainAxisSize: MainAxisSize.min,
                                children: <Widget>[
                                  SizedBox(height: 8,),
                                  Text('リクエスト通知の表示'),
                              ],
                            ),
                          ),
                        ),
                      ),                 
                    ],
                  );
                },
            child: IconButton(
              onPressed: _overlayController1st.toggle,
              icon: const Icon(Icons.add_outlined))
            ),          


          // ■ DMの通知ボタン
          OverlayPortal(
            controller: _overlayController2nd, 
            overlayChildBuilder: (BuildContext context){
             return  Stack(
               children: [
                 GestureDetector(
                 // Stack()最下層の全領域がスコープの範囲
                   onTap: (){
                      _overlayController2nd.toggle();
                   },
                   child: Container(color: Colors.transparent),
                 ),
                   
                 const Positioned(
                   top: 70,
                   left: 55,
                   height: 140,
                   width: 400,
                   child: 
                      Card(
                        elevation: 20,                              
                        color:Color.fromARGB(255, 156, 156, 156),
                        child:
                          Padding(
                            padding: EdgeInsets.all(10.0),
                            child: 
                              Column(
                                mainAxisSize: MainAxisSize.min,
                                children: <Widget>[
                                  SizedBox(height: 8,),
                                  Text('DM通知の表示'),
                              ],
                            ),
                          ),
                        ),
                      ),                 
                    ],
                  );
                },
            child: IconButton(
              onPressed: _overlayController2nd.toggle,
              icon: const Icon(Icons.visibility))
            ), 


          // ■ マッチングヒストリーの表示ボタン
          Builder(
            builder: (context) {
              return IconButton(onPressed: (){
                Scaffold.of(context).openEndDrawer();
                // .of(context)は記述したそのウィジェット以外のスコープでscaffoldを探す
                // AppBar は Scaffold の内部にあるので、AppBar の context では scaffold が見つけられない
                // Builderウィジェット は Scaffold から独立してるので、その context においては scaffold が見つけられる
              }, icon: const Icon(Icons.alarm_off_sharp));
            }
          ),
        ],        
      ),


      drawer: Drawer(
        child: Column(
          children: [
            Expanded(
            //ListView が無限の長さを持つので直接 column でラップすると不具合
            //Expanded で長さを限界値に指定
              child: ListView(
                children: const[
                  SizedBox(
                    height: 160.0,
                    child: 
                      DrawerHeader(
                        child:
                          Column(
                            children: [
                              Text('フレンド登録を5人達成するとフィルターの有料機能が使える'),
                              Spacer(flex: 1,),
                              Text('☆5の登録済みチェック部分'),
                              Spacer(flex: 1,),
                                
                              ],                              
                             )
                           ),
                  ),
                  ListTile(title: Text('text'),),
                  Spacer(flex: 1,), 
                  ListTile(title: Text('test'),),
                ]          
              ),
            ),

            const Spacer(flex: 1,),

            Container(
              decoration: const BoxDecoration(
                border: Border(
                   top: BorderSide(
                     color: Color.fromARGB(255, 199, 199, 199), 
                     width: 1.0),
                ),                  
              ),
              padding: const EdgeInsets.all(8),
              child: 
                const Row(
                  children: [                
                    Text('サブスクリプション'),                                           
                ]
              )
            ),

            Container(
              decoration: const BoxDecoration(
                border: Border(
                   top: BorderSide(
                     color: Color.fromARGB(255, 199, 199, 199), 
                     width: 1.0),
                ),                  
              ),
              padding: const EdgeInsets.all(8),
              child: 
                const Row(
                  children: [                
                    Text('ログインID表示 環境設定関連'),                                           
                ]
              )
            )
          ],          
        ),
      ),

      endDrawer: Drawer(
        child: Column(children: <Widget>[
        Container(),
        Container(),
        ],),

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
                                  Navigator.pushAndRemoveUntil (context,                              
                                    MaterialPageRoute(
                                      builder: (context) => MatchingProgressPage(matchingProgress!)),   
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
                      IconButton (onPressed: (){  
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