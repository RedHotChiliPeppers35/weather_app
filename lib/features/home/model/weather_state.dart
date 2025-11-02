import 'package:weather/weather.dart';

class WeatherViewState {
  final Weather? weather;
  final bool isDay;
  final String? locationText;

  const WeatherViewState({this.weather, this.isDay = true, this.locationText});

  WeatherViewState copyWith({
    Weather? weather,
    bool? isDay,
    String? locationText,
  }) {
    return WeatherViewState(
      weather: weather ?? this.weather,
      isDay: isDay ?? this.isDay,
      locationText: locationText ?? this.locationText,
    );
  }
}
