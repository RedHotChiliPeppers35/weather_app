import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:weather/weather.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ForecastItem {
  final DateTime time;
  final double temp;
  final String description;

  ForecastItem({
    required this.time,
    required this.temp,
    required this.description,
  });
}

class WeatherService {
  final WeatherFactory _weatherFactory = WeatherFactory(
    dotenv.env['OPENWEATHER_KEY']!,
  );

  String get apiKey => dotenv.env['OPENWEATHER_KEY']!;

  Future<Weather?> getWeather(double lat, double lng) async {
    return _weatherFactory.currentWeatherByLocation(lat, lng);
  }

  Future<List<ForecastItem>> getForecast(double lat, double lng) async {
    final url =
        'https://api.openweathermap.org/data/2.5/forecast?lat=$lat&lon=$lng&appid=${dotenv.env['OPENWEATHER_KEY']}&units=metric';

    final response = await http.get(Uri.parse(url));

    if (response.statusCode != 200) {
      throw Exception('Failed to load forecast: ${response.statusCode}');
    }

    final decoded = jsonDecode(response.body);
    final list = decoded['list'] as List;

    return list.map((e) {
      final date = DateTime.parse(e['dt_txt']);
      final temp = (e['main']['temp'] as num).toDouble();
      final desc = e['weather'][0]['description'] as String;
      return ForecastItem(time: date, temp: temp, description: desc);
    }).toList();
  }

  Future<Weather> getWeatherByCity(String city) async {
    return await _weatherFactory.currentWeatherByCityName(city);
  }

  Future<List<Weather>> getForecastByCity(String city) async {
    return await _weatherFactory.fiveDayForecastByCityName(city);
  }
}
