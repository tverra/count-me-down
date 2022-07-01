extension MockableDateTime on DateTime {
  static DateTime? mockTime;

  static DateTime get current {
    final DateTime? time = mockTime;

    if (time != null) {
      return time;
    } else {
      return DateTime.now();
    }
  }
}
