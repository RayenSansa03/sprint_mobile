import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'weather_models.dart';

part 'weather_service.g.dart';

@riverpod
class WeatherService extends _$WeatherService {
  late Dio _dio;

  @override
  FutureOr<void> build() {
    _dio = Dio(BaseOptions(baseUrl: 'https://api.open-meteo.com/v1'));
  }

  Future<LocationWeather> fetchWeather(String name, double lat, double lon) async {
    try {
      final response = await _dio.get(
        '/forecast',
        queryParameters: {
          'latitude': lat,
          'longitude': lon,
          'current': 'temperature_2m,weather_code',
          'hourly': 'temperature_2m,weather_code',
          'timezone': 'auto',
          'forecast_days': 1,
        },
      );

      final data = response.data;
      final current = data['current'];
      final hourly = data['hourly'];

      final List<HourlyForecast> hourlyForecasts = [];
      for (int i = 0; i < (hourly['time'] as List).length; i++) {
        // Only take the next 24 hours from the current time if possible, 
        // or just the first 24 if we only requested 1 day.
        hourlyForecasts.add(HourlyForecast(
          time: hourly['time'][i],
          temperature: hourly['temperature_2m'][i].toDouble(),
          weatherCode: hourly['weather_code'][i],
        ));
      }

      return LocationWeather(
        name: name,
        latitude: lat,
        longitude: lon,
        temperature: current['temperature_2m'].toDouble(),
        weatherCode: current['weather_code'],
        hourlyForecasts: hourlyForecasts,
      );
    } catch (e) {
      throw Exception('Failed to fetch weather for $name: $e');
    }
  }

  Future<List<LocationWeather>> fetchAllLocations() async {
    final locations = [
      {'name': 'Mornag', 'lat': 36.6775, 'lon': 10.2878},
      {'name': 'Sidi Thabet', 'lat': 36.9103, 'lon': 10.0401},
      {'name': 'Sfax', 'lat': 34.7400, 'lon': 10.7600},
    ];

    return Future.wait(
      locations.map((loc) => fetchWeather(
            loc['name'] as String,
            loc['lat'] as double,
            loc['lon'] as double,
          )),
    );
  }
}

@riverpod
Future<List<LocationWeather>> allWeather(AllWeatherRef ref) async {
  return ref.watch(weatherServiceProvider.notifier).fetchAllLocations();
}
