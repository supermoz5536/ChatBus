import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart' as intl;
import 'package:udemy_copy/firestore/room_firestore.dart';
import 'package:udemy_copy/firestore/user_firestore.dart';
import 'package:udemy_copy/model/lounge_back.dart';
import 'package:udemy_copy/model/massage.dart';
import 'package:udemy_copy/model/matching_progress.dart';
import 'package:udemy_copy/model/talk_room.dart';
import 'package:udemy_copy/model/user.dart';
import 'package:udemy_copy/page/lounge_back_page.dart';
import 'package:udemy_copy/page/matching_progress_page.dart';
import 'package:udemy_copy/riverpod/provider.dart';
import 'package:udemy_copy/utils/screen_transition.dart';
import 'package:udemy_copy/utils/shared_prefs.dart';
import 'package:udemy_copy/utils/unit_functions.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class TalkRoomPage extends ConsumerStatefulWidget {
  final TalkRoom talkRoom;
  const TalkRoomPage(this.talkRoom, {super.key}); //this.talkRoomでtalkRoomのオブジェクト（入れ物）を用意してる。
//10,11行で、TalkRoomPageクラスのインスタンス変数に、ルームの基本情報型を備えた変数talkRoomが設定された
//画面に「起動/更新/遷移」があった際に、TalkRoomPageクラスが各々個別の情報によってインスタンス化する。

  @override
  ConsumerState<TalkRoomPage> createState() => _TalkRoomPageState();
}

class _TalkRoomPageState extends ConsumerState<TalkRoomPage> {
  Future<User?>? futureTalkuserProfile;
  User? talkuserProfile;
  bool? isDisabled;
  bool? isChatting;
  bool isInputEmpty = true;
  String? longPressedItemId;
  StreamSubscription? talkuserDocSubscription;
  MatchingProgress? matchingProgress;
  final _overlayController3rd = OverlayPortalController();
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

    UserFirestore.updateChattingStatus(widget.talkRoom.myUid, true)
     .then((_) async {
        await Future.delayed(
          const Duration(milliseconds: 400), //リスナー開始までの時間
        );

          var talkuserDocStream = UserFirestore.streamTalkuserDoc(widget.talkRoom.talkuserUid);
          print('トークルーム: streamの起動(リスンの参照を取得)');
          // print ('コンストラクタのtalkRoomのmyUid == ${widget.talkRoom.myUid}');

          talkuserDocSubscription = talkuserDocStream.listen((snapshot) {
            print('トークルーム: streamデータをリスン');
            print(
                'トークルーム: chatting_status: ${snapshot.data()!['chatting_status']}');

            if (snapshot.data()!.isNotEmpty &&
                (snapshot.data()!['chatting_status'] == false ||
                    snapshot.data()!['is_lounge'] == true)) {
              // ■■■■■■islounge を実装したら、上記のコメントアウトを実装する

              print('トークルーム: [chatting_status == false] OR [is_lounge == true]');
              print('トークルーム: isDisabled == false にしてフッター再描画');
              setState(() {
                isChatting = false;
                // 状態を更新：フッターUIを再描画
              });
            }
          });
        });

    UserFirestore.updateHistory(
      widget.talkRoom.myUid,
      widget.talkRoom.talkuserUid,
      widget.talkRoom.roomId,
    );

