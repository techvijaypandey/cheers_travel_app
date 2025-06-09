class Airport {
  final String airportName;
  final String airportCode;
  final String cityCode;
  final String cityName;
  final String countryCode;
  final String countryName;
  final int citySequence;
  final int airportSequence;

  Airport({
    required this.airportName,
    required this.airportCode,
    required this.cityCode,
    required this.cityName,
    required this.countryCode,
    required this.countryName,
    required this.citySequence,
    required this.airportSequence,
  });

  factory Airport.fromJson(Map<String, dynamic> json) {
    return Airport(
      airportName: json['airportName'] as String,
      airportCode: json['airportCode'] as String,
      cityCode: json['cityCode'] as String,
      cityName: json['cityName'] as String,
      countryCode: json['countryCode'] as String,
      countryName: json['countryName'] as String,
      citySequence: json['citySequence'] as int,
      airportSequence: json['airportSequence'] as int,
    );
  }

  @override
  String toString() {
    return '$cityName, $airportName ($airportCode), $countryName';
  }
} 