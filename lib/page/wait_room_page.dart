import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:udemy_copy/firestore/room_firestore.dart';
import 'package:udemy_copy/firestore/user_firestore.dart';
import 'package:udemy_copy/model/talk_room.dart';
import 'package:udemy_copy/page/talk_room_page.dart';


//initstate()の実行に時間が掛かって、Widget build()の本体の実行が先走ってる。

//if(DB上にマッチング相手が：いる場合)
//① iniState()のtalkUserUidの取得通信が完了する前に、talkUserUid ==null として 本体のWidget builder()が走る
//② iniState()のtalkUserUidの取得通信が完了して、iniState()内でcreateRoom()まで完了する
//③ iniState()のtalkUserUidの取得が完了したので、body部分の if(talkUserUid == null) に該当せず、list[0][1]は描画されない

//if(DB上にマッチング相手が：いない場合)
//① talkUserUid ==nullで 本体のWidget builder()が走る
//②if(snapshot.hasData)がtrueになるまで、list[0][1]が描画される



class WaitRoomPage extends StatefulWidget {                            
  const WaitRoomPage({super.key});  //this.talkRoomでtalkRoomのオブジェクト（入れ物）を用意してる。
//10,11行で、TalkRoomPageクラスのインスタンス変数に、ルームの基本情報型を備えた変数talkRoomが設定された
//画面に「起動/更新/遷移」があった際に、TalkRoomPageクラスが各々個別の情報によってインスタンス化する。

  @override
  State<WaitRoomPage> createState() => _WaitRoomPageState();    //「stateクラス」として「_WaitRoomPageState()」を定義 
                                                                //「stateクラス」＝StatefulWifetを継承したWidfetの状態を管理するクラス
}

class _WaitRoomPageState extends State<WaitRoomPage> {          //「stateクラス」を継承した新たな「 _WaitRoomPageState」クラスを宣言（機能追加）
  String? myUid;
  String? talkuserUid;
  StreamSubscription? unmatchedUserSubscription;
  StreamSubscription? myDocSubscription;
  

  


    //initState()は、Widget作成時にflutterから自動的に一度だけ呼び出されます。
    //このメソッド内で、widgetが必要とする初期設定やデータの初期化を行うことが一般的
    //initState()とは　https://sl.bing.net/ivIFfFUd6Vo
    @override                                         //追加機能の記述部分であることの明示
    void initState() {                                //関数の呼び出し（initStateはFlutter標準メソッド）
      super.initState();                              //親クラスの初期化処理　  //「親クラス＝Stateクラス＝_WaitRoomPageState」のinitStateメソッドの呼び出し
      


      

    //■起動時に1度行うmyUidを確認する処理
      UserFirestore.getAccount()                    //自分のユーザー情報をDBへ書き込み
                   .then((String? uid) {            //.then(引数){コールバック関数}で、親クラス(=initState)の非同期処理が完了したときに実行するサブの関数を定義
                    setState(() {myUid = uid;});    //状態変数myUidに、非同期処理の結果（uid）を設定           
                      print('wait_room_page.dartの初期取得myUid = $myUid');
 
      
     UserFirestore.retry(myUid, (){                                                 //retry start 
            FirebaseFirestore.instance.runTransaction((transaction) async {  //transaction start
       try{      
            await UserFirestore.getUserField(myUid);                         //read check (myUid)                   
            await UserFirestore.getUnmatchedUser(myUid)                      //read check (talkuser 4人)                  
                         .then((String? uid){
                          setState(() {talkuserUid = uid;});



                  //■「自分がマッチングする場合」の処理  
                  if((talkuserUid != null)){
                    print('「自分がマッチングする場合」の処理実行(トランザクション内)');  
                    print('wait_room_page.dartの初期取得talkUserUid = $talkuserUid');
                    UserFirestore.getUserField(talkuserUid);              //read check 

                    Future<String?> roomIdFuture = RoomFirestore.createRoom(myUid!, talkuserUid);        //ここまでで、DB上からリアルタイムに「matched_status == false」の相手を検索して、トークルームを作ることができた
                                    roomIdFuture.then((roomId){                   //roomIdの取得通信を確認(.then)してから
                    UserFirestore.updateDocField(myUid!, roomId, true);           //自分のroom_idの更新
                    UserFirestore.updateDocField(talkuserUid!, roomId, true);     //相手のroom_idの更新
                    TalkRoom talkRoom = TalkRoom(roomId: roomId);                 //TalkRoomPageクラスのコンストラクタに引き渡すため、TalkRoom型の変数talkRoomを用意
                    return talkRoom;

                  }).then((talkRoom){                                             //画面遷移は .thenの応答関数で記述してるので、transactionの範囲に含まれてない
                    print('「自分がマッチングする場合」の「トークルームの作成」実行');      
                    Navigator.push(                                               //画面遷移の定型   何やってるかの説明：https://sl.bing.net/b4piEYGC70C
                    context,                                                      //1回目のcontextは、「Navigator.pushメソッドが呼び出された時点」のビルドコンテキストを参照し
                        MaterialPageRoute(                                        //新しい画面への遷移を定義(アニメーションとか遷移先の画面の設定)
                        builder: (context) => TalkRoomPage(talkRoom)              //遷移先の画面を構築する関数を指定                                                                              
                        ),
                        );
                        myDocSubscription!.cancel();
                        }); //.then                
                  }         //if((talkuserUid != null))
                  });       //UserFirestore.getUnmatchedUser                                                  
                  } catch (e) {                                      //talkuserUidが取得できた上で、transaction実行が失敗した場合                    
                    talkuserUid == null;                                          //transaction失敗 → talkuserUid == null で リスナーOn
                    print('トランザクション内の「自分がマッチングする場合」の処理失敗 retry実行');                           
                    throw e; 
                  }         //try-catch
                  });       //transaction end
                  if(talkuserUid == null) {                         //talkuserUid == null で エラーの起こりうるif(){}部分をスルーしてしまった場合に、エラーを手動で返してretryさせる
                    throw Exception('talkuserUid == nullなので、transactionのretry実行');
                  }  
                  });       //retry end




                  //■「自分がマッチングされた場合」のstream処理  
                  if(talkuserUid == null) {
                        print('wait_room_page.dartの初期取得talkUserUid = null');             //ここまでは読み込めてる            
                        var myDocStream = UserFirestore.streamMyDoc(myUid);  
                     
                      myDocSubscription = 
                      myDocStream.listen((snapshot) {              
                     
                          if (snapshot.data()!.isNotEmpty                                       //TESTドキュメントはFiledが空なので、避けるために必要
                           && snapshot.data()!['matched_status'] == true) {  

                            print('「自分がマッチングされた場合」のstream処理開始');
                              Map<String, dynamic>? doc = snapshot.data();
                              TalkRoom talkRoom = TalkRoom(roomId: doc?['room_id']);            //TalkRoomPageクラスのコンストラクタに引き渡すため、TalkRoom型の変数talkRoomを用意

                              if (context.mounted) {                                                       
                                  Navigator.push(                                               //画面遷移の定型   何やってるかの説明：https://sl.bing.net/b4piEYGC70C
                                  context,                                                      //1回目のcontextは、「Navigator.pushメソッドが呼び出された時点」のビルドコンテキストを参照し
                                      MaterialPageRoute(                                        //新しい画面への遷移を定義(アニメーションとか遷移先の画面の設定)
                                      builder: (context) => TalkRoomPage(talkRoom)              //遷移先の画面を構築する関数を指定                                                                                                              
                      ),
                    );
                    myDocSubscription!.cancel();
                    }                         
                    }        
                    }); //myDocSubscription =
                  } //■「自分がマッチングされた場合」のstream処理 
             }); //getAccount             
          }// initState





  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.lightBlueAccent,
      appBar: AppBar(
        title: const Text('Waiting Room'),
        ),  

