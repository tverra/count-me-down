import 'dart:convert';

import 'package:count_me_down/database/repos/drink_repo.dart';
import 'package:count_me_down/database/repos/profile_repo.dart';
import 'package:count_me_down/models/drink.dart';
import 'package:count_me_down/models/preferences.dart';
import 'package:count_me_down/models/profile.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:package_info/package_info.dart';
import 'package:provider/provider.dart';

String trimTextBlock(String text) {
  return text.replaceAll(RegExp('\\s+'), ' ');
}

Color getThemeTextColor(BuildContext context) {
  return Theme.of(context).primaryTextTheme.headline6?.color ?? Colors.white;
}

String formatDuration(Duration duration) {
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

String formatDatetime(
  DateTime dateTime, {
  BuildContext? context,
  bool weekDay = false,
  bool timeOfDay = true,
}) {
  final String? locale =
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

Future<void> drinkWebHook(BuildContext context) async {
  final Preferences preferences = context.read<Preferences>();
  final PackageInfo packageInfo = await PackageInfo.fromPlatform();

  if (preferences.drinkWebHook != null && preferences.drinkWebHook != '') {
    final Map<String, String> headers = <String, String>{};
    final Map<String, dynamic> body = <String, dynamic>{};

    headers.putIfAbsent('Content-Type', () => 'application/json');
    headers.putIfAbsent('x-api-version', () => '2');
    headers.putIfAbsent(
      'x-app-version',
      () => '${packageInfo.version}+${packageInfo.buildNumber}',
    );

    final List<Drink> drinks = await getDrinks(
      sessionId: preferences.activeSessionId,
    );
    final Profile? profile = await getProfile(
      preferences.activeProfileId ?? 0,
    );

    body.putIfAbsent(
      'drinks',
      () => drinks.map((Drink d) => d.toMap()).toList(),
    );
    body.putIfAbsent('profile', () => profile?.toMap());

    http
        .post(
          Uri.parse(preferences.drinkWebHook ?? ''),
          headers: headers,
          body: jsonEncode(body),
        )
        .timeout(const Duration(seconds: 10));
  }
}

void printInternalErrors(
  Map<String, dynamic> errors,
  dynamic error,
  dynamic stacktrace,
) {
  debugPrint('\n${error.toString()}');
  debugPrint(stacktrace.toString());
}
