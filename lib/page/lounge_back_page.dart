import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:udemy_copy/firestore/user_firestore.dart';
import 'package:udemy_copy/model/lounge_back.dart';
import 'package:udemy_copy/model/matching_progress.dart';
import 'package:udemy_copy/model/selected_gender.dart';
import 'package:udemy_copy/model/selected_language.dart';
import 'package:udemy_copy/model/talk_room.dart';
import 'package:udemy_copy/model/user.dart';
import 'package:udemy_copy/page/matching_progress_page.dart';
import 'package:udemy_copy/riverpod/provider/selected_gender_provider.dart';
import 'package:udemy_copy/riverpod/provider/selected_language_provider.dart';
import 'package:udemy_copy/riverpod/provider/selected_native_language_provider.dart';
import 'package:udemy_copy/riverpod/provider/target_language_provider.dart';
import 'package:udemy_copy/utils/screen_functions.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:udemy_copy/riverpod/provider/me_user_provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:udemy_copy/utils/service/language_notifier_service.dart';



class LoungeBackPage extends ConsumerStatefulWidget {
  final LoungeBack? loungeBack;
  const LoungeBackPage(this.loungeBack, {super.key});

  @override
  ConsumerState<LoungeBackPage> createState() => _LoungeBackPageState();
}

class _LoungeBackPageState extends ConsumerState<LoungeBackPage> {

  String? myUid;
  bool? isDisabled;
  bool isInputEmpty = true;
  TalkRoom? talkRoom;
  Future<Map<String, dynamic>?>? myDataFuture;
  MatchingProgress? matchingProgress;
  int? currentIndex;
  int? selectedBottomIconIndex;
  int? selectedHistoryIndex;
  final _overlayController1st = OverlayPortalController();
  final _overlayController2nd = OverlayPortalController();
  final TextEditingController controller = TextEditingController();
// TextEditingConttrolloerはTextFieldで使うテキスト入力を管理するクラス

  @override
  void initState() {
    super.initState();

    isDisabled = false;
    currentIndex = widget.loungeBack!.currentIndex;

    /// MatchedHistoryPage用のコンストラクタなので
    /// myUidはnullでも問題が起きてない  
    talkRoom = TalkRoom(myUid: myUid, roomId: '');
        
  }
  

