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
  User? meUser;
  Future<QuerySnapshot<Object?>>? futureStreamFirstSnapshot;
  Future<List<DMRoom>?>? futureDMRooms;
  
  @override
  void initState() {
    super.initState();

      futureStreamFirstSnapshot = DMRoomFirestore
                                    .fetchDMSnapshot(widget.meUserData!.uid)
                                    .first;
      // futureStreamFirstSnapshot!.then((StreamFirstSnapshot) async{
      //  var tempDMRooms = await DMRoomFirestore
      //                     .fetchJoinedDMRooms(
      //                         meUser!.uid,
      //                         StreamFirstSnapshot,
      //                     );
      // });
  }

  @override
  Widget build(BuildContext context) {
    meUser = ref.watch(meUserProvider);

    return Scaffold(
        // appBar: AppBar(
        //   title: const Text('data'),
        //   titleTextStyle: const TextStyle(
        //     color: Colors.white, 
        //     fontSize: 20),
        //   backgroundColor: Colors.blue,
        //   ),


        body:

                       FutureBuilder<QuerySnapshot<Object?>?>(
                        future: futureStreamFirstSnapshot,
                        builder: (context, futureSnapshot) {
                          if(futureSnapshot.connectionState == ConnectionState.waiting){
                            return const CircularProgressIndicator();
                          } else if (futureSnapshot.hasError) {
                            return const Text('エラーが発生しました');
                          } else {
                          // if(futureSnapshot.hasData) {

                            return 
                            StreamBuilder<QuerySnapshot>(
                                    stream: DMRoomFirestore.fetchDMSnapshot(meUser!.uid),  
                                    builder: (context, streamSnapshot) {
                                      if(streamSnapshot.hasData && streamSnapshot.data!.docs.isNotEmpty) {
                                        var streamSnapshotData = streamSnapshot.data;

                                        
                                        DMRoomFirestore.fetchJoinedDMRooms(
                                          meUser!.uid,
                                          streamSnapshotData,
                                        ).then((result) {
                                        List<DMRoom> dMRooms = result!;
                                  
                                      
                                    
                                    
                                    return                    
                                    ListView.builder(            
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
                                                      myUid: meUser!.uid,
                                                      talkuserUid: dMRooms[index].talkuserUid,
                                                      dMRoomId: dMRooms[index].dMRoomId
                                                    );

                                                    // db上のmyUidの未読フラグを削除して
                                                    await DMRoomFirestore.removeIsReadElement(
                                                      dMRoom.dMRoomId,
                                                      meUser!.uid
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
                                        });
                              }else{
                              return const Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Center(child: Text('まだメッセージがありません。')),
                                                Center(child: Text('友達にメッセージを送りましょう!')),
                                    ],
                                  );
                                  }
                                  return Text('トークの取得に失敗しました');
                            }
                        );


                                // } else {
                                // return Text('トークの取得に失敗しました');
                                // }                    
                          }
                        }
                      ),         
          //           }else{
          //           return const Column(
          //             mainAxisAlignment: MainAxisAlignment.center,
          //             children: [
          //                Center(child: Text('まだメッセージがありません。')),
          //                Center(child: Text('友達にメッセージを送りましょう!')),
          //             ],
          //           );
          //           }
          //      }
          //  ),
       );
   }


}





                          // return Column(
                          // children: <Widget>[

                          //               Ink(
                          //                 child: InkWell(
                          //                   child: SizedBox(
                          //                     height: 115,
                          //                     child: ListTile(
                          //                       leading: CircleAvatar(
                          //                           radius: 30,
                          //                           backgroundImage: NetworkImage(
                          //                              dMRooms[index]
                          //                             .talkuserProfile!
                          //                             .userImageUrl!
                          //                             )),
                          //                       title: Text(
                          //                              dMRooms[index]
                          //                             .talkuserProfile!
                          //                             .userName!,
                          //                         style: const TextStyle(
                          //                           fontSize: 20,
                          //                         ),
                          //                         ),
                          //                       subtitle: const Padding(
                          //                         padding: EdgeInsets.only(top: 8.0),
                          //                         child: Text(
                          //                           '{countryName}',
                          //                           style: TextStyle(
                          //                             color: Color.fromARGB(255, 176, 176, 176),
                          //                             fontSize: 15,
                          //                           ),
                          //                           ),
                          //                       ),
                          //                       trailing: const Icon(Icons.remove_circle_outline),
                          //                     ),
                          //                   ),
                          //                 ),
                          //               ),
                                 
                          //   ]);