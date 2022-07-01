class DataParser {
  final bool forQuery;

  DataParser({this.forQuery = false});

  int parseInt(dynamic value) {
    if (value == null) throw TypeError();

    return int.parse(value.toString());
  }

  int? tryParseInt(dynamic value) {
    if (value == null) return null;

    return int.tryParse(value.toString());
  }

  String parseString(dynamic value) {
    if (value == null) throw TypeError();

    return value as String;
  }

  String? tryParseString(dynamic value) {
    return value as String?;
  }

  bool parseBool(dynamic value) {
    if (value == null) throw TypeError();

    return value == 1 || value == '1' || value == true || value == 'true';
  }

  bool? tryParseBool(dynamic value) {
    if (value == null) return null;

    return parseBool(value);
  }

  double parseDouble(dynamic value) {
    if (value == null) throw TypeError();

    return double.parse(value.toString());
  }

  double? tryParseDouble(dynamic value) {
    if (value == null) return null;

    return double.tryParse(value.toString());
  }

  DateTime parseDateTime(dynamic value) {
    if (value == null) throw TypeError();

    final int? parsedInt = tryParseInt(value);

    return parsedInt != null
        ? DateTime.fromMillisecondsSinceEpoch(
            parsedInt,
            isUtc: true,
          )
        : DateTime.parse(value.toString());
  }

  DateTime? tryParseDateTime(dynamic value) {
    if (value == null) return null;

    final int? parsedInt = tryParseInt(value);

    return parsedInt != null
        ? DateTime.fromMillisecondsSinceEpoch(
            parsedInt,
            isUtc: true,
          )
        : DateTime.tryParse(value.toString());
  }

  dynamic parseDynamic(dynamic value) {
    return value;
  }

  dynamic tryParseDynamic(dynamic value) {
    return parseDynamic(value);
  }

  dynamic serializeInt(int? value) {
    return value;
  }

  dynamic serializeString(String? value) {
    return value;
  }

  // ignore: avoid_positional_boolean_parameters
  dynamic serializeBool(bool? value) {
    if (value == null) return null;
    if (forQuery) return value ? 1 : 0;

    return value;
  }

  dynamic serializeDouble(double? value) {
    if (value == null) return null;

    return value;
  }

  dynamic serializeDateTime(DateTime? value) {
    if (value == null) return null;
    if (forQuery) return value.millisecondsSinceEpoch;

    return value.toIso8601String();
  }

  dynamic serializeDynamic(dynamic value) {
    return value;
  }
}
