import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:project_expo/views/Login.dart';
import 'services/notification.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  AwesomeNotifications().initialize(
      null,
      [NotificationChannel(channelKey: 'basic_channel',
          channelName: 'basic_notification',
          defaultColor: Colors.lightBlue,
        importance: NotificationImportance.High,
        channelShowBadge: true,
      )]);
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      home: LogIn(),
      debugShowCheckedModeBanner: false,
    );
  }
}

