import 'package:intl/intl.dart';

class Volume {
  final int millilitres;

  Volume(this.millilitres);

  factory Volume.exact({
    int? litres,
    int? decilitres,
    int? centilitres,
    int? millilitres,
  }) {
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
    final NumberFormat format = NumberFormat('#.##', 'nb_NO');

    if (millilitres >= 1000 || millilitres <= -1000) {
      return '${format.format(litres)} L';
    } else if (millilitres >= 100 || millilitres <= -100) {
      return '${format.format(decilitres)} dL';
    } else if (millilitres >= 10 || millilitres <= -10) {
      return '${format.format(centilitres)} cL';
    } else {
      return '${format.format(millilitres)} mL';
    }
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Volume && millilitres == other.millilitres;

  @override
  int get hashCode => millilitres.hashCode;
}
