import 'package:firebase_analytics/firebase_analytics.dart';


class CustomAnalytics {
  static final FirebaseAnalytics _analytics = FirebaseAnalytics.instance;

static Future<void> logEvent() async {
    await _analytics.logEvent(name: 'log');
  }

}