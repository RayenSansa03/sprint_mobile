// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'weather_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$LocationWeatherImpl _$$LocationWeatherImplFromJson(
        Map<String, dynamic> json) =>
    _$LocationWeatherImpl(
      name: json['name'] as String,
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      temperature: (json['temperature'] as num).toDouble(),
      weatherCode: (json['weatherCode'] as num).toInt(),
      hourlyForecasts: (json['hourlyForecasts'] as List<dynamic>?)
              ?.map((e) => HourlyForecast.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
    );

Map<String, dynamic> _$$LocationWeatherImplToJson(
        _$LocationWeatherImpl instance) =>
    <String, dynamic>{
      'name': instance.name,
      'latitude': instance.latitude,
      'longitude': instance.longitude,
      'temperature': instance.temperature,
      'weatherCode': instance.weatherCode,
      'hourlyForecasts': instance.hourlyForecasts,
    };

_$HourlyForecastImpl _$$HourlyForecastImplFromJson(Map<String, dynamic> json) =>
    _$HourlyForecastImpl(
      time: json['time'] as String,
      temperature: (json['temperature'] as num).toDouble(),
      weatherCode: (json['weatherCode'] as num).toInt(),
    );

Map<String, dynamic> _$$HourlyForecastImplToJson(
        _$HourlyForecastImpl instance) =>
    <String, dynamic>{
      'time': instance.time,
      'temperature': instance.temperature,
      'weatherCode': instance.weatherCode,
    };
