import 'dart:async';
import 'package:flutter/material.dart';
import 'package:udemy_copy/cloud_functions/functions.dart';
import 'package:udemy_copy/firestore/room_firestore.dart';
import 'package:udemy_copy/firestore/user_firestore.dart';
import 'package:udemy_copy/model/matching_progress.dart';
import 'package:udemy_copy/model/talk_room.dart';
import 'package:udemy_copy/page/lounge_page.dart';
import 'package:udemy_copy/page/talk_room_page.dart';
import 'package:synchronized/synchronized.dart';
import 'package:udemy_copy/utils/screen_transition.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';


// initstate()の実行に時間が掛かって、Widget build()の本体の実行が先走ってる。

// if(DB上にマッチング相手が：いる場合)
// ① iniState()のtalkUserUidの取得通信が完了する前に、talkUserUid ==null として 本体のWidget builder()が走る
// ② iniState()のtalkUserUidの取得通信が完了して、iniState()内でcreateRoom()まで完了する
// ③ iniState()のtalkUserUidの取得が完了したので、body部分の if(talkUserUid == null) に該当せず、list[0][1]は描画されない

// if(DB上にマッチング相手が：いない場合)
// ① talkUserUid ==nullで 本体のWidget builder()が走る
// ②if(snapshot.hasData)がtrueになるまで、list[0][1]が描画される

class MatchingProgressPage extends StatefulWidget {
  final MatchingProgress matchingProgress;
  const MatchingProgressPage(this.matchingProgress,
      {super.key}); // this.talkRoomでtalkRoomのオブジェクト（入れ物）を用意してる。
// 10,11行で、TalkRoomPageクラスのインスタンス変数に、ルームの基本情報型を備えた変数talkRoomが設定された
// 画面に「起動/更新/遷移」があった際に、TalkRoomPageクラスが各々個別の情報によってインスタンス化する。

  @override
  State<MatchingProgressPage> createState() =>
      _MatchingProgressPageState(); //「stateクラス」として「_WaitRoomPageState()」を定義
  //「stateクラス」＝StatefulWifetを継承したWidfetの状態を管理するクラス
}

class _MatchingProgressPageState extends State<MatchingProgressPage> {
  //「stateクラス」を継承した新たな「 _WaitRoomPageState」クラスを宣言（機能追加）
  String? myUid;
  String? talkuserUid;
  String? myRoomId;
  // StreamSubscription? unmatchedUserSubscription;
  StreamSubscription? myDocSubscription;
  bool? isInputEmpty;
  bool? isDisabled;
  bool? shouldBreak;
  bool? isTransitioned;
  final lock = Lock();
  final TextEditingController controller = TextEditingController();
  // TextEditingConttrolloerはTextFieldで使うテキスト入力を管理するクラス

