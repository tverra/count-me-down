import 'package:count_me_down/extensions.dart';
import 'package:count_me_down/models/drink.dart';
import 'package:count_me_down/models/profile.dart';

class AlcoholTracker {
  final List<Drink> _drinks = <Drink>[];
  final Profile profile;

  AlcoholTracker({
    required this.profile,
  });

  DateTime get lastSober {
    final Drink? drink = _drinks.isNotEmpty ? _drinks.first : null;
    final DateTime? timestamp = drink?.timestamp;

    if (drink == null || timestamp == null) {
      return DateTime.now();
    }

    return timestamp;
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

    final List<Drink> relevantDrinks = _drinks
        .where((Drink drink) => drink.consumedBetween(from, to))
        .toList();

    for (final Drink drink in relevantDrinks) {
      sum += drink
          .currentlyAbsorbedAlcohol(profile.absorptionTime ?? Duration.zero);
    }

    return sum;
  }

  double _totalBloodAlcoholPerMil(DateTime timestamp) {
    return (consumedAlcoholBetween(lastSober, timestamp) /
            ((profile.bodyWeight?.grams ?? 0) *
                (profile.bodyWaterPercentage?.fraction ?? 0))) *
        1000;
  }

  double _metabolizedAlcoholPerMil(DateTime timestamp) {
    return (profile.perMilMetabolizedPerHour ?? 0) *
        durationSinceLastSober.inHours;
  }
}
