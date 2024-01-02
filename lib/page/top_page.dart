// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/material.dart';
// import 'package:udemy_copy/firestore/room_firestore.dart';
// import 'package:udemy_copy/model/talk_room.dart';
// import 'talk_room_page.dart';

// class TopPage extends StatefulWidget {
//   const TopPage({super.key});

//   @override
//   State<TopPage> createState() => _TopPageState();
// }

// class _TopPageState extends State<TopPage> {


//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       home: Scaffold(
//         appBar: AppBar(
//           title: const Text('data'),
//           titleTextStyle: TextStyle(
//             color: Colors.white, 
//             fontSize: 20),
//           backgroundColor: Colors.blue,
//           ),

//         body:StreamBuilder<QuerySnapshot>(
//             stream: RoomFirestore.jointRoomSnapshot,      //jointRoomSnapshot、つまり、自分の参加してるルームのドキュメントをリアルタイムで取得
//             builder: (context, streamSnapshot) {                //このBuiderが作動する　
//             if(streamSnapshot.hasData){
//                 return FutureBuilder<List<TalkRoom>?>(
//               future: RoomFirestore.fetchJoinedRooms(streamSnapshot.data!),
//               builder: (context, futureSnapshot) {   //「？」Ftuturebuilderのfuturesnapshotの.dataで扱える値って何？？？
//                   if(futureSnapshot.connectionState == ConnectionState.waiting){
//                     return CircularProgressIndicator();
//                   } else {
//                   if(futureSnapshot.hasData) {
//                     List<TalkRoom> talkRooms = futureSnapshot.data!;  //ここでtoalkRoomsを宣言
//                     return ListView.builder(            // "アイテムを縦に並べる" ために使用するwidgetでタイムラインのイメージ）
//                         itemCount: talkRooms.length,     //.lengsという書き方にすると、talkRooms変数の中の要素の"数"を取り出せる
//                         itemBuilder: (context, index) {     //この形がListview.builderの基本
//                           return InkWell(                   //Inkwellは普段押せないwidgetを押せるようにするwidget
//                             onTap: () {
//                               print('タップ検知');
//                               Navigator.push(context, MaterialPageRoute(    //画面遷移させたい時の定型
//                                 builder: (context) => TalkRoomPage(talkRooms[index]),    //画面遷移させたい時の定型　
//                                 //talkRooms[index]で、fetchJoinedRooms()でリスト型のtalkRoomsの情報を、タップ時に検出してる
//                                 //top_pageでリスト化されてるルームの序列番号と、fetchJoinedRoomsでリスト化した際のルームの序列番号は同じ（てか、同じじゃないとこの処理は成立しない）
//                                 //この[index]は37,38行目でリスト化され、ナンバリングされたtalkroomsのナンバーと同じもの、つまり、リストナンバーごとにTalkRoomPageを別々にインスタンス化して表示する。
//                                 //https://sl.bing.net/byg2DhmZnnE
//                                 ));
//                               },
//                             child: SizedBox(   //ユーザーごとの１つ１つのタブ
//                               height: 70,
//                               child: Row(       //ユーザーの画像、名前、最後のメッセージが横に表示されるようにするためrow
//                                 children: [      //childrenプロパティにwidgetを書くと、どんどん横に配置されてく
//                                   // Padding(       //ユーザー画像
//                                   //   padding: const EdgeInsets.symmetric(horizontal: 10.0),
//                                   //   child: CircleAvatar(
//                                   //     radius: 30,
//                                   //     backgroundImage: talkRooms[index].talkUser.ImagePath == null
//                                   //     ? null
//                                   //     : NetworkImage(talkRooms[index].talkUser.ImagePath!)),
//                                   // ),
//                                   Column(  //ユーザー名とその下に最後のメッセージ
//                                     crossAxisAlignment: CrossAxisAlignment.start,    
//                                     mainAxisAlignment: MainAxisAlignment.center,
//                                     children:[
//                                           Text('トーク相手の名前', style: const TextStyle(
//                                             fontSize: 16, 
//                                             fontWeight:FontWeight.bold),),

//                                   ],
//                                 )
//                               ],
//                             ),
//                                   ),
//                           );
//                             },
//                           );
//                         } else {
//                         return Text('トークの取得に失敗しました');
//                         }                    
//                   }

 
//               }
//             );            
//          }else{
//           return CircularProgressIndicator();

//          }
//       }
//      ),
//     ),
//   );
//   }
// }




