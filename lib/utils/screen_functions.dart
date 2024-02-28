import 'package:flutter/material.dart';
import 'package:udemy_copy/model/talk_room.dart';
import 'package:udemy_copy/model/user.dart';
import 'package:udemy_copy/page/sub_page/search_page.dart';
import 'package:udemy_copy/page/sub_page/friend_list_page.dart';
import 'package:udemy_copy/page/sub_page/matched_history_page.dart';
import 'package:udemy_copy/page/sub_page/dm_list_page.dart';

class ScreenFunctions {

static setCurrentScreem(int? currentIndex, User? userData, TalkRoom talkRoom) {
  List<Widget> currentScreen = [
                                SearchPage(),
                                DMListPage(userData),
                                FriendListPage(userData),
                                MatchedHistoryPage(talkRoom),
                              ];
    switch (currentIndex) {
      case 0:
        return currentScreen[0];
      case 1:
        return currentScreen[1];
      case 2:
        return currentScreen[2];
      case 3:
        return currentScreen[3];
      default:
        return currentScreen[0];
      }
 }
}