  @override
  void initState() {
    super.initState();
    // 追加機能の記述部分であることの明示
    // 関数の呼び出し（initStateはFlutter標準メソッド）
    // .superは現在の子クラスの親クラスを示す → 親クラスの初期化
    //「親クラス＝Stateクラス＝_WaitRoomPageState」をinitStateメソッドで状態初期化
    // initState()は、Widget作成時にflutterから自動的に一度だけ呼び出されます。
    // このメソッド内で、widgetが必要とする初期設定やデータの初期化を行うことが一般的
    // initState()とは　https://sl.bing.net/ivIFfFUd6Vo
    isInputEmpty = true;
    isDisabled = false;
    shouldBreak = false;
    isTransitioned = false;
    myUid = widget.matchingProgress.myUid;

    // 起動時に1度行うmyUidを確認する処理
    UserFirestore.initForMatching(myUid).then((_) async {
      myRoomId = await RoomFirestore.createRoom(myUid, talkuserUid);
      TalkRoom talkRoom = TalkRoom(myUid: myUid, roomId: myRoomId);

      UserFirestore.retry(myUid, shouldBreak, () async {
        // retry start
        setState(() {
          isDisabled = true; // キャンセルボタンのロック
        });

        await UserFirestore.getUnmatchedUser(myUid).then((getUid) async {
          talkuserUid = getUid;

          // 「自分がマッチングする場合」の処理
          if (talkuserUid != null) {
            bool myProgressMarker =
                await UserFirestore.checkMyProgressMarker(myUid);
            // print('myUidのマッチング処理状況の確認');

            if (myProgressMarker == true) {
              // myUidのマッチング処理状況の確認：「される場合」の処理との競合を避けるため
              print('「される場合」のマッチング処理を確認： retry end');
              setState(() {
                isDisabled = false; // キャンセルボタンのロック解除
              });
              throw Exception('End Retry'); // retry終了
            } else {
              await UserFirestore.updateProgressMarker(myUid,
                  true); // falseの場合は「される場合」は実行されてないので、trueにして競合防止してからtransactionを開始
              print('「する場合」の処理開始直前に progress_marker を trueに変更');

              await CloudFunctions.runTransactionDB(
                      myUid, talkuserUid, myRoomId) // transaction start

                  .then((_) async {
                // transaction 成功の分岐
                if (talkuserUid != null) {
                  // transaction処理内でtalkuserUidに変更がないかの確認
                  print('トランザクション成功: myRoomのField情報の更新、画面遷移');
                  shouldBreak = true;

                  RoomFirestore.updateRoom(myRoomId, talkuserUid);
                  talkRoom.talkuserUid = talkuserUid;
                  //TalkRoomクラスの渡す一連のコンストラクタ変数を用意

                  await myDocSubscription!.cancel();

                  await lock.synchronized(() async {
                    if (context.mounted && isTransitioned == false) {
                      print('「する場合」の画面遷移 実行');
                      isTransitioned = true;
                      await Navigator.pushAndRemoveUntil(
                          //画面遷移の定型   何やってるかの説明：https://sl.bing.net/b4piEYGC70C
                          context, //1回目のcontextは、「Navigator.pushメソッドが呼び出された時点」のビルドコンテキストを参照し
                          MaterialPageRoute(
                              builder: (context) =>
                                  TalkRoomPage(talkRoom)), //遷移先の画面を構築する関数を指定
                          (_) => false);
                    }
                  });
                }
              }).catchError((error) {
                // transactionのエラーハンドリング
                print('トランザクション失敗: talkuserUidをnullにしてretry: $error');
                UserFirestore.updateProgressMarker(myUid, false);
                print('「する場合」の処理が失敗したので progress_marker を falseに戻す');
                talkuserUid = null;
                setState(() {
                  isDisabled = false; // キャンセルボタンのロック解除
                }); // キャンセルボタンのロック解除
                throw Exception();
              });
            } //　if(myProgressMaker == false)
          } //　if(talkuserUid != null)
        }); //　getUnmatchedUser
        if (talkuserUid == null) {
          //　talkuserUid == null で エラーの起こりうるif(){}部分をスルーしてしまった場合に、エラーを手動で返してretryさせる
          print('マッチング可能な相手が0人、retry関数再実行の待機中)');
          setState(() {
            isDisabled = false; // キャンセルボタンのロック解除
          });
          throw Exception();
        }
      }); // retry end

      // 「自分がマッチングされた場合」のstream処理
      if (talkuserUid == null) {
        var myDocStream = UserFirestore.streamMyDoc(myUid);
        print('マッチングルームのstreamの起動(リスンの参照を取得)');

        myDocSubscription = myDocStream.listen((snapshot) async {
          if (snapshot.data()!.isNotEmpty) {
            //TESTドキュメントはFiledが空なので、避けるために必要

            if (snapshot.data()!['progress_marker'] == true) {
              //myUidのマッチング処理状況の確認：「する場合」の処理との競合を避けるため
              print('「する場合」のマッチング処理を確認： 受信したstreamへの「された場合」の処理を終了');
              return;
            } else if (snapshot.data()!['progress_marker'] == false &&
                snapshot.data()!['matched_status'] == true) {
              print('「された場合」の処理開始');
              setState(() {
                isDisabled = true;
              }); // キャンセルボタンのロック
              shouldBreak = true; // retry終了
              // isTransitioned = true;
              await UserFirestore.updateProgressMarker(
                  myUid, true); //「される場合」の処理開始。「する場合」の競合防止マーカー更新
              await RoomFirestore.deleteRoom(myRoomId);

              Map<String, dynamic>? doc = snapshot.data();
              talkRoom.roomId = doc?['room_id'];
              RoomFirestore.getRoomMember(myUid, talkRoom.roomId)
                  .then((roomMemberUid) async {
                // 時々論理エラー発生する箇所
                // .thenではなく、awaitにした方が良いかもしれない
                talkRoom.talkuserUid = roomMemberUid;
                await myDocSubscription!.cancel();
                //コンストラクタ変数を用意 & リスナー解除

                await lock.synchronized(() async {
                  if (context.mounted && isTransitioned == false) {
                    print('「する場合」の画面遷移 実行');
                    isTransitioned = true;
                    await Navigator.pushAndRemoveUntil(
                        //画面遷移の定型   何やってるかの説明：https://sl.bing.net/b4piEYGC70C
                        context, //1回目のcontextは、「Navigator.pushメソッドが呼び出された時点」のビルドコンテキストを参照し
                        MaterialPageRoute(
                            builder: (context) =>
                                TalkRoomPage(talkRoom)), //遷移先の画面を構築する関数を指定
                        (_) => false);
                  }
                });
              });
            }
          }
        }); // myDocSubscription =
      } // 「自分がマッチングされた場合」のstream処理
    }); // initForMatching
  } // initState



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 188, 234, 255),
      appBar: AppBar(
        title: const Text('Waiting Room'),
      ),
      body: Stack(
        // Stackは、childrenに積み重ねて表示させたいウィジェットを下層から順に追加する  //https://coderenkin.com/flutter-stack/
        children: [
          // Stackウィジェットのchildren

          if (talkuserUid ==
              null) // Streambuilderは、データが更新されると、新しいスナップショットを取得し、builder関数を再度呼び出してUIを更新する

            Padding(
              padding: const EdgeInsets.only(bottom: 60.0),
              child: ListView.builder(
                  // ListViewは、スクロール可能なリストを表示するためのウィジェット
                  physics:
                      RangeMaintainingScrollPhysics(), // phyisicsがスクロールを制御するプロパティ。画面を超えて要素が表示され始めたらスクロールが可能になるような設定のやり方
                  shrinkWrap:
                      true, // 表示してるchildrenに含まれるwidgetのサイズにlistviewを設定するやり方
                  reverse: false, // スクロールがした始まりで上に滑っていく設定になる
                  itemCount: 2,
                  itemBuilder: (conxtext, index) {
                    // ListView.builderの基本設定パラメーター
                    // ListViewの定型パターン

                    if (index == 0) {
                      return Padding(
                        padding: const EdgeInsets.all(20),
                        child: Container(
                            // [0]の吹き出し部分を、コンテナで表示
                            constraints: BoxConstraints(
                                maxWidth: MediaQuery.of(context).size.width *
                                    0.6), //この書き方で今表示可能な画面幅を取得できる
                            decoration: BoxDecoration(
                                color: Colors.green,
                                borderRadius: BorderRadius.circular(15)),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 18, vertical: 6),
                            child: ListTile(
                              title: // コンテナのchild部分に、[0]のメッセージを表示
                                  Text(
                                      style: const TextStyle(
                                        fontSize: 17,
                                        color: Colors.white,
                                      ),
                                      AppLocalizations.of(context)!.termsOfUse
                                      ),
                            )),
                      );
                    }

                    if (index == 1) {
                      return Padding(
                        padding: const EdgeInsets.all(20),
                        child: Container(
                            // [0]の吹き出し部分を、コンテナで表示
                            constraints: BoxConstraints(
                                maxWidth: MediaQuery.of(context).size.width *
                                    0.6), //この書き方で今表示可能な画面幅を取得できる
                            decoration: BoxDecoration(
                                color: Colors.green,
                                borderRadius: BorderRadius.circular(15)),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 18, vertical: 6),
                            child: ListTile(
                              title: // コンテナのchild部分に、[1]のメッセージを表示
                                  Text(AppLocalizations.of(context)!.systemMessageInMatchingProgress),
                            )),
                      );
                    }
                    return null;
                  }),
            ),



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
                    // ■「キャンセル」ボタン
                    Container(
                        child: Padding(
                      padding: const EdgeInsets.only(left: 20),
                      child: ElevatedButton(
                        // onPressed: isDisabled! ? null : () async{
                        onPressed: isDisabled!
                            ? () {}
                            : () async {
                                print('キャンセルボタンクリック');
                                setState(() {
                                  isDisabled = true;
                                  // 二重タップ防止
                                  // isProcessingの使い方は、progressMarkerと同じ
                                  // trueにして、タップをブロック
                                });

                                await Future.delayed(
                                  const Duration(milliseconds: 25), //無効にする時間
                                );

                                shouldBreak = true;
                                await myDocSubscription!.cancel();
                                await UserFirestore.updateMatchedStatus(
                                    myUid, true);
                                await UserFirestore.updateProgressMarker(
                                    myUid, false);
                                await UserFirestore.updateIsLounge(myUid, true);
                                // Lounge_pageに戻る時の一連の処理
                                // リスナーを反応させないために両方trueする

                                if (isTransitioned == false) {
                                  await RoomFirestore.deleteRoom(myRoomId);
                                  await lock.synchronized(() async {
                                    if (context.mounted) {
                                      print('キャンセルボタンの画面遷移の実行');
                                      await Navigator.pushAndRemoveUntil(
                                          context, //画面遷移の定型   何やってるかの説明：https://sl.bing.net/b4piEYGC70C                                                                        //1回目のcontextは、「Navigator.pushメソッドが呼び出された時点」のビルドコンテキストを参照し
                                          SlideRightRoute(
                                              page:
                                                  const LoungePage()), //遷移先の画面を構築する関数を指定
                                          (_) => false);
                                    }
                                  });
                                }
                              },
                        child: Text(AppLocalizations.of(context)!.cancel),
                      ),
                    )),

                    // ■入力フィールド
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
                            isInputEmpty =
                                value.isEmpty; // isEmptyメソッドは、bool値を返す
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
                        onPressed: () {
                          controller.clear(); // 送信すると文字を消す
                        },
                        icon: Icon(
                          Icons.send,
                          color: isInputEmpty! ? Colors.grey : Colors.blue,
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
