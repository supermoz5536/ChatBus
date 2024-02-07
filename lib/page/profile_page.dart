import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:udemy_copy/firestore/dm_room_firestore.dart';
import 'package:udemy_copy/firestore/user_firestore.dart';
import 'package:udemy_copy/model/dm.dart';
import 'package:udemy_copy/model/lounge_back.dart';
import 'package:udemy_copy/model/matching_progress.dart';
import 'package:udemy_copy/model/talk_room.dart';
import 'package:udemy_copy/model/user.dart';
import 'package:udemy_copy/page/dm_room_page.dart';
import 'package:udemy_copy/page/lounge_back_page.dart';
import 'package:udemy_copy/page/matching_progress_page.dart';
import 'package:udemy_copy/page/sub_page/dm_list_page.dart';
import 'package:udemy_copy/page/sub_page/friend_list_page.dart';
import 'package:udemy_copy/utils/screen_functions.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:udemy_copy/riverpod/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:udemy_copy/utils/screen_transition.dart';



class ProfilePage extends ConsumerStatefulWidget {
  final User? user;
  const ProfilePage(this.user, {super.key});

  @override
  ConsumerState<ProfilePage> createState() => _LoungePageState();
}

class _LoungePageState extends ConsumerState<ProfilePage> {

  String? myUid;
  bool isDisabled = false; 
  bool isInputEmpty = true;
  TalkRoom? talkRoom;
  Future<Map<String, dynamic>?>? myDataFuture;
  MatchingProgress? matchingProgress;
  int? currentIndex;
  bool deleteConfirmedMarker = false;
  // int? selectedBottomIconIndex;
  int? selectedHistoryIndex;
  final _overlayController1st = OverlayPortalController();
  final _overlayController2nd = OverlayPortalController();
  final TextEditingController controller = TextEditingController();
// TextEditingConttrolloerはTextFieldで使うテキスト入力を管理するクラス.

