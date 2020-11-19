import 'package:count_me_down/extensions.dart';
import 'package:count_me_down/models/drink.dart';
import 'package:count_me_down/models/profile.dart';
import 'package:meta/meta.dart';

class AlcoholTracker {
  final List<Drink> _drinks = <Drink>[];
  final Profile profile;

  AlcoholTracker({
    @required this.profile,
  });

  DateTime get lastSober {
    return _drinks.first.timestamp;
  }

  Duration get durationSinceLastSober {
    return MockableDateTime.current.difference(lastSober);
  }

  void addDrink(Drink drink) {
    _drinks.add(drink);
  }

  double getBloodAlcoholContent(DateTime timestamp) {
    if (_drinks.isEmpty) return 0;

    final double bloodAlcoholContent = _totalBloodAlcoholPerMil(timestamp) -
        _metabolizedAlcoholPerMil(timestamp);

    if (bloodAlcoholContent < 0) return 0;

    return bloodAlcoholContent;
  }

  double consumedAlcoholBetween(DateTime from, DateTime to) {
    double sum = 0.0;

    final List<Drink> relevantDrinks =
        _drinks.where((drink) => drink.consumedBetween(from, to)).toList();

    relevantDrinks.forEach((drink) =>
        sum += drink.currentlyAbsorbedAlcohol(profile.absorptionTime));

    return sum;
  }

  double _totalBloodAlcoholPerMil(DateTime timestamp) {
    return (consumedAlcoholBetween(lastSober, timestamp) /
            (profile.bodyWeight.grams * profile.bodyWaterPercentage.fraction)) *
        1000;
  }

  double _metabolizedAlcoholPerMil(DateTime timestamp) {
    return profile.perMilMetabolizedPerHour * durationSinceLastSober.inHours;
  }
}
