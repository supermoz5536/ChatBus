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
      backgroundColor: const Color.fromARGB(255, 246, 246, 246),
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 246, 246, 246),
        title: const Text('トーク履歴'),  //statefulWigetで定義した変数talkRoomは、Widget. の形にしないとStateクラスで使うことができない。
        bottom: const PreferredSize(
            preferredSize: Size.fromHeight(0),
            child: Divider(
              color: Color.fromARGB(255, 150, 150, 150),
              height: 0,
              thickness: 1,
              indent: 100,
              endIndent: 100,
            )),
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
                              translatedMessage: data['translated_message'], 
                              messageId: doc.id,                              
                              isMe: Shared_Prefes.fetchUid() == data['sender_id'], //自分のIDとsnapshotから取得したメッセージのIDが一致してたら、それは自分のメッセージでTRUE
                              sendTime: data['send_time'],
                              isDivider: data['is_divider']
                              //各々の吹き出しの情報となるので、召喚獣を実際に呼び出して、個別化した方がいい。
                              //data()でメソッドを呼ぶと、ドキュメントデータがdynamic型(オブジェクト型)で返されるため、キーを設定してMap型で処理するには明示的にMap<Stgring, dynamic>と宣言する必要がある                                            
                              );

                     return Padding(
                            padding: const EdgeInsets.only(top: 20, left: 11, right: 11, bottom: 20),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              textDirection: message.isMe
                                  ? TextDirection.rtl
                                  : TextDirection.ltr,
                              children: [
                                // 吹き出し部分全体の「背景色」と「丸み」の設定
                                Container(
                                  decoration: BoxDecoration(
                                      color: message.isMe
                                          ? const Color.fromARGB(255, 201, 238, 255)
                                          : Colors.white,
                                      borderRadius: BorderRadius.circular(15), // 角の丸みの設定
                                      border: Border.all(
                                        color: const Color.fromARGB(255, 195, 195, 195))),
                                  child: Column(
                                    crossAxisAlignment:CrossAxisAlignment.start,
                                    children: [

                                      // メッセージ表示の上部分
                                      Container(
                                        // 境界線のインデント処理のためのサブ記述
                                        decoration: BoxDecoration(
                                            color: message.isMe
                                                ? const Color.fromARGB(255, 201, 238, 255)
                                                : Colors.white,
                                            borderRadius:
                                                const BorderRadius.only(
                                              topLeft: Radius.circular(15),
                                              topRight: Radius.circular(15),
                                            )),
                                        child: Padding(
                                          padding: const EdgeInsets.only(
                                              left: 8, right: 8),

                                          //メイン記述: 上部分
                                          child: IntrinsicWidth(
                                            child: Container(
                                                constraints: BoxConstraints(
                                                    maxWidth: MediaQuery.of(context).size.width *0.6), 
                                                    //この書き方で今表示可能な画面幅を取得できる
                                                decoration: BoxDecoration(
                                                    border: const Border(
                                                        bottom: BorderSide(
                                                            color: Color.fromARGB(255, 199, 199, 199),
                                                            width: 1
                                                            ),
                                                            ), // 上下部境界線の縦の太さ
                                                    color: message.isMe
                                                        ? const Color.fromARGB(255, 201, 238, 255)
                                                        : Colors.white,
                                                    borderRadius: const BorderRadius.only(
                                                        topLeft: Radius.circular(15),
                                                        topRight: Radius.circular(15))),
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 18,
                                                        vertical: 6),
                                                child: Text(message.message),
                                                ),
                                          ),
                                        ),
                                      ),


                                      //メッセージ表示の下部分
                                      Container(
                                        // 境界線のインデント処理のためのサブ記述
                                        decoration: BoxDecoration(
                                            color: message.isMe
                                                ? const Color.fromARGB(255, 201, 238, 255)
                                                : Colors.white,
                                            borderRadius:
                                                const BorderRadius.only(
                                              bottomLeft: Radius.circular(15),
                                              bottomRight: Radius.circular(15),
                                            )),
                                        child: Padding(
                                          padding: const EdgeInsets.only(
                                              left: 8, right: 8),

                                          // メイン記述: 下部分
                                          child: IntrinsicWidth(
                                            child: Container(
                                                constraints: BoxConstraints(
                                                    maxWidth: MediaQuery.of(context).size.width *0.6), 
                                                    //この書き方で今表示可能な画面幅を取得できる
                                                decoration: BoxDecoration(
                                                    border: const Border(
                                                        bottom: BorderSide(
                                                            color: Color.fromARGB(255, 199, 199, 199),
                                                            width: 1
                                                            ),
                                                            ), // 上下部境界線の縦の太さ
                                                    color: message.isMe
                                                        ? const Color.fromARGB(255, 201, 238, 255)
                                                        : Colors.white,
                                                    borderRadius: const BorderRadius.only(
                                                        topLeft: Radius.circular(15),
                                                        topRight: Radius.circular(15))),
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 18,
                                                        vertical: 6),
                                                    child: message.isMe == true
                                                            ? null
                                                            : Text(message.translatedMessage),
                                            ),
                                          ),
                                        )
                                      ),
                                    ],
                                  ),
                                ),
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