    /// アイコンの表示とポップアップ描画に必要な情報のFuture
    futureTalkuserProfile = UserFirestore.fetchProfile(widget.talkRoom.talkuserUid);
    

  } // initState

  @override
  Widget build(BuildContext context) {
    User? meUser = ref.watch(meUserProvider);
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 3,
        shadowColor: Colors.black.withOpacity(0.7),
        surfaceTintColor: Colors.transparent,
        title: const Text('トークルーム'),
        centerTitle: true,
        bottom: const PreferredSize(
            preferredSize: Size.fromHeight(15),
            child: Divider(
              color: Colors.white,
              height: 0,
            )),
      ),
      body: Stack(        
        children: [
          
          StreamBuilder<QuerySnapshot>(
              //？？？？？<QuerySnapshot>の意味は？
              stream: RoomFirestore.fetchMessageSnapshot(widget.talkRoom.roomId!),
              /// widgetは、statefulwidgetクラスのプロパティにアクセスするために必要なキーワード
              /// 該当のroomドキュメントに変更があるたびにstreamを取得する
              /// 変更が新たな変更のトリガーになって、限定的に無限ループしている？
              /// その場合、「何の変更がトリガーか？」「どのポイントで無限ループが解消してるか？」
              builder: (context, streamSnapshot) {
                if (streamSnapshot.hasData) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 60.0),

                    child: ListView.builder(
                        physics: const RangeMaintainingScrollPhysics(), //phyisicsがスクロールを制御するプロパティ。画面を超えて要素が表示され始めたらスクロールが可能になるような設定のやり方
                        shrinkWrap: true, //表示してるchildrenに含まれるwidgetのサイズにlistviewを設定するやり方
                        reverse: true, //スクロールがした始まりで上に滑っていく設定になる
                        itemCount: streamSnapshot.data!.docs.length,
                        itemBuilder: (conxtext, index) {
                          final doc = streamSnapshot.data!.docs[index]; //これでメッセージ情報が含まれてる、任意の部屋のdocデータ（ドキュメント情報）を取得してる
                          final Map<String, dynamic> data = doc.data() as Map<String, dynamic>; //これでオブジェクト型をMap<String dynamic>型に変換
                          final Message message = Message(
                                                    messageId: doc.id,
                                                    message: data['message'],
                                                    translatedMessage: data['translated_message'], 
                                                    isMe: Shared_Prefes.fetchUid() == data['sender_id'],
                                                    sendTime: data['send_time'],
                                                    isDivider: data['is_divider']
                                                  );
                                                  //各々の吹き出しの情報となるので、召喚獣を実際に呼び出して、個別化した方がいい。
                                                  //data()でメソッドを呼ぶと
                                                  //ドキュメントデータがdynamic型(オブジェクト型)で返されるため
                                                  //キーを設定してMap型で処理するには明示的にMap<Stgring, dynamic>と宣言する必要がある



                          /// 自分の送信した未翻訳のmessageドキュメントの場合
                          // /// 翻訳したtextを、をdbに書き込み
                          // if (message.isMe == false
                          //  && message.translatedMessage == ''
                          //  && message.isDivider == false) {
                          //       UnitFunctions.translateAndUpdateRoom(
                          //       message.message,                  /// 未翻訳text
                          //       meUser!.language,                 /// target 言語
                          //       widget.talkRoom.roomId,           /// ルームID
                          //       message.messageId,
                          //       );              /// 翻訳済textをwriteするメッセージのドキュメントID
                          // }                        


                          // 吹き出し部分全体の環境設定
                          return Padding(
                            padding: const EdgeInsets.only(top: 20, left: 11, right: 11, bottom: 20),
                            child: Row(
                              /// リスト[index]ごとに
                              /// 各吹き出し部分を
                              /// 1番下(.end)に指定して
                              /// 左右の一方から配置する、結果として
                              /// 右下(isMe == true)か、左下に(isMe == false)になる
                              crossAxisAlignment: CrossAxisAlignment.start,
                              textDirection: message.isMe
                                  ? TextDirection.rtl
                                  : TextDirection.ltr,
                              children: [
                            
                                /// アイコンの記述
                                /// 必要な情報は、image_path, user_name, statement, 
                                if (message.isMe == false) 
                                FutureBuilder(
                                   future: futureTalkuserProfile,
                                   builder: (context, futureSnapshot) {
                                     if (futureSnapshot.hasData) {

                                      /// ■ アイコンタップ時のポップアップ
                                      /// ポップアップ表示用のトリガー処理 → アイコン
                                      return GestureDetector(
                                          onTap: _overlayController3rd.toggle,
                                          child: Padding(
                                                    padding: const EdgeInsets.only(left: 0, right: 4),
                                                    child: CircleAvatar(
                                                      radius: 22.5,
                                                      backgroundImage: NetworkImage(
                                                        futureSnapshot.data!.userImageUrl!),
                                                    ),
                                                  ),
                                      );
                                         
                                                                    
                                     } else {
                                       // データがない場合やエラーが発生した場合のプレースホルダー
                                       return const Padding(
                                           padding: EdgeInsets.only(left: 0, right: 4),
                                           child: CircleAvatar(
                                             radius: 22.5, // 明示的にサイズを指定
                                             backgroundColor: Colors.transparent,
                                          ),
                                        );
                                      }
                                    }
                                  ),
                                
                            
                                IntrinsicHeight(
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.stretch,
                                    textDirection: message.isMe
                                      ? TextDirection.rtl
                                      : TextDirection.ltr,                                    
                                    children: [

                                      // 吹き出し部分全体の「背景色」と「丸み」の設定
                                      GestureDetector(                                        
                                        onLongPressStart: (details) {
                                          setState(() {
                                            longPressedItemId = doc.id;
                                          });

                                          final RenderBox overlay = Overlay.of(context).context.findRenderObject() as RenderBox;
                                          final RenderBox referenceBox = context.findRenderObject() as RenderBox;
                                          final Offset tapPosition = referenceBox.globalToLocal(details.globalPosition);

                                          // タップされた位置に基づいてRelativeRectを計算
                                            // 取得ポジションにoffset-115分のズレがあるので
                                            // 手動で調整
                                            // overlayの左上隅が原点（0,0）にあり、
                                            // その右下隅がoverlay.size（幅と高さ）に
                                            // 基づく位置にある長方形領域を定義しています。
                                          final RelativeRect menuPosition = RelativeRect.fromRect(
                                            Rect.fromPoints(
                                              tapPosition - const Offset(0, -115),
                                              tapPosition - const Offset(0, -115),
                                            ),
                                            Offset.zero & overlay.size,
                                          );

                                            showMenu(
                                              context: context,
                                              position: menuPosition,
                                              color: const Color.fromARGB(255, 48, 48, 48),
                                              // shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                              elevation: 4,
                                              items: <PopupMenuEntry<dynamic>>[

                                                const PopupMenuItem(
                                                  value: 1,
                                                  padding: EdgeInsets.only(left: 20, right: 1),
                                                  child: ListTile(
                                                    leading: Icon(
                                                      Icons.translate_outlined,
                                                      color: Colors.white,
                                                      ),
                                                    title: Text(
                                                      '翻訳',
                                                      style: TextStyle(color: Colors.white)),
                                                    tileColor: Color.fromARGB(255, 48, 48, 48),
                                                    dense: true,
                                                  ),
                                                ),

                                              ]
                                            ).then((value) {
                                                if (value == null) {
                                                  setState(() {
                                                    longPressedItemId = null;
                                                  });
                                                  return;
                                                }
                                                /// textを翻訳して、dbに書き込み
                                                if (message.translatedMessage == ''
                                                && message.isDivider == false) {
                                                      UnitFunctions.translateAndUpdateRoom(
                                                      message.message,                  /// 未翻訳text
                                                      meUser!.language,                 /// target 言語
                                                      widget.talkRoom.roomId,           /// ルームID
                                                      message.messageId,                /// 翻訳済textを書き込む、メッセージドキュメントID
                                                      );
                                                      setState(() {
                                                        longPressedItemId = null;
                                                      });        
                                                }      
                                            });
                                        },
                                        
                                        
                                        // 未翻訳の表示形式
                                        child: message.translatedMessage == ''
                                          ? Container(
                                              decoration: BoxDecoration(
                                                  color: message.isMe
                                                    ? doc.id == longPressedItemId 
                                                      ? const Color.fromARGB(255, 192, 227, 244)
                                                      : const Color.fromARGB(255, 201, 238, 255)
                                                    : doc.id == longPressedItemId 
                                                      ? const Color.fromARGB(255, 229, 229, 229)
                                                      : Colors.white,
                                                  borderRadius: BorderRadius.circular(15), // 角の丸みの設定
                                                  border: Border.all(
                                                    color: const Color.fromARGB(255, 195, 195, 195))),
                                              child: IntrinsicWidth(
                                                 child: Container(
                                                    alignment: Alignment.center,
                                                    constraints: BoxConstraints(
                                                       maxWidth: MediaQuery.of(context).size.width *0.6), 
                                                    padding:
                                                       const EdgeInsets.symmetric(
                                                          horizontal: 13,
                                                          vertical: 9),
                                                    child: Text(message.message)
                                                 ),
                                              ),
                                            )


                                          // 翻訳済の表示形式
                                          // メッセージ表示の全体を覆ってる部分
                                          : Container(
                                              decoration: BoxDecoration(
                                                  color: message.isMe
                                                    ? doc.id == longPressedItemId 
                                                      ? const Color.fromARGB(255, 192, 227, 244)
                                                      : const Color.fromARGB(255, 201, 238, 255)
                                                    : doc.id == longPressedItemId 
                                                      ? const Color.fromARGB(255, 229, 229, 229)
                                                      : Colors.white,
                                                  borderRadius: BorderRadius.circular(15), // 角の丸みの設定
                                                  border: Border.all(
                                                    color: const Color.fromARGB(255, 195, 195, 195))),
                                              child: Column(
                                                children: [
                                                                              
                                                  // メッセージ表示の上部分
                                                  Container(
                                                    // 境界線のインデント処理のためのサブ記述 
                                                    decoration: const BoxDecoration(
                                                        color: Colors.transparent,
                                                        borderRadius:
                                                          BorderRadius.only(
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
                                                            decoration: const BoxDecoration(
                                                                border: Border(
                                                                    bottom: BorderSide(
                                                                        color: Color.fromARGB(255, 199, 199, 199),
                                                                        width: 1)),
                                                                color: Colors.transparent,
                                                                borderRadius: BorderRadius.only(
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
                                                    decoration: const BoxDecoration(
                                                        color: Colors.transparent,
                                                        borderRadius:
                                                          BorderRadius.only(
                                                            bottomLeft: Radius.circular(15),
                                                            bottomRight: Radius.circular(15),
                                                        )),
                                                    child: Padding(
                                                      padding: const EdgeInsets.only( // 下部の翻訳済文章領域のpadding設定
                                                        top: 8, bottom: 8, left: 10, right: 10
                                                        ),
                                                                              
                                                      // メイン記述: 下部分
                                                      child: message.isMe 
                                                      ? message.translatedMessage != ''   
                                                        ? IntrinsicWidth( // 翻訳済みmessageがdbに "ある" 場合
                                                          child: Container(
                                                              constraints: BoxConstraints(
                                                              maxWidth: MediaQuery.of(context).size.width *0.6),
                                                              color: Colors.transparent,
                                                              child: Text(message.translatedMessage)))
                                                        :  const Text('')
                                            
                                                      : message.translatedMessage != ''   
                                                        ? IntrinsicWidth( // 翻訳済みmessageがdbに "ある" 場合
                                                          child: Container(
                                                              constraints: BoxConstraints(
                                                              maxWidth: MediaQuery.of(context).size.width *0.6),
                                                              color: Colors.transparent,
                                                              child: Text(message.translatedMessage)))
                                                        :  const Text('')
                                                    ),
                                                  )
                                                ],
                                              ),
                                            )
                                      ),
                                      

                 
                                      
                                      Container(
                                        alignment: Alignment.bottomCenter,
                                        child: Text(intl.DateFormat('HH:mm').format(message.sendTime.toDate()))),
                                      //①DateFormatは、DateTime型のオブジェクトをString型に変えるメソッド。
                                      //②DateFormatを機能させるために、sendTimeでDBから取得するオブジェクトはtimestamp型に設定されてるので、toDate()で型を一致させる
                                  ]),
                                ),
                              ]),
                          );
                        }),
                  );
                } else {
                  return const Center(
                    child: Text('メッセージがありません'),
                  );
                }
              }),





          // ■フッター部分(chatting)
          Column(
            // column()の縦移動で、画面1番下に配置
            mainAxisAlignment: MainAxisAlignment
                .end, // https://zenn.dev/wm3/articles/7332788c626b39
            children: [
              Container(
                decoration: const BoxDecoration(
                    color: Color.fromARGB(255, 250, 250, 250),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black,
                        offset: Offset(0, 4.5), // 上方向への影
                        blurRadius: 7, // ぼかしの量
                      )
                    ]),
                height: 68, // フッター領域の縦幅
                child: isChatting!
                    ? buildChattingFooter(context)
                    : buildEndedFooter(context), // 条件付きレンダリング
              ),
            ],
          ),


          /// ポップアップ表示関数の記述
          FutureBuilder(
            future: futureTalkuserProfile,
            builder: (context, futureSnapshot) {
              if (futureSnapshot.hasData) {
                return OverlayPortal(
                
                  /// controller: 表示と非表示を制御するコンポーネント
                  /// overlayChildBuilder: OverlayPortal内の表示ウィジェットを構築する応答関数です。
                  controller: _overlayController3rd,
                  overlayChildBuilder: (BuildContext context) {
                  
                  /// 画面サイズ情報を取得
                  final Size screenSize = MediaQuery.of(context).size;
                
                    return Stack(
                      children: [
                
                        /// 範囲外をタップしたときにOverlayを非表示する処理
                        /// Stack()最下層の全領域がスコープの範囲
                        GestureDetector(
                          onTap: () {
                            _overlayController3rd.toggle();
                          },
                          child: Container(color: Colors.transparent),
                        ),
                
                        /// ポップアップの表示位置
                        Positioned(
                          top: screenSize.height * 0.15, // 画面高さの15%の位置から開始
                          left: screenSize.width * 0.05, // 画面幅の5%の位置から開始
                          height: screenSize.height * 0.6, // 画面高さの30%の高さ
                          width: screenSize.width * 0.9, // 画面幅の90%の幅
                          child: Card(
                            elevation: 20,
                            color: const Color.fromARGB(255, 140, 182, 255),
                            child: Padding(
                              padding: const EdgeInsets.all(10.0),
                
                              /// ポップアップの表示内容
                              /// Userクラスのインスタンスが必要
                              ///
                              child: Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                                    
                                  children: [
                                
                                    const Spacer(flex: 2),
                                    
                                    CircleAvatar(            
                                      backgroundImage: NetworkImage(futureSnapshot.data!.userImageUrl!),
                                      radius: 60,
                                      ),
                                
                                    const Spacer(flex: 1),
                                
                                    Text(
                                      futureSnapshot.data!.userName!,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 35,
                                      ),
                                    ),
                                
                                    const Spacer(flex: 1),
                                
                                    
                                    SizedBox(
                                    height: 100,
                                    width: 300,
                                      child: Text(
                                        futureSnapshot.data!.statement!,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 17.5,
                                        ), 
                                      )
                                    ),

                                    const Spacer(flex: 1),

                                    /// 友達リクエストボタン
                                    ElevatedButton(
                                      onPressed: () async{

                                      /// フレンドに追加しようとするuidが既に登録済みかを確認
                                      bool isUidExist = await UserFirestore.checkExistFriendUid(
                                                               meUser!.uid,
                                                               futureSnapshot.data!.uid
                                                         );
                                       
                                        if (isUidExist == false) {
                                        /// 登録済みではない場合
                                        /// 自分のfirendサブコレクションに相手のuidを追加
                                          await UserFirestore.setFriendUid(
                                            meUser.uid,                // tartgetUid
                                            futureSnapshot.data!.uid,  // addUid
                                            futureSnapshot.data!,      // UserData of talkser
                                            );

                                          /// 相手のfirendサブコレクションに自分のuidを追加
                                          await UserFirestore.setFriendUid(
                                            futureSnapshot.data!.uid,   // tartgetUid
                                            meUser.uid,                 // addUid
                                            meUser,                     // UserData of mine
                                            );

                                        } else { // ある場合は追加する必要がないのでnull
                                        /// 登録済みの場合
                                        /// 何もする必要がないので空関数を実行
                                        (){};
                                        }
                                      },

                                      child: const Text('友達に追加'),
                                      ),
                
                                    const Spacer(flex: 6),
                
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                );
              } else {
                return const CircularProgressIndicator();
              }
              }
            )



        ],
      ),
    );
  }


  // ■ フッター（チャット中）
  Row buildChattingFooter(BuildContext context) {
    return Row(
      children: [
        
        // ■「チャットを終了」ボタン
        const SizedBox(width: 20,),

        ElevatedButton(
          onPressed: () async {
            // 状態を更新：フッターUIを再描画
            setState(() {
              isChatting = false;
            });
            // トーク相手にチャット終了を伝える
            await UserFirestore.updateChattingStatus(widget.talkRoom.myUid, false);
          },
           child: Text(AppLocalizations.of(context)!.exit),
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
              // TextFiledのテキストが変更されるたびに呼び出される応答関数を指定
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

        // ■ 送信アイコン
        IconButton(
            onPressed: controller.text.isEmpty
            ? null
            : () async {
              await RoomFirestore.sendMessage(
                  roomId: widget.talkRoom.roomId!,
                  message: controller.text);
              controller.clear();
              setState(() {
                isInputEmpty = true;
              });
            },
            icon: Icon(
              Icons.send,
              color: isInputEmpty ? Colors.grey : Colors.blue,
            ))
      ],
    );
  }

  // ■ フッター（チャット終了後）
  Row buildEndedFooter(BuildContext context) {
    return Row(
      children: [
        // ■ 「次の相手を探す」ボタン
        Container(
            child: ElevatedButton(
          onPressed: isDisabled!
              ? null
              : () async {
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
                    matchingProgress =
                        MatchingProgress(myUid: widget.talkRoom.myUid);
                    Navigator.pushAndRemoveUntil(
                        context, //画面遷移の定型   何やってるかの説明：https://sl.bing.net/b4piEYGC70C                                                                        //1回目のcontextは、「Navigator.pushメソッドが呼び出された時点」のビルドコンテキストを参照し
                        SlideRightRoute(
                            page: MatchingProgressPage(
                                matchingProgress!)), //遷移先の画面を構築する関数を指定
                        (_) => false);
                  }
                  isDisabled = false;
                  //入力のタップを解除
                },
          child: Text(AppLocalizations.of(context)!.goNext),
        )),

        // ■ 「最初の画面に戻る」ボタン
        Container(
            child: ElevatedButton(
          onPressed: isDisabled!
              ? null
              : () async {
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
                    LoungeBack loungeBack = LoungeBack(currentIndex: 0);
                    Navigator.pushAndRemoveUntil(
                        context, //画面遷移の定型   何やってるかの説明：https://sl.bing.net/b4piEYGC70C                                                                        //1回目のcontextは、「Navigator.pushメソッドが呼び出された時点」のビルドコンテキストを参照し
                        SlideRightRoute(
                            page: LoungeBackPage(loungeBack)), //遷移先の画面を構築する関数を指定
                        (_) => false);
                  }
                  isDisabled = false;
                  //入力のタップを解除
                },
          child: Text(AppLocalizations.of(context)!.goHome),
        )),

      ],
    );
  }
}






                                      // GestureDetector(
                                      //   onLongPressStart: (details) {
                                      //     final position = details.globalPosition;
                                      //     final Size screenSize = MediaQuery.of(context).size; // 画面のサイズを取得   
                                      //     bool isBelowCenter = position.dy > screenSize.height / 2;  // 画面中央よりタップ位置が上にあるか下にあるかを判断

                                      //     // メニューの表示位置を計算
                                      //     RelativeRect menuPosition;
                                      //     if (isBelowCenter) {
                                      //       // メッセージが画面中央より下にある場合、メッセージの上にメニューを表示
                                      //       menuPosition = RelativeRect.fromLTRB(
                                      //         position.dx, // 左端
                                      //         position.dy, // タップ位置より少し上（メニューの高さ分を考慮）
                                      //         screenSize.width - position.dx, // 右側の余白
                                      //         screenSize.height - position.dy, // 下側の余白
                                      //       );
                                      //     } else {
                                      //       // メッセージが画面中央より上にある場合、メッセージの下にメニューを表示
                                      //       menuPosition = RelativeRect.fromLTRB(
                                      //         position.dx, // 左端
                                      //         position.dy, // タップ位置
                                      //         screenSize.width - position.dx, // 右側の余白
                                      //         screenSize.height - position.dy, // 下側の余白
                                      //       );
                                      //     }