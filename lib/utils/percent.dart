class Percent {
  final double fraction;

  Percent(this.fraction);

  factory Percent.fromPercentage(double percentage) {
    if (percentage == null) return null;
    return Percent(percentage / 100);
  }

  double get percentage {
    return fraction * 100;
  }

  @override
  String toString() {
    if (fraction == null) return null.toString();
    return '${percentage.toStringAsFixed(1)}%';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is Percent && fraction == other.fraction;

  @override
  int get hashCode => fraction.hashCode;
}
