import 'dart:math';

import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';

int createUniqueId(){
  Random random = new Random();
  return random.nextInt(1000);
}



Future<void> createNotification() async{
  await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: createUniqueId(),
        channelKey: 'basic_channel',
        title: 'Help',
        body: 'Someone near you needs help',
        bigPicture: 'asset://assets/notification_big_picture.png',
        notificationLayout: NotificationLayout.BigPicture,
      ));
}

