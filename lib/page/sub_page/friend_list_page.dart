import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flag/flag_widget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:udemy_copy/firestore/user_firestore.dart';
import 'package:udemy_copy/model/user.dart';
import 'package:udemy_copy/page/profile_page.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';


class FriendListPage extends ConsumerStatefulWidget {
  final User? meUserData;
  const FriendListPage(this.meUserData, {super.key});

  @override
  ConsumerState<FriendListPage> createState() => _FriendListPageState();
}

class _FriendListPageState extends ConsumerState<FriendListPage> {
  Future<List<String?>?>? futureFriendIds;
  Future<QuerySnapshot<Map<String, dynamic>>?>? futureFriendDetails;
  List<String?>? friendIds;
  // QuerySnapshot<Map<String, dynamic>>? snapshot;


  @override
  void initState() {
    super.initState();

    // FutureBuilder用のfutureを事前に宣言
    futureFriendIds = UserFirestore.fetchFriendIds(widget.meUserData!.uid);
    futureFriendIds!.then((friendIds) {
      // 「前のFutureに依存する」FutureBuilder用のfutureを
      // .thenの応答関数を利用して連鎖的に宣言
      futureFriendDetails = UserFirestore.fetchFriendLatestSnapshot(friendIds);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [                           
              // if (snapshot != null)            
                FutureBuilder(
                  future: futureFriendIds,
                  builder: (context, futureFriendIdsSnapshot) {
                    if (futureFriendIdsSnapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (futureFriendIdsSnapshot.hasError) {
                      return Text(AppLocalizations.of(context)!.error);
                    } else {
                      friendIds = futureFriendIdsSnapshot.data!;
                    }

                    return FutureBuilder(
                      future: futureFriendDetails,
                      builder: (context, futureFriendDetailsSnapshot) {
                        if (futureFriendDetailsSnapshot.connectionState == ConnectionState.waiting) {
                          return const Center(child: CircularProgressIndicator());
                        } else if (futureFriendDetailsSnapshot.hasError) {
                          return Text(AppLocalizations.of(context)!.error);
                        } else if (futureFriendDetailsSnapshot.hasData) {

                        
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 60.0),
                          child: ListView.builder(
                              physics: const RangeMaintainingScrollPhysics(),  //phyisicsがスクロールを制御するプロパティ。画面を超えて要素が表示され始めたらスクロールが可能になるような設定のやり方
                              shrinkWrap: true,                                //表示してるchildrenに含まれるwidgetのサイズにlistviewを設定するやり方
                              reverse: false,                                  //スクロールがした始まりで上に滑っていく設定になる
                              itemCount: futureFriendDetailsSnapshot.data!.docs.length,
                              itemBuilder: (conxtext, index){
                        
                                  /// UIロジックで描画する素材と舞台
                                  ///「image_path」「名前」「国名」「trailingIcon: 友達リストから削除」
                                  /// 画面遷移時に必要なコンストラクタの値: uid
                                  final doc = futureFriendDetailsSnapshot.data!.docs[index];
                                  final Map<String, dynamic> talkuserFields = doc.data();
                                  User talkuserData = User(
                                                        userName: talkuserFields['user_name'],
                                                        uid: doc.id,
                                                        userImageUrl: talkuserFields['user_image_url'],
                                                        statement: talkuserFields['statement'],
                                                        country: talkuserFields['country'],
                                                      );
                                  
                                    return Column(
                                      children: <Widget>[
                        
                                                  /// Ink()とMaterial()は互換可能
                                                  /// 使い分けは、SizeBox()とContainer()と同じ考え方でOK
                                                  /// SizeBox() = Ink()
                                                  /// Container() = Material()
                                                  Ink(
                                                    child: InkWell(
                                                      onTap: (){
                                                        /// uidに該当するProfilePageへの画面遷移の処理
                                                        /// コンストラクタの値に何が必要か？
                                                        /// imagePath, user_name, 自己紹介文, が必要
                                                        /// uidをコンストラクタで渡せば
                                                        /// ProfilePage で まず変数を宣言して
                                                        /// initState()でfield情報を取得して、代入
                                                        /// UIロジックで使用すればいい
                                                        /// つまりこの部分で記述が必要なのか
                                                        /// 表示対象のuidをコンストラクタとして渡す画面遷移の記述
                                                        if (context.mounted) {
                                                          Navigator.pushAndRemoveUntil(
                                                              context,
                                                              MaterialPageRoute(
                                                                  builder: (context) =>
                                                                      ProfilePage(talkuserData)),
                                                              (_) => false);
                                                        }                                              
                                                      },
                                                      child: 
                                                      SizedBox(
                                                        height: 115,
                                                        width: MediaQuery.of(context).size.width,
                                                        child: Row(
                                                          crossAxisAlignment: CrossAxisAlignment.center,
                                                          children: [
                                                            
                                                            Padding(
                                                              padding: const EdgeInsets.only(
                                                                left: 15,
                                                                right: 15,
                                                              ),
                                                              child: CircleAvatar(
                                                                radius: 35,
                                                                backgroundImage: NetworkImage(talkuserFields['user_image_url'])),
                                                            ),
                                                        
                                                            Column(
                                                              crossAxisAlignment: CrossAxisAlignment.start,
                                                              children: [
                                                                Padding(
                                                                  padding: const EdgeInsets.only(top: 20),
                                                                  child: Text(
                                                                    talkuserFields['user_name'],
                                                                    style: const TextStyle(
                                                                      fontSize: 20,
                                                                    ),
                                                                  ),
                                                                ),
                                                        
                                                                Padding(
                                                                  padding: const EdgeInsets.only(
                                                                    top: 8,
                                                                  ),
                                                                  child: Container(
                                                                    height: 30,
                                                                    width: 45,
                                                                    decoration: BoxDecoration(
                                                                      border: Border.all(
                                                                        color: Color.fromARGB(255, 138, 138, 138),
                                                                        width: 1,
                                                                      )
                                                                    ),
                                                                    child: Flag.fromString(
                                                                      talkuserFields['country'],
                                                                      fit:BoxFit.fill,
                                                                    ),
                                                                  ),
                                                                )
                                                        
                                                              ],
                                                            ),
                                                        
                                                                 Expanded(
                                                                   child: Align(
                                                                    alignment: Alignment.centerRight,
                                                                     child: Padding(
                                                                       padding: const EdgeInsets.only(right:30),
                                                                       child: IconButton(
                                                                        onPressed: () {},
                                                                         icon: const Icon(
                                                                          Icons.add_circle_outline,
                                                                          color: Colors.grey,
                                                                          size: 30,
                                                                         ),
                                                                         tooltip: 'Comming soon!',
                                                                       ),
                                                                     ),
                                                                   ),
                                                                 ),
                                                          ],
                                                        ),
                                                      ),

                                                    ),
                                                  ),
                        
                                                  const Divider(
                                                    height: 0,
                                                    // thickness: ,
                                                    color: Color.fromARGB(255, 199, 199, 199),
                                                    indent: 99,
                                                    // endIndent: ,
                                                  ),                                        
                                      ]);
                              }),
                              );
                      } else {
                        return Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Center(child: Text(AppLocalizations.of(context)!.thereIsNoFriend)),
                            Center(child: Text(AppLocalizations.of(context)!.sendRequestToYourChatPartner)),
                          ],
                        );
                      }       
                      }
                    );
                  }
                ),
      ]
     )
    );
  }
}

