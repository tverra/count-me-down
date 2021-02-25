class Percent {
  final double fraction;

  Percent(this.fraction);

  factory Percent.fromPercent(double percent) {
    return Percent(percent / 100);
  }

  double get percent {
    return fraction * 100;
  }

  double get perMil {
    return fraction * 1000;
  }

  @override
  String toString() {
    if (fraction >= 0.01 || fraction == 0.0) {
      return '${percent.toStringAsFixed(0)}%';
    }
    return '${perMil.toStringAsFixed(0)}‰';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is Percent && fraction == other.fraction;

  @override
  int get hashCode => fraction.hashCode;
}
