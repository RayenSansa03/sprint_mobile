// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'weather_service.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$allWeatherHash() => r'3096fac046c830a1b76385d089c75f641ac9fd08';

/// See also [allWeather].
@ProviderFor(allWeather)
final allWeatherProvider =
    AutoDisposeFutureProvider<List<LocationWeather>>.internal(
  allWeather,
  name: r'allWeatherProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$allWeatherHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef AllWeatherRef = AutoDisposeFutureProviderRef<List<LocationWeather>>;
String _$weatherServiceHash() => r'7e465e7638ff4dd70582c935674ae1a8af0f6d3f';

/// See also [WeatherService].
@ProviderFor(WeatherService)
final weatherServiceProvider =
    AutoDisposeAsyncNotifierProvider<WeatherService, void>.internal(
  WeatherService.new,
  name: r'weatherServiceProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$weatherServiceHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$WeatherService = AutoDisposeAsyncNotifier<void>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
