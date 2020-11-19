class Volume {
  final int millilitres;

  Volume(this.millilitres);

  factory Volume.exact(
      {int litres, int decilitres, int centilitres, int millilitres}) {
    int sum = 0;

    if (litres != null) sum += litres * 1000;
    if (decilitres != null) sum += decilitres * 100;
    if (centilitres != null) sum += centilitres * 10;
    if (millilitres != null) sum += millilitres;

    return Volume(sum);
  }

  double get litres => millilitres / 1000.0;

  double get decilitres => millilitres / 100.0;

  double get centilitres => millilitres / 10.0;

  @override
  String toString() {
    if (millilitres == null) return null;
    if (millilitres > 1000) {
      return '$litres} l';
    } else if (millilitres > 100) {
      return '$decilitres dl';
    } else if (millilitres > 10) {
      return '$centilitres cl';
    } else {
      return '$millilitres ml';
    }
  }
}
