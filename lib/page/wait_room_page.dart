import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart' as intl;
import 'package:udemy_copy/firestore/room_firestore.dart';
import 'package:udemy_copy/firestore/user_firestore.dart';
import 'package:udemy_copy/model/massage.dart';
import 'package:udemy_copy/utils/shared_prefs.dart';


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
  String? talkUserUid;

  @override                                    //追加機能の記述部分であることの明示
  void initState() {                           //関数の呼び出し（initStateはFlutter標準メソッド）
    super.initState();                         //親クラスの初期化処理　  //「親クラス＝Stateクラス＝_WaitRoomPageState」のinitStateメソッドの呼び出し
    UserFirestore.getAccount()                 //自分のユーザー情報をDBへ書き込み
                 .then((String? uid) {         //.then(引数){コールバック関数}で、親クラス(=initState)の非同期処理が完了したときに実行するサブの関数を定義
                 setState(() {myUid = uid;});  //状態変数myUidに、非同期処理の結果（uid）を設定
          if(myUid == null) {
                  print('wait_room_page.dartの初期取得myUid = null');

          }else{
                  print('wait_room_page.dartの初期取得myUid = $myUid');

    UserFirestore.getUnmatchedUser(myUid)      //getAccount()でのmyUid取得通信が完了する前に、.getUnmatcheduserが実行されてしまっていて、myUidがnullじゃないのにnullで処理されてしまってる　→ .thenで 囲む
                 .then((String? uid){
                 setState(() {talkUserUid = uid;});
                 if(talkUserUid == null) {
                  print('wait_room_page.dartの初期取得talkUserUid = null');
                 }else{
                  print('wait_room_page.dartの初期取得talkUserUid = $talkUserUid');

    RoomFirestore.createRoom(myUid, talkUserUid);  


               }
              });
          }  
        });                 
    }
             
   
  
  //initState()は、Widget作成時にflutterから自動的に一度だけ呼び出されます。
  //このメソッド内で、widgetが必要とする初期設定やデータの初期化を行うことが一般的
  //initState()とは　https://sl.bing.net/ivIFfFUd6Vo



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.lightBlueAccent,
      appBar: AppBar(
        title: const Text('Waiting Room'),
        ),  

      body: Stack(                            //Stackは、childrenに積み重ねて表示させたいウィジェットを下層から順に追加する  //https://coderenkin.com/flutter-stack/
        children: [                           //Stackウィジェットのchildren
          StreamBuilder<QuerySnapshot>(       //Streambuilderは、データが更新されると、新しいスナップショットを取得し、builder関数を再度呼び出してUIを更新する
                                              //<QuerySnapshot>は、その関数において、「uerySnapshot型のデータを扱いますよ」とStreambuilderに伝えている
            stream: UserFirestore.streamUnmatchedUser(),  //何のドキュメントのsnapshotが必要か？ → usersCollectionの「matchedステータスがfalseのユーザー」
            builder: (context, snapshot) {               //contextは、StreanBuilderの位置情報を宣言してるらしい、固定値でOK //snapshotはstreamに設定したエリアのsnapshotの意味。
              if (snapshot.hasData) {   
                  var talkUser = snapshot.data!.docs.first;
                  var talkUserUid = talkUser.id;  
                  // Future<String?> roomIdFuture = RoomFirestore.createRoom(myUid!, talkUserUid);        //ここまでで、DB上からリアルタイムに「matched_status == false」の相手を検索して、トークルームを作ることができた
                  //                 roomIdFuture.then((roomId){                                          //①roomIdの取得通信を確認(.then)してから
                  // UserFirestore.updateTalkuser(talkUserUid, roomId, true);                             //②相手ユーザーのドキュメント情報に書き込み
                  // });
                      //ここからtalk_room_page.dartのTalkRoomPageクラスをインスタンス化して画面遷移





                           
                return Padding(
                    padding: const EdgeInsets.only(bottom: 60.0),
                    child: ListView.builder(                       //ListViewは、スクロール可能なリストを表示するためのウィジェット
                        physics: RangeMaintainingScrollPhysics(),  //phyisicsがスクロールを制御するプロパティ。画面を超えて要素が表示され始めたらスクロールが可能になるような設定のやり方
                        shrinkWrap: true,                          //表示してるchildrenに含まれるwidgetのサイズにlistviewを設定するやり方
                        reverse: false,                             //スクロールがした始まりで上に滑っていく設定になる
                        itemCount: snapshot.data!.docs.length + 1,
                        itemBuilder: (conxtext, index){            //ListViewの定型パターン


                        if(index == 0){
                          return Padding(
                            padding: const EdgeInsets.all(20),
                            child: Container(    //[0]の吹き出し部分を、コンテナで表示
                              constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.6),    //この書き方で今表示可能な画面幅を取得できる
                              decoration: BoxDecoration(
                              color: Colors.green,
                              borderRadius: BorderRadius.circular(15)),
                              padding: EdgeInsets.symmetric(horizontal: 18, vertical: 6),
                              
                              child: const ListTile(title: //コンテナのchild部分に、[0]のメッセージを表示
                                         Text( style: TextStyle(
                                               fontSize: 17, 
                                               color: Colors.white,  ),
                                                  'どもー。ChatBusシステムです(・Д・)ﾉ\n'
                                                  '最初に[利用規約]のお話をさせてね！\n'
                                                  '・相手を不快にさせるような発言はしないでね\n'
                                                  '・出会いを目的にした利用はしないでね\n'
                                                  '・個人情報を相手に教えないでね\n'
                                                  '楽しい時間をすごための約束だよ(・Д・)b\n',      
                                   ),)),
                          );
                        }


                        if(index == 1){
                          return Padding(
                            padding: const EdgeInsets.all(20),
                            child: Container(    //[0]の吹き出し部分を、コンテナで表示
                              constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.6),    //この書き方で今表示可能な画面幅を取得できる
                              decoration: BoxDecoration(
                              color: Colors.green,
                              borderRadius: BorderRadius.circular(15)),
                              padding: EdgeInsets.symmetric(horizontal: 18, vertical: 6),
                              
                              child: ListTile(title: //コンテナのchild部分に、[1]のメッセージを表示
                                         Text('チャット相手を検索中だよ〜！'),)),
                          );
                        }                        



                          //doc情報に配列番号を付して、
                          //配列番号ごとに
                          //取得したdoc情報から抽出するmessage情報を
                          //Messageクラスのmessageインスタンス変数代入して、各messageをインスタンス化する
                          //data()でメソッドを呼ぶと、ドキュメントデータがdynamic型(オブジェクト型)で返されるため、キーを設定してMap型で処理するには明示的にMap<Stgring, dynamic>と宣言する必要がある                                            
                          final doc = snapshot.data!.docs[index - 1];                            //これでメッセージ情報が含まれてる、任意の部屋のdocデータ（ドキュメント情報）を取得してる                                                       
                          final Map<String, dynamic> data = doc.data() as Map<String, dynamic>;  //これでオブジェクト型をMap<String dynamic>型に変換                                                                                                               
                          final Message message = Message(                                       //Message()でMessageクラスのコンストラクタを呼び出し、変数のmessageにそのインスタンスを代入してる
                              message: data['message'], 
                              isMe: Shared_Prefes.fetchUid() == data['sender_id'],               //自分のIDとsnapshotから取得したメッセージのIDが一致してたら、それは自分のメッセージでTRUE
                              sendTime: data['send_time']
                              );




                          //配列番号継続した状態で
                          //messageの背景＝吹き出し部分の設定
                     return Padding( 
                        padding: const EdgeInsets.only(top: 20, left: 11, right: 11, bottom: 20),
                        child: Row(  //bodyのx軸を担当してると考える
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