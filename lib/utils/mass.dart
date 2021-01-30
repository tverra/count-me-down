class Mass {
  final int grams;

  Mass(this.grams);

  factory Mass.exact({int kilos, int grams}) {
    int sum = 0;

    if (kilos != null) sum += kilos * 1000;
    if (grams != null) sum += grams;

    return Mass(sum);
  }

  double get kilos => grams / 1000.0;

  @override
  String toString() {
    if (grams == 0) return '0 g';
    if (grams >= 1000) return '${kilos.toStringAsFixed(1)} kg';
    return '${grams.toStringAsFixed(1)} g';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is Mass && grams == other.grams;

  @override
  int get hashCode => grams.hashCode;
}
