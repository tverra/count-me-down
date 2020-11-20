import 'dart:convert';

import 'package:count_me_down/models/drink.dart';
import 'package:count_me_down/models/preferences.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class Utils {
  static String trimTextBlock(String text) {
    return text.replaceAll(RegExp('\\s+'), ' ');
  }

  static Color getThemeTextColor(BuildContext context) {
    return Theme.of(context).primaryTextTheme.headline6.color;
  }

  static String formatDuration(Duration duration) {
    final int seconds = duration.inSeconds % 60;
    final int minutes = duration.inMinutes % 60;
    final int hours = duration.inHours;
    final StringBuffer buffer = StringBuffer();

    if (hours > 0) {
      if (hours > 1) {
        buffer.write('$hours hours');
      } else {
        buffer.write('$hours hour');
      }
    }

    if (minutes > 0) {
      if (hours > 0) {
        if (seconds > 0) {
          buffer.write(', ');
        } else {
          buffer.write(' and ');
        }
      }

      if (minutes > 1) {
        buffer.write('$minutes minutes');
      } else {
        buffer.write('$minutes minute');
      }
    }

    if (seconds > 0) {
      if (buffer.isNotEmpty) {
        buffer.write(' and ');
      }

      if (seconds > 1) {
        buffer.write('$seconds seconds');
      } else {
        buffer.write('$seconds second');
      }
    }
    return buffer.toString();
  }

  static String formatDatetime(DateTime dateTime,
      {BuildContext context, bool weekDay = false, bool timeOfDay = true}) {
    final String locale =
        context != null ? Localizations.localeOf(context).languageCode : null;

    final StringBuffer buffer = StringBuffer();

    if (weekDay) {
      buffer.write(DateFormat('EEEE ', locale).format(dateTime.toLocal()));
    }

    buffer.write(dateTime.toLocal().day);
    buffer.write('. ');
    buffer.write(DateFormat('MMMM', locale).format(dateTime.toLocal()));
    if (DateTime.now().year != dateTime.toLocal().year) {
      buffer.write(DateFormat(' y', locale).format(dateTime.toLocal()));
    }

    if (timeOfDay) {
      buffer.write(', ');
      buffer.write(DateFormat('HH:mm', locale).format(dateTime.toLocal()));
    }

    return buffer.toString();
  }

  static Future<void> drinkWebHook(BuildContext context, Drink drink) async {
    final Preferences preferences = context.read<Preferences>();

    if (preferences.drinkWebHook != null && preferences.drinkWebHook != '') {
      final Map<String, String> headers = <String, String>{};
      headers.putIfAbsent('Content-Type', () => 'application/json');

      http
          .post(preferences.drinkWebHook,
              headers: headers, body: jsonEncode(drink.toMap()))
          .timeout(Duration(seconds: 10));
    }
  }
}
