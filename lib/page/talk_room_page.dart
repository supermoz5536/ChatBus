import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart' as intl;
import 'package:udemy_copy/firestore/room_firestore.dart';
import 'package:udemy_copy/firestore/user_firestore.dart';
import 'package:udemy_copy/model/massage.dart';
import 'package:udemy_copy/model/matching_progress.dart';
import 'package:udemy_copy/model/talk_room.dart';
import 'package:udemy_copy/page/lounge_page.dart';
import 'package:udemy_copy/page/matching_progress_page.dart';
import 'package:udemy_copy/utils/screen_transition.dart';
import 'package:udemy_copy/utils/shared_prefs.dart';
// import 'package:udemy_copy/utils/screen_transition.dart';


class TalkRoomPage extends StatefulWidget {      
  final TalkRoom talkRoom;                         
  const TalkRoomPage(this.talkRoom, {super.key});  //this.talkRoomでtalkRoomのオブジェクト（入れ物）を用意してる。
//10,11行で、TalkRoomPageクラスのインスタンス変数に、ルームの基本情報型を備えた変数talkRoomが設定された
//画面に「起動/更新/遷移」があった際に、TalkRoomPageクラスが各々個別の情報によってインスタンス化する。

  @override
  State<TalkRoomPage> createState() => _TalkRoomPageState();
}

class _TalkRoomPageState extends State<TalkRoomPage> {
  bool isInputEmpty = true;
  bool? isDisabled;
  bool? isChatting;
  StreamSubscription? talkuserDocSubscription;
  MatchingProgress? matchingProgress;
  final TextEditingController controller = TextEditingController();


  @override               // 追加機能の記述部分であることの明示
    void initState() {    // 関数の呼び出し（initStateはFlutter標準メソッド）
      super.initState();  // .superは現在の子クラスの親クラスを示す → 親クラスの初期化
      // 追加機能の記述部分であることの明示
      // 関数の呼び出し（initStateはFlutter標準メソッド）
      // .superは現在の子クラスの親クラスを示す → 親クラスの初期化
        isDisabled = false;
        isChatting = true;
 
 
        UserFirestore.updateChattingStatus(widget.talkRoom.myUid, true)
                     .then((_) async{

                            await Future.delayed(
                            const Duration(milliseconds: 400), //リスナー開始までの時間
                            );

          var talkuserDocStream = UserFirestore.streamTalkuserDoc(widget.talkRoom.talkuserUid);
                            print ('トークルーム: streamの起動(リスンの参照を取得)');
                            // print ('コンストラクタのtalkRoomのmyUid == ${widget.talkRoom.myUid}');                            
                              
                              talkuserDocSubscription = talkuserDocStream.listen((snapshot) {
                              print ('トークルーム: streamデータをリスン');     
                              print('トークルーム: chatting_status: ${snapshot.data()!['chatting_status']}');

                                  if (snapshot.data()!.isNotEmpty && 
                                     (snapshot.data()!['chatting_status'] == false || snapshot.data()!['is_lounge']== true)) { 
                                    // ■■■■■■islounge を実装したら、上記のコメントアウトを実装する

                                        print ('トークルーム: [chatting_status == false] OR [is_lounge == true]');
                                        print ('トークルーム: isDisabled == false にしてフッター再描画');                                                                              
                                        setState(() {
                                          isChatting =false;
                                          // 状態を更新：フッターUIを再描画                                
                                        });                               
                                  }
                              });
                      });                            



    } // initState
 

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.lightBlueAccent,
      appBar: AppBar(
        title: const Text('トークルーム'),  //statefulWigetで定義した変数talkRoomは、Widget. の形にしないとStateクラスで使うことができない。
        ),  

