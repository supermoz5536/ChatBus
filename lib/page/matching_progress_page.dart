import 'dart:async';
import 'package:flutter/material.dart';
import 'package:udemy_copy/cloud_functions/functions.dart';
import 'package:udemy_copy/firestore/room_firestore.dart';
import 'package:udemy_copy/firestore/user_firestore.dart';
import 'package:udemy_copy/model/talk_room.dart';
import 'package:udemy_copy/page/talk_room_page.dart';


// initstate()の実行に時間が掛かって、Widget build()の本体の実行が先走ってる。

// if(DB上にマッチング相手が：いる場合)
// ① iniState()のtalkUserUidの取得通信が完了する前に、talkUserUid ==null として 本体のWidget builder()が走る
// ② iniState()のtalkUserUidの取得通信が完了して、iniState()内でcreateRoom()まで完了する
// ③ iniState()のtalkUserUidの取得が完了したので、body部分の if(talkUserUid == null) に該当せず、list[0][1]は描画されない

// if(DB上にマッチング相手が：いない場合)
// ① talkUserUid ==nullで 本体のWidget builder()が走る
// ②if(snapshot.hasData)がtrueになるまで、list[0][1]が描画される



class MatchingProgressPage extends StatefulWidget {                            
const MatchingProgressPage({super.key});  // this.talkRoomでtalkRoomのオブジェクト（入れ物）を用意してる。
// 10,11行で、TalkRoomPageクラスのインスタンス変数に、ルームの基本情報型を備えた変数talkRoomが設定された
// 画面に「起動/更新/遷移」があった際に、TalkRoomPageクラスが各々個別の情報によってインスタンス化する。

  @override
  State<MatchingProgressPage> createState() => _MatchingProgressPageState();    //「stateクラス」として「_WaitRoomPageState()」を定義 
                                                                //「stateクラス」＝StatefulWifetを継承したWidfetの状態を管理するクラス
}

class _MatchingProgressPageState extends State<MatchingProgressPage> {          //「stateクラス」を継承した新たな「 _WaitRoomPageState」クラスを宣言（機能追加）
  String? myUid;
  String? talkuserUid;
  String? myRoomId;
  StreamSubscription? unmatchedUserSubscription;
  StreamSubscription? myDocSubscription;


