import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:udemy_copy/cloud_storage/user_storage.dart';
import 'package:udemy_copy/constant/language_name.dart';
import 'package:udemy_copy/firestore/dm_room_firestore.dart';
import 'package:udemy_copy/firestore/user_firestore.dart';
import 'package:udemy_copy/model/dm_notification.dart';
import 'package:udemy_copy/model/friend_request_notification.dart';
import 'package:udemy_copy/model/lounge_back.dart';
import 'package:udemy_copy/model/matching_progress.dart';
import 'package:udemy_copy/model/selected_gender.dart';
import 'package:udemy_copy/model/selected_language.dart';
import 'package:udemy_copy/model/talk_room.dart';
import 'package:udemy_copy/model/user.dart';
import 'package:udemy_copy/page/matching_progress_page.dart';
import 'package:udemy_copy/riverpod/provider/dm_notifications_provider.dart';
import 'package:udemy_copy/riverpod/provider/friend__request_notifications_provider.dart';
import 'package:udemy_copy/riverpod/provider/selected_gender_provider.dart';
import 'package:udemy_copy/riverpod/provider/selected_language_provider.dart';
import 'package:udemy_copy/riverpod/provider/selected_native_language_provider.dart';
import 'package:udemy_copy/riverpod/provider/target_language_provider.dart';
import 'package:udemy_copy/utils/custom_length_text_Input_formatter.dart';
import 'package:udemy_copy/utils/screen_functions.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:udemy_copy/riverpod/provider/me_user_provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:udemy_copy/utils/service/dm_notifier_service.dart';
import 'package:udemy_copy/utils/service/friend_request_notifier_service.dart';
import 'package:udemy_copy/utils/service/language_notifier_service.dart';
import 'package:udemy_copy/utils/shared_prefs.dart';
import 'dart:ui' as ui;




class LoungeBackPage extends ConsumerStatefulWidget {
  final LoungeBack? loungeBack;
  const LoungeBackPage(this.loungeBack, {super.key});

  @override
  ConsumerState<LoungeBackPage> createState() => _LoungeBackPageState();
}

class _LoungeBackPageState extends ConsumerState<LoungeBackPage> {

  String? myUid;
  String? currentLanguageCode = ui.window.locale.languageCode;
  String? currentSelectedLanguageCode;
  String? currentTargetLanguageCode;
  String? showDialogGender;
  bool isDisabled = false;
  bool isMydataFutureDone = false;
  bool isGenderSelected = false;
  bool isSelectedLanguage = false;
  User? user;
  User? meUser;
  bool isInputEmpty = true;
  TalkRoom? talkRoom;
  Future<Map<String, dynamic>?>? myDataFuture;
  MatchingProgress? matchingProgress;
  LanguageNotifierService? languageNotifierService;
  DMNotifierService? dMNotifierservice;
  FriendRequestNotifierService? friendRequestNotifierservice;
  int? currentIndex = 0;
  int? selectedBottomIconIndex;
  int? selectedHistoryIndex;
  int? selectedUnreadIndex;
  final _overlayController1st = OverlayPortalController();
  final _overlayController2nd = OverlayPortalController();
  final TextEditingController controller = TextEditingController();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController statementController = TextEditingController();
  StreamSubscription? dMSubscription;
  StreamSubscription? friendRequestSubscription;
  // TextEditingConttrolloerはTextFieldで使うテキスト入力を管理するクラス

