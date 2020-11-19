extension MockableDateTime on DateTime {
  static DateTime mockTime;
  static DateTime get current {
    if (mockTime != null)
      return mockTime;
    else
      return DateTime.now();
  }
}
