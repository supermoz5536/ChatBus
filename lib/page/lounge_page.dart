import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart';
import 'package:udemy_copy/analytics/custom_analytics.dart';
import 'package:udemy_copy/authentication/auth_service.dart';
import 'package:udemy_copy/cloud_functions/functions.dart';
import 'package:udemy_copy/cloud_storage/user_storage.dart';
import 'package:udemy_copy/map_value/language_name.dart';
import 'package:udemy_copy/firestore/dm_room_firestore.dart';
import 'package:udemy_copy/firestore/user_firestore.dart';
import 'package:udemy_copy/model/dm_notification.dart';
import 'package:udemy_copy/model/friend_request_notification.dart';
import 'package:udemy_copy/model/lounge.dart';
import 'package:udemy_copy/model/matching_progress.dart';
import 'package:udemy_copy/model/selected_gender.dart';
import 'package:udemy_copy/model/selected_language.dart';
import 'package:udemy_copy/model/talk_room.dart';
import 'package:udemy_copy/model/user.dart';
import 'package:udemy_copy/page/log_in_page.dart';
import 'package:udemy_copy/page/matching_progress_page.dart';
import 'package:udemy_copy/riverpod/provider/dm_notifications_provider.dart';
import 'package:udemy_copy/riverpod/provider/friend__request_notifications_provider.dart';
import 'package:udemy_copy/riverpod/provider/mode_name_provider.dart';
import 'package:udemy_copy/riverpod/provider/selected_gender_provider.dart';
import 'package:udemy_copy/riverpod/provider/selected_language_provider.dart';
import 'package:udemy_copy/riverpod/provider/selected_native_language_provider.dart';
import 'package:udemy_copy/riverpod/provider/target_language_provider.dart';
import 'package:udemy_copy/stripe/stripe_checkout.dart';
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


class LoungePage extends ConsumerStatefulWidget {
  final Lounge lounge;
  const LoungePage(this.lounge, {super.key});

  @override
  ConsumerState<LoungePage> createState() => _LoungePageState();
}

class _LoungePageState extends ConsumerState<LoungePage> {

  String? myUid;
  String? currentLanguageCode = ui.window.locale.languageCode;
  String? currentSelectedLanguageCode;
  String? currentTargetLanguageCode;
  String? showDialogGender;
  String? currentMode;
  String email = '';
  String password = '';
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  bool hidePassword = true;
  bool isDisabled = false;
  bool isMydataFutureDone = false;
  bool isGenderSelected = false;
  bool isSelectedLanguage = false;
  User? user;
  User? meUser;
  bool isInputEmpty = true;
  TalkRoom? talkRoom = TalkRoom(myUid: '', roomId: '');
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
  final TextEditingController nameController = TextEditingController();
  final TextEditingController showDialogNameController = TextEditingController();
  final TextEditingController statementController = TextEditingController();
  StreamSubscription? dMSubscription;
  StreamSubscription? friendRequestSubscription;
  GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();
  // TextEditingConttrolloerはTextFieldで使うテキスト入力を管理するクラス

