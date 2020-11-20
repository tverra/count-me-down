class Percentage {
  final double fraction;

  Percentage(this.fraction);

  factory Percentage.fromPercentage(double percentage) {
    if (percentage == null) return null;
    return Percentage(percentage / 100);
  }

  double get percentage {
    return fraction * 100;
  }

  @override
  String toString() {
    if (fraction == null) return null.toString();
    return '${percentage.toStringAsFixed(1)}%';
  }
}
