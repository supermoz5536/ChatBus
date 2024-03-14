import 'package:firebase_analytics/firebase_analytics.dart';


class CustomAnalytics {
  static final FirebaseAnalytics _analytics = FirebaseAnalytics.instance;


static Future<void> logMainIn() async {
    await _analytics.logEvent(name: 'MainIn');
  }

static Future<void> logLoungePageIn() async {
    await _analytics.logEvent(name: 'LoungePageIn');
  }

static Future<void> logLoungeBackPageIn() async {
    await _analytics.logEvent(name: 'LoungeBackPageIn');
}

static Future<void> logMatchingProgressPageIn() async {
    await _analytics.logEvent(name: 'MatchingProgressPageIn');
}

static Future<void> logTalkRoomPageIn() async {
    await _analytics.logEvent(name: 'TalkRoomPageIn');
}


static Future<void> logReadHowToUse() async {
    await _analytics.logEvent(name: 'ReadHowToUse');
}






}
