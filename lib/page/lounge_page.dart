import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:udemy_copy/firestore/user_firestore.dart';
import 'package:udemy_copy/model/matching_progress.dart';
import 'package:udemy_copy/page/matching_progress_page.dart';

class LoungePage extends StatefulWidget {
  const LoungePage({super.key});

  @override
  State<LoungePage> createState() => _LoungePageState();
}



class _LoungePageState extends State<LoungePage> {

final TextEditingController controller = TextEditingController();
// TextEditingConttrolloerはTextFieldで使うテキスト入力を管理するクラス
bool isInputEmpty = true;
String? myUid;
bool? isDisabled;
MatchingProgress? matchingProgress;
var _overlayController1st = OverlayPortalController();
var _overlayController2nd = OverlayPortalController();
Future<String?>? myUidFuture; 

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
     myUidFuture = UserFirestore.getAccount();        //EndDrawerのstreamがmyUidのgetに先走って実行してエラーになるのを防ぐ処理
     myUidFuture!.then((uid) {                    // .then(引数){コールバック関数}で、親クラス(=initState)の非同期処理が完了したときに実行するサブの関数を定義
      if (uid != null) {
         matchingProgress = MatchingProgress(myUid: uid);              
      }
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

        child: 
          Column(children: <Widget>[
            Container(
              decoration: const BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                     color: Color.fromARGB(255, 199, 199, 199), 
                     width: 1.0,
                  )
                )
              ),
              height: 50,
              width: 200,
              child: 
                Center(child: 
                  Text(
                    'マッチングの履歴',
                    style: TextStyle(fontSize: 24),

                )
              )
            ),
            // const Divider(
            //   height: 10,
            //   thickness: 1,
            //   color: Colors.grey,
            //   indent: 10,
            //   endIndent: 10,
            // ),

            FutureBuilder(
              future: myUidFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                    return const CircularProgressIndicator();     
                } else if (snapshot.hasError) {
                    return Text('エラーが発生しました');
                } else {            
                    return StreamBuilder<QuerySnapshot>(                      
                      stream: UserFirestore.streamHistoryCollection(snapshot.data),
                      //snapshot.data == 非同期操作における「現在の型の状態 + 変数の値」が格納されてる
                      builder: (context, snapshot) {
                        if (snapshot.hasData && snapshot.data!.docs.isNotEmpty) {
                          return Expanded(
                            child: 
                              Padding(
                                padding: const EdgeInsets.all(10.0),
                                child: 
                                  ListView.builder(
                                    itemCount: snapshot.data!.docs.length,                              
                                    itemBuilder: (context, index) {
                                      DocumentSnapshot talkuserProf = snapshot.data!.docs[index];
                                      DateTime createdAt = (talkuserProf['created_at'] as Timestamp).toDate();
                                      // グループ処理：ザルに通すデータを取得
                                      
                                      DateTime now = DateTime.now();
                                      DateTime today = DateTime(now.year, now.month, now.day); // 夜中の00:00
                                      DateTime yesterday = today.subtract(Duration(days: 1));
                                      DateTime oneWeek = today.subtract(Duration(days: 7));
                                      // DateTime twoWeek = today.subtract(Duration(days: 14));
                                      // グループ処理：ザルの編み目を作成
                                      
                                      // グループ処理：index当該リストをザルに通す                                      
                                      String dateLabel = '';
                                      print('createdAt: $createdAt');                                      

                                        if (createdAt.isBefore(oneWeek)) {
                                              dateLabel = '1週間以上前';
                                 } else if (createdAt.isAfter(oneWeek)
                                         && createdAt.isBefore(yesterday)) {
                                              dateLabel = 'この１週間';
                                 } else if (createdAt.isAfter(today)
                                        ||  createdAt.isAtSameMomentAs(today)) {
                                              dateLabel = '今日';
                                 } else if (createdAt.isAfter(yesterday)
                                        ||  createdAt.isAtSameMomentAs(yesterday)) {
                                              dateLabel = '昨日';
                                 }

                                      String prevDateLabel = '';
                                      // グループ処理：index当該リストの1つ前（配置が上）のリストをザルに通す                          
                                      if (index > 0) {
                                        DateTime prevCreatedAt = (snapshot.data!
                                                                          .docs[index - 1]['created_at']
                                                                           as Timestamp)
                                                                          .toDate();
                                        print('prevCreatedAt: $prevCreatedAt');

                                        if (prevCreatedAt.isBefore(oneWeek)) {
                                              prevDateLabel = '1週間以上前';
                                 } else if (prevCreatedAt.isAfter(oneWeek)
                                         && prevCreatedAt.isBefore(yesterday)) {
                                              prevDateLabel = 'この１週間';
                                 } else if (prevCreatedAt.isAfter(today)
                                        ||  prevCreatedAt.isAtSameMomentAs(today)) {
                                              prevDateLabel = '今日';
                                 } else if (prevCreatedAt.isAfter(yesterday)
                                        ||  prevCreatedAt.isAtSameMomentAs(yesterday)) {
                                              prevDateLabel = '昨日';
                                 }
                                      }

                                     
                                      if (index == 0 || dateLabel != prevDateLabel) {
                                      // 1番上のリスト or 直上に配置されたリストとdateLabelが異なる場合だけTrue 
                                        return Column(children: <Widget>[
                                          Text(
                                            '---$dateLabel---',
                                            style: const TextStyle(fontSize: 17),
                                          ),
                                          ListTile(
                                            // leading: Image.network(talkuserProf['user_image_url']),
                                            title: Text(talkuserProf['user_name']),                                  
                                          )
                                        ]);

                                      } else {
                                        return ListTile(
                                          // leading: Image.network(talkuserProf['user_image_url']),
                                          title: Text(talkuserProf['user_name']),                                  
                                        );
                                      }
                                  }),
                              ),
                            );
                        }    
                          return const Text('まだマッチングの履歴がないようです');
                  });
                }
              } 
            )
         ])
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