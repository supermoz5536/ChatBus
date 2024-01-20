import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:udemy_copy/firestore/room_firestore.dart';
import 'package:udemy_copy/model/massage.dart';
import 'package:udemy_copy/model/talk_room.dart';
import 'package:udemy_copy/utils/shared_prefs.dart';
import 'package:intl/intl.dart' as intl;

class MatchedHistoryPage extends StatefulWidget {
  final TalkRoom talkRoom;
  const MatchedHistoryPage(this.talkRoom, {super.key});

  @override
  State<MatchedHistoryPage> createState() => _MatchedHistoryPageState();
}

class _MatchedHistoryPageState extends State<MatchedHistoryPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 188, 234, 255),
      appBar: AppBar(
        title: const Text('トーク履歴'),  //statefulWigetで定義した変数talkRoomは、Widget. の形にしないとStateクラスで使うことができない。
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

               ],
             ),
           );
  }
}