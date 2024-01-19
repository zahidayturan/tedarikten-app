import 'package:firebase_auth/firebase_auth.dart';
import 'package:tedarikten/models/user_info.dart';

class NotificationInfo {
  String? id;
  String userId;
  String senderId;
  String title;
  String date;
  bool isRead;

  NotificationInfo({
    this.id,
    required this.userId,
    required this.senderId,
    required this.title,
    required this.date,
    required this.isRead,
  });

  factory NotificationInfo.fromJson(Map<String, dynamic> json) {
    return NotificationInfo(
      id: json['id'] ?? '',
      userId: json['userId'] ?? '',
      senderId: json['senderId'] ?? '',
      title: json['title'] ?? '',
      date: json['date'] ?? '',
      isRead: json['isRead'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'senderId': senderId,
      'title': title,
      'date': date,
      'isRead': isRead,
    };
  }
}

class CombinedNotificationInfo {
  late NotificationInfo notificationInfo;
  late TUserInfo userInfo;

  CombinedNotificationInfo({required this.notificationInfo, required this.userInfo});

  factory CombinedNotificationInfo.fromFirestore(
       Map<String, dynamic> notificationInfo,Map<String, dynamic> userInfo) {
    return CombinedNotificationInfo(
      notificationInfo: NotificationInfo.fromJson(notificationInfo),
        userInfo: TUserInfo.fromJson(userInfo)
    );
  }
}
