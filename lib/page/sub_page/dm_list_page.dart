import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:udemy_copy/firestore/dm_room_firestore.dart';
import 'package:udemy_copy/firestore/room_firestore.dart';
import 'package:udemy_copy/model/dm.dart';
import 'package:udemy_copy/model/talk_room.dart';
import 'package:udemy_copy/model/user.dart';
import 'package:udemy_copy/page/dm_room_page.dart';
import 'package:udemy_copy/riverpod/provider.dart';

class DMListPage extends ConsumerStatefulWidget {
  const DMListPage({super.key});

  @override
  ConsumerState<DMListPage> createState() => _DMListPageState();
}

class _DMListPageState extends ConsumerState<DMListPage> {
// int? selectedDMIndex;

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
                stream: DMRoomFirestore.fetchDMSnapshot(meUser!.myUid),  
                builder: (context, streamSnapshot) {
                  if(streamSnapshot.hasData){

                    /// 事前のFutureBuilder用のFutureを生成
                    /// StreamBuilderは、更新データをリスンし、利用可能になるたびにビルダー関数を再実行します。
                    /// このビルダー関数はAsyncSnapshot<T>型のオブジェクトを引数として受け取ります。
                    /// ここでTはストリームが提供するデータの型です。
                    /// Firestoreの場合、TはQuerySnapshotになります。
                    /// 
                    /// AsyncSnapshotクラスは、非同期操作の現在の状態をカプセル化します。
                    /// 主に以下のプロパティを持っています：
                    /// 
                    /// data：非同期操作から受け取った最新のデータ。
                    /// connectionState：非同期操作の現在の状態
                    /// 　Ex.：ConnectionState.waiting、ConnectionState.doneなど）
                    /// error：非同期操作中に発生したエラー。
                    final Future<List<DMRoom>?> futureDMRooms = DMRoomFirestore
                                                                .fetchJoinedDMRooms(
                                                                  meUser.myUid,
                                                                  streamSnapshot.data
                                                                  );



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
                                                  onTap: (){
                                                    /// 画面遷移に必要なコンストラクタ用を用意して
                                                    /// DMRoomPageへの画面遷移
                                                    if (context.mounted) {
                                                        DMRoom dMRoom = DMRoom(
                                                          myUid: meUser.myUid,
                                                          talkuserUid: dMRooms[index].talkuserUid,
                                                          dMRoomId: dMRooms[index].dMRoomId);

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
                                return Text('トークの取得に失敗しました');
                                }                    
                      }

  
                }
              );            
          }else{
            return CircularProgressIndicator();

         }
      }
     ),
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