      body: Stack(                            //Stackは、childrenに積み重ねて表示させたいウィジェットを下層から順に追加する  //https://coderenkin.com/flutter-stack/
        children: [                           //Stackウィジェットのchildren
          StreamBuilder<QuerySnapshot>(       //？？？？？<QuerySnapshot>の意味は？
            stream: RoomFirestore.fetchMessageSnapshot(widget.talkRoom.roomId!),  //widgetは、statefulwidgetクラスのプロパティにアクセスするために必要なキーワード
            builder: (context, snapshot) {
              if (snapshot.hasData) {              
                return Padding(
                    padding: const EdgeInsets.only(bottom: 60.0),
                    child: ListView.builder(
                        physics: RangeMaintainingScrollPhysics(),  //phyisicsがスクロールを制御するプロパティ。画面を超えて要素が表示され始めたらスクロールが可能になるような設定のやり方
                        shrinkWrap: true,                          //表示してるchildrenに含まれるwidgetのサイズにlistviewを設定するやり方
                        reverse: true,                             //スクロールがした始まりで上に滑っていく設定になる
                        itemCount: snapshot.data!.docs.length,
                        itemBuilder: (conxtext, index){    //ListViewの定型パターン
                      
                          final doc = snapshot.data!.docs[index];  //これでメッセージ情報が含まれてる、任意の部屋のdocデータ（ドキュメント情報）を取得してる                                                       
                          final Map<String, dynamic> data = doc.data() as Map<String, dynamic>;  //これでオブジェクト型をMap<String dynamic>型に変換                                                                                                               
                          final Message message = Message(     //Message()でMessageクラスのコンストラクタを呼び出し、変数のmessageにそのインスタンスを代入してる
                              message: data['message'], 
                              isMe: Shared_Prefes.fetchUid() == data['sender_id'], //自分のIDとsnapshotから取得したメッセージのIDが一致してたら、それは自分のメッセージでTRUE
                              sendTime: data['send_time']
                              //各々の吹き出しの情報となるので、召喚獣を実際に呼び出して、個別化した方がいい。
                              //data()でメソッドを呼ぶと、ドキュメントデータがdynamic型(オブジェクト型)で返されるため、キーを設定してMap型で処理するには明示的にMap<Stgring, dynamic>と宣言する必要がある                                            
                              );

                     return Padding( //メッセージ吹き出し部分
                        padding: const EdgeInsets.only(top: 20, left: 11, right: 11, bottom: 20),
                        child: Row(                        //bodyのx軸を担当してると考える
                            crossAxisAlignment: CrossAxisAlignment.end,
                            textDirection: message.isMe ? TextDirection.rtl : TextDirection.ltr,
                              children: [
                          Container(
                            constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.6),    //この書き方で今表示可能な画面幅を取得できる
                            decoration: BoxDecoration(
                              color: message.isMe ? Colors.green : Colors.white,
                              borderRadius: BorderRadius.circular(15)),
                            padding: EdgeInsets.symmetric(horizontal: 18, vertical: 6),
                                child: Text(message.message)),   //index番目のメッセージをreturn
                                       Text(intl.DateFormat('HH:mm').format(message.sendTime.toDate())),
                                        //①DateFormatは、DateTime型のオブジェクトをString型に変えるメソッド。
                                        //②DateFormatを機能させるために、sendTimeでDBから取得するオブジェクトはtimestamp型に設定されてるので、toDate()で型を一致させる
                  ],  
                 ),
                );
               }),
              );
                 } else {
                  return Center(child: Text('メッセージがありません'),);
              }
            }
          ),


          // ■フッター部分(chatting)
          Column( // column()の縦移動で、画面1番下に配置
                mainAxisAlignment: MainAxisAlignment.end, // https://zenn.dev/wm3/articles/7332788c626b39
                children: [
                  Container(
                      color: Colors.white,
                      height: 68, // フッター領域の縦幅                  
                      child: isChatting! ? buildChattingFooter(context) : buildEndedFooter(context), // 条件付きレンダリング

                     ),
                   ],
                 ),
               ],
             ),
           );
         }



        // ■ フッター（チャット中）
        Row buildChattingFooter(BuildContext context) {
          return Row(children: [
                      
                        // ■「チャットを終了」ボタン
                        Container(child:
                          ElevatedButton( 
                              onPressed: () async{ 
                              setState(() {
                                isChatting =false;
                                // 状態を更新：フッターUIを再描画                                
                              });                                                  
                              await UserFirestore.updateChattingStatus(widget.talkRoom.myUid, false);
                              // トーク相手にチャット終了を伝える                                                                                                                                         
                              },
                              child: const Text("チャットを終了"),
                          )
                        ),


                        // ■ 入力フィールド
                        Expanded(child: Padding( // TextFieldウィジェットをExpandedウィジェットで横に伸長させている
                          padding: const EdgeInsets.all(8.0), // 入力フィールドの枠の大きさ

                          child: TextField(               
                                      controller: controller,          // columとrowは子要素の範囲を指定しないから, expandedで自動で範囲をしてしてやると、textfiledが範囲を理解できて表示される
                                      onChanged: (value){              // TextFiledのテキストが変更されるたびに呼び出される応答関数を指定
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

                        // ■ 送信アイコン
                        IconButton (onPressed: () async{                                                              
                          await RoomFirestore.sendMessage(
                                roomId: widget.talkRoom.roomId!, 
                                message: controller.text);
                                controller.clear();
                                setState(() {
                                  isInputEmpty = true;
                                });
                                },  
                                icon: Icon(Icons.send,
                                color: isInputEmpty? Colors.grey : Colors.blue,
                              ))
                            ],
                        );
                      }  
              

        
        // ■ フッター（チャット終了後）
        Row buildEndedFooter(BuildContext context) {
          return Row(children: [

                        // ■ 「次の相手を探す」ボタン
                        Container(child:
                          ElevatedButton( 
                              onPressed: isDisabled! ? null : () async{ 
                              setState(() {
                                isDisabled = true;
                                // 二重タップ防止  
                                // isProcessingの使い方は、progressMarkerと同じ                             
                                // trueにして、タップをブロック
                              });

                                await Future.delayed(
                                const Duration(milliseconds: 50), //無効にする時間
                                );
                              
                                await talkuserDocSubscription!.cancel(); 
                                // matching_progress_pageに戻る時の一連の処理                                                                                                                            

                              if (context.mounted) { 
                                matchingProgress = MatchingProgress(myUid: myUid);   
                                  Navigator.pushAndRemoveUntil(context,                              //画面遷移の定型   何やってるかの説明：https://sl.bing.net/b4piEYGC70C                                                                        //1回目のcontextは、「Navigator.pushメソッドが呼び出された時点」のビルドコンテキストを参照し
                                    SlideRightRoute(page: MatchingProgressPage(matchingProgress!)),    //遷移先の画面を構築する関数を指定                                                                                                              
                                    (_) => false                               
                                  );
                              }
                                isDisabled = false;
                                //入力のタップを解除
                              },
                              child: const Text("次のチャット相手を探す"),
                            )
                          ),

                        // ■ 「最初の画面に戻る」ボタン
                        Container(child:
                          ElevatedButton( 
                              onPressed: isDisabled! ? null : () async{ 
                              setState(() {
                                isDisabled = true;
                                // 二重タップ防止  
                                // isProcessingの使い方は、progressMarkerと同じ                             
                                // trueにして、タップをブロック
                              });

                                await Future.delayed(
                                const Duration(milliseconds: 50), //無効にする時間
                                );

                                await talkuserDocSubscription!.cancel();                                                       
                                // lounge_pageに戻る時の一連の処理                    

                              if (context.mounted) {    
                                  Navigator.pushAndRemoveUntil(context,                              //画面遷移の定型   何やってるかの説明：https://sl.bing.net/b4piEYGC70C                                                                        //1回目のcontextは、「Navigator.pushメソッドが呼び出された時点」のビルドコンテキストを参照し
                                    SlideRightRoute(page: const LoungePage()),    //遷移先の画面を構築する関数を指定                                                                                                              
                                    (_) => false                               
                                  );
                              }
                                isDisabled = false;
                                //入力のタップを解除
                              },
                              child: const Text("最初の画面に戻る"),
                            )
                          ),


                        // ■ 入力フィールド
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
                        IconButton (onPressed: () async{                                                              
                          await RoomFirestore.sendMessage(
                                roomId: widget.talkRoom.roomId!, 
                                message: controller.text);
                                controller.clear();}, 
                                icon: Icon(Icons.send,
                                color: isInputEmpty? Colors.grey : Colors.blue,
                                    ))
                                  ],
                                );
                              }
}

                  