  @override
  void initState() {
    super.initState();
    // 追加機能の記述部分であることの明示　
    // 関数の呼び出し（initStateはFlutter標準メソッド）
    // 親クラスの初期化処理
    //「親クラス＝Stateクラス＝_WaitRoomPageState」のinitStateメソッドの呼び出し
    // initState()は、Widget作成時にflutterから自動的に一度だけ呼び出されます。
    // このメソッド内で、widgetが必要とする初期設定やデータの初期化を行うことが一般的
    // initState()とは　https://sl.bing.net/ivIFfFUd6Vo

    currentIndex = widget.loungeBack!.currentIndex;
    talkRoom = TalkRoom(myUid: myUid, roomId: '');
    /// MatchedHistoryPage用のコンストラクタなので
    /// myUidはnullでも問題が起きてない.
  
    // ■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■
    // riverpodが利用できるまでの待機が目的なら
    // Future.delayedの記述の方が適切かもしれない
    // でもWidgetsBindingの方が確実に安全
    // Future.delayed(Duration.zero, () async {
    WidgetsBinding.instance.addPostFrameCallback((_) {

    print('dMNotifierservice == $dMNotifierservice');        
    print('dMNotifierservice == ${meUser!.uid}');        
      // DMの通知リスナー起動
      if (dMNotifierservice != null) {
        print('LoungeBackPage: setupUnreadDMNotification開始');
        dMSubscription = dMNotifierservice!.setupUnreadDMNotification(meUser!.uid);
      }
      // フレンドリクエストの通知リスナー起動
      if (friendRequestNotifierservice != null) {
        print('LoungeBackPage: setupFriendRequestNotification');
        friendRequestSubscription = friendRequestNotifierservice!.setupFriendRequestNotification(meUser!.uid);
      }
    });
    // });
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
            // selectedNativeLanguageの状態変数更新
            ref.read(selectedNativeLanguageProvider.notifier)
              .switchSelectedNativeLanguage(currentLanguageCode);
      },
    );
  }
  

  @override
  void dispose() {
    // DM通知, フレンドリクエスト通知のリスナーを閉じる
    if (dMSubscription != null) dMSubscription!.cancel();
    if (friendRequestSubscription != null) friendRequestSubscription!.cancel();
    // 最後に super.dispose() でリソースの慣習的な解放処理を行う
    super.dispose();
    print('LoungePage: dispose( )の実行完了');
  }


  @override
  Widget build(BuildContext context) {
    meUser = ref.watch(meUserProvider);
    String? targetLanguageCode = ref.watch(targetLanguageProvider);
    SelectedGender? selectedGender = ref.watch(selectedGenderProvider);
    SelectedLanguage? selectedLanguage = ref.watch(selectedLanguageProvider);
    SelectedLanguage? selectedNativeLanguage = ref.watch(selectedNativeLanguageProvider);
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
        leading:  StreamBuilder<DocumentSnapshot>(
                    stream: UserFirestore.streamProfImage(meUser!.uid),
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
                                      image: NetworkImage(snapshot.data!['user_image_url']),
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

        // title: const Text('ラウンジページ'),
        // centerTitle: true,
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
                                              subtitle: Text('${dMNotifications[index]!.lastMessage!}',
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


          // ■ マッチングヒストリーの表示ボタン
          Builder(builder: (context) {
            return IconButton(
              onPressed: () {
                Scaffold.of(context).openEndDrawer();
              },
              icon: const Icon(Icons.contacts_outlined,
                  color: Color.fromARGB(255, 176, 176, 176)),
              iconSize: 27,
              tooltip: AppLocalizations.of(context)!.displayMatchingHistory,
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
              //Expanded で長さを限界値に指定.
              child: ListView(
                children: [
                  SizedBox(
                    height: 380,
                    child: DrawerHeader(
                        child: Column(
                          children: [

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
                                  UserFirestore.updateUserImageUrl(meUser!.uid, newUserImageUrl);
                                  ref.read(meUserProvider.notifier).updateUserImageUrl(newUserImageUrl);
                                },
                                child: const SizedBox(width: 110, height: 110),
                                // InkWellの有効範囲はchildのWidgetの範囲に相当するので
                                // タップの有効領域確保のために、空のSizedBoxを設定
                              ),
                            ),
                          ),

                            // Ink(
                            //   child: InkWell(
                            //     onTap: (){},
                            //     child: CircleAvatar(     
                            //       radius: 50,
                            //       backgroundImage: NetworkImage(
                            //         meUser!.userImageUrl!),
                            //     ),
                            //   ),
                            // ),

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
                                          title: Text(AppLocalizations.of(context)!.changeName),
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
                                                if (context.mounted) Navigator.pop(context);
                                              },
                                              child: Text(AppLocalizations.of(context)!.ok)),
                                            TextButton(
                                              onPressed: () {
                                                if (context.mounted) Navigator.pop(context);                                        
                                              },
                                              child: Text(AppLocalizations.of(context)!.cancel))
                                          ],
                                        );
                                    });
                                  },
                                  child: const Text('変更') 
                                ), 
                            ]),

                            Row(
                              children: [
                                Expanded(
                                  child: ListTile(
                                    title: Text(AppLocalizations.of(context)!.statement),
                                    subtitle: Text('${meUser!.statement}',
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
                                          title: Text(AppLocalizations.of(context)!.changeStatement),
                                          content: TextField(
                                            controller: statementController,
                                            decoration: InputDecoration(
                                              hintText: AppLocalizations.of(context)!.inputNewStatement,
                                              hintStyle: const TextStyle(
                                                color: Color.fromARGB(255, 153, 153, 153)
                                              )
                                            ),
                                            keyboardType: TextInputType.multiline, // キーボードタイプを複数行対応に設定
                                            inputFormatters: [CustomLengthTextInputFormatter(maxCount: 120)],
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
                                                if (context.mounted) Navigator.pop(context);
                                              },
                                              child: Text(AppLocalizations.of(context)!.name)),
                                            TextButton(
                                              onPressed: () {
                                                if (context.mounted) Navigator.pop(context);                                        
                                              },
                                              child: Text(AppLocalizations.of(context)!.cancel))
                                          ],
                                        );
                                    });
                                  },
                                  child: Text(AppLocalizations.of(context)!.cancel) 
                                ), 
                            ]),
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





            Container(
                decoration: const BoxDecoration(
                  border: Border(
                    top: BorderSide(
                        color: Color.fromARGB(255, 199, 199, 199), width: 1.0),
                  ),
                ),
                padding: const EdgeInsets.all(8),
                child: Row(children: [
                  Text(AppLocalizations.of(context)!.subscription),
                ])),


            Container(
                decoration: const BoxDecoration(
                  border: Border(
                    top: BorderSide(
                        color: Color.fromARGB(255, 199, 199, 199), width: 1.0),
                  ),
                ),
                padding: const EdgeInsets.all(8),
                child: Row(children: [
                  Text(AppLocalizations.of(context)!.environmentalSetting),
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
            child: Center(
                child: Text(
              AppLocalizations.of(context)!.headerMatchingHistryDrawer,
              style: const TextStyle(fontSize: 24),
            ))),
                 StreamBuilder<QuerySnapshot>(
                    stream: UserFirestore.streamHistoryCollection(meUser!.uid),
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
                                    dateLabel = AppLocalizations.of(context)!.moreThanOneWeekAgo;
                                  } else if (createdAt.isAfter(oneWeek) &&
                                      createdAt.isBefore(yesterday)) {
                                    dateLabel = AppLocalizations.of(context)!.thisWeek;
                                  } else if (createdAt.isAfter(today) ||
                                      createdAt.isAtSameMomentAs(today)) {
                                    dateLabel = AppLocalizations.of(context)!.today;
                                  } else if (createdAt.isAfter(yesterday) ||
                                      createdAt.isAtSameMomentAs(yesterday)) {
                                    dateLabel = AppLocalizations.of(context)!.yesterday;
                                  }

                                  String prevDateLabel = '';
                                  // グループ処理：index当該リストの1つ前（配置が上）のリストをザルに通す
                                  if (index > 0) {
                                    DateTime prevCreatedAt =
                                        (snapshot.data!.docs[index - 1]
                                                ['created_at'] as Timestamp)
                                            .toDate();

                                    if (prevCreatedAt.isBefore(oneWeek)) {
                                      prevDateLabel = AppLocalizations.of(context)!.moreThanOneWeekAgo;
                                    } else if (prevCreatedAt.isAfter(oneWeek) &&
                                        prevCreatedAt.isBefore(yesterday)) {
                                      prevDateLabel = AppLocalizations.of(context)!.thisWeek;
                                    } else if (prevCreatedAt.isAfter(today) ||
                                        prevCreatedAt.isAtSameMomentAs(today)) {
                                      prevDateLabel = AppLocalizations.of(context)!.today;
                                    } else if (prevCreatedAt
                                            .isAfter(yesterday) ||
                                        prevCreatedAt
                                            .isAtSameMomentAs(yesterday)) {
                                      prevDateLabel = AppLocalizations.of(context)!.yesterday;
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
                                            ? const Color.fromARGB(255, 225, 225, 225)
                                            : null,
                                        onTap: () {
                                          setState(() {
                                            selectedHistoryIndex = index;
                                            currentIndex = 3;
                                            talkRoom!.talkuserUid = talkuserFields['talkuser_id'];
                                            talkRoom!.roomId = talkuserFields['room_id'];
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
                                          ? const Color.fromARGB(255, 225, 225, 225)
                                          : null,
                                      onTap: () {
                                        setState(() {
                                          selectedHistoryIndex = index;
                                          currentIndex = 3;
                                        talkRoom!.talkuserUid = talkuserFields['talkuser_id'];
                                        talkRoom!.roomId = talkuserFields['room_id'];
                                        });
                                      },
                                    );
                                  }
                                }),
                          ),
                        );
                      }
                      return Padding(
                        padding: const EdgeInsets.only(top: 300),
                        child: Text(AppLocalizations.of(context)!.thereIsNoMatchingHistory),
                      );
                    }),
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
                          child: ElevatedButton(
                            onPressed: isDisabled == false
                                ? () async {
                                    setState(() {
                                      isDisabled = true;
                                      // 二重タップ防止.
                                      // trueにして、タップをブロック
                                    });

                                    await Future.delayed(
                                      const Duration(milliseconds: 50), // 無効にする時間
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
                                  }
                                : null,
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
                            tooltip: AppLocalizations.of(context)!.searchPageTooltip,
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
                              AppLocalizations.of(context)!.searchBelowIcon,
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
                            tooltip: AppLocalizations.of(context)!.dMListPageTooltip,
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
                              AppLocalizations.of(context)!.messageBelowIcon,
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
                            tooltip: AppLocalizations.of(context)!.friendListPageTooltip,
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
                              AppLocalizations.of(context)!.friendsBelowIcon,
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
}

