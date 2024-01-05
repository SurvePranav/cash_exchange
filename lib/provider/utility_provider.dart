import 'dart:async';
import 'dart:developer';

import 'package:cashxchange/provider/auth_provider.dart';
import 'package:cashxchange/utils/notification_services.dart';
import 'package:flutter/material.dart';

class UtilityProvider extends ChangeNotifier {
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  int _notificationCounter = 0;
  int get notificationCounter => _notificationCounter;

  int _chatCounterCounter = 0;
  int get chatCounter => _chatCounterCounter;

  int _dMCounter = 0;
  int get dMCounter => _dMCounter;

  int _clockCounter = 0;
  int get clockCounter => _clockCounter;

  late StreamSubscription<List<int>>? _chatsSubscription;
  late StreamSubscription<int>? _notificationsSubscription;

  // for the clock counter
  void incrementClockCounter() {
    _clockCounter++;
    notifyListeners();
  }

  // for notifications badge
  void incrementNotificationCounter(int increment) {
    _notificationCounter = increment;
    notifyListeners();
  }

  void listenToUnreadedNotificationsStream() {
    Stream<int> notificationsStream =
        NotificationServics.getUnreadNotificationCount();
    _notificationsSubscription = notificationsStream.listen((data) {
      log('total unreaded Chats: $data');
      incrementNotificationCounter(data);
    });
  }

  // for chats badge
  void incrementChatCounter(int increment) {
    _chatCounterCounter = increment;
    notifyListeners();
  }

  // for chats badge
  void incrementDMCounter(int increment) {
    _dMCounter = increment;
    notifyListeners();
  }

  void listenToUnreadedChatsStream() {
    Stream<List<int>> chatsStream = AuthProvider.getUnreadChatsCount();
    _chatsSubscription = chatsStream.listen((data) {
      log('total unreaded Chats: $data');
      incrementChatCounter(data[0]);
      incrementDMCounter(data[1]);
    });
  }

// unlistening to all the streams
  void unsubscribeToStreams() {
    _chatsSubscription?.cancel();
    _chatsSubscription = null;
    _notificationsSubscription?.cancel();
    _notificationsSubscription = null;
  }

  void setLoading(bool loading) {
    if (loading) {
      _isLoading = true;
      notifyListeners();
    } else {
      _isLoading = false;
      notifyListeners();
    }
  }
}
