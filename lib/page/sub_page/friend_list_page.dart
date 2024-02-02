import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:udemy_copy/firestore/room_firestore.dart';
import 'package:udemy_copy/firestore/user_firestore.dart';
import 'package:udemy_copy/riverpod/provider.dart';

class FriendListPage extends ConsumerStatefulWidget {
  const FriendListPage({super.key});

  @override
  ConsumerState<FriendListPage> createState() => _FriendListPageState();
}

class _FriendListPageState extends ConsumerState<FriendListPage> {
  int? selectedFriendIndex;

  @override
  Widget build(BuildContext context) {
   return Scaffold(
    body: Stack(                            //Stackは、childrenに積み重ねて表示させたいウィジェットを下層から順に追加する  //https://coderenkin.com/flutter-stack/
        children: [                           //Stackウィジェットのchildren
          StreamBuilder<QuerySnapshot>(       //？？？？？<QuerySnapshot>の意味は？
            stream: UserFirestore.friendSnapshot(ref.watch(myUidProvider)),  //widgetは、statefulwidgetクラスのプロパティにアクセスするために必要なキーワード
            builder: (context, snapshot) {
              if (snapshot.hasData) {              
                return Padding(
                    padding: const EdgeInsets.only(bottom: 60.0),
                    child: ListView.builder(
                        physics: const RangeMaintainingScrollPhysics(),  //phyisicsがスクロールを制御するプロパティ。画面を超えて要素が表示され始めたらスクロールが可能になるような設定のやり方
                        shrinkWrap: true,                          //表示してるchildrenに含まれるwidgetのサイズにlistviewを設定するやり方
                        reverse: false,                             //スクロールがした始まりで上に滑っていく設定になる
                        itemCount: snapshot.data!.docs.length,
                        itemBuilder: (conxtext, index){    //ListViewの定型パターン

                        /// UIロジックで描画する素材と舞台
                        ///「プロフアイコン」「名前」「国名」「trailingIcon: 友達リストから削除」
                        final doc = snapshot.data!.docs[index];
                        final Map<String, dynamic> talkuserFields = doc.data() as Map<String, dynamic>; //これでオブジェクト型をMap<String dynamic>型に変換

                        /// 最上部のListTileのみ別途調整
                        if (index == 0) {
                          return Column(
                          children: <Widget>[
                                        const Divider(
                                          height: 20,
                                          // thickness: ,
                                          color: Colors.white,
                                          indent: 63,
                                          // endIndent: ,
                                        ),

                                        ListTile(
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
                                          tileColor: selectedFriendIndex == index
                                              ? const Color.fromARGB(255, 225, 225, 225)
                                              : null,
                                          onTap: () {
                                            setState(() {
                                              selectedFriendIndex = index;
                                            });
                                          },
                                        ),

                                        const Divider(
                                          height: 45,
                                          // thickness: ,
                                          color: Color.fromARGB(255, 199, 199, 199),
                                          indent: 63,
                                          // endIndent: ,
                                        ),                                        
                            ]);
                        }
                    


                      return Column(
                          children: <Widget>[
                                        ListTile(
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
                                          tileColor: selectedFriendIndex == index
                                              ? const Color.fromARGB(255, 225, 225, 225)
                                              : null,
                                          onTap: () {
                                            setState(() {
                                              selectedFriendIndex = index;
                                            });
                                          },
                                        ),

                                        const Divider(
                                          height: 45,
                                          // thickness: ,
                                          color: Color.fromARGB(255, 199, 199, 199),
                                          indent: 63,
                                          // endIndent: ,
                                        ),
                            ]);
                        }),
                      );
                  } else {
                    return Center(child: Text('メッセージがありません'),);
              }
            }
           ),
         ],
       ),


    );
  }
}