  @override
  void initState() {
    super.initState();
      // currentIndex = 0;
      // talkRoom = TalkRoom(myUid: myUid, roomId: '');
  }
  

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 4,
        shadowColor: Colors.black.withOpacity(0.5),
        surfaceTintColor: Colors.transparent,
        leading: FutureBuilder(
            future: myDataFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const CircularProgressIndicator();
              } else if (snapshot.hasError) {
                return Text('エラーが発生しました');
              } else {
                return StreamBuilder<DocumentSnapshot>(
                    stream: UserFirestore.streamProfImage(ref.watch(myUidProvider)),
                    //snapshot.data == 非同期操作における「現在の型の状態 + 変数の値」が格納されてる
                    builder: (context, snapshot) {
                      if (snapshot.hasData && snapshot.data!.exists) {
                        return Padding(
                          padding: const EdgeInsets.only(top: 8, left: 8),
                          child: Material(
                            color: Colors.transparent,
                            child: Ink(
                              decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  image: DecorationImage(
                                      image: NetworkImage(
                                          snapshot.data!['user_image_url']),
                                      fit: BoxFit.cover)),
                              // BoxFith は画像の表示方法の制御
                              // cover は満遍なく埋める
                              child: InkWell(
                                splashColor: Colors.black.withOpacity(0.1),
                                radius: 100,
                                customBorder: const CircleBorder(),
                                onTap: () {
                                  Scaffold.of(context).openDrawer();
                                },
                                child: const SizedBox(width: 200, height: 200),
                                // InkWellの有効範囲はchildのWidgetの範囲に相当するので
                                // タップの有効領域確保のために、空のSizedBoxを設定
                              ),
                            ),
                          ),
                        );
                      } else {
                        return const Text('');
                      }
                    });
              }
            }),
        title: const Text('プロフィールページ'),
        centerTitle: true,
        bottom: const PreferredSize(
            preferredSize: Size.fromHeight(15),
            child: Divider(
              color: Colors.white,
              height: 0,
            )),
        actions: <Widget>[
          // ■ リクエスト通知ボタン
          OverlayPortal(
              controller: _overlayController1st,
              overlayChildBuilder: (BuildContext context) {
                return Stack(
                  children: [
                    GestureDetector(
                      // Stack()最下層の全領域がスコープの範囲
                      onTap: () {
                        _overlayController1st.toggle();
                      },
                      child: Container(color: Colors.transparent),
                    ),
                    const Positioned(
                      top: 120,
                      left: 20,
                      height: 200,
                      width: 375,
                      child: Card(
                        elevation: 20,
                        color: Color.fromARGB(255, 156, 156, 156),
                        child: Padding(
                          padding: EdgeInsets.all(10.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              SizedBox(
                                height: 8,
                              ),
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
                icon: const Icon(Icons.person_add_alt_outlined,
                    color: Color.fromARGB(255, 176, 176, 176)),
                iconSize: 35,
                tooltip: '友達リクエストの通知',
              )),

          // ■ DMの通知ボタン
          OverlayPortal(
              controller: _overlayController2nd,
              overlayChildBuilder: (BuildContext context) {
                return Stack(
                  children: [
                    GestureDetector(
                      // Stack()最下層の全領域がスコープの範囲
                      onTap: () {
                        _overlayController2nd.toggle();
                      },
                      child: Container(color: Colors.transparent),
                    ),
                    const Positioned(
                      top: 120,
                      left: 20,
                      height: 200,
                      width: 375,
                      child: Card(
                        elevation: 20,
                        color: Color.fromARGB(255, 156, 156, 156),
                        child: Padding(
                          padding: EdgeInsets.all(10.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              SizedBox(
                                height: 8,
                              ),
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
                icon: const Icon(Icons.notifications_none_outlined,
                    color: Color.fromARGB(255, 176, 176, 176)),
                iconSize: 35,
                tooltip: '受信メールの通知',
              )),

          // ■ マッチングヒストリーの表示ボタン
          Builder(builder: (context) {
            return IconButton(
              onPressed: () {
                Scaffold.of(context).openEndDrawer();
              },
              icon: const Icon(Icons.contacts_outlined,
                  color: Color.fromARGB(255, 176, 176, 176)),
              iconSize: 27,
              tooltip: 'マッチング履歴の表示',
              // .of(context)は記述したそのウィジェット以外のスコープでscaffoldを探す
              // AppBar は Scaffold の内部にあるので、AppBar の context では scaffold が見つけられない
              // Builderウィジェット は Scaffold から独立してるので、その context においては scaffold が見つけられる,
            );
          })
        ],
      ),
      drawer: Drawer(
        child: Column(
          children: [
            Expanded(
              //ListView が無限の長さを持つので直接 column でラップすると不具合
              //Expanded で長さを限界値に指定
              child: ListView(children: [
                SizedBox(
                  height: 160.0,
                  child: DrawerHeader(
                      child: Column(
                    children: [
                      Text('プロフィール画像の設定'),
                      Spacer(flex: 1),
                      Text('名前の設定'),
                      Spacer(flex: 1),
                      Text('自己紹介文の設定'),
                      Spacer(flex: 1),
                      SizedBox(
                          child: ElevatedButton(
                              onPressed: () {}, child: Text('ランダムネーミングのボタン'))),
                    ],
                  )),
                ),
                ListTile(title: Text('設定しておくと安心だよ！')),
                ListTile(title: Text('IDの設定 :')),
                Spacer(
                  flex: 1,
                ),
                ListTile(title: Text('パスワードの設定 :')),
              ]),
            ),
            const Divider(),
            const Spacer(
              flex: 1,
            ),
            Container(
                decoration: const BoxDecoration(
                  border: Border(
                    top: BorderSide(
                        color: Color.fromARGB(255, 199, 199, 199), width: 1.0),
                  ),
                ),
                padding: const EdgeInsets.all(8),
                child: const Row(children: [
                  Text('サブスクリプション： フリープラン'),
                ])),
            Container(
                decoration: const BoxDecoration(
                  border: Border(
                    top: BorderSide(
                        color: Color.fromARGB(255, 199, 199, 199), width: 1.0),
                  ),
                ),
                padding: const EdgeInsets.all(8),
                child: const Row(children: [
                  Text('ログインID表示 環境設定関連'),
                ]))
          ],
        ),
      ),
      endDrawer: Drawer(
          child: Column(children: <Widget>[
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
          width: 280,
          child: const Center(
            child: Text(
              'マッチングの履歴',
              style: TextStyle(fontSize: 24),
            )
          )
        ),

                StreamBuilder<QuerySnapshot>(
                    stream: UserFirestore.streamHistoryCollection(ref.watch(myUidProvider)),
                    //snapshot.data == 非同期操作における「現在の型の状態 + 変数の値」が格納されてる
                    builder: (context, snapshot) {
                      if (snapshot.hasData && snapshot.data!.docs.isNotEmpty) {
                        return Expanded(
                          child: Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: ListView.builder(
                                itemCount: snapshot.data!.docs.length,
                                itemBuilder: (context, index) {
                                  DocumentSnapshot talkuserFields = snapshot.data!.docs[index];
                                  DateTime createdAt = (talkuserFields['created_at'] as Timestamp)
                                                       .toDate();
                                  // グループ処理：ザルに通すデータを取得

                                  DateTime now = DateTime.now();
                                  DateTime today = DateTime(
                                      now.year, now.month, now.day); // 夜中の00:00
                                  DateTime yesterday =
                                      today.subtract(const Duration(days: 1));
                                  DateTime oneWeek =
                                      today.subtract(const Duration(days: 7));
                                  // DateTime twoWeek = today.subtract(Duration(days: 14));
                                  // グループ処理：ザルの編み目を作成

                                  // グループ処理：index当該リストをザルに通す
                                  String dateLabel = '';

                                  if (createdAt.isBefore(oneWeek)) {
                                    dateLabel = '1週間以上前';
                                  } else if (createdAt.isAfter(oneWeek) &&
                                      createdAt.isBefore(yesterday)) {
                                    dateLabel = 'この１週間';
                                  } else if (createdAt.isAfter(today) ||
                                      createdAt.isAtSameMomentAs(today)) {
                                    dateLabel = '今日';
                                  } else if (createdAt.isAfter(yesterday) ||
                                      createdAt.isAtSameMomentAs(yesterday)) {
                                    dateLabel = '昨日';
                                  }

                                  String prevDateLabel = '';
                                  // グループ処理：index当該リストの1つ前（配置が上）のリストをザルに通す
                                  if (index > 0) {
                                    DateTime prevCreatedAt =
                                        (snapshot.data!.docs[index - 1]
                                                ['created_at'] as Timestamp)
                                            .toDate();

                                    if (prevCreatedAt.isBefore(oneWeek)) {
                                      prevDateLabel = '1週間以上前';
                                    } else if (prevCreatedAt.isAfter(oneWeek) &&
                                        prevCreatedAt.isBefore(yesterday)) {
                                      prevDateLabel = 'この１週間';
                                    } else if (prevCreatedAt.isAfter(today) ||
                                        prevCreatedAt.isAtSameMomentAs(today)) {
                                      prevDateLabel = '今日';
                                    } else if (prevCreatedAt
                                            .isAfter(yesterday) ||
                                        prevCreatedAt
                                            .isAtSameMomentAs(yesterday)) {
                                      prevDateLabel = '昨日';
                                    }
                                  }

                                  if (index == 0 ||
                                      dateLabel != prevDateLabel) {
                                    // 1番上のリスト or 直上に配置されたリストとdateLabelが異なる場合だけTrue
                                    return Column(children: <Widget>[
                                      Text(
                                        '---$dateLabel---',
                                        style: const TextStyle(fontSize: 17),
                                      ),
                                      ListTile(
                                        leading: CircleAvatar(
                                            backgroundImage: NetworkImage(
                                                talkuserFields['user_image_url'])),
                                        title: Text(talkuserFields['user_name']),
                                        tileColor: selectedHistoryIndex == index
                                            ? Color.fromARGB(255, 225, 225, 225)
                                            : null,
                                        onTap: () {
                                          setState(() {
                                            selectedHistoryIndex = index;
                                            currentIndex = 3;
                                            talkRoom!.roomId =
                                                talkuserFields['room_id'];
                                          });
                                        },
                                      )
                                    ]);
                                  } else {
                                    return ListTile(
                                      leading: CircleAvatar(
                                          backgroundImage: NetworkImage(
                                              talkuserFields['user_image_url'])),
                                      title: Text(talkuserFields['user_name']),
                                      tileColor: selectedHistoryIndex == index
                                          ? Color.fromARGB(255, 225, 225, 225)
                                          : null,
                                      onTap: () {
                                        setState(() {
                                          selectedHistoryIndex = index;
                                          currentIndex = 3;
                                          talkRoom!.roomId =
                                              talkuserFields['room_id'];
                                        });
                                      },
                                    );
                                  }
                                }),
                          ),
                        );
                      }
                      return const Padding(
                        padding: EdgeInsets.only(top: 300),
                        child: Text('まだマッチングの履歴がないようです'),
                      );
                    })            
      ]
      )
      ),



      body: Stack(
        children: <Widget>[
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
        
              children: [

                const Spacer(flex: 2),
                
                CircleAvatar(            
                  backgroundImage: NetworkImage(widget.user!.userImageUrl!),
                  radius: 60,
                  ),

                const Spacer(flex: 1),

                Text(
                  widget.user!.userName!,
                  style: const TextStyle(
                    fontSize: 35
                  ),
                ),

                const Spacer(flex: 1),


                SizedBox(
                  height: 100,
                  width: 300,
                    child: Text(
                      widget.user!.statement!,
                      style: const TextStyle(
                        color: Color.fromARGB(255, 34, 34, 34),
                        fontSize: 17.5,
                      ), 
                    )
                  ),

                const Spacer(flex: 1),
                const Spacer(flex: 5),

            ]),
          ),



          // ■フッター部分
          Column(
            // column()の縦移動で、画面1番下に配置
            mainAxisAlignment: MainAxisAlignment.end, // https://zenn.dev/wm3/articles/7332788c626b39
            children: [
              Container(
                decoration: const BoxDecoration(
                    color: Color.fromARGB(255, 250, 250, 250),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black,
                        offset: Offset(0, 3), // 上方向への影
                        blurRadius: 5, // ぼかしの量
                      )
                    ]),
                // color: Colors.white,
                height: 75, // フッター領域縦幅
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [

                    const Spacer(flex: 1),

                    // ■「チャット開始」ボタン 
                    SizedBox(
                        // height: 40,
                        // width: 130,
                        child: ElevatedButton(
                      onPressed: isDisabled!
                          ? null
                          : () async {
                              setState(() {
                                isDisabled = true;
                                // 二重タップ防止
                                // trueにして、タップをブロック
                              });
                    
                              await Future.delayed(
                                const Duration(milliseconds: 50), //無効にする時間
                              );
                    
                              if (context.mounted) {
                                LoungeBack loungeBack = LoungeBack(currentIndex: 2);
                                Navigator.pushAndRemoveUntil(
                                    context, //画面遷移の定型   何やってるかの説明：https://sl.bing.net/b4piEYGC70C                                                                        //1回目のcontextは、「Navigator.pushメソッドが呼び出された時点」のビルドコンテキストを参照し
                                    SlideRightRoute(
                                        page: LoungeBackPage(loungeBack)), //遷移先の画面を構築する関数を指定
                                    (_) => false);
                                      }
                              //   setState(() {
                              //     isDisabled = false;
                              //     //入力のタップを解除
                              // });
                            },
                      style: ElevatedButton.styleFrom(elevation: 4),
                      child: const Text(
                        '戻る',
                        style: TextStyle(fontSize: 17)
                      ),
                    )),


                    const Spacer(flex: 1),


                    /// ■ DMアイコン
                    Column(
                      children: [
                        const Spacer(flex: 2),
                        IconButton(
                          icon: const Icon(Icons.chat_bubble_outline),
                          iconSize: 35,
                          // tooltip: 'マッチングしたい相手の設定ができます',
                          color: const Color.fromARGB(255, 79, 155, 255),
                          padding: EdgeInsets.zero,
                          onPressed: () {
                            setState(() async{
                              /// db上にmyUidと相手のuid のjoinedされたDMRoomを参照してget()
                             String? dMRoomId = await DMRoomFirestore.getDMRoomId(
                                                  ref.watch(myUidProvider),
                                                  widget.user!.uid
                                                  );

                              if (dMRoomId != null) {
                                
                              /// ある場合：返り値のdMRoomIdでdm_room_page.dartに画面遷移
                              if (context.mounted) {
                                DMRoom dMRoom = DMRoom(
                                  myUid: ref.watch(myUidProvider),
                                  talkuserUid: widget.user!.uid,
                                  dMRoomId: dMRoomId);
                                Navigator.pushAndRemoveUntil(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            DMRoomPage(dMRoom)),
                                    (_) => false);}
                              
                              } else {
                              /// ない場合：dmroomCollectionにdmroomを作成して画面遷移
                              dMRoomId = await DMRoomFirestore.createDmRoom(
                                           ref.watch(myUidProvider),
                                           widget.user!.uid
                                           );

                                if (context.mounted) {
                                  DMRoom dMRoom = DMRoom(
                                    myUid: ref.watch(myUidProvider),
                                    talkuserUid: widget.user!.uid,
                                    dMRoomId: dMRoomId);
                                  Navigator.pushAndRemoveUntil(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              DMRoomPage(dMRoom)),
                                      (_) => false);
                                }
                              }
                            });
                          },
                        ),
                        const Spacer(flex: 1),
                        const Center(
                          child: Text(
                            '挨拶する',
                            style: TextStyle(
                              color: Color.fromARGB(255, 79, 155, 255),
                              fontSize: 17,
                              fontWeight: FontWeight.bold
                            ),
                          ),
                        ),
                        const Spacer(flex: 2),
                      ]),


                    const Spacer(flex: 1),


                    /// ■ ブロックアイコン
                    Column(
                      children: [
                        const Spacer(flex: 2),
                        IconButton(
                            icon: const Icon(Icons.block_outlined),
                            iconSize: 35,
                            // tooltip: 'マッチングしたい相手の設定ができます',
                            color: const Color.fromARGB(255, 79, 155, 255),
                            padding: EdgeInsets.zero,
                            onPressed: () async{
                                if (deleteConfirmedMarker){
                                  /// 自分のfriendサブコレクションから相手のドキュメントIDを削除
                                    await UserFirestore.deleteFriendUid(ref.watch(myUidProvider), widget.user!.uid);

                                    /// 相手のfriendサブコレクションから自分のドキュメントIDを削除
                                    await UserFirestore.deleteFriendUid(widget.user!.uid, ref.watch(myUidProvider));

                                    /// LoungeBackPage に画面遷移
                                    if (context.mounted) {
                                      LoungeBack loungeBack = LoungeBack(currentIndex: 2);
                                      Navigator.pushAndRemoveUntil(
                                          context, //画面遷移の定型   何やってるかの説明：https://sl.bing.net/b4piEYGC70C                                                                        //1回目のcontextは、「Navigator.pushメソッドが呼び出された時点」のビルドコンテキストを参照し
                                          SlideRightRoute(
                                              page: LoungeBackPage(loungeBack)), //遷移先の画面を構築する関数を指定
                                          (_) => false);
                                    }                             
                                } else {
                                    setState(() {
                                      deleteConfirmedMarker = true;
                                    });
                                }
                            },
                        ),

                        const Spacer(flex: 1),
                        
                        Center(
                          child: Text(
                            deleteConfirmedMarker ? '本当？' : 'ブロックする',
                            style: const TextStyle(
                              color: Color.fromARGB(255, 79, 155, 255),
                              fontSize: 17,
                              fontWeight: FontWeight.bold
                            ),
                          ),
                        ),
                        const Spacer(flex: 2),
                      ]),


                    const Spacer(flex: 1),    


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
