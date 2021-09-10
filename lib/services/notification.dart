import 'dart:math';

import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';

int createUniqueId(){
  Random random = new Random();
  return random.nextInt(1000);
}

Future<void> firebaseHandler(RemoteMessage message)async{
  print("Message: ${message.data}");

  AwesomeNotifications().createNotificationFromJsonData(message.data);
}

void subscribeTopic(String uid) async{
  await FirebaseMessaging.instance.subscribeToTopic(uid).then((value) => print('Subcribed'));

  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: createUniqueId(),
        channelKey: 'basic_channel',
        title: 'Hi im billa',
        body: message.notification?.body,
        bigPicture: 'https://www.localguidesconnect.com/t5/image/serverpage/image-id/784350i2CA2F54E4D4F1963?v=v2',
        notificationLayout: NotificationLayout.BigPicture
      ),
    );
  });
}

void unsubscribeTopic(String uid) async{
  await FirebaseMessaging.instance.unsubscribeFromTopic(uid).then((value) => print('Unsubcribed'));
}


Future<void> createNotification() async{
  await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: createUniqueId(),
        channelKey: 'basic_channel',
        title: '${Emojis.activites_balloon}',
        body: 'This is Sample notification',
      ));
}

