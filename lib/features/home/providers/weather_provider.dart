import 'package:flutter_application_1/features/home/service/weather_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:weather/weather.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

final weatherNotifierProvider =
    StateNotifierProvider<WeatherNotifier, AsyncValue<WeatherViewState>>(
      (ref) => WeatherNotifier(WeatherService()),
    );

class WeatherViewState {
  final Weather? weather;
  final bool isDay;
  final String? locationText;
  final List<ForecastItem> forecast;

  WeatherViewState({
    this.weather,
    this.isDay = true,
    this.locationText,
    this.forecast = const [],
  });

  WeatherViewState copyWith({
    Weather? weather,
    bool? isDay,
    String? locationText,
    List<ForecastItem>? forecast,
  }) {
    return WeatherViewState(
      weather: weather ?? this.weather,
      isDay: isDay ?? this.isDay,
      locationText: locationText ?? this.locationText,
      forecast: forecast ?? this.forecast,
    );
  }
}

class WeatherNotifier extends StateNotifier<AsyncValue<WeatherViewState>> {
  final WeatherService _weather;

  WeatherNotifier(this._weather) : super(const AsyncLoading()) {
    refresh();
  }

  /// 🔄 Fetch current location weather and forecast
  Future<void> refresh() async {
    state = const AsyncLoading();
    try {
      final position = await _getPosition();
      if (position == null) {
        state = const AsyncError('Location unavailable', StackTrace.empty);
        return;
      }

      final currentWeather = await _weather.getWeather(
        position.latitude,
        position.longitude,
      );
      final isDay = await _isDayTime(position.latitude, position.longitude);

      final forecast = await _weather.getForecast(
        position.latitude,
        position.longitude,
      );

      state = AsyncData(
        WeatherViewState(
          weather: currentWeather,
          isDay: isDay,
          forecast: forecast,
          locationText:
              'Lat: ${position.latitude.toStringAsFixed(4)}, Lng: ${position.longitude.toStringAsFixed(4)}',
        ),
      );
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }

  Future<void> fetchWeatherByCity(String city) async {
    state = const AsyncLoading();
    try {
      print('🔍 Fetching coordinates for city: $city');

      // Step 1️⃣ Get accurate coordinates from OpenWeather Geocoding API
      final geoUrl =
          'https://api.openweathermap.org/geo/1.0/direct?q=$city&limit=1&appid=${_weather.apiKey}';
      final geoResponse = await http.get(Uri.parse(geoUrl));

      if (geoResponse.statusCode != 200) {
        throw Exception('Failed to get coordinates for $city');
      }

      final geoData = jsonDecode(geoResponse.body);
      if (geoData.isEmpty) throw Exception('City not found: $city');

      final lat = (geoData[0]['lat'] as num).toDouble();
      final lon = (geoData[0]['lon'] as num).toDouble();

      print('📍 Coordinates for $city → lat=$lat, lon=$lon');

      // Step 2️⃣ Get weather and forecast using WeatherFactory
      final weather = await _weather.getWeatherByCity(city);
      final forecastWeather = await _weather.getForecastByCity(city);

      // Step 3️⃣ Calculate correct day/night based on the city’s coordinates
      final isDay = await _isDayTime(lat, lon);

      // Step 4️⃣ Convert forecast
      final forecast =
          forecastWeather.map((w) {
            return ForecastItem(
              time: w.date ?? DateTime.now(),
              temp: w.temperature?.celsius ?? 0,
              description: w.weatherDescription ?? 'N/A',
            );
          }).toList();

      // Step 5️⃣ Update state
      state = AsyncData(
        WeatherViewState(
          weather: weather,
          forecast: forecast,
          isDay: isDay,
          locationText:
              '${weather.areaName ?? city} (${lat.toStringAsFixed(2)}, ${lon.toStringAsFixed(2)})',
        ),
      );

      print('✅ Weather for $city loaded (lat=$lat, lon=$lon). isDay=$isDay');
    } catch (e, st) {
      print('❌ Error fetching weather for $city: $e');
      state = AsyncError(e, st);
    }
  }

  Future<Position?> _getPosition() async {
    if (!await Geolocator.isLocationServiceEnabled()) return null;

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return null;
    }

    if (permission == LocationPermission.deniedForever) return null;

    return Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 0,
      ),
    );
  }

  Future<bool> _isDayTime(double lat, double lng) async {
    try {
      final response = await http.get(
        Uri.parse(
          'https://api.sunrise-sunset.org/json?lat=$lat&lng=$lng&formatted=0',
        ),
      );

      if (response.statusCode != 200) {
        print('❌ Sunrise API failed with ${response.statusCode}');
        return true;
      }

      final data = jsonDecode(response.body);
      final sunriseUtc = DateTime.parse(data['results']['sunrise']).toUtc();
      final sunsetUtc = DateTime.parse(data['results']['sunset']).toUtc();

      // convert UTC -> local
      final sunriseLocal = sunriseUtc.toLocal();
      final sunsetLocal = sunsetUtc.toLocal();
      final nowLocal = DateTime.now();

      final isDay =
          nowLocal.isAfter(sunriseLocal) && nowLocal.isBefore(sunsetLocal);

      print('🕒 Checking daylight for lat=$lat, lng=$lng');
      print('🌅 Sunrise (local): $sunriseLocal');
      print('🌇 Sunset (local):  $sunsetLocal');
      print('🕰 Now (local):     $nowLocal');
      print('☀️ isDay (final):   $isDay');

      return isDay;
    } catch (e) {
      print('⚠️ Error in _isDayTime: $e');
      return true;
    }
  }
}
