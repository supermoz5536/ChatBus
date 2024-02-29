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
import 'package:udemy_copy/model/selected_gender.dart';
import 'package:udemy_copy/model/selected_language.dart';
import 'package:udemy_copy/model/talk_room.dart';
import 'package:udemy_copy/model/user.dart';
import 'package:udemy_copy/page/lounge_back_page.dart';
import 'package:udemy_copy/page/matching_progress_page.dart';
import 'package:udemy_copy/riverpod/provider/selected_gender_provider.dart';
import 'package:udemy_copy/riverpod/provider/me_user_provider.dart';
import 'package:udemy_copy/riverpod/provider/selected_language_provider.dart';
import 'package:udemy_copy/riverpod/provider/selected_native_language_provider.dart';
import 'package:udemy_copy/riverpod/provider/target_language_provider.dart';
import 'package:udemy_copy/utils/screen_transition.dart';
import 'package:udemy_copy/utils/service/language_notifier_service.dart';
import 'package:udemy_copy/utils/shared_prefs.dart';
import 'package:udemy_copy/utils/unit_functions.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class MatchedHistoryPage extends ConsumerStatefulWidget {
  final TalkRoom talkRoom;
  const MatchedHistoryPage(this.talkRoom, {super.key});

  @override
  ConsumerState<MatchedHistoryPage> createState() => _MatchedHistoryPageState();
}

class _MatchedHistoryPageState extends ConsumerState<MatchedHistoryPage> {
  Future<User?>? futureTalkuserProfile;
  final _overlayController3rd = OverlayPortalController();
  bool? isDisabledRequest = false;
  bool isFriendRequestExist = false;
  bool isFriendUidExist = false;
  String? longPressedItemId;

  @override
  void initState() {
    super.initState();
    /// アイコンの表示とポップアップ描画に必要な情報のFuture
    futureTalkuserProfile = UserFirestore.fetchProfile(widget.talkRoom.talkuserUid);
  }

  @override
  Widget build(BuildContext context) {
    User? meUser = ref.watch(meUserProvider);
    
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        // elevation: 3,
        // shadowColor: Colors.black.withOpacity(0.7),
        surfaceTintColor: Colors.transparent,
        title: const Text('トーク履歴'),
        centerTitle: true,
        bottom: const PreferredSize(
            preferredSize: Size.fromHeight(0),
            child: Divider(
              color: Color.fromARGB(255, 176, 176, 176),
              indent: 100,
              endIndent: 100,
            )
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
                                      message.translatedMessage == ''
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
                                                             meUser.uid,
                                                             futureSnapshot.data!.uid
                                                           );
                                        
                                        if (isFriendRequestExist == false && isFriendUidExist == false) {
                                          // 登録済みではない場合
                                          // 自他のfriend_requestコレクションに
                                          // リクエストドキュメントを作成する関数を作成

                                          // 相手：pending 
                                          await UserFirestore.setFriendRequestToFriend(
                                            widget.talkRoom.talkuserUid,
                                            meUser.uid,
                                          );
                                          // 自分：waiting
                                          await UserFirestore.setFriendRequestToMe(
                                            meUser.uid,
                                            widget.talkRoom.talkuserUid,
                                          );

                                          setState(() {isFriendRequestExist = true;});
                                          
                                        } else {
                                          setState(() {});
                                          }
                                      },
                                      child: isFriendRequestExist == false && isFriendUidExist == false
                                        ? const Text('友達に追加')
                                        : isFriendRequestExist == true
                                          ? const Text('リクエスト中')
                                          : const Text('既に友達です')
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
}