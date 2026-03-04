import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'weather_models.freezed.dart';
part 'weather_models.g.dart';

@freezed
class LocationWeather with _$LocationWeather {
  const factory LocationWeather({
    required String name,
    required double latitude,
    required double longitude,
    required double temperature,
    required int weatherCode,
    @Default([]) List<HourlyForecast> hourlyForecasts,
  }) = _LocationWeather;

  factory LocationWeather.fromJson(Map<String, dynamic> json) => _$LocationWeatherFromJson(json);
}

@freezed
class HourlyForecast with _$HourlyForecast {
  const factory HourlyForecast({
    required String time,
    required double temperature,
    required int weatherCode,
  }) = _HourlyForecast;

  factory HourlyForecast.fromJson(Map<String, dynamic> json) => _$HourlyForecastFromJson(json);
}

// Extension to get weather icon and advice based on WMO code
extension WeatherCodeExtension on int {
  IconData get weatherIcon {
    if (this == 0) return FontAwesomeIcons.sun;
    if (this <= 3) return FontAwesomeIcons.cloudSun;
    if (this <= 48) return FontAwesomeIcons.smog;
    if (this <= 67) return FontAwesomeIcons.cloudRain;
    if (this <= 77) return FontAwesomeIcons.snowflake;
    if (this <= 82) return FontAwesomeIcons.cloudShowersHeavy;
    if (this <= 99) return FontAwesomeIcons.bolt;
    return FontAwesomeIcons.cloud;
  }

  String get description {
    if (this == 0) return 'Clair';
    if (this <= 3) return 'Partiellement nuageux';
    if (this <= 67) return 'Pluie';
    if (this <= 77) return 'Neige';
    if (this <= 82) return 'Averses';
    return 'Nuageux';
  }
  
  String get agriAdvice {
    if (this == 0) return 'Conditions idéales pour les travaux extérieurs et le séchage.';
    if (this <= 3) return 'Bon moment pour l\'inspection des cultures et l\'entretien léger.';
    if (this <= 67) return 'Évitez d\'appliquer de l\'engrais ou des pesticides avant la pluie.';
    if (this <= 77) return 'Protégez les cultures sensibles contre le froid intense.';
    if (this <= 82) return 'Assurez un bon drainage pour éviter la stagnation de l\'eau.';
    return 'Conditions modérées. Surveillez l\'humidité du sol.';
  }
}
