import 'package:firebase_analytics_web/firebase_analytics_web.dart';


class CustomAnalyticsWeb {
  static final FirebaseAnalyticsWeb _analytics = FirebaseAnalyticsWeb();


static Future<void> logMyAppWeb() async {
    await _analytics.logEvent(name: 'MyUppWeb');
  }


}