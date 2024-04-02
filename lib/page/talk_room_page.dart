import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flag/flag_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart' as intl;
import 'package:udemy_copy/analytics/custom_analytics.dart';
import 'package:udemy_copy/audio_service/just_audio.dart';
import 'package:udemy_copy/audio_service/soundpool.dart';
import 'package:udemy_copy/authentication/auth_service.dart';
import 'package:udemy_copy/cloud_functions/functions.dart';
import 'package:udemy_copy/cloud_storage/user_storage.dart';
import 'package:udemy_copy/map_value/language_name.dart';
import 'package:udemy_copy/firestore/dm_room_firestore.dart';
import 'package:udemy_copy/firestore/room_firestore.dart';
import 'package:udemy_copy/firestore/user_firestore.dart';
import 'package:udemy_copy/model/dm_notification.dart';
import 'package:udemy_copy/model/friend_request_notification.dart';
import 'package:udemy_copy/model/lounge.dart';
import 'package:udemy_copy/model/massage.dart';
import 'package:udemy_copy/model/matching_progress.dart';
import 'package:udemy_copy/model/selected_gender.dart';
import 'package:udemy_copy/model/selected_language.dart';
import 'package:udemy_copy/model/talk_room.dart';
import 'package:udemy_copy/model/user.dart';
import 'package:udemy_copy/page/lounge_page.dart';
import 'package:udemy_copy/page/matching_progress_page.dart';
import 'package:udemy_copy/riverpod/provider/dm_notifications_provider.dart';
import 'package:udemy_copy/riverpod/provider/friend__request_notifications_provider.dart';
import 'package:udemy_copy/riverpod/provider/mode_name_provider.dart';
import 'package:udemy_copy/riverpod/provider/selected_gender_provider.dart';
import 'package:udemy_copy/riverpod/provider/me_user_provider.dart';
import 'package:udemy_copy/riverpod/provider/selected_language_provider.dart';
import 'package:udemy_copy/riverpod/provider/selected_native_language_provider.dart';
import 'package:udemy_copy/riverpod/provider/target_language_provider.dart';
import 'package:udemy_copy/stripe/stripe_checkout.dart';
import 'package:udemy_copy/utils/custom_length_text_input_formatter.dart';
import 'package:udemy_copy/utils/screen_transition.dart';
import 'package:udemy_copy/utils/service/dm_notifier_service.dart';
import 'package:udemy_copy/utils/service/friend_request_notifier_service.dart';
import 'package:udemy_copy/utils/service/language_notifier_service.dart';
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
  User? meUser;
  User? talkuserProfile;
  int? soundId;
  int? prevItemCount = 1;
  Future<User?>? futureTalkuserProfile;
  String? currentLanguageCode;
  String? currentTargetLanguageCode;
  String? currentMode;
  String? longPressedItemId;
  bool? isDisabled = false;
  bool? isDisabledRequest = false;
  bool? isChatting = true;
  bool isInputEmpty = true;
  bool isFriendRequestExist = false;
  bool isFriendUidExist = false;
  MatchingProgress? matchingProgress;
  LanguageNotifierService? languageNotifierService;
  DMNotifierService? dMNotifierservice;
  FriendRequestNotifierService? friendRequestNotifierservice;
  final _overlayController1st = OverlayPortalController();
  final _overlayController2nd = OverlayPortalController();
  final _overlayController3rd = OverlayPortalController();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController statementController = TextEditingController();
  final TextEditingController footerTextController = TextEditingController();
  StreamSubscription? talkuserDocSubscription;
  StreamSubscription? dMSubscription;
  StreamSubscription? friendRequestSubscription;

  String email = '';
  String password = '';
  bool hidePassword = true;
  final GlobalKey<FormState> formKeyTalkRoom = GlobalKey<FormState>();
  GlobalKey<ScaffoldMessengerState> scaffoldMessengerKeyTalkRoom = GlobalKey<ScaffoldMessengerState>();

  @override // 追加機能の記述部分であることの明示
  void initState() {
    // 関数の呼び出し（initStateはFlutter標準メソッド）
    super.initState(); // .superは現在の子クラスの親クラスを示す → 親クラスの初期化
    // 追加機能の記述部分であることの明示
    // 関数の呼び出し（initStateはFlutter標準メソッド）
    // .superは現在の子クラスの親クラスを示す → 親クラスの初期化

    CustomAnalytics.logTalkRoomPageIn();

    // SoundPool.loadSeMessage().then((result){
    //   soundId = result;
    // });

    // JustAudio.loadAllAudio();

    UserFirestore.updateChattingStatus(widget.talkRoom.myUid, true)
     .then((_) async {
        await Future.delayed(
          const Duration(milliseconds: 400), //リスナー開始までの時間
        );

        var talkuserDocStream = UserFirestore.streamTalkuserDoc(widget.talkRoom.talkuserUid);
        print('トークルーム: streamの起動(リスンの参照を取得)');

        talkuserDocSubscription = talkuserDocStream.listen((snapshot) {
          print('トークルーム: streamデータをリスン');
          print('トークルーム: chatting_status: ${snapshot.data()!['chatting_status']}');
          if (snapshot.data()!.isNotEmpty &&
              (snapshot.data()!['chatting_status'] == false ||
                  snapshot.data()!['is_lounge'] == true)) {
            print('トークルーム: [chatting_status == false] OR [is_lounge == true]');
            print('トークルーム: isDisabled == false にしてフッター再描画');
            setState(() {
              // 状態を更新：フッターUIを再描画
              isChatting = false;
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

    // コンテクストの完全な確率を確認してからの状態変更を伴うリスナーを設置
    WidgetsBinding.instance.addPostFrameCallback((_) {
      currentLanguageCode = meUser!.language;

      // DMの通知リスナー起動
      if (dMNotifierservice != null) {
        dMSubscription = dMNotifierservice!.setupUnreadDMNotification(widget.talkRoom.myUid);
      }
      // フレンドリクエストの通知リスナー起動
      if (friendRequestNotifierservice != null) {
        friendRequestSubscription = friendRequestNotifierservice!.setupFriendRequestNotification(widget.talkRoom.myUid);
      }
    });
  }

  DropdownButton<String> dropdownButtonAppLanguage(StateSetter setState) {
  return DropdownButton(
    isDense: true,
    underline: Container(
      height: 1,
      color: const Color.fromARGB(255, 198, 198, 198),),
    icon: const Icon(Icons.keyboard_arrow_down_outlined),
    iconEnabledColor: const Color.fromARGB(255, 187, 187, 187),
    value: currentLanguageCode,
    items: <String>['en', 'ja', 'es', 'ko','zh', 'zh_TW'].map<DropdownMenuItem<String>>((String value) {
        return DropdownMenuItem<String>(
          value: value,   //引数の言語コードをシステム識別用に設定
          child: Text(
            languageNames[value]!,
            style: const TextStyle(color: Colors.black)));
        }).toList(),
    onChanged: (String? newLanguageCode) {
        setState(() {
          // 初期値はデバイスの設定言語
          currentLanguageCode = newLanguageCode!;
        });
          // meUserの状態変数の更新（'language'だけはdbも更新）
          languageNotifierService!.changeLanguage(currentLanguageCode);
      },
    );
  }


  // disposeメソッドをオーバーライド.
  @override
  void dispose() {
    if (dMSubscription != null) dMSubscription!.cancel();
    if (friendRequestSubscription != null) friendRequestSubscription!.cancel();
    if (talkuserDocSubscription != null) talkuserDocSubscription!.cancel();
    if (dMSubscription != null) dMSubscription!.cancel();
    if (friendRequestSubscription != null) friendRequestSubscription!.cancel();
    nameController.dispose();
    statementController.dispose();
    footerTextController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    meUser = ref.watch(meUserProvider);
    String? targetLanguageCode = ref.watch(targetLanguageProvider);
    languageNotifierService = LanguageNotifierService(ref);
    dMNotifierservice = DMNotifierService(ref);
    friendRequestNotifierservice = FriendRequestNotifierService(ref);
    List<DMNotification?>? dMNotifications = ref.watch(dMNotificationsProvider);
    List<FriendRequestNotification?>? friendNotifications = ref.watch(friendRequestNotificationsProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 3,
        shadowColor: Colors.black.withOpacity(0.7),
        surfaceTintColor: Colors.transparent,
        title: Text(AppLocalizations.of(context)!.headerTalkRoomPage),
        centerTitle: true,
        leading:  StreamBuilder<DocumentSnapshot>(
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
                    }),

        bottom: const PreferredSize(
            preferredSize: Size.fromHeight(15),
            child: Divider(
              color: Colors.white,
              height: 0,
            )),
        actions: <Widget>[

          // ■ リクエスト通知ボタン
          OverlayPortal(
            /// controller: 表示と非表示を制御するコンポーネント
            /// overlayChildBuilder: OverlayPortal内の表示ウィジェットを構築する応答関数です。
            controller: _overlayController1st,
            overlayChildBuilder: (BuildContext context) {
            
            /// 画面サイズ情報を取得
            final Size screenSize = MediaQuery.of(context).size;
            

              return Stack(
                children: [

                  /// 範囲外をタップしたときにOverlayを非表示する処理
                  /// Stack()最下層の全領域がスコープの範囲
                  GestureDetector(
                    onTap: () {
                      _overlayController1st.toggle();
                    },
                    child: Container(color: Colors.transparent),
                  ),

                  /// ポップアップの表示位置, 表示内容
                  Positioned(
                    top: screenSize.height * 0.15, // 画面高さの15%の位置から開始
                    left: screenSize.width * 0.05, // 画面幅の5%の位置から開始
                    height: screenSize.height * 0.3, // 画面高さの30%の高さ
                    width: screenSize.width * 0.9, // 画面幅の90%の幅
                    child: Card(
                      elevation: 20,
                      color: Colors.white,
                      child: friendNotifications.isEmpty
                        ? Column(
                          children: [
                            Container(
                                  height: 30,
                                  width: double.infinity,
                                  color: const Color.fromARGB(255, 94, 94, 94),
                                  child: Center(
                                    child: Text(
                                      AppLocalizations.of(context)!.friendRequest,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold
                                      )
                                    ),
                                  )
                                ),
                            Padding(
                              padding: const EdgeInsets.all(50),
                              child: Center(child: 
                                Text(AppLocalizations.of(context)!.thereIsNoFriendRequest,
                                style: const TextStyle(
                                  color: Color.fromARGB(255, 91, 91, 91),
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold
                                ),
                                )),
                            ),
                          ],
                        )

                        : SingleChildScrollView(
                            child: Column(
                                children: [
                                  Container(
                                    height: 30,
                                    width: double.infinity,
                                    color: const Color.fromARGB(255, 94, 94, 94),
                                    child: Center(
                                      child: Text(
                                        AppLocalizations.of(context)!.friendRequest,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold
                                        )
                                      ),
                                    )
                                  ),
                                  // Columnが無限の高さを持っているので
                                  // ListView.builderが高さを把握できるように
                                  // Expandedで利用可能な最大範囲を確定させる.
                                  ListView.builder(
                                      // shrinkWrap: アイテムの合計サイズに基づいて自身の高さを調整します
                                      shrinkWrap: true,
                                      // SingleChildScrollView がスクロール機能を担当するので.
                                      // ListView.builderのその機能をOFFにする
                                      physics: const NeverScrollableScrollPhysics(),
                                      itemCount: friendNotifications.length,
                                      itemBuilder: (cnntext, index) {
                                        Widget? tile;
                                        if (friendNotifications[index]!.requestStatus == 'pending') {
                                          tile = Row(children: <Widget>[

                                            Expanded(
                                              flex: 4,
                                              child: ListTile(
                                                title: Text(friendNotifications[index]!.friendName!,
                                                style: const TextStyle(
                                                  fontSize: 14
                                                ),),
                                              ),
                                            ),

                                            ElevatedButton(
                                              style: ButtonStyle(
                                                // ボタンの最小サイズを設定
                                                minimumSize: MaterialStateProperty.all(const Size(0, 30))),
                                              child: Text(AppLocalizations.of(context)!.acceptRequest,
                                                style: const TextStyle(
                                                  fontSize: 12,
                                                  color: Color.fromARGB(255, 82, 82, 82))),
                                              onPressed: () async{
                                              // 承認する場合の処理

                                              // 自分のフレンドリクエストドキュメントを削除
                                              await UserFirestore.deleteFriendRequest(
                                                meUser!.uid,
                                                friendNotifications[index]!.frienduserUid
                                                );

                                              // 状態関数から、該当要素を削除してUI再描画
                                              ref.read(friendRequestNotificationsProvider.notifier)
                                                 .removeFriendRequestNotification(
                                                    friendNotifications[index]!.frienduserUid);

                                              // 相手のフレンドリクエストドキュメントをacceptedに更新
                                              await UserFirestore.updateFriendRequestAccepted(
                                                meUser!.uid,
                                                friendNotifications[index]!.frienduserUid
                                                );

                                              
                                              /// 自分のfirendサブコレクションに相手のuidを追加
                                              /// FriendListPageで、User情報は取得するので
                                              /// フィールド情報は必要ない
                                              await UserFirestore.setFriendUidToMe(
                                                meUser!.uid,
                                                friendNotifications[index]!.frienduserUid
                                              );

                                              /// 相手のfirendサブコレクションに自分のuidを追加
                                              /// FriendListPageで、User情報は取得するので.
                                              /// フィールド情報は必要ない
                                              await UserFirestore.setFriendUidToTalkuser(
                                                meUser!.uid,
                                                friendNotifications[index]!.frienduserUid
                                                );

                                              },
                                            ),

                                            Padding(
                                              padding: const EdgeInsets.only(left: 10, right: 10),
                                              child: ElevatedButton(
                                                style: ButtonStyle(
                                                  // ボタンの最小サイズを設定
                                                  minimumSize: MaterialStateProperty.all(const Size(0, 30))),
                                                child: Text(AppLocalizations.of(context)!.denyRequest,
                                                  style: const TextStyle(
                                                    fontSize: 12,
                                                    color: Color.fromARGB(255, 82, 82, 82))),
                                                onPressed: () async{
                                                  // 却下する場合の処理
                                                  // 相手のフレンドリクエストドキュメントをdeniedに更新
                                                  await UserFirestore.updateFriendRequestDenied(
                                                    meUser!.uid,
                                                    friendNotifications[index]!.frienduserUid
                                                    );

                                                  // 自分のフレンドリクエストドキュメントを削除
                                                  await UserFirestore.deleteFriendRequest(
                                                    meUser!.uid,
                                                    friendNotifications[index]!.frienduserUid
                                                    );

                                                  // 状態関数から、該当要素を削除してUI再描画
                                                  ref.read(friendRequestNotificationsProvider.notifier)
                                                    .removeFriendRequestNotification(
                                                        friendNotifications[index]!.frienduserUid);
                                                },
                                              ),
                                            ),
                                            // const Expanded(flex: 1,child: SizedBox()),
                                          ]);
                                        } else {
                                          tile = ListTile(
                                                   title: Text(friendNotifications[index]!.friendName!),
                                                   subtitle: friendNotifications[index]!.requestStatus! == 'waiting'
                                                     ? Text(AppLocalizations.of(context)!.waitingForRequest)
                                                     : friendNotifications[index]!.requestStatus! == 'accepted'
                                                       ? Text(AppLocalizations.of(context)!.acceptedRequest)
                                                       : Text(AppLocalizations.of(context)!.deniedRequest),
                                                   onTap: () async{
                                                    // 自分のフレンドリクエストドキュメントを削除
                                                    await UserFirestore.deleteFriendRequest(
                                                      meUser!.uid,
                                                      friendNotifications[index]!.frienduserUid
                                                      );

                                                    // 状態関数から、該当要素を削除してUI再描画
                                                    ref.read(friendRequestNotificationsProvider.notifier)
                                                      .removeFriendRequestNotification(
                                                          friendNotifications[index]!.frienduserUid);
                                                   },
                                                 );
                                        }
                                        return Column(
                                          children: [
                                             tile,
                                             const Divider(
                                                height: 0,
                                                color: Color.fromARGB(255, 199, 199, 199),
                                                indent: 10,
                                                endIndent: 10,
                                              ),   
                                          ],
                                        );
                                      }                         
                                    ),
                                 ],
                              ),
                          ),
                      ),
                    ),
                  ],
                );
              },
            child: Badge(
                  backgroundColor: Colors.red,
                  isLabelVisible: friendNotifications!.isNotEmpty,
                  largeSize: 20,
                  label: Text('${friendNotifications.length}'),                  
                  child: IconButton(
                      onPressed: () {_overlayController1st.toggle();},
                      icon: const Icon(Icons.person_add_outlined,
                          color: Color.fromARGB(255, 176, 176, 176)),
                      iconSize: 35,
                      tooltip: AppLocalizations.of(context)!.friendRequest,
                    ),
                )
          ),


          // ■ DMの通知ボタン
          OverlayPortal(
            /// controller: 表示と非表示を制御するコンポーネント
            /// overlayChildBuilder: OverlayPortal内の表示ウィジェットを構築する応答関数です。
            controller: _overlayController2nd,
            overlayChildBuilder: (BuildContext context) {
            
            /// 画面サイズ情報を取得
            final Size screenSize = MediaQuery.of(context).size;
            

              return Stack(
                children: [

                  /// 範囲外をタップしたときにOverlayを非表示する処理
                  /// Stack()最下層の全領域がスコープの範囲
                  GestureDetector(
                    onTap: () {
                      _overlayController2nd.toggle();
                    },
                    child: Container(color: Colors.transparent),
                  ),

                  /// ポップアップの表示位置, 表示内容
                  Positioned(
                    top: screenSize.height * 0.15, // 画面高さの15%の位置から開始
                    left: screenSize.width * 0.05, // 画面幅の5%の位置から開始
                    height: screenSize.height * 0.3, // 画面高さの30%の高さ
                    width: screenSize.width * 0.9, // 画面幅の90%の幅.
                    child: Card(
                      elevation: 20,
                      color: Colors.white,
                      child: dMNotifications.isEmpty
                        ? Column(
                          children: [
                            Container(
                                  height: 30,
                                  width: double.infinity,
                                  color: const Color.fromARGB(255, 94, 94, 94),
                                  child: Center(
                                    child: Text(
                                      AppLocalizations.of(context)!.mailNotification,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold
                                      )
                                    ),
                                  )
                                ),
                            Padding(
                              padding: const EdgeInsets.all(50),
                              child: Center(child: 
                                Text(AppLocalizations.of(context)!.thereIsNoUnreadMail,
                                style: const TextStyle(
                                  color: Color.fromARGB(255, 91, 91, 91),
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold
                                ),
                                )),
                            ),
                          ],
                        )

                        : SingleChildScrollView(
                            child: Column(
                                children: [
                                  Container(
                                    height: 30,
                                    width: double.infinity,
                                    color: const Color.fromARGB(255, 192, 192, 192),
                                    child: Center(
                                      child: Text(
                                        AppLocalizations.of(context)!.mailNotification,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold
                                        )
                                      ),
                                    )
                                  ),
                                  // Columnが無限の高さを持っているので
                                  // ListView.builderが高さを把握できるように
                                  // Expandedで利用可能な最大範囲を確定させる.
                                  ListView.builder(
                                      // shrinkWrap: アイテムの合計サイズに基づいて自身の高さを調整します
                                      shrinkWrap: true,
                                      // SingleChildScrollView がスクロール機能を担当するので
                                      // ListView.builderのその機能をOFFにする
                                      physics: const NeverScrollableScrollPhysics(),
                                      itemCount: dMNotifications.length,
                                      itemBuilder: (cnntext, index) {
                                        return Column(
                                          children: [
                                            ListTile(
                                              title: Text(dMNotifications[index]!.talkuserName!),
                                              subtitle: Text(
                                                dMNotifications[index]!.lastMessage == null
                                                 ? ''
                                                 : dMNotifications[index]!.lastMessage!.length < 10
                                                   ? dMNotifications[index]!.lastMessage!
                                                   // ignore: prefer_interpolation_to_compose_strings
                                                   : dMNotifications[index]!.lastMessage!.substring(0, 9) + '...',
                                                style: const TextStyle(
                                                  color: Color.fromARGB(255, 133, 133, 133))),
                                              onTap: () async{
                                                // db上のmyUidの未読フラグを削除
                                                await DMRoomFirestore.removeIsReadElement(
                                                  dMNotifications[index]!.dMRoomId,
                                                  meUser!.uid
                                                  );
                                                            
                                                // 状態管理してるListオブジェクトから
                                                // index番目（タップした）の通知要素を削除
                                                ref.read(dMNotificationsProvider.notifier)
                                                  .removeDMNotification(dMNotifications[index]!.dMRoomId,);
                                                            
                                                // // 状態管理してるListオブジェクト自体を更新します
                                                // // 理由は、要素の更新だけしても
                                                // // データのメモリアドレスが変更されないため
                                                // // riverpodが更新をキャッチできず
                                                // // ウィジェットの再描画が発生しないから
                                                // ref.read(dMNotificationsProvider.notifier)
                                                //   .setDMNotifications(dMNotifications);
                                              },
                                            ),
                                              
                                              const Divider(
                                                height: 0,
                                                color: Color.fromARGB(255, 199, 199, 199),
                                                indent: 10,
                                                endIndent: 10,
                                              ),   
                                          ],
                                        );
                                      }                         
                                    ),
                                 ],
                              ),
                          ),
                      ),
                    ),
                  ],
                );
              },
            child: Badge(
                  backgroundColor: Colors.red,
                  isLabelVisible: dMNotifications!.isNotEmpty,
                  largeSize: 20,
                  label: Text('${dMNotifications.length}'),                  
                  child: IconButton(
                      onPressed: () {_overlayController2nd.toggle();},
                      icon: const Icon(Icons.notifications_none_outlined,
                          color: Color.fromARGB(255, 176, 176, 176)),
                      iconSize: 35,
                      tooltip: AppLocalizations.of(context)!.notificationOfInbox,
                    ),
                )
          ),


        ],
      ),

      drawer: Drawer(
        child: Column(
          children: [
            Expanded(
              //ListView が無限の長さを持つので直接 column でラップすると不具合
              //Expanded で長さを限界値に指定.
              child: ListView(
                children: [
                  SizedBox(
                    height: 380,
                    child: DrawerHeader(
                        child: Column(
                          children: [

                            // ■ プロフィール画面選択
                            Material(
                            color: Colors.transparent,
                            child: Ink(
                              decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  image: DecorationImage(
                                      image: NetworkImage(meUser!.userImageUrl!),
                                      fit: BoxFit.cover)),
                              // BoxFith は画像の表示方法の制御
                              // cover は満遍なく埋める
                              child: InkWell(
                                splashColor: Colors.black.withOpacity(0.1),
                                radius: 100,
                                customBorder: const CircleBorder(),
                                onTap: () async{
                                  // 画像Dataのピックアップし
                                  // Firestorageのプロフ画像を更新
                                  // Firestoreのurlを更新
                                  // 状態変数の更新
                                  // ウィジェット再描画.
                                  String? newUserImageUrl = await UserFirebaseStorage.pickAndUploadProfImage(meUser!.uid);
                                  if (newUserImageUrl != null) {
                                  UserFirestore.updateUserImageUrl(meUser!.uid, newUserImageUrl);
                                  ref.read(meUserProvider.notifier).updateUserImageUrl(newUserImageUrl);
                                  }
                                },
                                child: const SizedBox(width: 110, height: 110),
                                // InkWellの有効範囲はchildのWidgetの範囲に相当するので
                                // タップの有効領域確保のために、空のSizedBoxを設定
                              ),
                            ),
                          ),

                            // ■ 名前の選択
                            Row(
                              children: [
                                Expanded(
                                  child: ListTile(
                                    title: Text(AppLocalizations.of(context)!.name),
                                    subtitle: Text('${meUser!.userName}',
                                      style: const TextStyle(
                                        color: Color.fromARGB(255, 153, 153, 153)
                                      ),),
                                  )),
                                ElevatedButton(
                                  style: ButtonStyle(
                                    // ボタンの最小サイズを設定
                                    minimumSize: MaterialStateProperty.all(const Size(0, 30))),
                                  onPressed:(){
                                    showDialog(
                                      barrierDismissible: false,
                                      context: context,
                                      builder: (_){
                                        return AlertDialog(
                                          // title: Text(AppLocalizations.of(context)!.changeName),
                                          content: TextField(
                                            controller: nameController,
                                            decoration: InputDecoration(
                                              hintText: AppLocalizations.of(context)!.inputNewName,
                                              hintStyle: const TextStyle(
                                                color: Color.fromARGB(255, 153, 153, 153)
                                              )
                                            ),
                                            keyboardType: TextInputType.multiline, // キーボードタイプを複数行対応に設定
                                            inputFormatters: [CustomLengthTextInputFormatter(maxCount: 16)],
                                          ),
                                          actions: <Widget>[
                                            TextButton(
                                              onPressed: () async{
                                                // db上のmyUidのドキュメントの
                                                // 'user_name'フィールドを
                                                // 入力されているテキスト内容で update して
                                                // meUsern 状態変数を更新してUI再描画
                                                await UserFirestore.updateUserName(
                                                  meUser!.uid,
                                                  nameController.text,
                                                );
                                                ref.read(meUserProvider.notifier).updateUserName(nameController.text);
                                                if (mounted) Navigator.pop(context);
                                              },
                                              style: TextButton.styleFrom(
                                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), // パディングを調整
                                                minimumSize: const Size(32, 16)), // ボタンの最小サイズを指定
                                              child: Text(AppLocalizations.of(context)!.ok),
                                              ),
                                              
                                              
                                            TextButton(
                                              onPressed: () {
                                                if (mounted) Navigator.pop(context);                                        
                                              },
                                              style: TextButton.styleFrom(
                                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), // パディングを調整
                                                minimumSize: const Size(32, 16)), // ボタンの最小サイズを指定
                                              child: Text(AppLocalizations.of(context)!.cancel),
                                              )
                                          ],
                                        );
                                    });
                                  },
                                  child: Text(AppLocalizations.of(context)!.change) 
                                ), 
                            ]),

                            // ■ プロフィールコメントの選択
                            Row(
                              children: [
                                Expanded(
                                  child: ListTile(
                                    title: Text(AppLocalizations.of(context)!.statement),
                                    // subtitle: Text('${meUser!.statement}',
                                    //   style: const TextStyle(
                                    //     color: Color.fromARGB(255, 153, 153, 153)
                                    //   ),),
                                  )),
                                ElevatedButton(
                                  style: ButtonStyle(
                                    // ボタンの最小サイズを設定
                                    minimumSize: MaterialStateProperty.all(const Size(0, 30))),
                                  onPressed:(){
                                    showDialog(
                                      barrierDismissible: false,
                                      context: context,
                                      builder: (_){
                                        return AlertDialog(
                                          // title: Text(AppLocalizations.of(context)!.changeStatement),
                                          content: TextField(
                                            controller: statementController,
                                            decoration: InputDecoration(
                                              hintText: AppLocalizations.of(context)!.inputNewStatement,
                                              hintStyle: const TextStyle(
                                                color: Color.fromARGB(255, 153, 153, 153)
                                              )
                                            ),
                                            // keyboardType: TextInputType.multiline, // キーボードタイプを複数行対応に設定
                                            inputFormatters: [CustomLengthTextInputFormatter(maxCount: 68)],
                                          ),
                                          actions: <Widget>[
                                            TextButton(
                                              onPressed: () async{
                                                // db上のmyUidのドキュメントの
                                                // 'statement'フィールドを
                                                // 入力されているテキスト内容で update して
                                                // meUsern 状態変数を更新してUI再描画
                                                await UserFirestore.updateStatement(
                                                  meUser!.uid,
                                                  statementController.text,
                                                );
                                                ref.read(meUserProvider.notifier).updateStatement(statementController.text);
                                                if (mounted) Navigator.pop(context);
                                              },
                                              style: TextButton.styleFrom(
                                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), // パディングを調整
                                                minimumSize: const Size(32, 16)), // ボタンの最小サイズを指定
                                              child: Text(AppLocalizations.of(context)!.ok)),

                                            TextButton(
                                              onPressed: () {
                                                if (mounted) Navigator.pop(context);                                        
                                              },
                                              style: TextButton.styleFrom(
                                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), // パディングを調整
                                                minimumSize: const Size(32, 16)), // ボタンの最小サイズを指定
                                              child: Text(AppLocalizations.of(context)!.cancel))
                                          ],
                                        );
                                    });
                                  },
                                  child: Text(AppLocalizations.of(context)!.change) 
                                ), 
                            ]),

                            // ■ プロフィールコメント表示欄
                            Row(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(left: 15.0),
                                  child: Container(
                                    color: Colors.white,
                                    height: 100,
                                    width: 225,
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Text('${meUser!.statement}',
                                      style: const TextStyle(
                                        color: Color.fromARGB(255, 153, 153, 153)
                                      ),),
                                    ),
                                  ),
                                ),
                              ],
                            )
                      ],
                    )),
                  ),
              ]),
            ),

            const Center(
              child: SizedBox(
                height: 50,
                child: Center(
                  child: Text('Comming soon!')),
              ),
            ),
            
            // ■ Display Language
            Container(
              decoration: const BoxDecoration(
                border: Border(
                  top: BorderSide(
                      color: Color.fromARGB(255, 199, 199, 199), width: 1.0),
                ),
              ),
              padding: const EdgeInsets.all(8),
              child: Row(
                children: [
                  Expanded(
                    child: ListTile(
                      title: Text(AppLocalizations.of(context)!.appLanguage),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(right: 20),
                    child: dropdownButtonAppLanguage(setState),
                  ),
                ],
              ),
            ),

            // ■ Target Language
            Container(
              decoration: const BoxDecoration(
                border: Border(
                  top: BorderSide(
                      color: Color.fromARGB(255, 199, 199, 199), width: 1.0),
                ),
              ),
              padding: const EdgeInsets.all(8),
              child: Row(
                children: [
                  Expanded(
                    child: ListTile(
                      title: Text(AppLocalizations.of(context)!.targetLanguage),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(right: 20),
                    child: dropdownButtonTranslateTargetLanguage(targetLanguageCode),
                  ),
                ],
              ),
            ),



            // ■ サブスクリプション
            Container(
                decoration: const BoxDecoration(
                  border: Border(
                    top: BorderSide(
                        color: Color.fromARGB(255, 199, 199, 199), width: 1.0),
                  ),
                ),
                padding: const EdgeInsets.all(8),
                child: Row(
                  children: [

                  Expanded(
                    child: ListTile(
                      title: Text(AppLocalizations.of(context)!.subscription),
                    ),
                  ),

                  // ■ プラン選択 
                  Padding(
                    padding: const EdgeInsets.only(right: 20),
                    child: ElevatedButton(
                      style: ButtonStyle(
                        // ボタンの最小サイズを設定
                        minimumSize: MaterialStateProperty.all(const Size(0, 30))),
                      onPressed: () {
                        planWindowShowModalBottomSheet(context);
                      },
                      child: Text(
                        // '現在のプラン名',
                        meUser!.subscriptionPlan! == 'free'
                        ? 'Free'
                        : 'Premium',
                        style: const TextStyle(
                          fontSize: 15
                        ),
                        ),
                    )
                  ),
                ]
              )
            ),

            // ■ 最下部の環境設定部分
            Container(
                decoration: const BoxDecoration(
                  border: Border(
                    top: BorderSide(
                        color: Color.fromARGB(255, 199, 199, 199), width: 1.0),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    IconButton(
                            icon: const Icon(Icons.settings),
                            iconSize: 25,
                            tooltip: 'comming soon',
                            color: const Color.fromARGB(255, 130, 130, 130),
                            padding: EdgeInsets.zero,
                            onPressed: () {},
                          ),
                ])
            ),   
          ],
        ),
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
                  // 静的なシステムメッセージを表示するためのindex空間を確保している
                  int itemCount = streamSnapshot.data!.docs.length + 1;

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 60.0),                     
                    child: ListView.builder(
                        physics: const RangeMaintainingScrollPhysics(), //phyisicsがスクロールを制御するプロパティ。画面を超えて要素が表示され始めたらスクロールが可能になるような設定のやり方
                        shrinkWrap: true, //表示してるchildrenに含まれるwidgetのサイズにlistviewを設定するやり方
                        reverse: true, //スクロールがした始まりで上に滑っていく設定になる
                        itemCount: itemCount,
                        itemBuilder: (conxtext, index) {

                          if (itemCount <= 1) {
                            return Padding(
                              padding: const EdgeInsets.all(20),
                              child: Container(
                                  // [0]の吹き出し部分を、コンテナで表示
                                  constraints: BoxConstraints(
                                      maxWidth: MediaQuery.of(context).size.width * 0.6), //この書き方で今表示可能な画面幅を取得できる
                                  decoration: BoxDecoration(
                                      color: Colors.green,
                                      borderRadius: BorderRadius.circular(15)),
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 18, vertical: 6),
                                  child: FutureBuilder(
                                    future: futureTalkuserProfile,
                                    builder: (context, futureSnapshot) {
                                      if (futureSnapshot.hasData) {
                                        return ListTile(
                                          title: Text(
                                                  '${futureSnapshot.data!.userName!}${AppLocalizations.of(context)!.sayHi}',
                                                  style: const TextStyle(
                                                    fontSize: 17,
                                                    color: Colors.white
                                                  ),
                                                ),
                                        );
                                      } else {
                                        return const SizedBox();
                                      }
                                    }
                                  )),
                            );

                          } else {                            
                            // indexが最終末尾の場合に（古い）、静的メッセージを描画
                            if (index == itemCount -1) {
                              return Padding(
                                padding: const EdgeInsets.all(20),
                                child: Container(
                                    // [0]の吹き出し部分を、コンテナで表示
                                    constraints: BoxConstraints(
                                        maxWidth: MediaQuery.of(context).size.width * 0.6), //この書き方で今表示可能な画面幅を取得できる
                                    decoration: BoxDecoration(
                                        color: Colors.green,
                                        borderRadius: BorderRadius.circular(15)),
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 18, vertical: 6),
                                  child: FutureBuilder(
                                    future: futureTalkuserProfile,
                                    builder: (context, futureSnapshot) {
                                      if (futureSnapshot.hasData) {
                                        return ListTile(
                                          title: Text(
                                                  '${futureSnapshot.data!.userName!}${AppLocalizations.of(context)!.sayHi}',
                                                  style: const TextStyle(
                                                    fontSize: 17,
                                                    color: Colors.white
                                                  ),
                                                ),
                                        );
                                      } else {
                                        return const SizedBox();
                                      }
                                    }
                                  )),
                              );
                            } else {   
                              // 静的なシステムメッセージを表示するために確保したindex空間を、
                              // -1 することで差し引いてる  
                              final doc = streamSnapshot.data!.docs[index]; 
                              //これでオブジェクト型をMap<String dynamic>型に変換
                              final Map<String, dynamic> data = doc.data() as Map<String, dynamic>; 
                              // さらに [key: value] の形式を持つtranslated_fieldをmap型に整理
                              final translatedMessageMap = data['translated_message'] as Map<String, dynamic>; // translated_message フィールドをMapとして取得
                              final Message message = Message(
                                                        messageId: doc.id,
                                                        message: data['message'],
                                                        translatedMessage: translatedMessageMap[meUser!.uid], 
                                                        isMe: meUser!.uid == data['sender_id'],
                                                        sendTime: data['send_time'],
                                                        isDivider: data['is_divider']
                                                      );
                                                      //各々の吹き出しの情報となるので、召喚獣を実際に呼び出して、個別化した方がいい。
                                                      //data()でメソッドを呼ぶと
                                                      //ドキュメントデータがdynamic型(オブジェクト型)で返されるため
                                                      //キーを設定してMap型で処理するには明示的にMap<Stgring, dynamic>と宣言する必要がある

                              // 相手からのメッセージの場合のみ効果音をトリガー
                              // itemCount と prevItemCount をフラグに
                              // messageが増えた時の値のズレを利用する
                              if (itemCount > prevItemCount! && message.isMe == false) {
                                print('if内実行されました。');
                                // JustAudio.playSeMessage();
                                // SoundPool.playSeMessage(soundId);
                              }
                              // 完了後は同値に戻す
                              prevItemCount = itemCount;
                                                                                   
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

                                                    PopupMenuItem(
                                                      value: 1,
                                                      padding: const EdgeInsets.only(left: 20, right: 1),
                                                      child: ListTile(
                                                        leading: const Icon(
                                                          Icons.translate_outlined,
                                                          color: Colors.white,
                                                          ),
                                                        title: Text(
                                                          AppLocalizations.of(context)!.translation,
                                                          style: const TextStyle(color: Colors.white)),
                                                        tileColor: const Color.fromARGB(255, 48, 48, 48),
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
                                                          targetLanguageCode,               /// target 言語
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
                          }
                          }
                        }),
                  );
                } else {
                  return const Center(
                    child: Text(
                      ''
                      // AppLocalizations.of(context)!.thereIsNoMessage
                      ),
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

                                    Padding(
                                      padding: const EdgeInsets.only(
                                        top: 8,
                                      ),
                                      child: Container(
                                        height: 50,
                                        width: 75,
                                        decoration: BoxDecoration(
                                          border: Border.all(
                                            color: Color.fromARGB(255, 138, 138, 138),
                                            width: 1,
                                          )
                                        ),
                                        child: Flag.fromString(
                                          futureSnapshot.data!.country!,
                                          fit:BoxFit.fill,
                                        ),
                                      ),
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
                                        textAlign: TextAlign.center,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 17.5,
                                        ), 
                                      )
                                    ),

                                    const Spacer(flex: 1),

                                    /// 友達リクエストボタン
                                    ElevatedButton(
                                      onPressed: isDisabledRequest! ? null : () async{
                                        setState(() {
                                          isDisabledRequest = true;
                                        });

                                        // uidが既にリクエスト中か確認
                                        isFriendRequestExist = await UserFirestore.checkExistFriendRequest(
                                                                 meUser!.uid,
                                                                 futureSnapshot.data!.uid
                                                               );                                    

                                        /// uidが既にフレンド登録済みかを確認
                                        isFriendUidExist = await UserFirestore.checkExistFriendUid(
                                                             meUser!.uid,
                                                             futureSnapshot.data!.uid
                                                           );
                                        
                                        if (isFriendRequestExist == false && isFriendUidExist == false) {
                                          // 登録済みではない場合
                                          // 自他のfriend_requestコレクションに
                                          // リクエストドキュメントを作成する関数を作成

                                          // 相手：pending 
                                          await UserFirestore.setFriendRequestToFriend(
                                            widget.talkRoom.talkuserUid,
                                            meUser!.uid,
                                          );
                                          // 自分：waiting
                                          await UserFirestore.setFriendRequestToMe(
                                            meUser!.uid,
                                            widget.talkRoom.talkuserUid,
                                          );

                                          setState(() {isFriendRequestExist = true;});
                                          
                                        } else {
                                          setState(() {});
                                          }
                                      },
                                      child: isFriendRequestExist == false && isFriendUidExist == false
                                        ? Text(AppLocalizations.of(context)!.addFriend)
                                        : isFriendRequestExist == true
                                          ? Text(AppLocalizations.of(context)!.requesting)
                                          : Text(AppLocalizations.of(context)!.alreadyFriend)
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
                return const Center(child: CircularProgressIndicator());
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
           child: Text(AppLocalizations.of(context)!.endChat),
        ),

        // ■ 入力フィールド
        Expanded(
            child: Padding(
          // TextFieldウィジェットをExpandedウィジェットで横に伸長させている
          padding: const EdgeInsets.all(8.0), // 入力フィールドの枠の大きさ

          child: TextField(
            controller: footerTextController, // columとrowは子要素の範囲を指定しないから, expandedで自動で範囲をしてしてやると、textfiledが範囲を理解できて表示される
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
            onSubmitted: (_) async{
              await sendMessage();
            },
          ),
        )),

        // ■ 送信アイコン
        IconButton(
            onPressed: footerTextController.text.isEmpty
            ? null
            : () async {
              await sendMessage();
            },
            icon: Icon(
              Icons.send,
              color: isInputEmpty ? Colors.grey : Colors.blue,
            ))
      ],
    );
  }

  Future<void> sendMessage() async {
    await RoomFirestore.sendMessage(
        roomId: widget.talkRoom.roomId!,
        message: footerTextController.text,
        myUid: meUser!.uid!,
        talkuserUid: widget.talkRoom.talkuserUid!,
        );
    footerTextController.clear();
    setState(() {
      isInputEmpty = true;
    });
  }


  // ■ フッター（チャット終了後）
  Row buildEndedFooter(BuildContext context) {
    User? meUser = ref.watch(meUserProvider);
    SelectedGender? selectedGender = ref.watch(selectedGenderProvider);
    SelectedLanguage? selectedLanguage = ref.watch(selectedLanguageProvider);
    SelectedLanguage? selectedNativeLanguage = ref.watch(selectedNativeLanguageProvider);
    currentMode = ref.watch(modeNameProvider);

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
                    /// 画面遷移に必要なコンストラクタ
                    List<String?>? selectedLanguageList = SelectedLanguage.getSelectedLanguageTrueItem(
                                                            selectedLanguage,
                                                            currentMode
                                                          );
                    List<String?>? selectedNativeLanguageList = SelectedLanguage.getSelectedLanguageTrueItem(
                                                                  selectedNativeLanguage,
                                                                  currentMode
                                                                );
                    String? selectedGenderTrueItem = SelectedGender.getSelectedGenderTrueItem(selectedGender);

                    matchingProgress = MatchingProgress(
                                          myUid: meUser!.uid,
                                          selectedGener: selectedGenderTrueItem,
                                          selectedLanguage: selectedLanguageList, 
                                          selectedNativeLanguage: selectedNativeLanguageList, 
                                       ); 
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
          child: Text(AppLocalizations.of(context)!.findNextPartner),
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
                    Lounge? loungeConstructor = Lounge(
                                                  showDialogAble: false,
                                                  afterInitialization: true
                                                );
                    Navigator.pushAndRemoveUntil(
                        context, //画面遷移の定型   何やってるかの説明：https://sl.bing.net/b4piEYGC70C                                                                        //1回目のcontextは、「Navigator.pushメソッドが呼び出された時点」のビルドコンテキストを参照し
                        SlideRightRoute(
                            page: LoungePage(loungeConstructor)), //遷移先の画面を構築する関数を指定
                        (_) => false);
                  }
                  isDisabled = false;
                  //入力のタップを解除
                },
          child: Text(AppLocalizations.of(context)!.backToHome),
        )),

      ],
    );
  }


  DropdownButton<String> dropdownButtonTranslateTargetLanguage(String? targetLanguageCode) {
    return DropdownButton(
                    isDense: true,
                    underline: Container(
                      height: 1,
                      color: const Color.fromARGB(255, 198, 198, 198),),
                    icon: const Icon(Icons.keyboard_arrow_down_outlined),
                    iconEnabledColor: const Color.fromARGB(255, 187, 187, 187),
                    value: currentTargetLanguageCode = targetLanguageCode,
                    items: <String>['en', 'ja', 'es', 'ko','zh']
                      .map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,   //引数の言語コードをシステム識別用に設定
                          child: Text(
                            languageNames[value]!,
                            style: const TextStyle(color: Colors.black)));
                      }).toList(),
                    onChanged: (String? newTargetLanguageCode) {
                        setState(() {
                          ref.read(targetLanguageProvider.notifier).updateTargetLanguage(newTargetLanguageCode);
                          // プロバイダーの翻訳ターゲットの言語コードの状態変数に、onChangedで入力された言語コードに変更
                        });
                    },
                  );
  }

  Future<dynamic> planWindowShowModalBottomSheet(BuildContext context) {
    return showModalBottomSheet(
                        isDismissible: false,
                        backgroundColor: Colors.white,
                        isScrollControlled: true,
                        context: context,
                        builder: (_) {
                          // この Scaffold と ScaffoldMessenger は
                          // confirmCancelPlan に応答するSnackBarの参照用
                          return ScaffoldMessenger(
                            key: scaffoldMessengerKeyTalkRoom,
                            child: Scaffold(
                              body: SingleChildScrollView(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [

                                    // ■ ヘッダー部分
                                    Container(
                                      height: 75,
                                      width: MediaQuery.of(context).size.width,
                                      decoration: const BoxDecoration(
                                        color: Color.fromARGB(255, 105, 105, 105),
                                      ),
                                      child: Row(
                                        children: [ 
                                            Expanded(
                                              child: Align(
                                                alignment: Alignment.center,
                                                child: Padding(
                                                  padding: const EdgeInsets.only(left: 65),
                                                  child: Text(AppLocalizations.of(context)!.pricePlan,
                                                    style: const TextStyle(
                                                      fontSize: 30,
                                                      color: Colors.white,
                                                      fontWeight: FontWeight.bold
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),                                         
                                          Padding(
                                            padding: const EdgeInsets.only(right: 15),
                                            child: IconButton(
                                              icon: const Icon(Icons.close,
                                                size: 30,
                                                color: Colors.white,
                                                ),
                                              onPressed: () {
                                                Navigator.of(context).pop();
                                              }   
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                                              
                                    const SizedBox(height: 30),
                                                              
                                    // ■ フリープラン説明
                                    Padding(
                                      padding: const EdgeInsets.only(
                                        left: 35,
                                        right: 35
                                      ),
                                      child: Container(
                                        decoration: const BoxDecoration(
                                            color: Color.fromARGB(255, 129, 155, 250),
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.black,
                                                offset: Offset(0, 1.5), // 上方向への影
                                                blurRadius: 5, // ぼかしの量
                                              )
                                            ]),
                                        child: Column(
                                          mainAxisAlignment: MainAxisAlignment.start,
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                                                
                                            const SizedBox(height: 10),
                                                                
                                            // ■ プラン名
                                            Text(AppLocalizations.of(context)!.free,
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 25,
                                                fontWeight: FontWeight.bold
                                              ),
                                            ),
                                                                
                                            // ■ 価格表示
                                            Text(AppLocalizations.of(context)!.freePlanPrice,
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 17.5,
                                                fontWeight: FontWeight.bold
                                              ),
                                            ),
                                            const SizedBox(height: 10),
                                                                
                                            const Divider(
                                                    color: Colors.white,
                                                    height: 0,
                                                    thickness: 1,
                                                    indent: 30,
                                                    endIndent: 30,
                                                  ),
                                                                
                                            // ■ １段落目
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                top: 10,
                                                left: 30,
                                                right: 30, 
                                                bottom: 5,
                                              ),
                                              child: SizedBox(
                                                child: Padding(
                                                  padding: const EdgeInsets.all(8.0),
                                                  child: Row(
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: [
                                                  
                                                      const Padding(
                                                        padding: EdgeInsets.only(
                                                          left: 8,
                                                          right: 10,
                                                          ),                                  
                                                        child: const Icon(
                                                          Icons.lightbulb,
                                                          size: 22.5,
                                                          color: Colors.white)
                                                      ),
                                                  
                                                      Flexible(
                                                        child: Text(
                                                          AppLocalizations.of(context)!.freePlanLine1,
                                                          style: const TextStyle(
                                                            color: Colors.white,
                                                            fontSize: 14,
                                                            fontWeight: FontWeight.bold
                                                          ),
                                                          ),
                                                      ),
                                                  
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ),
                                                                
                                            // ■ ２段落目
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                top: 10,
                                                left: 30,
                                                right: 30, 
                                                bottom: 5,
                                              ),
                                              child: SizedBox(
                                                child: Padding(
                                                  padding: const EdgeInsets.all(8.0),
                                                  child: Row(
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: [
                                                  
                                                      const Padding(
                                                        padding: EdgeInsets.only(
                                                          left: 8,
                                                          right: 10,
                                                          ),                                  
                                                        child: Opacity(
                                                          opacity: 0.5,
                                                          child: const Icon(
                                                            Icons.clear,
                                                            size: 22.5,
                                                            color: Colors.white),
                                                        )
                                                      ),
                                                  
                                                      Flexible(
                                                        child: Opacity(
                                                          opacity: 0.5,
                                                          child: Text(
                                                            AppLocalizations.of(context)!.freePlanLine2,
                                                            style: const TextStyle(
                                                              color: Colors.white,
                                                              fontWeight: FontWeight.bold,
                                                              fontSize: 14,
                                                            ),
                                                            ),
                                                        ),
                                                      ),
                                                  
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ),
                                                                
                                            // ■ ３段落目
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                top: 10,
                                                left: 30,
                                                right: 30, 
                                                bottom: 10,
                                              ),
                                              child: Container(
                                                color: Colors.white,
                                                child: Padding(
                                                  padding: const EdgeInsets.all(8.0),
                                                  child: Row(
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: [
                                      
                                                      const Padding(
                                                        padding: EdgeInsets.only(
                                                          left: 8,
                                                          right: 10,
                                                          ),                                  
                                                        child: const Icon(
                                                          Icons.check,
                                                          size: 20,
                                                          color: Color(0xFF6c8cfc))
                                                      ),
                                      
                                                      Flexible(
                                                        child: RichText(text: TextSpan(
                                                          style: TextStyle(
                                                            color: const Color.fromARGB(255, 139, 164, 252),
                                                            fontSize: 14,
                                                            // fontStyle: DefaultTextStyle.of(context).style,
                                                          ),
                                                          children: [
                                                            TextSpan(
                                                              text: AppLocalizations.of(context)!.freePlanLine3_1 + '\n',
                                                              style: TextStyle(                                                                
                                                                fontWeight: FontWeight.bold)),
                                                            TextSpan(
                                                              text: AppLocalizations.of(context)!.freePlanLine3_2,
                                                              ),
                                                          ]
                                                        ))
                                                      ),
                                      
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ),
                                                                
                                            const Divider(
                                                    color: Colors.white,
                                                    height: 0,
                                                    thickness: 1,
                                                    indent: 30,
                                                    endIndent: 30,
                                                  ),
                                                                
                                            // ■ プラン選択ボタン: free
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                top: 10,
                                                bottom: 10
                                              ),
                                              child: meUser!.subscriptionPlan == 'free'
                                                // freeプランを契約中の場合
                                                // ボタンを無効化
                                                ? IgnorePointer(
                                                  ignoring: true,
                                                  child: Opacity(
                                                    opacity: 0.3,
                                                    child: ElevatedButton(
                                                        onPressed: () {},
                                                        style: ElevatedButton.styleFrom(
                                                          backgroundColor: Colors.white, // ボタンの背景色
                                                          foregroundColor: const Color(0xFFf08c28), // ボタンのテキスト色
                                                          shape: RoundedRectangleBorder(
                                                            borderRadius: BorderRadius.circular(5), // 角の丸みを設定
                                                          ),
                                                        ),
                                                          child: Text(AppLocalizations.of(context)!.choosePlan)
                                                      ),
                                                  ),
                                                )
                                                // freeプランを契約してない場合
                                                // ボタンを有効化
                                                : ElevatedButton(
                                                    onPressed: () {
                                                      confirmCancelPlan(context);
                                                      // makePermanentAccountShowDialog(context);
                                                    },
                                                    style: ElevatedButton.styleFrom(
                                                      backgroundColor: Colors.white, // ボタンの背景色
                                                      foregroundColor: const Color(0xFFf08c28), // ボタンのテキスト色
                                                      shape: RoundedRectangleBorder(
                                                        borderRadius: BorderRadius.circular(5), // 角の丸みを設定
                                                      ),
                                                    ),
                                                      child: Text(AppLocalizations.of(context)!.choosePlan,
                                                        style: const TextStyle(
                                                          fontWeight: FontWeight.bold
                                                        ),
                                                      )
                                                ),
                                            )
                                          ],
                                        ),
                                      ),
                                    ),
                                                              
                                    const SizedBox(height: 30),
                                                              
                                    // ■ Premiumプラン説明
                                    Padding(
                                      padding: const EdgeInsets.only(
                                        left: 35,
                                        right: 35
                                      ),
                                      child: Container(
                                        decoration: const BoxDecoration(
                                            color: Color.fromARGB(255, 129, 155, 250),
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.black,
                                                offset: Offset(0, 1.5), // 上方向への影
                                                blurRadius: 5, // ぼかしの量
                                              )
                                            ]),
                                        child: Column(
                                          mainAxisAlignment: MainAxisAlignment.start,
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                                                
                                            const SizedBox(height: 10),
                                                                
                                            // ■ プラン名
                                            Text(AppLocalizations.of(context)!.premium,
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 25,
                                                fontWeight: FontWeight.bold
                                              ),
                                            ),
                                                                                                
                                            // ■ 価格表示
                                            Text(AppLocalizations.of(context)!.premiumPlanPrice,
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 17.5,
                                                fontWeight: FontWeight.bold
                                              ),
                                            ),
                                            const SizedBox(height: 10),
                                                                
                                            const Divider(
                                                    color: Colors.white,
                                                    height: 0,
                                                    thickness: 1,
                                                    indent: 30,
                                                    endIndent: 30,
                                                  ),
                                                                
                                            // ■ １段落目
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                top: 10,
                                                left: 30,
                                                right: 30, 
                                                bottom: 5,
                                              ),
                                              child: SizedBox(
                                                child: Padding(
                                                  padding: const EdgeInsets.all(8.0),
                                                  child: Row(
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: [
                                                  
                                                      const Padding(
                                                        padding: EdgeInsets.only(
                                                          left: 8,
                                                          right: 10,
                                                          ),                                  
                                                        child: const Icon(
                                                          Icons.tips_and_updates_rounded,
                                                          size: 22.5,
                                                          color: Colors.white)
                                                      ),
                                                  
                                                      Flexible(
                                                        child: Text(
                                                          AppLocalizations.of(context)!.premiumPlanLine1,
                                                          style: const TextStyle(
                                                            color: Colors.white,
                                                            fontSize: 14,
                                                            fontWeight: FontWeight.bold
                                                          ),
                                                          ),
                                                      ),
                                                  
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ),
                                                                
                                            // ■ ２段落目
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                top: 10,
                                                left: 30,
                                                right: 30, 
                                                bottom: 5,
                                              ),
                                              child: SizedBox(
                                                child: Padding(
                                                  padding: const EdgeInsets.all(8.0),
                                                  child: Row(
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: [
                                                  
                                                      const Padding(
                                                        padding: EdgeInsets.only(
                                                          left: 8,
                                                          right: 10,
                                                          ),                                  
                                                        child: const Icon(
                                                          Icons.check_circle,
                                                          size: 20,
                                                          color: Colors.white)
                                                      ),
                                                  
                                                      Flexible(
                                                        child: Text(
                                                          AppLocalizations.of(context)!.premiumPlanLine2,
                                                          style: const TextStyle(
                                                            color: Colors.white,
                                                            fontWeight: FontWeight.bold,
                                                            fontSize: 14,
                                                          ),
                                                          ),
                                                      ),
                                                  
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ),
                                                                
                                            // ■ ３段落目
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                top: 10,
                                                left: 30,
                                                right: 30, 
                                                bottom: 10,
                                              ),
                                              child: Container(
                                                color: Colors.white,
                                                child: Padding(
                                                  padding: const EdgeInsets.all(8.0),
                                                  child: Row(
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: [
                                      
                                                      const Padding(
                                                        padding: EdgeInsets.only(
                                                          left: 8,
                                                          right: 10,
                                                          ),                                  
                                                        child: const Icon(
                                                          Icons.check,
                                                          size: 20,
                                                          color: Color(0xFF6c8cfc))
                                                      ),
                                      
                                                      Flexible(
                                                        child: RichText(text: TextSpan(
                                                          style: TextStyle(
                                                            color: const Color.fromARGB(255, 139, 164, 252),
                                                            fontSize: 14,
                                                            // fontStyle: DefaultTextStyle.of(context).style,
                                                          ),
                                                          children: [
                                                            TextSpan(
                                                              text: AppLocalizations.of(context)!.premiumPlanLine3_1 + '\n',
                                                              style: TextStyle(                                                                
                                                                fontWeight: FontWeight.bold)),
                                                            TextSpan(
                                                              text: AppLocalizations.of(context)!.premiumPlanLine3_2,
                                                              ),
                                                          ]
                                                        ))
                                                      ),
                                      
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ),
                                                                
                                            const Divider(
                                                    color: Colors.white,
                                                    height: 0,
                                                    thickness: 1,
                                                    indent: 30,
                                                    endIndent: 30,
                                                  ),
                                                                
                                            // ■ プラン選択ボタン: premium
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                top: 10,
                                                bottom: 10
                                              ),
                                              child: meUser!.subscriptionPlan == 'premium'
                                                // premiumプランを契約中の場合
                                                // ボタンを無効化
                                                ? IgnorePointer(
                                                  ignoring: true,
                                                  child: Opacity(
                                                    opacity: 0.3,
                                                    child: ElevatedButton(
                                                        onPressed: () {},
                                                        style: ElevatedButton.styleFrom(
                                                          backgroundColor: Colors.white, // ボタンの背景色
                                                          foregroundColor: const Color(0xFFf08c28), // ボタンのテキスト色
                                                          shape: RoundedRectangleBorder(
                                                            borderRadius: BorderRadius.circular(5), // 角の丸みを設定
                                                          ),
                                                        ),
                                                          child: Text(AppLocalizations.of(context)!.choosePlan)
                                                      ),
                                                  ),
                                                )
                                                // premiumプランを契約してない場合
                                                // ボタンを有効化
                                                : ElevatedButton(
                                                    onPressed: () async{
                                                      switch (meUser!.accountStatus) {
                                                        // 匿名アカウントの場合: 
                                                        // ① 永久アカウント作成用のshowDialogを表示
                                                        // ② showDialog内でStripeの決済画面へ遷移
                                                        case 'anonymous': 
                                                          makePermanentAccountShowDialog(context);
                                                          break;
                                                                
                                                        // 永久アカウントの場合: 
                                                        // ①Stripeの決済画面へ遷移
                                                        case 'permanent': 
                                                          String? result = await CloudFunctions.callCreateCheckoutSession(meUser!.uid);
                                                          if (context.mounted) StripeCheckout.redirectToCheckout(context, result);
                                                          break;
                                                      }
                                                    },
                                                    style: ElevatedButton.styleFrom(
                                                      backgroundColor: Colors.white, // ボタンの背景色
                                                      foregroundColor: const Color(0xFFf08c28), // ボタンのテキスト色
                                                      shape: RoundedRectangleBorder(
                                                        borderRadius: BorderRadius.circular(5), // 角の丸みを設定
                                                      ),
                                                    ),
                                                      child: Text(AppLocalizations.of(context)!.choosePlan,
                                                        style: const TextStyle(
                                                          fontWeight: FontWeight.bold
                                                        ),
                                                      )
                                                ),
                                            )
                                          ],
                                        ),
                                      ),
                                    ),
                                          const SizedBox(height: 20),
                                  ],
                                )
                              ),
                            ),
                          );
                        }
                      );
  }

  Future<dynamic> confirmCancelPlan(BuildContext context) {
    // print('showDialog called with context: $context'); // showDialogを呼び出す時のcontextをログ出力
 
    return showDialog(
      barrierDismissible: false,
      context: context,
      builder: (_) {

        return AlertDialog(
            title: Center(
              child: Text(AppLocalizations.of(context)!.confirmCancelPremium,
                style: const TextStyle(
                  fontWeight: FontWeight.bold
                ),
              ),
            ),
            content: Text(AppLocalizations.of(context)!.confirmAfterCancelPremium),
            actions: [
        
              TextButton(
                    onPressed: () async{
                      // premium → free のプランの切り替え処理を行う
                      String? result = await CloudFunctions.callUpdateCancelAtPeriodEnd(meUser!.uid);
                      // scaffoldKeyを通じてScaffoldStateにアクセスする
                      // scaffoldKey が参照する Scaffold が mounted かを確認
                      // 参照先 Scaffold は showModalBottomSheet の直下
                      if (scaffoldMessengerKeyTalkRoom.currentState?.mounted ?? false) {
                        scaffoldMessengerKeyTalkRoom.currentState?.showSnackBar(cancelPlanSnackBar(result));
                      }
                      if (context.mounted) Navigator.pop(context);
                    },
                    child: Text(AppLocalizations.of(context)!.yes)
                  ),
        
          
              TextButton(
                onPressed: () {
                  print('Close dialog context (no): $context'); // ダイアログ閉じる操作のcontextをログ出力
                  if (context.mounted) Navigator.pop(context);
                },
                child: Text(AppLocalizations.of(context)!.no)
              ),
          
            ],
          );
      });
    }

  Future<dynamic> makePermanentAccountShowDialog(BuildContext context) {
    print('makePermanentAccountShowDialog called with context: $context'); // showDialogを呼び出す時のcontextをログ出力
    return showDialog(                          
      barrierDismissible: false,
      context: context,
      builder: (_) {
        print('makePermanentAccountShowDialog context: $context'); // ダイアログのBuildContextをログ出力
        return  Scaffold(
          backgroundColor: Colors.transparent,
          body: AlertDialog(
            title: Center(
              child: Text(AppLocalizations.of(context)!.createAccount,
                style: const TextStyle(
                  fontWeight: FontWeight.bold
                ),
              ),
            ),
            content: SingleChildScrollView(
            child: Form(
              // バリデーションの一括管理用のグローバルキー
              key: formKeyTalkRoom,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
              
                  // ■ Subtitle
                  Text(AppLocalizations.of(context)!.requireCreateAccount,
                    style: const TextStyle(
                      fontSize: 15,
                    ),
                  ),
              
                  // ■ E-Mailアドレス入力欄
                  TextFormField(
                    decoration: InputDecoration(
                      icon: const Icon(Icons.mail),
                      hintText: 'sample@chatbus.net',
                      labelText: AppLocalizations.of(context)!.emailAdress,
                    ),
                    onChanged: (String value) {
                      setState(() {
                        email = value;
                      });
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        // 以下のエラー文がTextFieldの直下に表示されます
                        return 'enter your e-mail address';
                      }
                        // null means there is no error
                        return null; 
                    }                                      
                  ),
              
                  // ■ パスワード入力欄
                  TextFormField(
                    obscureText: hidePassword,
                    decoration: InputDecoration(
                      icon: const Icon(Icons.lock),
                      labelText: AppLocalizations.of(context)!.password,
                      suffixIcon: IconButton(
                        icon: Icon(
                          hidePassword ? Icons.visibility_off : Icons.visibility,
                        ),
                        onPressed: () {
                          setState(() {
                            hidePassword = !hidePassword;
                          });
                        },
                      ),
                    ),
                    onChanged: (String value) {
                      setState(() {
                        password = value;
                      });
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty || value.length < 6) {
                        // 以下のエラー文がTextFieldの直下に表示されます
                        return 'Password must be at least 6 characters';
                      }
                      // null means there is no error
                      return null; 
                    },
                  ),
                ],
              ),
            ), 
            ),
          
            actions: [
              TextButton(
                onPressed: () async{
                  // validateメソッドは
                  // フォーム内のすべてのFormFieldのvalidatorを実行し、
                  // 全てがパスすればtrueを、一つでも失敗すればfalseを返します。 
                  if (formKeyTalkRoom.currentState!.validate()) {
                    // アカウントのクリエイトメソッドの実行
                    String? result = await FirebaseAuthentication.upgradeAccountToPermanent(
                      email,
                      password,
                    );
          
                    if (result == 'success') {
                      // アカウント作成できた場合は、
                      // ① 状態変数を永久アカウントである permanent 更新して
                      ref.read(meUserProvider.notifier).updateUserAccountStatus('permanent');
                      // ② db上のFieldを更新して
                      UserFirestore.updateAccountStatusFiled(
                        meUser!.uid,
                        'permanent',
                        );
                      // ③ showDialogを閉じて
                      if (context.mounted) Navigator.pop(context);
                      // ④ stripeの決済画面へ遷移
                      String? result = await CloudFunctions.callCreateCheckoutSession(meUser!.uid);
                      if (context.mounted) StripeCheckout.redirectToCheckout(context, result);
                    } else {
                      if (context.mounted) {
                      print('makePermanentAccountShowDialog context (作成する): $context'); // SnackBar表示時のcontextをログ出力
                      ScaffoldMessenger.of(context).showSnackBar(upgradeToPermanentErrorSnackBar(result));
                      }
                    }
                  }
                },
                child: Text(AppLocalizations.of(context)!.create)
              ),
          
              TextButton(
                onPressed: () {
                  if (context.mounted) Navigator.pop(context);
                },
                child: Text(AppLocalizations.of(context)!.cancel)
              )
            ],
          ),
        );
      }
    );
  }

  SnackBar upgradeToPermanentErrorSnackBar(String? errorResult) {
    return SnackBar(
      duration: const Duration(milliseconds: 2500),
      behavior: SnackBarBehavior.floating,
      margin: const EdgeInsets.all(30),
      content: SizedBox(
        height: 100,
        child: Row(
          children: [
             const Padding(
              padding: EdgeInsets.only(left: 5, right: 20),
                child: Icon(
                  Icons.error_outline_outlined,
                  color: Colors.white,),
            ),
            Flexible(
              child: Padding(
                padding: EdgeInsets.only(right: 10),
                child:
                  Text(AppLocalizations.of(context)!.errorEmailFormat,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: Colors.white,
                  ),),
              ),
            ),
          ],
        ),
      ),
      backgroundColor: const Color.fromARGB(255, 94, 94, 94),
    );
  }

  SnackBar cancelPlanSnackBar(String? result) {
    return SnackBar(
      duration:  const Duration(milliseconds: 2500),
      behavior: SnackBarBehavior.floating,
      margin:  const EdgeInsets.all(30),
      content: SizedBox(
        height: 100,
        child: Row(
          children: [
            Padding(
              padding: EdgeInsets.only(left: 5, right: 20),
              child: result == "canceled"
              ? const Icon(
                  Icons.check_circle_outline_outlined,
                  color: Colors.white,)
              : const Icon(
                  Icons.error_outline_outlined,
                  color: Colors.white,)
            ),
            Flexible(
              child: Padding(
                padding: const EdgeInsets.only(right: 10),
                child:
                  Text( result == "canceled"
                    ? AppLocalizations.of(context)!.doneSwitchFreePlan
                    : result == 'already_canceled'
                      ? AppLocalizations.of(context)!.doneAlreadySwitchFreePlan
                      : AppLocalizations.of(context)!.contactSupport,
                    style:  const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      color: Colors.white,
                    ),
                  ),
              ),
            ),
          ],
        ),
      ),
      backgroundColor: const Color.fromARGB(255, 94, 94, 94),
    );
  }


}

