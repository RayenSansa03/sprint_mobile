// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'weather_models.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

LocationWeather _$LocationWeatherFromJson(Map<String, dynamic> json) {
  return _LocationWeather.fromJson(json);
}

/// @nodoc
mixin _$LocationWeather {
  String get name => throw _privateConstructorUsedError;
  double get latitude => throw _privateConstructorUsedError;
  double get longitude => throw _privateConstructorUsedError;
  double get temperature => throw _privateConstructorUsedError;
  int get weatherCode => throw _privateConstructorUsedError;
  List<HourlyForecast> get hourlyForecasts =>
      throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $LocationWeatherCopyWith<LocationWeather> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $LocationWeatherCopyWith<$Res> {
  factory $LocationWeatherCopyWith(
          LocationWeather value, $Res Function(LocationWeather) then) =
      _$LocationWeatherCopyWithImpl<$Res, LocationWeather>;
  @useResult
  $Res call(
      {String name,
      double latitude,
      double longitude,
      double temperature,
      int weatherCode,
      List<HourlyForecast> hourlyForecasts});
}

/// @nodoc
class _$LocationWeatherCopyWithImpl<$Res, $Val extends LocationWeather>
    implements $LocationWeatherCopyWith<$Res> {
  _$LocationWeatherCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? name = null,
    Object? latitude = null,
    Object? longitude = null,
    Object? temperature = null,
    Object? weatherCode = null,
    Object? hourlyForecasts = null,
  }) {
    return _then(_value.copyWith(
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      latitude: null == latitude
          ? _value.latitude
          : latitude // ignore: cast_nullable_to_non_nullable
              as double,
      longitude: null == longitude
          ? _value.longitude
          : longitude // ignore: cast_nullable_to_non_nullable
              as double,
      temperature: null == temperature
          ? _value.temperature
          : temperature // ignore: cast_nullable_to_non_nullable
              as double,
      weatherCode: null == weatherCode
          ? _value.weatherCode
          : weatherCode // ignore: cast_nullable_to_non_nullable
              as int,
      hourlyForecasts: null == hourlyForecasts
          ? _value.hourlyForecasts
          : hourlyForecasts // ignore: cast_nullable_to_non_nullable
              as List<HourlyForecast>,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$LocationWeatherImplCopyWith<$Res>
    implements $LocationWeatherCopyWith<$Res> {
  factory _$$LocationWeatherImplCopyWith(_$LocationWeatherImpl value,
          $Res Function(_$LocationWeatherImpl) then) =
      __$$LocationWeatherImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String name,
      double latitude,
      double longitude,
      double temperature,
      int weatherCode,
      List<HourlyForecast> hourlyForecasts});
}

/// @nodoc
class __$$LocationWeatherImplCopyWithImpl<$Res>
    extends _$LocationWeatherCopyWithImpl<$Res, _$LocationWeatherImpl>
    implements _$$LocationWeatherImplCopyWith<$Res> {
  __$$LocationWeatherImplCopyWithImpl(
      _$LocationWeatherImpl _value, $Res Function(_$LocationWeatherImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? name = null,
    Object? latitude = null,
    Object? longitude = null,
    Object? temperature = null,
    Object? weatherCode = null,
    Object? hourlyForecasts = null,
  }) {
    return _then(_$LocationWeatherImpl(
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      latitude: null == latitude
          ? _value.latitude
          : latitude // ignore: cast_nullable_to_non_nullable
              as double,
      longitude: null == longitude
          ? _value.longitude
          : longitude // ignore: cast_nullable_to_non_nullable
              as double,
      temperature: null == temperature
          ? _value.temperature
          : temperature // ignore: cast_nullable_to_non_nullable
              as double,
      weatherCode: null == weatherCode
          ? _value.weatherCode
          : weatherCode // ignore: cast_nullable_to_non_nullable
              as int,
      hourlyForecasts: null == hourlyForecasts
          ? _value._hourlyForecasts
          : hourlyForecasts // ignore: cast_nullable_to_non_nullable
              as List<HourlyForecast>,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$LocationWeatherImpl implements _LocationWeather {
  const _$LocationWeatherImpl(
      {required this.name,
      required this.latitude,
      required this.longitude,
      required this.temperature,
      required this.weatherCode,
      final List<HourlyForecast> hourlyForecasts = const []})
      : _hourlyForecasts = hourlyForecasts;

  factory _$LocationWeatherImpl.fromJson(Map<String, dynamic> json) =>
      _$$LocationWeatherImplFromJson(json);

  @override
  final String name;
  @override
  final double latitude;
  @override
  final double longitude;
  @override
  final double temperature;
  @override
  final int weatherCode;
  final List<HourlyForecast> _hourlyForecasts;
  @override
  @JsonKey()
  List<HourlyForecast> get hourlyForecasts {
    if (_hourlyForecasts is EqualUnmodifiableListView) return _hourlyForecasts;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_hourlyForecasts);
  }

  @override
  String toString() {
    return 'LocationWeather(name: $name, latitude: $latitude, longitude: $longitude, temperature: $temperature, weatherCode: $weatherCode, hourlyForecasts: $hourlyForecasts)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$LocationWeatherImpl &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.latitude, latitude) ||
                other.latitude == latitude) &&
            (identical(other.longitude, longitude) ||
                other.longitude == longitude) &&
            (identical(other.temperature, temperature) ||
                other.temperature == temperature) &&
            (identical(other.weatherCode, weatherCode) ||
                other.weatherCode == weatherCode) &&
            const DeepCollectionEquality()
                .equals(other._hourlyForecasts, _hourlyForecasts));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      name,
      latitude,
      longitude,
      temperature,
      weatherCode,
      const DeepCollectionEquality().hash(_hourlyForecasts));

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$LocationWeatherImplCopyWith<_$LocationWeatherImpl> get copyWith =>
      __$$LocationWeatherImplCopyWithImpl<_$LocationWeatherImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$LocationWeatherImplToJson(
      this,
    );
  }
}

abstract class _LocationWeather implements LocationWeather {
  const factory _LocationWeather(
      {required final String name,
      required final double latitude,
      required final double longitude,
      required final double temperature,
      required final int weatherCode,
      final List<HourlyForecast> hourlyForecasts}) = _$LocationWeatherImpl;

  factory _LocationWeather.fromJson(Map<String, dynamic> json) =
      _$LocationWeatherImpl.fromJson;

  @override
  String get name;
  @override
  double get latitude;
  @override
  double get longitude;
  @override
  double get temperature;
  @override
  int get weatherCode;
  @override
  List<HourlyForecast> get hourlyForecasts;
  @override
  @JsonKey(ignore: true)
  _$$LocationWeatherImplCopyWith<_$LocationWeatherImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

HourlyForecast _$HourlyForecastFromJson(Map<String, dynamic> json) {
  return _HourlyForecast.fromJson(json);
}

/// @nodoc
mixin _$HourlyForecast {
  String get time => throw _privateConstructorUsedError;
  double get temperature => throw _privateConstructorUsedError;
  int get weatherCode => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $HourlyForecastCopyWith<HourlyForecast> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $HourlyForecastCopyWith<$Res> {
  factory $HourlyForecastCopyWith(
          HourlyForecast value, $Res Function(HourlyForecast) then) =
      _$HourlyForecastCopyWithImpl<$Res, HourlyForecast>;
  @useResult
  $Res call({String time, double temperature, int weatherCode});
}

/// @nodoc
class _$HourlyForecastCopyWithImpl<$Res, $Val extends HourlyForecast>
    implements $HourlyForecastCopyWith<$Res> {
  _$HourlyForecastCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? time = null,
    Object? temperature = null,
    Object? weatherCode = null,
  }) {
    return _then(_value.copyWith(
      time: null == time
          ? _value.time
          : time // ignore: cast_nullable_to_non_nullable
              as String,
      temperature: null == temperature
          ? _value.temperature
          : temperature // ignore: cast_nullable_to_non_nullable
              as double,
      weatherCode: null == weatherCode
          ? _value.weatherCode
          : weatherCode // ignore: cast_nullable_to_non_nullable
              as int,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$HourlyForecastImplCopyWith<$Res>
    implements $HourlyForecastCopyWith<$Res> {
  factory _$$HourlyForecastImplCopyWith(_$HourlyForecastImpl value,
          $Res Function(_$HourlyForecastImpl) then) =
      __$$HourlyForecastImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String time, double temperature, int weatherCode});
}

/// @nodoc
class __$$HourlyForecastImplCopyWithImpl<$Res>
    extends _$HourlyForecastCopyWithImpl<$Res, _$HourlyForecastImpl>
    implements _$$HourlyForecastImplCopyWith<$Res> {
  __$$HourlyForecastImplCopyWithImpl(
      _$HourlyForecastImpl _value, $Res Function(_$HourlyForecastImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? time = null,
    Object? temperature = null,
    Object? weatherCode = null,
  }) {
    return _then(_$HourlyForecastImpl(
      time: null == time
          ? _value.time
          : time // ignore: cast_nullable_to_non_nullable
              as String,
      temperature: null == temperature
          ? _value.temperature
          : temperature // ignore: cast_nullable_to_non_nullable
              as double,
      weatherCode: null == weatherCode
          ? _value.weatherCode
          : weatherCode // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$HourlyForecastImpl implements _HourlyForecast {
  const _$HourlyForecastImpl(
      {required this.time,
      required this.temperature,
      required this.weatherCode});

  factory _$HourlyForecastImpl.fromJson(Map<String, dynamic> json) =>
      _$$HourlyForecastImplFromJson(json);

  @override
  final String time;
  @override
  final double temperature;
  @override
  final int weatherCode;

  @override
  String toString() {
    return 'HourlyForecast(time: $time, temperature: $temperature, weatherCode: $weatherCode)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$HourlyForecastImpl &&
            (identical(other.time, time) || other.time == time) &&
            (identical(other.temperature, temperature) ||
                other.temperature == temperature) &&
            (identical(other.weatherCode, weatherCode) ||
                other.weatherCode == weatherCode));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, time, temperature, weatherCode);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$HourlyForecastImplCopyWith<_$HourlyForecastImpl> get copyWith =>
      __$$HourlyForecastImplCopyWithImpl<_$HourlyForecastImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$HourlyForecastImplToJson(
      this,
    );
  }
}

abstract class _HourlyForecast implements HourlyForecast {
  const factory _HourlyForecast(
      {required final String time,
      required final double temperature,
      required final int weatherCode}) = _$HourlyForecastImpl;

  factory _HourlyForecast.fromJson(Map<String, dynamic> json) =
      _$HourlyForecastImpl.fromJson;

  @override
  String get time;
  @override
  double get temperature;
  @override
  int get weatherCode;
  @override
  @JsonKey(ignore: true)
  _$$HourlyForecastImplCopyWith<_$HourlyForecastImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