    @override                  // 追加機能の記述部分であることの明示
    void initState() {         // 関数の呼び出し（initStateはFlutter標準メソッド）
      super.initState();       // 親クラスの初期化処理　
                               //「親クラス＝Stateクラス＝_WaitRoomPageState」のinitStateメソッドの呼び出し
      // initState()は、Widget作成時にflutterから自動的に一度だけ呼び出されます。
      // このメソッド内で、widgetが必要とする初期設定やデータの初期化を行うことが一般的
      // initState()とは　https://sl.bing.net/ivIFfFUd6Vo      


      

    // 起動時に1度行うmyUidを確認する処理
     UserFirestore.getAccount()                         // 自分のユーザー情報をDBへ書き込み
                  .then((String? uid) async{            // .then(引数){コールバック関数}で、親クラス(=initState)の非同期処理が完了したときに実行するサブの関数を定義
                     setState(() {myUid = uid;});       // 状態変数myUidに、非同期処理の結果（uid）を設定           
                     print('wait_room_page.dartの初期取得myUid = $myUid');

     String? myRoomId = await RoomFirestore.createRoom(myUid!, talkuserUid);
     TalkRoom talkRoom = TalkRoom(roomId: myRoomId);
     //■■■Footerのキャンセルボタンを押したら、RoomFirestore.deleteRoom(myRoomId); する必要がある。
     //■■■予期しない形で離脱して取り残されたroomの、サーバーサイドお掃除処理が必要
                                                 
      
     UserFirestore.retry(myUid, () async{    // retry start 
             await UserFirestore.getUnmatchedUser(myUid)                      
                                .then((String? uid) async{
                                 setState(() {talkuserUid = uid;});
                                              
                  // 「自分がマッチングする場合」の処理  
                if(talkuserUid != null) {                                                                                

                    bool myProgressMarker = await UserFirestore.checkMyProgressMarker(myUid);                  
                    print('myUidのマッチング処理状況の確認');  

                     if(myProgressMarker == true){                                                  // myUidのマッチング処理状況の確認：「される場合」の処理との競合を避けるため
                          print('「される場合」のマッチング処理を確認： retry end');
                          throw Exception('End Retry');  // retry()への例外

                      }else{
                        await UserFirestore.updateMyProgressMarker(myUid, true);                    // falseの場合は「される場合」は実行されてないので、trueにして競合防止してからtransactionを開始
                          print('「する場合」の処理開始直前に progress_marker を trueに変更');

                        await CloudFunctions.runTransactionDB(myUid, talkuserUid, myRoomId)         // transaction start          

                            .then((_){                                                              // transaction 成功の分岐
                                if(talkuserUid != null) {                                           // transaction処理内でtalkuserUidに変更がないかの確認
                                   print('トランザクション成功: myRoomのField情報の更新、画面遷移');
                                      RoomFirestore.updateRoom(myRoomId, talkuserUid);      
                                      Navigator.push(                                               //　画面遷移の定型   何やってるかの説明：https://sl.bing.net/b4piEYGC70C
                                      context,                                                      //　1回目のcontextは、「Navigator.pushメソッドが呼び出された時点」のビルドコンテキストを参照し
                                          MaterialPageRoute(                                        //　新しい画面への遷移を定義(アニメーションとか遷移先の画面の設定)
                                          builder: (context) => TalkRoomPage(talkRoom)              //　遷移先の画面を構築する関数を指定                                                                              
                                          ));
                                        print('「する場合」の画面遷移 完了');                                            
                                              myDocSubscription!.cancel();
                                      } 

                          }).catchError((error) {
                          // transactionのエラーハンドリング
                              print('トランザクション失敗: talkuserUidをnullにしてretry: $error');
                              UserFirestore.updateMyProgressMarker(myUid, false);  
                              print('「する場合」の処理が失敗したので progress_marker を falseに戻す');                              
                              talkuserUid = null;        
                              throw Exception(); 
                          });                                                                       
        
        } //　if(myProgressMaker == false)
      }  //　if(talkuserUid != null)  
    }); //　getUnmatchedUser           
              if (talkuserUid == null) {                                                //　talkuserUid == null で エラーの起こりうるif(){}部分をスルーしてしまった場合に、エラーを手動で返してretryさせる
                  print('マッチング可能な相手が0人、retry関数再実行の待機中)');
                  throw Exception();} 
  }); // retry end




                  // 「自分がマッチングされた場合」のstream処理  
                if (talkuserUid == null) {
                    var myDocStream = UserFirestore.streamMyDoc(myUid);  
                    print ('streamの起動');                        
                    
                    myDocSubscription = myDocStream.listen((snapshot) {              
                        if (snapshot.data()!.isNotEmpty){                                       //TESTドキュメントはFiledが空なので、避けるために必要

                            if (snapshot.data()!['progress_marker'] == true){                //myUidのマッチング処理状況の確認：「する場合」の処理との競合を避けるため                               
                                print('「する場合」のマッチング処理を確認： 受信したstreamへの「された場合」の処理を終了');                          

                     } else if (snapshot.data()!['progress_marker'] == false &&
                                snapshot.data()!['matched_status']  == true) { 
                                        
                                print('「された場合」の処理開始');                            
                                UserFirestore.updateProgressMarker(myUid, true);                   //「される場合」の処理開始。「する場合」の競合防止マーカー更新
                                Map<String, dynamic>? doc = snapshot.data();
                                TalkRoom talkRoom = TalkRoom(roomId: doc?['room_id']);            //TalkRoomPageクラスのコンストラクタに引き渡すため、TalkRoom型の変数talkRoomを用意

                                RoomFirestore.deleteRoom(myRoomId);

                                if (context.mounted) {                                                       
                                    Navigator.push(                                               //画面遷移の定型   何やってるかの説明：https://sl.bing.net/b4piEYGC70C
                                    context,                                                      //1回目のcontextは、「Navigator.pushメソッドが呼び出された時点」のビルドコンテキストを参照し
                                        MaterialPageRoute(                                        //新しい画面への遷移を定義(アニメーションとか遷移先の画面の設定)
                                        builder: (context) => TalkRoomPage(talkRoom)              //遷移先の画面を構築する関数を指定                                                                                                              
                                        )
                                        );
                                        print('「された場合」の画面遷移 完了');  
                                        myDocSubscription!.cancel();}                         
                                }  
                            }
                    }); // myDocSubscription =
                } // 「自分がマッチングされた場合」のstream処理 
             }); // getAccount             
          }// initState





  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.lightBlueAccent,
      appBar: AppBar(
        title: const Text('Waiting Room'),
        ),  