  @override
  Widget build(BuildContext context) {
    User? meUser = ref.watch(meUserProvider);
    String? targetLanguageCode = ref.watch(targetLanguageProvider);
    SelectedGender? selectedGender = ref.watch(selectedGenderProvider);
    SelectedLanguage? selectedLanguage = ref.watch(selectedLanguageProvider);
    SelectedLanguage? selectedNativeLanguage = ref.watch(selectedNativeLanguageProvider);
    final serviceNotifier = LanguageNotifierService(ref);
    
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
                    stream: UserFirestore.streamProfImage(meUser!.uid),
                    //snapshot.data == 非同期操作における「現在の型の状態 + 変数の値」が格納されてる
                    builder: (context, snapshot) {
                      if (snapshot.hasData && snapshot.data!.exists) {
                        return Padding(
                          padding: const EdgeInsets.only(top: 8, left: 10),
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
        title: const Text('ラウンジページ'),
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

                /// ■■■■■■■■■■■■■■■■■■■■このSizedBox部分で描画エラーが出てるので、■■■■■■■■■■■■■■■■■■■■
                /// ■■■■■■■■■■■■■■■■■■■■作り込んでいく際に対処する■■■■■■■■■■■■■■■■■■■■
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
                    ]))),
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
            ))),
            height: 50,
            width: 280,
            child: const Center(
                child: Text(
              'マッチングの履歴',
              style: TextStyle(fontSize: 24),
            ))),
        FutureBuilder(
            future: myDataFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const CircularProgressIndicator();
              } else if (snapshot.hasError) {
                return Text('エラーが発生しました');
              } else {
                return StreamBuilder<QuerySnapshot>(
                    stream: UserFirestore.streamHistoryCollection(meUser!.uid),
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
                    });
              }
            })
      ])),




      body: Stack(
        children: <Widget>[
          ScreenFunctions.setCurrentScreem(currentIndex, meUser, talkRoom!),



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
                        offset: Offset(0, 4.5), // 上方向への影
                        blurRadius: 7, // ぼかしの量
                      )
                    ]),
                // color: Colors.white,
                height: 70, // フッター領域の縦幅
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    // ■「チャット開始」ボタン
                    Padding(
                      padding: const EdgeInsets.only(left: 20),
                      child: SizedBox(
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
                                  /// 画面遷移に必要なコンストラクタ
                                  List<String?>? selectedLanguageList = SelectedLanguage.getSelectedLanguageTrueItem(selectedLanguage);
                                  List<String?>? selectedNativeLanguageList = SelectedLanguage.getSelectedLanguageTrueItem(selectedNativeLanguage);
                                  String? selectedGenderTrueItem = SelectedGender.getSelectedGenderTrueItem(selectedGender);
                                  matchingProgress = MatchingProgress(
                                                       myUid: meUser!.uid,
                                                       selectedGener: selectedGenderTrueItem,
                                                       selectedLanguage: selectedLanguageList, 
                                                       selectedNativeLanguage: selectedNativeLanguageList, 
                                                     );                                        
                                  Navigator.pushAndRemoveUntil(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              MatchingProgressPage(
                                                  matchingProgress!)),
                                      (_) => false);
                                }
                                //   setState(() {
                                //     isDisabled = false;
                                //     //入力のタップを解除
                                // });
                              },
                        style: ElevatedButton.styleFrom(elevation: 4),
                        child: Text(
                          AppLocalizations.of(context)!.start,
                          // style: TextStyle(fontSize: 12)
                        ),
                      )),
                    ),

                    const Spacer(),

                    // Searchアイコン
                    Column(
                      children: [
                        const SizedBox(height: 10),
                        Flexible(
                          flex: 1,
                          child: IconButton(
                            icon: const Icon(Icons.travel_explore_outlined),
                            iconSize: 35,
                            tooltip: 'マッチングしたい相手の設定ができます',
                            color: selectedBottomIconIndex == 0
                                ? const Color.fromARGB(255, 79, 155, 255)
                                : const Color.fromARGB(255, 176, 176, 176),
                            padding: EdgeInsets.zero,
                            onPressed: () {
                              setState(() {
                                currentIndex = 0;
                                selectedBottomIconIndex = 0;
                              });
                            },
                          ),
                        ),
                        Flexible(
                          flex: 1,
                          child: Center(
                            child: Text(
                              AppLocalizations.of(context)!.search,
                              style: TextStyle(
                                color: selectedBottomIconIndex == 0
                                    ? const Color.fromARGB(255, 79, 155, 255)
                                    : const Color.fromARGB(255, 176, 176, 176),
                                fontSize: 10,
                              ),
                            ),
                          ),
                        )
                      ],
                    ),

                    const Spacer(),

                    // Messageアイコン
                    Column(
                      children: [
                        const SizedBox(height: 10),
                        Flexible(
                          flex: 1,
                          child: IconButton(
                            icon: const Icon(Icons.email_outlined),
                            iconSize: 35,
                            tooltip: '友達から受信したメールの一覧が見られます',
                            color: selectedBottomIconIndex == 1
                                ? const Color.fromARGB(255, 79, 155, 255)
                                : const Color.fromARGB(255, 176, 176, 176),
                            padding: EdgeInsets.zero,
                            onPressed: () {
                              setState(() {
                                currentIndex = 1;
                                selectedBottomIconIndex = 1;
                              });
                            },
                          ),
                        ),
                        Flexible(
                          flex: 1,
                          child: Center(
                            child: Text(
                              AppLocalizations.of(context)!.message,
                              style: TextStyle(
                                color: selectedBottomIconIndex == 1
                                    ? const Color.fromARGB(255, 79, 155, 255)
                                    : const Color.fromARGB(255, 176, 176, 176),
                                fontSize: 10,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),

                    const Spacer(),

                    // Friendアイコン
                    Column(
                      children: [
                        const SizedBox(height: 10),
                        Flexible(
                          flex: 1,
                          child: IconButton(
                            icon: const Icon(Icons.people_alt_outlined),
                            iconSize: 35,
                            tooltip: '友達リストが見られます',
                            color: selectedBottomIconIndex == 2
                                ? const Color.fromARGB(255, 79, 155, 255)
                                : const Color.fromARGB(255, 176, 176, 176),
                            padding: EdgeInsets.zero,
                            onPressed: () {
                              setState(() {
                                currentIndex = 2;
                                selectedBottomIconIndex = 2;
                              });
                            },
                          ),
                        ),
                        Flexible(
                          flex: 1,
                          child: Center(
                            child: Text(
                              AppLocalizations.of(context)!.friends,
                              style: TextStyle(
                                color: selectedBottomIconIndex == 2
                                    ? const Color.fromARGB(255, 79, 155, 255)
                                    : const Color.fromARGB(255, 176, 176, 176),
                                fontSize: 10,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),

                    const Spacer(),
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
