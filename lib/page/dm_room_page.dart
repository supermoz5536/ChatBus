import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart' as intl;
import 'package:udemy_copy/firestore/dm_room_firestore.dart';
import 'package:udemy_copy/model/dm.dart';
import 'package:udemy_copy/model/lounge_back.dart';
import 'package:udemy_copy/model/massage.dart';
import 'package:udemy_copy/model/matching_progress.dart';
import 'package:udemy_copy/model/user.dart';
import 'package:udemy_copy/page/lounge_back_page.dart';
import 'package:udemy_copy/riverpod/provider.dart';
import 'package:udemy_copy/utils/screen_transition.dart';
import 'package:udemy_copy/utils/shared_prefs.dart';
import 'package:udemy_copy/utils/unit_functions.dart';


class DMRoomPage extends ConsumerStatefulWidget {
  final DMRoom dMRoom;
  const DMRoomPage(this.dMRoom, {super.key}); 


  @override
  ConsumerState<DMRoomPage> createState() => _TalkRoomPageState();
}

class _TalkRoomPageState extends ConsumerState<DMRoomPage> {
  bool isInputEmpty = true;
  bool? isDisabled;
  bool? isChatting;
  Future<String?>? futureTranslation;
  StreamSubscription? talkuserDocSubscription;
  MatchingProgress? matchingProgress;
  final TextEditingController controller = TextEditingController();

  @override // 追加機能の記述部分であることの明示
  void initState() {
    // 関数の呼び出し（initStateはFlutter標準メソッド）
    super.initState(); // .superは現在の子クラスの親クラスを示す → 親クラスの初期化
    // 追加機能の記述部分であることの明示
    // 関数の呼び出し（initStateはFlutter標準メソッド）
    // .superは現在の子クラスの親クラスを示す → 親クラスの初期化
    isDisabled = false;
    isChatting = true;

    // UserFirestore.updateChattingStatus(widget.talkRoom.myUid, true)
    //     .then((_) async {
    //   await Future.delayed(
    //     const Duration(milliseconds: 400), //リスナー開始までの時間
    //   );

    //   var talkuserDocStream =
    //       UserFirestore.streamTalkuserDoc(widget.talkRoom.talkuserUid);
    //   print('トークルーム: streamの起動(リスンの参照を取得)');
    //   // print ('コンストラクタのtalkRoomのmyUid == ${widget.talkRoom.myUid}');

    //   talkuserDocSubscription = talkuserDocStream.listen((snapshot) {
    //     print('トークルーム: streamデータをリスン');
    //     print(
    //         'トークルーム: chatting_status: ${snapshot.data()!['chatting_status']}');

    //     if (snapshot.data()!.isNotEmpty &&
    //         (snapshot.data()!['chatting_status'] == false ||
    //             snapshot.data()!['is_lounge'] == true)) {
    //       // ■■■■■■islounge を実装したら、上記のコメントアウトを実装する

    //       print('トークルーム: [chatting_status == false] OR [is_lounge == true]');
    //       print('トークルーム: isDisabled == false にしてフッター再描画');
    //       setState(() {
    //         isChatting = false;
    //         // 状態を更新：フッターUIを再描画
    //       });
    //     }
    //   });
    // });

    // UserFirestore.updateHistory(
    //   widget.talkRoom.myUid,
    //   widget.talkRoom.talkuserUid,
    //   widget.talkRoom.roomId,
    // );
  } // initState