  @override
  void initState() {
    super.initState();
    // 追加機能の記述部分であることの明示　
    // 親クラスの初期化処理
    //「親クラス＝Stateクラス＝_WaitRoomPageState」のinitStateメソッドの呼び出し
    
    CustomAnalytics.logLoungePageIn();

    // ■ 初期化処理を終えていて、他のページから画面遷移してきている場合の処理
    //（main.dart と LogInPage を除いたクラスからの画面遷移）
    if (widget.lounge.afterInitialization!) {
      // AppBar > leading の FutureBuilderをトリガーするために
      // ダミーのFutureで即解決させる
      myDataFuture = Future.value();
      isMydataFutureDone = true;

      // ProfilePage と DMRoomPage から画面遷移した時に
      // Searchタブが表示されないための固定フラグ
      currentIndex = widget.lounge.currentIndex;

      WidgetsBinding.instance.addPostFrameCallback((_) {
        // DMの通知リスナー起動
        if (dMNotifierservice != null) {
          dMSubscription = dMNotifierservice!.setupUnreadDMNotification(meUser!.uid);
        }
        // フレンドリクエストの通知リスナー起動
        if (friendRequestNotifierservice != null) {
          friendRequestSubscription = friendRequestNotifierservice!.setupFriendRequestNotification(meUser!.uid);
        }
        // ■■■■■　currentIndexをコンストラクタで更新する必要があるかも　■■■■■
        // そうしないとPrfilePageとDMRoomPageから画面遷移のたびに
        // SearchPageに戻ってしまう可能性がある
      });

    // ■ これから初期化処理を行う場合
    //（main.dart もしくは LogInPageからの画面遷移）
    } else {
      String? sharedPrefesInitMyUid = Shared_Prefes.fetchUid();
      if (sharedPrefesInitMyUid == null) showDialogWhenReady();
      if (sharedPrefesInitMyUid != null 
      && widget.lounge.showDialogAble == true) showDialogWhenReady();

      myDataFuture = UserFirestore.getAccount(); 
      /// ① initState関数の中は、.then関数で同期化して対応 → すぐ下の行
      /// ② Build関数の中は、FutureBuilderで同期化して対応 → Drawer内のStream処理

      myDataFuture!.then((result) { 
        if (result != null && mounted) {
            isMydataFutureDone = true;
            user = User(
                      uid: result['myUid'],
                      userName: result['userName'], 
                      userImageUrl: result['userImageUrl'],
                      statement: result['statement'],
                      language: result['language'],
                      country: result['country'],
                      nativeLanguage: [result['native_language']],
                      gender: result['gender'],
                      accountStatus: result['account_status'],
                      subscriptionPlan: result['subscription_plan'],
                    );

          // MeUserProvider の状態変数を更新
          ref.read(meUserProvider.notifier).setUser(user);

          // App表示言語：現在選択中のアイテム名をUIに反映
          // setState()がなくても他の描画プロセスが関連して
          // UIが反映されるが、一応setState()を記述しておく。
          setState(() {
            currentLanguageCode = result['language'];
          });     

          // TargetLanguageProvider の状態変数を更新
          // 起動時に、App表示言語と一致させてあげるユーザーフレンドリー
          // targetLanguageのdropdownMenuのvalueに
          // 'zh_TW'はないので
          // その場合は更新せず、初期値の'en'が設定される        
          if (result['language'] != 'zh_TW') {
          ref.read(targetLanguageProvider.notifier).setTargetLanguage(result['language']);
          }   

          // 'isNewUser'のフィールドがある場合：キャッシュにIDはあったが
          // dbに該当するドキュメントがなかった場合なので.
          // 新規IDするから、Showdialogを表示する
          // しかし、db側でドキュメントIDを削除した場合のみ発生するケース
          if (result['isNewUser'] != null && sharedPrefesInitMyUid != null) showDialogWhenReady();

          // DMの通知リスナー起動
          if (dMNotifierservice != null) {
          dMSubscription = dMNotifierservice!.setupUnreadDMNotification(result['myUid']);
          }

          // フレンドリクエストの通知リスナー起動
          if (friendRequestNotifierservice != null) {
          friendRequestSubscription = friendRequestNotifierservice!.setupFriendRequestNotification(result['myUid']);
          }
        }
      });
    }
  }

