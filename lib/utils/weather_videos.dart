/// Maps weather conditions to video backgrounds for both day & night.
/// Each key has a nested map: {'day': '...', 'night': '...'}
const Map<String, Map<String, String>> weatherVideoMap = {
  // ☀️ Clear / Sunny
  'clear': {
    'day': 'assets/videos/clear_day.mp4',
    'night': 'assets/videos/clear_night.mp4',
  },
  'sunny': {
    'day': 'assets/videos/clear_day.mp4',
    'night': 'assets/videos/clear_night.mp4',
  },
  'bright': {
    'day': 'assets/videos/clear_day.mp4',
    'night': 'assets/videos/clear_night.mp4',
  },

  // 🌤️ Partly Cloudy
  'few clouds': {
    'day': 'assets/videos/partly_cloudy_day.mp4',
    'night': 'assets/videos/partly_cloudy_night.mp4',
  },
  'partly cloudy': {
    'day': 'assets/videos/partly_cloudy_day.mp4',
    'night': 'assets/videos/partly_cloudy_night.mp4',
  },
  'scattered clouds': {
    'day': 'assets/videos/partly_cloudy_day.mp4',
    'night': 'assets/videos/partly_cloudy_night.mp4',
  },

  // ☁️ Cloudy / Overcast
  'cloudy': {
    'day': 'assets/videos/cloudy_day.mp4',
    'night': 'assets/videos/cloudy_night.mp4',
  },
  'overcast': {
    'day': 'assets/videos/cloudy_day.mp4',
    'night': 'assets/videos/cloudy_night.mp4',
  },
  'broken clouds': {
    'day': 'assets/videos/cloudy_day.mp4',
    'night': 'assets/videos/cloudy_night.mp4',
  },

  // 🌧 Rain / Showers
  'rain': {
    'day': 'assets/videos/rainy_day.mp4',
    'night': 'assets/videos/rainy_night.mp4',
  },
  'light rain': {
    'day': 'assets/videos/rainy_day.mp4',
    'night': 'assets/videos/rainy_night.mp4',
  },
  'showers': {
    'day': 'assets/videos/rainy_day.mp4',
    'night': 'assets/videos/rainy_night.mp4',
  },
  'drizzle': {
    'day': 'assets/videos/rainy_day.mp4',
    'night': 'assets/videos/rainy_night.mp4',
  },

  // 🌩 Thunderstorm
  'thunderstorm': {
    'day': 'assets/videos/thunderstorm_day.mp4',
    'night': 'assets/videos/thunderstorm_night.mp4',
  },
  'storm': {
    'day': 'assets/videos/thunderstorm_day.mp4',
    'night': 'assets/videos/thunderstorm_night.mp4',
  },
  'lightning': {
    'day': 'assets/videos/thunderstorm_day.mp4',
    'night': 'assets/videos/thunderstorm_night.mp4',
  },

  // ❄️ Snow / Blizzard
  'snow': {
    'day': 'assets/videos/snowy_day.mp4',
    'night': 'assets/videos/snowy_night.mp4',
  },
  'light snow': {
    'day': 'assets/videos/snowy_day.mp4',
    'night': 'assets/videos/snowy_night.mp4',
  },
  'blizzard': {
    'day': 'assets/videos/snowy_day.mp4',
    'night': 'assets/videos/snowy_night.mp4',
  },
  'sleet': {
    'day': 'assets/videos/snowy_day.mp4',
    'night': 'assets/videos/snowy_night.mp4',
  },

  // 🌫 Fog / Mist / Haze
  'fog': {
    'day': 'assets/videos/fogy_day.mp4',
    'night': 'assets/videos/fogy_night.mp4',
  },
  'mist': {
    'day': 'assets/videos/fogy_day.mp4',
    'night': 'assets/videos/fogy_night.mp4',
  },
  'haze': {
    'day': 'assets/videos/fogy_day.mp4',
    'night': 'assets/videos/fogy_night.mp4',
  },
  'smoke': {
    'day': 'assets/videos/fogy_day.mp4',
    'night': 'assets/videos/fogy_night.mp4',
  },

  // 🌪 Wind / Dust / Sandstorm
  'windy': {
    'day': 'assets/videos/windy_day.mp4',
    'night': 'assets/videos/windy_night.mp4',
  },
  'dust': {
    'day': 'assets/videos/windy_day.mp4',
    'night': 'assets/videos/windy_night.mp4',
  },
  'sandstorm': {
    'day': 'assets/videos/windy_day.mp4',
    'night': 'assets/videos/windy_night.mp4',
  },
};

/// Returns the appropriate video file path based on weather and time.
String getVideoForWeather(String description, bool isDay) {
  final lower = description.toLowerCase();
  for (final entry in weatherVideoMap.entries) {
    if (lower.contains(entry.key)) {
      return entry.value[isDay ? 'day' : 'night']!;
    }
  }
  // Fallback defaults
  return isDay
      ? 'assets/videos/default_day.mp4'
      : 'assets/videos/default_night.mp4';
}
