import 'package:flutter_local_notifications/flutter_local_notifications.dart';

// This service class is responsible for managing local notifications in the app.
class NotificationService {
  //create an instance of the FlutterLocalNotificationsPlugin
  final _notifications = FlutterLocalNotificationsPlugin();

  // This method initializes the notification settings for Android.
  Future<void> init() async {
    //specify the app icon to yse for notifications
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');

    //wrap the initialization settings in a platform-specific settings object
    const settings = InitializationSettings(android: android);

    //initialize the notifications plugin with the specified settings
    await _notifications.initialize(settings);
  }

  //display a notification with the specified title and body
  Future<void> showNotification(String title, String body) async {
    //define the Android-specific details for the notification
    const androidDetails = AndroidNotificationDetails(
      'channelId', //unique channel ID for the notification channel
      'Weather Alerts', //name of the channel
      importance: Importance.max, //importance level of the notification
      priority: Priority.high, //priority level of the notification
    );

    // wrap android specific details in a platform-specific details object
    const details = NotificationDetails(android: androidDetails);

    //show the notification with the specified title, body, and details
    await _notifications.show(0, title, body, details);
  }
}