  void showDialogWhenReady() {
      WidgetsBinding.instance.addPostFrameCallback((_) {
      showDialog(
        barrierDismissible: false,
        context: context,
        builder: (context) {
          return StatefulBuilder(
            // 第二引数は「StatefulBuilderが提供するsetState関数」を
            // 利用するための引数として使用します。
            builder: (context, setState) {
              showDialogNameController.addListener(() {setState((){});});
                return AlertDialog(
                  title: Center(
                    child: Text(AppLocalizations.of(context)!.beforeStart,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold
                      ),
                    )),
                    content: SingleChildScrollView(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,                  
                        children: [
                          Text(
                            AppLocalizations.of(context)!.setBelow,
                            style: const TextStyle(
                              fontSize: 15,
                            ),
                            ),
                          Row(    
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,                
                            children: [
                              // ■ 左縦列
                              Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children:[
                                  const SizedBox(height: 30),
                                  Text(
                                    AppLocalizations.of(context)!.gender,
                                    style: const TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold
                                    ),),
                                  const SizedBox(height: 20),
                                  // Center(
                                  //   child: Text(
                                  //     AppLocalizations.of(context)!.learningLanguage,
                                  //     textAlign: TextAlign.center,
                                  //     style: const TextStyle(
                                  //       fontSize: 15,
                                  //       fontWeight: FontWeight.bold
                                  //     ),),
                                  // ),
                                  // const SizedBox(height: 20),
                                  Text(
                                    AppLocalizations.of(context)!.name,
                                    style: const TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold
                                    ),),
                                ]),
                                
                                          
                              // ■ 右縦列
                              Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  // const SizedBox(height: 50),  
                                  Row(
                                    children: [
                                      IconButton(
                                        icon: Icon(
                                          Icons.face_outlined,
                                          size: 40,
                                          color: showDialogGender == 'male' ? Colors.lightBlue
                                                                            : Colors.grey),
                                        onPressed: () {
                                          setState(() {
                                            showDialogGender = 'male';
                                            isGenderSelected = true;
                                          });
                                        },
                                      ),
                          
                                      IconButton(
                                        icon: Icon(
                                          Icons.face_2,
                                          size: 35,
                                          color: showDialogGender == 'female' ? Colors.lightBlue
                                                                              : Colors.grey),
                                        onPressed: () {
                                          setState(() {
                                            showDialogGender = 'female';
                                            isGenderSelected = true;
                                          });
                                        },
                                      ),
                                    ],
                                  ),
                      
                                  // const SizedBox(height: 20),  
                                  // dropdownButtonAppLanguage(setState),
                                  const SizedBox(height: 10),  
                                  // dropdownButtonSelectedLanguage(setState),
                                  // const SizedBox(height: 30),  
                                  SizedBox(
                                    height: 20,
                                    width: 150,
                                    child: TextField(
                                      controller: showDialogNameController,
                                      decoration: InputDecoration(
                                        hintText: AppLocalizations.of(context)!.inputName,
                                        hintStyle: const TextStyle(
                                          color: Color.fromARGB(255, 153, 153, 153)
                                        ),
                                      ),
                                      textAlign: TextAlign.center,
                                      keyboardType: TextInputType.multiline, // キーボードタイプを複数行対応に設定
                                      maxLines: 1, 
                                      inputFormatters: [CustomLengthTextInputFormatter(maxCount: 16)],
                                    ),
                                  ),
                                ],
                              ),
                          
                          ]),
                          const SizedBox(height: 25),

                          RichText(
                            text: TextSpan(
                              children: [
                                TextSpan(
                                  text: AppLocalizations.of(context)!.alreadyRegistered,
                                  style: const TextStyle(
                                    color: Color.fromARGB(255, 27, 26, 26)
                                  )),
                                const WidgetSpan(child: SizedBox(width: 4)),
                                // カスケード記法（..）を使用
                                // = が挟まっているのは
                                // TapGestureRecognizerクラスに onTap プロパティがあるので
                                // その値として応答関数を代入してる
                                TextSpan(
                                  text: AppLocalizations.of(context)!.login,
                                  style: const TextStyle(
                                    color: Colors.deepPurple
                                  ),
                                  recognizer: TapGestureRecognizer()
                                    ..onTap = () {
                                      if (context.mounted) {
                                        Navigator.pushAndRemoveUntil(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                              const LogInPage()
                                          ),
                                          (_) => false);
                                      }
                                    }
                                ),
                              ]
                            )
                          ),
                        ],
                      ),
                    ),
                
