import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class MyDateUtil {
  // for getting formatted time from milliSecondsSinceEpochs String
  static String getFormattedTime(
      {required BuildContext context, required String time}) {
    final date = DateTime.fromMillisecondsSinceEpoch(int.parse(time));
    return TimeOfDay.fromDateTime(date).format(context);
  }

  // for getting formatted time for sent & read
  static String getMessageTime(
      {required BuildContext context, required String time}) {
    final DateTime sent = DateTime.fromMillisecondsSinceEpoch(int.parse(time));
    final DateTime now = DateTime.now();

    if (now.day == sent.day &&
        now.month == sent.month &&
        now.year == sent.year) {
      log('returning from here');
      return DateFormat('jm').format(sent.toLocal());
    } else if (now.year == sent.year) {
      log('returning from here full date');
      return DateFormat('d MMM h:mm a').format(sent.toLocal());
    } else {
      return DateFormat('dd/MM/yy h:mm a').format(sent.toLocal());
    }
  }

  static String getTimeStamp(
      {required BuildContext context, required String time}) {
    final DateTime sent = DateTime.fromMillisecondsSinceEpoch(int.parse(time));
    return DateFormat('dd/MM/yy h:mm a').format(sent.toLocal());
  }

  //get last message time (used in chat user card)
  static String getLastMessageTime(
      {required BuildContext context,
      required String time,
      bool showYear = false}) {
    final DateTime sent = DateTime.fromMillisecondsSinceEpoch(int.parse(time));
    final DateTime now = DateTime.now();

    if (now.day == sent.day &&
        now.month == sent.month &&
        now.year == sent.year) {
      return DateFormat('jm').format(sent.toLocal());
    } else if (now.day - 1 == sent.day) {
      return 'Yesterday';
    } else if (now.year == sent.year) {
      return DateFormat('d MMM').format(sent.toLocal());
    } else {
      return DateFormat('dd/MM/yyyy').format(sent.toLocal());
    }
  }

  String formatMillisecondsSinceEpoch(int millisecondsSinceEpoch) {
    DateTime dateTime =
        DateTime.fromMillisecondsSinceEpoch(millisecondsSinceEpoch);
    String formattedDateTime =
        DateFormat('dd MMM hh:mm a').format(dateTime.toLocal());
    return formattedDateTime;
  }

  // formatted time ago
  static String formatTimeAgo(int millisecondsSinceEpoch) {
    final DateTime currentDate = DateTime.now();
    final DateTime providedDate =
        DateTime.fromMillisecondsSinceEpoch(millisecondsSinceEpoch);

    final Duration difference = currentDate.difference(providedDate);

    if (difference.inHours < 24) {
      if (difference.inMinutes < 1) {
        return 'Just now';
      } else if (difference.inMinutes < 2) {
        return '${difference.inMinutes} min ago';
      } else if (difference.inMinutes < 60) {
        return '${difference.inMinutes} mins ago';
      } else if (difference.inHours < 2) {
        return '${difference.inHours} hour ago';
      } else if (difference.inHours < 24) {
        return '${difference.inHours} hours ago';
      } else {
        return DateFormat.jm().format(providedDate); // Today's time with AM/PM
      }
    } else if (difference.inDays == 1) {
      return '1 day ago';
    } else if (difference.inDays >= 2 && difference.inDays <= 6) {
      return '${difference.inDays} days ago';
    } else if (difference.inDays == 7) {
      return '1 week ago';
    } else if (difference.inDays > 7 && difference.inDays <= 30) {
      return '${difference.inDays ~/ 7} weeks ago';
    } else if (difference.inDays > 30 && difference.inDays <= 365) {
      return '${difference.inDays ~/ 30} months ago';
    } else {
      return '${difference.inDays ~/ 365} years ago';
    }
  }
}
