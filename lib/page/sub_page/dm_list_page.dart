import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:udemy_copy/firestore/dm_room_firestore.dart';
import 'package:udemy_copy/model/dm.dart';
import 'package:udemy_copy/model/user.dart';
import 'package:udemy_copy/page/dm_room_page.dart';
import 'package:udemy_copy/riverpod/provider/me_user_provider.dart';

class DMListPage extends ConsumerStatefulWidget {
  final User? meUserData;
  const DMListPage(this.meUserData, {super.key});

  @override
  ConsumerState<DMListPage> createState() => _DMListPageState();
}

class _DMListPageState extends ConsumerState<DMListPage> {
  Future<List<DMRoom>?>?  futureDMRooms;
  StreamSubscription? subscription;

  @override
  void initState() {
    super.initState();
    // streamの参照を作成して、リスナーで変更を監視します
    // 変更取得のたびに、Future として FutureDmrooms が作成されます
    // FutureDmrooms の Futureが解決されるたびに
    // Futurebuilderが起動して、ListViewbuilderが実行されます。
    // UIの動的な再描画はStreambuilderが担っています。
    final stream = DMRoomFirestore.fetchDMSnapshot(widget.meUserData!.uid);
    subscription = stream.listen((snapshot) {
      futureDMRooms = DMRoomFirestore.fetchJoinedDMRooms(widget.meUserData!.uid, snapshot);
    });
  }

  @override
  void dispose() {
    if (subscription != null) subscription!.cancel();
    super.dispose();
  }
  

  @override
  Widget build(BuildContext context) {
    User? meUser = ref.watch(meUserProvider);

    return Scaffold(
        // appBar: AppBar(
        //   title: const Text('data'),
        //   titleTextStyle: const TextStyle(
        //     color: Colors.white, 
        //     fontSize: 20),
        //   backgroundColor: Colors.blue,
        //   ),


        body:StreamBuilder<QuerySnapshot>(
                stream: DMRoomFirestore.fetchDMSnapshot(meUser!.uid),  
                builder: (context, streamSnapshot) {
                  if (streamSnapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());

                  } else if (streamSnapshot.hasError) {
                    return const Text('エラーが発生しました');

                  } else if(streamSnapshot.hasData && streamSnapshot.data!.docs.isNotEmpty) {                 
                    return FutureBuilder<List<DMRoom>?>(
                      future: futureDMRooms,
                      builder: (context, futureSnapshot) {
                        if(futureSnapshot.connectionState == ConnectionState.waiting){
                          return const CircularProgressIndicator();
                        } else {
                          if(futureSnapshot.hasData) {
                            List<DMRoom> dMRooms = futureSnapshot.data!;  //ここでtoalkRoomsを宣言
                            return ListView.builder(            
                                itemCount: dMRooms.length,     
                                itemBuilder: (context, index) {
                                  return Column(
                                    children: <Widget>[

                                                  /// Ink()とMaterial()は互換可能
                                                  /// 使い分けは、SizeBox()とContainer()と同じ考え方でOK
                                                  /// SizeBox() = Ink()
                                                  /// Container() = Material()
                                                  Ink(
                                                    child: InkWell(
                                                      onTap: () async{
                                                        /// 画面遷移に必要なコンストラクタ用を用意して
                                                        DMRoom dMRoom = DMRoom(
                                                          myUid: meUser.uid,
                                                          talkuserUid: dMRooms[index].talkuserUid,
                                                          dMRoomId: dMRooms[index].dMRoomId
                                                        );

                                                        /// DMRoomPageへの画面遷移
                                                        if (context.mounted) {
                                                            Navigator.pushAndRemoveUntil(
                                                                context,
                                                                MaterialPageRoute(
                                                                    builder: (context) =>
                                                                        DMRoomPage(dMRoom)),
                                                                (_) => false);
                                                        }                                            
                                                      },
                                                      child: SizedBox(
                                                        height: 115,
                                                        child: Center(
                                                          child: ListTile(
                                                            leading: CircleAvatar(
                                                                radius: 30,
                                                                backgroundImage: NetworkImage(
                                                                    dMRooms[index]
                                                                  .talkuserProfile!
                                                                  .userImageUrl!
                                                                )),
                                                            title: Text(
                                                                      dMRooms[index]
                                                                      .talkuserProfile!
                                                                      .userName!,
                                                            style: const TextStyle(fontSize: 20,)),
                                                            subtitle: Padding(
                                                              padding: EdgeInsets.only(top: 8.0),
                                                              child: Text(
                                                                /// ?? 演算子を使用して
                                                                /// 左辺の lastMessage == nullの場合に
                                                                /// 右辺の空テキストを使用
                                                                dMRooms[index].lastMessage ?? "",
                                                                style: const TextStyle(
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
                                    },
                                  );
                                } else {
                                return Text('エラーが発生しました');
                                }                    
                        }
                      }
                    );            
                  }else{
                    return const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                          Center(child: Text('まだメッセージがありません。')),
                          Center(child: Text('友達にメッセージを送りましょう!')),
                      ],
                    );
                  }
               }
           ),
       );
   }


}
