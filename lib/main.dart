import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(
    fileName: "/Users/ataberkcinetci/Downloads/weather_app-main/.env",
  );
  print("✅ OPENWEATHER_KEY = ${dotenv.env['OPENWEATHER_KEY']}");

  runApp(const ProviderScope(child: MyApp()));
}