      body: Stack(                                           // Stackは、childrenに積み重ねて表示させたいウィジェットを下層から順に追加する  //https://coderenkin.com/flutter-stack/
        children: [                                          // Stackウィジェットのchildren
        
        if(talkuserUid == null)                              // Streambuilderは、データが更新されると、新しいスナップショットを取得し、builder関数を再度呼び出してUIを更新する
                                        
          Padding(padding: const EdgeInsets.only(bottom: 60.0),             
            child: ListView.builder(                         // ListViewは、スクロール可能なリストを表示するためのウィジェット
                physics: RangeMaintainingScrollPhysics(),    // phyisicsがスクロールを制御するプロパティ。画面を超えて要素が表示され始めたらスクロールが可能になるような設定のやり方
                shrinkWrap: true,                            // 表示してるchildrenに含まれるwidgetのサイズにlistviewを設定するやり方
                reverse: false,                              // スクロールがした始まりで上に滑っていく設定になる
                itemCount: 2,
                itemBuilder: (conxtext, index){              
                // ListView.builderの基本設定パラメーター
                // ListViewの定型パターン




                        if(index == 0){                          
                          return Padding(
                            padding: const EdgeInsets.all(20),
                            child: Container(                    // [0]の吹き出し部分を、コンテナで表示
                              constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.6),    //この書き方で今表示可能な画面幅を取得できる
                              decoration: BoxDecoration(
                              color: Colors.green,
                              borderRadius: BorderRadius.circular(15)),
                              padding: EdgeInsets.symmetric(horizontal: 18, vertical: 6),
                              
                              child: const ListTile(title:       // コンテナのchild部分に、[0]のメッセージを表示
                                         Text( style: TextStyle(
                                               fontSize: 17, 
                                               color: Colors.white,  ),
                                                  'どもー。ChatBusシステムです(・Д・)ﾉ\n'
                                                  '最初に[利用規約]のお話をさせてね！\n'
                                                  '・相手を不快にさせるような発言はしないでね\n'
                                                  '・出会いを目的にした利用はしないでね\n'
                                                  '・個人情報を相手に教えないでね\n'
                                                  '楽しい時間をすごための約束だよ(・Д・)b\n'),
                              )),
                          );
                        }



                                          
                        if(index == 1){
                          return Padding(
                            padding: const EdgeInsets.all(20),
                            child: Container(                    // [0]の吹き出し部分を、コンテナで表示
                              constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.6),    //この書き方で今表示可能な画面幅を取得できる
                              decoration: BoxDecoration(
                              color: Colors.green,
                              borderRadius: BorderRadius.circular(15)),
                              padding: EdgeInsets.symmetric(horizontal: 18, vertical: 6),
                              
                              child: const ListTile(title:              // コンテナのchild部分に、[1]のメッセージを表示
                                         Text('チャット相手を検索中だよ〜！'),
                              )),                                        
                          );
                        }


                          return null;


                   }),
                 ), 



          





          Column(            // 仮面下部の文字入力部分をColumnで構成
            mainAxisAlignment: MainAxisAlignment.end, // https://zenn.dev/wm3/articles/7332788c626b39
            children: [
              Container(
                  color: Colors.white,
                  height: 68,
                child: Row(children: [
                  //  Expanded(child: Padding(
                  //   padding: const EdgeInsets.all(8.0),
                  //   child: TextField( 
                  //     controller: controller,               //columとrowは子要素の範囲を指定しないから, expandedで自動で範囲をしてしてやると、textfiledが範囲を理解できて表示される
                  //     decoration: const InputDecoration(
                  //     contentPadding: EdgeInsets.only(left: 10),
                  //     border: OutlineInputBorder(),
                  //   ),
                  //   ),
                  // )), 
                  IconButton (onPressed: () async {
                    // await RoomFirestore.sendMessage(
                    //   roomId: widget.talkRoom.roomId, 
                    //   message: controller.text
                    //   );
                    //   controller.clear();
                  }, icon: Icon(Icons.send))
                ],
                ),
                ),
              // Container(  //下部入力フィールドのsafeare部分の余白埋める役割
              //   color: Colors.white,
              //   height: MediaQuery.of(context).padding.bottom,   //スマホ画面の入力fieldの下部の部分を覆う
              // )
            ],
          )
        ],                         
      ),
    );
  }  
}





   
            