      body: Stack(                                           //Stackは、childrenに積み重ねて表示させたいウィジェットを下層から順に追加する  //https://coderenkin.com/flutter-stack/
        children: [                                          //Stackウィジェットのchildren
        
        if(talkuserUid == null)                              //Streambuilderは、データが更新されると、新しいスナップショットを取得し、builder関数を再度呼び出してUIを更新する
                                        
          Padding(padding: const EdgeInsets.only(bottom: 60.0),             
            child: ListView.builder(                         //ListViewは、スクロール可能なリストを表示するためのウィジェット
                physics: RangeMaintainingScrollPhysics(),    //phyisicsがスクロールを制御するプロパティ。画面を超えて要素が表示され始めたらスクロールが可能になるような設定のやり方
                shrinkWrap: true,                            //表示してるchildrenに含まれるwidgetのサイズにlistviewを設定するやり方
                reverse: false,                              //スクロールがした始まりで上に滑っていく設定になる
                itemCount: 2,
                itemBuilder: (conxtext, index){              
                //ListView.builderの基本設定パラメーター
                //ListViewの定型パターン




                        if(index == 0){                          
                          return Padding(
                            padding: const EdgeInsets.all(20),
                            child: Container(                    //[0]の吹き出し部分を、コンテナで表示
                              constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.6),    //この書き方で今表示可能な画面幅を取得できる
                              decoration: BoxDecoration(
                              color: Colors.green,
                              borderRadius: BorderRadius.circular(15)),
                              padding: EdgeInsets.symmetric(horizontal: 18, vertical: 6),
                              
                              child: const ListTile(title:       //コンテナのchild部分に、[0]のメッセージを表示
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
                            child: Container(                    //[0]の吹き出し部分を、コンテナで表示
                              constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.6),    //この書き方で今表示可能な画面幅を取得できる
                              decoration: BoxDecoration(
                              color: Colors.green,
                              borderRadius: BorderRadius.circular(15)),
                              padding: EdgeInsets.symmetric(horizontal: 18, vertical: 6),
                              
                              child: const ListTile(title:              //コンテナのchild部分に、[1]のメッセージを表示
                                         Text('チャット相手を検索中だよ〜！'),
                              )),                                        
                          );
                        }


                          return null;


                   }),
                 ), 



          





          Column(            //仮面下部の文字入力部分をColumnで構成
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





   
            