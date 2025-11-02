import 'dart:convert';
import 'package:http/http.dart' as http;

class DaytimeService {
  Future<bool> isDayTime(double lat, double lng) async {
    try {
      final response = await http.get(
        Uri.parse(
          'https://api.sunrise-sunset.org/json?lat=$lat&lng=$lng&formatted=0',
        ),
      );
      if (response.statusCode != 200) return true;
      final data = jsonDecode(response.body);
      final sunrise = DateTime.parse(data['results']['sunrise']);
      final sunset = DateTime.parse(data['results']['sunset']);
      final now = DateTime.now().toUtc();
      return now.isAfter(sunrise) && now.isBefore(sunset);
    } catch (_) {
      return true;
    }
  }
}
