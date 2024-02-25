import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:udemy_copy/firestore/user_firestore.dart';
import 'package:udemy_copy/model/user.dart';
import 'package:udemy_copy/page/profile_page.dart';
import 'package:udemy_copy/riverpod/provider/me_user_provider.dart';

class FriendListPage extends ConsumerStatefulWidget {
  final User? meUserData;
  const FriendListPage(this.meUserData, {super.key});

  @override
  ConsumerState<FriendListPage> createState() => _FriendListPageState();
}

class _FriendListPageState extends ConsumerState<FriendListPage> {
  Future<List<String?>?>? futureFriendIds;
  QuerySnapshot<Map<String, dynamic>>? snapshot;


  @override
  void initState() {
    super.initState();

    futureFriendIds = UserFirestore.fetchFriendIds(widget.meUserData!.uid);
    futureFriendIds!.then((friendIds) async{
    var tempSnapshot = await UserFirestore.fetchFriendLatestSnapshot(friendIds);
      setState(() {
        // snapshotがFriendListPageのメンバ変数として宣言されてるので
        // setState()はtempSnapshotではなくsnapshotの状態変更を感知する
        // なので、代入して状態値を変更した後に、画面の再描画を行います。
        //
        //要するに、snapshot が状態変数として捉えられるのは、
        //それが Stateクラス内で宣言され、
        //ウィジェットの状態を保持・管理するために使用されているからです。
        //tempSnapshot はその状態変数に
        //非同期処理の結果を割り当てるための中間ステップとして機能します。
        snapshot = tempSnapshot;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    User? meUser = ref.watch(meUserProvider);

   return Scaffold(
    body: Stack(
        children: [                           
          // StreamBuilder<QuerySnapshot>(       
          //   stream: UserFirestore.friendSnapshot(meUser!.uid),
          //   builder: (context, snapshot) {
              if (snapshot != null)            
                // return 
                Padding(
                    padding: const EdgeInsets.only(bottom: 60.0),
                    child: ListView.builder(
                        physics: const RangeMaintainingScrollPhysics(),  //phyisicsがスクロールを制御するプロパティ。画面を超えて要素が表示され始めたらスクロールが可能になるような設定のやり方
                        shrinkWrap: true,                                //表示してるchildrenに含まれるwidgetのサイズにlistviewを設定するやり方
                        reverse: false,                                  //スクロールがした始まりで上に滑っていく設定になる
                        itemCount: snapshot!.docs.length,
                        itemBuilder: (conxtext, index){
                        print('buildウィジェット内 snapshot!.docs.length == ${snapshot!.docs.length}');

                            /// UIロジックで描画する素材と舞台
                            ///「image_path」「名前」「国名」「trailingIcon: 友達リストから削除」
                            /// 画面遷移時に必要なコンストラクタの値: uid
                            final doc = snapshot!.docs[index];
                            final Map<String, dynamic> talkuserFields = doc.data();
                            User user = User(
                                          userName: talkuserFields['user_name'],
                                          uid: doc.id,
                                          userImageUrl: talkuserFields['user_image_url'],
                                          statement: talkuserFields['statement'],
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
                                                                ProfilePage(user)),
                                                        (_) => false);
                                                  }                                              
                                                },
                                                child: SizedBox(
                                                  height: 115,
                                                  child: Center(
                                                    child: ListTile(
                                                      leading: CircleAvatar(
                                                          radius: 30,
                                                          backgroundImage: NetworkImage(talkuserFields['user_image_url'])),
                                                      title: Text(
                                                        talkuserFields['user_name'],
                                                        style: const TextStyle(
                                                          fontSize: 20,
                                                        ),
                                                        ),
                                                      subtitle: const Padding(
                                                        padding: EdgeInsets.only(top: 8.0),
                                                        child: Text(
                                                          '{countryName}',
                                                          style: TextStyle(
                                                            color: Color.fromARGB(255, 176, 176, 176),
                                                            fontSize: 15,
                                                          ),
                                                          ),
                                                      ),
                                                      trailing: const Icon(Icons.remove_circle_outline),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),

                                            const Divider(
                                              height: 0,
                                              // thickness: ,
                                              color: Color.fromARGB(255, 199, 199, 199),
                                              indent: 63,
                                              // endIndent: ,
                                            ),                                        
                                ]);
                        }),
                      ),
                  // } else {
                  //   return 
                    if (snapshot == null)
                      const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Center(child: Text('まだ友達がいません。')),
                          Center(child: Text('チャット相手のアイコンをタップして\n友達リクエストを送りましょう!')),
              //         ],
              //       );
              // }
          //   }
          //  ),
         ],
       ),
      ]
     )
    );
  }
}

