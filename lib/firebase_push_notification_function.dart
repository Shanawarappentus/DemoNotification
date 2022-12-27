import 'dart:convert';
import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_ringtone_player/flutter_ringtone_player.dart';
import 'package:no_context_navigation/no_context_navigation.dart';

setFirebasePushNotification() async {
  AndroidNotificationChannel androidNotificationChannel = setAndroidChannel();

  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = setFlutterNotificationPlugin();

  /// Create an Android Notification Channel.
  ///
  /// We use this channel in the `AndroidManifest.xml` file to override the
  /// default FCM channel to enable heads up notifications.
  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
      AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(androidNotificationChannel);

  /// Update the iOS foreground notification presentation options to allow
  /// heads up notifications.
  await FirebaseMessaging.instance
      .setForegroundNotificationPresentationOptions(
    alert: true,
    badge: true,
    sound: true,
  );
}

setAndroidChannel(){
  return const AndroidNotificationChannel(
    'high_importance_channel', // id
    'High Importance Notifications', // title // description
    importance: Importance.high,
  );
}

setFlutterNotificationPlugin(){
  return  FlutterLocalNotificationsPlugin();
}

firebasePushNotificationPermission(){
  if(Platform.isIOS){
    FirebaseMessaging.instance.requestPermission(
        alert: true,
        badge: true,
        sound: true
    );
  }
}

initialAppMessaging(){
  FirebaseMessaging.instance
      .getInitialMessage()
      .then((message) {
    if (message != null) {
      print("onCheck ${message.notification!.body}");
      FlutterRingtonePlayer.stop();
      //var jsonDecode = json.decode(message.notification!.body??'');
    }
  });

  var androiInit = AndroidInitializationSettings('@mipmap/ic_launcher');//for logo
  var iosInit = IOSInitializationSettings();
  var initSetting=InitializationSettings(android: androiInit,iOS: iosInit);

  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = setFlutterNotificationPlugin();
  flutterLocalNotificationsPlugin.initialize(initSetting,onSelectNotification: (String? payload)async{
    print('payload');
    print(payload.runtimeType);
    print('payload--------');

    print('payload decode');
    print(json.decode(payload??''));
    var jsonDecode = json.decode(payload??'');
    print('payload decode type');
    print(jsonDecode.runtimeType);
  });

}

openedAppMessaging(){
  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    RemoteNotification? notification = message.notification;
    AndroidNotification? android = message.notification?.android;
    print(notification!.body.toString());
    print(notification.title!);
    print(android);
    if (android != null) {
      print('notification>>>');
      print(message.data);
      showNotification(1,notification.title!,message.notification!.body,message.data);
    }
  });
}

openedAppFromMessagingFromBackground(){
  print('opened message app<<<<<<');
  FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
    RemoteNotification? notification = message.notification;
    AndroidNotification? android = message.notification?.android;
    print(notification!.body.toString());
    print(notification.title!);
    print(android);
    print('notification while opened app>>>');
    print(message.data);
    FlutterRingtonePlayer.stop();
    if (android != null) {
    /*  print('notification while opened app>>>');
      print(message.data);
      navigateToNotificationScreen(message.data['type'],message.data);*/
    }
  });
}

Future<void> showNotification(
    int notificationId,
    String notificationTitle,
    dynamic notificationContent,
    dynamic notificationBody

    ) async {
  print('notification>>>_showNotification');
  print(notificationContent);
  FlutterRingtonePlayer.play(
    //android: AndroidSounds.notification,
    fromAsset: 'assets/horn_blow.mp3',
    looping: false, // Android only - API >= 28
    volume: 1.0, // Android only - API >= 28
    asAlarm: true, // Android only - all APIs
  );
  //FlutterRingtonePlayer.playAlarm(asAlarm: true,looping: false,volume: 1.0);
  navService.pushNamed('/flash_logo');
  Future.delayed(const Duration(seconds: 15),(){
    FlutterRingtonePlayer.stop();
  });
  AndroidNotificationChannel androidNotificationChannel = setAndroidChannel();
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = setFlutterNotificationPlugin();
  var androidPlatformChannelSpecifics = AndroidNotificationDetails(
      androidNotificationChannel.id,
      androidNotificationChannel.name,
      playSound: true,
      importance: androidNotificationChannel.importance,
      icon: 'ic_launcher',
  );
  var iOSPlatformChannelSpecifics =
  const IOSNotificationDetails(presentSound: true,  presentAlert: true);
  var platformChannelSpecifics = NotificationDetails(android: androidPlatformChannelSpecifics,iOS: iOSPlatformChannelSpecifics);

  await flutterLocalNotificationsPlugin.show(
    notificationId,
    notificationTitle,
    notificationContent,
    platformChannelSpecifics,
    payload:json.encode(notificationBody)
  );
}