  @override
  Widget build(BuildContext context) {
    User? meUser = ref.watch(meUserProvider);

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 246, 246, 246),
      appBar: AppBar(
        title: const Text('ダイレクトメッセージ!'),
      ),
      body: Stack(        
        children: [
          StreamBuilder<QuerySnapshot>(
              //？？？？？<QuerySnapshot>の意味は？
              stream: DMRoomFirestore.streamDM(widget.dMRoom.dMRoomId!),
              /// widgetは、statefulwidgetクラスのプロパティにアクセスするために必要なキーワード
              /// 該当のroomドキュメントに変更があるたびにstreamを取得する
              /// 変更が新たな変更のトリガーになって、限定的に無限ループしている？
              /// その場合、「何の変更がトリガーか？」「どのポイントで無限ループが解消してるか？」
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 60.0),

                    child: ListView.builder(
                        physics: const RangeMaintainingScrollPhysics(), //phyisicsがスクロールを制御するプロパティ。画面を超えて要素が表示され始めたらスクロールが可能になるような設定のやり方
                        shrinkWrap: true, //表示してるchildrenに含まれるwidgetのサイズにlistviewを設定するやり方
                        reverse: true, //スクロールがした始まりで上に滑っていく設定になる
                        itemCount: snapshot.data!.docs.length,
                        itemBuilder: (conxtext, index) {
                          final doc = snapshot.data!.docs[index]; //これでメッセージ情報が含まれてる、任意の部屋のdocデータ（ドキュメント情報）を取得してる
                          final Map<String, dynamic> data = doc.data() as Map<String, dynamic>; //これでオブジェクト型をMap<String dynamic>型に変換
                          final Message message = Message(
                                                  message: data['message'],
                                                  translatedMessage: data['translated_message'], 
                                                  messageId: doc.id,
                                                  isMe: Shared_Prefes.fetchUid() == data['sender_id'],
                                                  sendTime: data['send_time'],
                                                  isDivider: data['is_divider']
                                                  );
                                                  //各々の吹き出しの情報となるので、召喚獣を実際に呼び出して、個別化した方がいい。
                                                  //data()でメソッドを呼ぶと
                                                  //ドキュメントデータがdynamic型(オブジェクト型)で返されるため
                                                  //キーを設定してMap型で処理するには明示的にMap<Stgring, dynamic>と宣言する必要がある


                          /// divierメッセージを表示するmessageの場合
                          if (message.isDivider == true && snapshot.data!.docs.length == 1) {
                            /// 最初がdividerメッセージの場合は何も表示しない
                            return const SizedBox.shrink();
                          }
                          if (message.isDivider == true && snapshot.data!.docs.length >= 2) {
                            return const Center(
                              child: Text(
                                '------ ここから新しいメッセージ ------',
                                style: TextStyle(
                                  color: Color.fromARGB(255, 176, 176, 176),
                                  fontWeight: FontWeight.bold
                                ),),
                            );
                          } 


                          /// 自分の送信した未翻訳のmessageドキュメントの場合
                          /// 翻訳したtextを、をdbに書き込み
                          if (message.isMe == false
                           && message.translatedMessage == ''
                           && message.isDivider == false) {
                             UnitFunctions.translateAndUpdateDMRoom(
                             message.message,                  /// 未翻訳text
                             meUser!.language,                 /// target 言語
                             widget.dMRoom.dMRoomId,           /// dmroomのID
                             message.messageId,                /// 翻訳済textをwriteするメッセージのドキュメントID
                             );              
                          }


                            
                          // 吹き出し部分全体の環境設定
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
                                          padding: const EdgeInsets.only(left: 6, right: 6), // 上下境界線のインデント設定

                                          //メイン記述: 上部分
                                          child: IntrinsicWidth(
                                            child: Container(
                                              alignment: Alignment.center,
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
                                                        horizontal: 10,
                                                        vertical: 6),
                                                child: Text(message.message)
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
                                          padding: const EdgeInsets.only( // 下部の翻訳済文章領域のpadding設定
                                             top: 8, bottom: 8, left: 10, right: 10
                                             ),

                                          // メイン記述: 下部分
                                          child: message.isMe 
                                          ? const Text('')
                                          : message.translatedMessage != ''   
                                             ? IntrinsicWidth( // 翻訳済みmessageがdbに "ある" 場合
                                               child: Container(
                                                   constraints: BoxConstraints(
                                                   maxWidth: MediaQuery.of(context).size.width *0.6),
                                                   color: Colors.white,
                                                   child: Text(message.translatedMessage)))
                                             :  const Text('')
                                        ),
                                      )
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
                  return const Center(
                    child: Text('メッセージがありません'),
                  );
                }
              }),




          // ■フッター部分
          Column(
            // column()の縦移動で、画面1番下に配置
            mainAxisAlignment: MainAxisAlignment
                .end, // https://zenn.dev/wm3/articles/7332788c626b39
            children: [
              Container(
                color: Colors.white,
                height: 68, // フッター領域の縦幅
                child: Row(
      children: [
        // ■ 「戻る」ボタン
        ElevatedButton(
          onPressed: isDisabled! ? null : () async {
              setState(() {
                isDisabled = true;
                // 二重タップ防止
                // isProcessingの使い方は、progressMarkerと同じ
                // trueにして、タップをブロック
              });
        
              await Future.delayed(
                const Duration(milliseconds: 50), //無効にする時間
              );
        
              // await talkuserDocSubscription!.cancel();
              // matching_progress_pageに戻る時の一連の処理
        
              if (context.mounted) {
                LoungeBack loungeBack = LoungeBack(currentIndex: 1);
                Navigator.pushAndRemoveUntil(
                    context, //画面遷移の定型   何やってるかの説明：https://sl.bing.net/b4piEYGC70C                                                                        //1回目のcontextは、「Navigator.pushメソッドが呼び出された時点」のビルドコンテキストを参照し
                    SlideRightRoute(
                        page: LoungeBackPage(loungeBack)), //遷移先の画面を構築する関数を指定
                    (_) => false);
              }
              /// 入力のタップを解除
              isDisabled = false;
            },
          child: const Text('戻る'),
        ),


        // ■ 入力フィールド
        Expanded(
            child: Padding(
          // TextFieldウィジェットをExpandedウィジェットで横に伸長させている
          padding: const EdgeInsets.all(8.0), // 入力フィールドの枠の大きさ

          child: TextField(
            controller:
                controller, // columとrowは子要素の範囲を指定しないから, expandedで自動で範囲をしてしてやると、textfiledが範囲を理解できて表示される
            onChanged: (value) {
              // TextFiledの値(value)を引数
              setState(() {
                // valueに変化があったら、応答関数で状態を更新
                isInputEmpty = value.isEmpty; // isEmptyメソッドは、bool値を返す
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
        IconButton(
            onPressed: () async {
              await DMRoomFirestore.sendDM(
                dMRoomId: widget.dMRoom.dMRoomId,
                message: controller.text);
              controller.clear();
            },
            icon: Icon(
              Icons.send,
              color: isInputEmpty ? Colors.grey : Colors.blue,
                    ))
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}