                  actions: [
                    TextButton(
                      // Futureの解決までロック.
                      onPressed: () async{
                                    if (isMydataFutureDone == true
                                    && isGenderSelected == true
                                    // && isSelectedLanguage == true
                                    && showDialogNameController.text.isNotEmpty) {
                                      await UserFirestore.updateGender(meUser!.uid, showDialogGender);
                                      await UserFirestore.updateUserName(meUser!.uid, showDialogNameController.text);
                                      ref.read(meUserProvider.notifier).updateUserName(showDialogNameController.text);
                                      if (context.mounted) Navigator.pop(context);
                                    }  
                                },
                      child: Text(AppLocalizations.of(context)!.ok,
                        style: TextStyle(
                          color: isMydataFutureDone == true
                              && isGenderSelected == true
                              // && isSelectedLanguage == true
                              && showDialogNameController.text.isNotEmpty
                                  ? Colors.blueAccent
                                  : Colors.grey
                        ),
                      ),
                    ),
                  ],
                );
            }
          );
        });
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
  

  DropdownButton<String> dropdownButtonSelectedLanguage(StateSetter setState) {
    return DropdownButton(
      isDense: true,
      underline: Container(
        height: 1,
        color: const Color.fromARGB(255, 198, 198, 198),),
      icon: const Icon(Icons.keyboard_arrow_down_outlined),
      iconEnabledColor: const Color.fromARGB(255, 187, 187, 187),
      value: currentSelectedLanguageCode,
      items: <String>['en', 'ja', 'es', 'ko','zh'].map<DropdownMenuItem<String>>((String value) {
          return DropdownMenuItem<String>(
            value: value,   //引数の言語コードをシステム識別用に設定
            child: Text(
              languageNames[value]!,
              style: const TextStyle(color: Colors.black)));
          }).toList(),
      onChanged: (String? newSelectedLanguageCode) {
          setState(() {
            currentSelectedLanguageCode = newSelectedLanguageCode!;
            isSelectedLanguage = true;
          });
            // selectedLanguageの状態変数更新
            ref.read(selectedLanguageProvider.notifier)
              .switchSelectedLanguage(currentSelectedLanguageCode);
      },
    );
  }


  // disposeメソッドをオーバーライド
  @override
  void dispose() {
    if (dMSubscription != null) dMSubscription!.cancel();
    if (friendRequestSubscription != null) friendRequestSubscription!.cancel();
    showDialogNameController.removeListener(() {setState((){});});
    showDialogNameController.dispose();
    nameController.dispose();
    statementController.dispose();
    super.dispose();
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
    currentMode = ref.watch(modeNameProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 3,
        shadowColor: Colors.black.withOpacity(0.7),
        surfaceTintColor: Colors.transparent,
        leading: FutureBuilder(
            future: myDataFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const CircularProgressIndicator();
              } else if (snapshot.hasError) {
                return Text(AppLocalizations.of(context)!.error);
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
                                      image: NetworkImage(meUser!.userImageUrl!),
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


          // ■ マッチングヒストリーの表示ボタン
          // Builderウィジェットで祖先のScaffoldを包括したcontextを取得
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

                  const Expanded(
                    child: ListTile(
                      title: Text('subscription'),
                    ),
                  ),

                  // ■ プラン選択 
                  Padding(
                    padding: const EdgeInsets.only(right: 20),
                    child: ElevatedButton(
                      onPressed: () {

                        showModalBottomSheet(
                          backgroundColor: Colors.white,
                          isScrollControlled: true,
                          context: context,
                          builder: (_) {
                            // この Scaffold と ScaffoldMessenger は
                            // confirmCancelPlan に応答するSnackBarの参照用
                            return ScaffoldMessenger(
                              key: scaffoldMessengerKey,
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
                                                    child: Text('料金プラン',
                                                      style: TextStyle(
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
                                                icon: Icon(Icons.close,
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
                                      Container(
                                        width: MediaQuery.of(context).size.width * 0.8,
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
                                            Text('フリー',
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 25,
                                                fontWeight: FontWeight.bold
                                              ),
                                            ),
                                                                
                                            // ■ 価格表示
                                            Text('0\$ / 月',
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
                                                          '無料で利用することができますが、いくつかの機能が制限されます。',
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
                                                            'ジェンダーフィルターと無制限の翻訳機能を利用できます。',
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
                                                              text: '全てのプランで利用可能\n',
                                                              style: TextStyle(                                                                
                                                                fontWeight: FontWeight.bold)),
                                                            TextSpan(
                                                              text: 'フレンド登録、ダイレクトメッセージ、マッチングヒストリー、プロフィール機能、等々。',
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
                                                          child: const Text('プランを選択')
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
                                                      child: const Text('プランを選択',
                                                        style: TextStyle(
                                                          fontWeight: FontWeight.bold
                                                        ),
                                                      )
                                                ),
                                            )
                                          ],
                                        ),
                                      ),
                                                                
                                      const SizedBox(height: 30),
                                                                
                                      // ■ Premiumプラン説明
                                      Container(
                                        width: MediaQuery.of(context).size.width * 0.8,
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
                                            Text('プレミアム',
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 25,
                                                fontWeight: FontWeight.bold
                                              ),
                                            ),
                                                                                                
                                            // ■ 価格表示
                                            Text('5\$ / 月',
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
                                                          '制限なく全ての機能を利用することができるプランです。',
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
                                                          'ジェンダーフィルターと無制限の翻訳機能を利用できます。',
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
                                                              text: '全てのプランで利用可能\n',
                                                              style: TextStyle(                                                                
                                                                fontWeight: FontWeight.bold)),
                                                            TextSpan(
                                                              text: 'フレンド登録、ダイレクトメッセージ、マッチングヒストリー、プロフィール機能、等々。',
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
                                                          child: const Text('プランを選択')
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
                                                      child: const Text('プランを選択',
                                                        style: TextStyle(
                                                          fontWeight: FontWeight.bold
                                                        ),
                                                      )
                                                ),
                                            )
                                          ],
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
                      },
                      child: const Text('現在のプラン名'),
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
                padding: const EdgeInsets.all(8),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('環境設定部分')
                ])
            ),               
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
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold),
            ))),
        FutureBuilder(
            future: myDataFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const CircularProgressIndicator();
              } else if (snapshot.hasError) {
                return Text(AppLocalizations.of(context)!.error);
              } else {
                return StreamBuilder<QuerySnapshot>(
                    stream: UserFirestore.streamHistoryCollection(snapshot.data!['myUid']),
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
                                    } else if (prevCreatedAt.isAfter(yesterday) ||
                                        prevCreatedAt.isAtSameMomentAs(yesterday)) {
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
                                            ? Color.fromARGB(255, 225, 225, 225)
                                            : null,
                                        onTap: () {
                                          setState(() {
                                            selectedHistoryIndex = index;
                                            currentIndex = 3;
                                            talkRoom!.myUid = meUser!.uid;
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
                                          ? Color.fromARGB(255, 225, 225, 225)
                                          : null,
                                      onTap: () {
                                        setState(() {
                                          selectedHistoryIndex = index;
                                          currentIndex = 3;
                                          talkRoom!.myUid = meUser!.uid;
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
                          child: ElevatedButton(
                            onPressed: isDisabled == false && isMydataFutureDone == true
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
                                      List<String?>? selectedLanguageList = SelectedLanguage.getSelectedLanguageTrueItem(
                                                                              selectedLanguage,
                                                                              currentMode
                                                                            );
                                      List<String?>? selectedNativeLanguageList =SelectedLanguage.getSelectedNativeLanguageTrueItem(
                                                                                    selectedNativeLanguage,
                                                                                    currentMode
                                                                                  );
                                      String? selectedGenderTrueItem = 
                                        SelectedGender.getSelectedGenderTrueItem(selectedGender);

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

  Future<dynamic> confirmCancelPlan(BuildContext context) {
    // print('showDialog called with context: $context'); // showDialogを呼び出す時のcontextをログ出力
 
    return showDialog(
      barrierDismissible: false,
      context: context,
      builder: (_) {

        return AlertDialog(
            title: const Center(
              child: Text('本当にフリープランに切り替えますか？',
                style: TextStyle(
                  fontWeight: FontWeight.bold
                ),
              ),
            ),
            content: const Text('切り替えた後も、引き続きpremiumプランは期間終了まで利用できます'),
            actions: [
        
              TextButton(
                    onPressed: () async{
                      // premium → free のプランの切り替え処理を行う
                      String? result = await CloudFunctions.callUpdateCancelAtPeriodEnd(meUser!.uid);
                      // scaffoldKeyを通じてScaffoldStateにアクセスする
                      // scaffoldKey が参照する Scaffold が mounted かを確認
                      // 参照先 Scaffold は showModalBottomSheet の直下
                      if (scaffoldMessengerKey.currentState?.mounted ?? false) {
                        scaffoldMessengerKey.currentState?.showSnackBar(cancelPlanSnackBar(result));
                      }
                      if (context.mounted) Navigator.pop(context);
                    },
                    child: const Text('はい')
                  ),
        
          
              TextButton(
                onPressed: () {
                  print('Close dialog context (no): $context'); // ダイアログ閉じる操作のcontextをログ出力
                  if (context.mounted) Navigator.pop(context);
                },
                child: const Text('いいえ')
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
            title: const Center(
              child: Text('アカウントを作成',
                style: TextStyle(
                  fontWeight: FontWeight.bold
                ),
              ),
            ),
            content: SingleChildScrollView(
            child: Form(
              // バリデーションの一括管理用のグローバルキー
              key: formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
              
                  // ■ Subtitle
                  const Text('プレミアムの登録には、アカウントの作成が必要です。',
                    style: TextStyle(
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
                  if (formKey.currentState!.validate()) {
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
                child: const Text('作成する')
              ),
          
              TextButton(
                onPressed: () {
                  if (context.mounted) Navigator.pop(context);
                },
                child: const Text('キャンセル')
              )
            ],
          ),
        );
      }
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


  SnackBar upgradeToPermanentErrorSnackBar(String? errorResult) {
    return const SnackBar(
      duration:  Duration(milliseconds: 2500),
      behavior: SnackBarBehavior.floating,
      margin:  EdgeInsets.all(30),
      content: SizedBox(
        height: 100,
        child: Row(
          children: [
             Padding(
              padding: EdgeInsets.only(left: 5, right: 20),
                child: Icon(
                  Icons.error_outline_outlined,
                  color: Colors.white,),
            ),
            Flexible(
              child: Padding(
                padding: EdgeInsets.only(right: 10),
                child:
                  Text('Emailの形式が正しくありません。',
                  style:  TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: Colors.white,
                  ),),
              ),
            ),
          ],
        ),
      ),
      backgroundColor: Color.fromARGB(255, 94, 94, 94),
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
            const Padding(
            padding: EdgeInsets.only(left: 5, right: 20),
              child: Icon(
                Icons.error_outline_outlined,
                color: Colors.white,),
            ),
            Flexible(
              child: Padding(
                padding: const EdgeInsets.only(right: 10),
                child:
                  Text( result == "canceled"
                    ? 'プランの切り替え処理が完了しました。Premiumプランの期間終了日にFreeプランへ切り替わります'
                    : result == 'already_canceled'
                      ? 'プランの切り替え処理は既に完了しています。Premiumプランの期間終了日にFreeプランへ切り替わります'
                      : 'システムエラーです。運営に問い合わせてください。',
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
      backgroundColor: Color.fromARGB(255, 94, 94, 94),
    );
  }



}


