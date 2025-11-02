import 'dart:ui';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/features/home/service/weather_service.dart';

import 'package:flutter_application_1/utils/weather_videos.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:video_player/video_player.dart';
import '../providers/weather_provider.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage>
    with WidgetsBindingObserver {
  Timer? _autoRefreshTimer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    _autoRefreshTimer = Timer.periodic(
      const Duration(minutes: 15),
      (_) => _refreshWeather(),
    );
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _autoRefreshTimer?.cancel();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) _refreshWeather();
  }

  void _refreshWeather() {
    ref.read(weatherNotifierProvider.notifier).refresh();
  }

  IconData _getWeatherIcon(String description, bool isDay) {
    final desc = description.toLowerCase();
    if (desc.contains('cloud')) return Icons.cloud;
    if (desc.contains('rain')) return Icons.beach_access;
    if (desc.contains('snow')) return Icons.ac_unit;
    if (desc.contains('storm') || desc.contains('thunder'))
      return Icons.flash_on;
    if (desc.contains('mist') || desc.contains('fog')) return Icons.grain;
    return isDay ? Icons.wb_sunny : Icons.nights_stay;
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(weatherNotifierProvider);

    Color getCurrentIconColor(AsyncValue state) {
      if (state is AsyncData) {
        final data = state.value;
        return data.isDay ? Colors.black : Colors.white;
      }
      return Colors.grey;
    }

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        iconTheme: IconThemeData(color: getCurrentIconColor(state)),
        elevation: 0,
        backgroundColor: Colors.transparent,
        title: Text(
          'Weather App',
          style: TextStyle(color: getCurrentIconColor(state)),
        ),
        actions: [
          _SearchButton(ref: ref, iconColor: getCurrentIconColor(state)),
        ],
      ),
      body: state.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error:
            (err, _) => _Background(
              isDay: true,
              child: Center(child: Text('Error: $err')),
            ),
        data:
            (data) => _Background(
              isDay: data.isDay,
              weatherDescription: data.weather?.weatherDescription,
              child: Padding(
                padding: const EdgeInsets.only(top: kToolbarHeight + 100),
                child: SingleChildScrollView(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        const SizedBox(height: 20),
                        if (data.weather != null) ...[
                          Text(
                            data.weather!.areaName ?? 'Unknown',
                            style: Theme.of(
                              context,
                            ).textTheme.headlineSmall?.copyWith(
                              color: data.isDay ? Colors.black : Colors.white,
                            ),
                          ),
                          Text(
                            '${data.weather!.temperature?.celsius?.toStringAsFixed(1)}°C',
                            style: Theme.of(
                              context,
                            ).textTheme.displayLarge?.copyWith(
                              color: data.isDay ? Colors.black : Colors.white,
                            ),
                          ),
                          Text(
                            'Condition: ${data.weather!.weatherDescription ?? 'N/A'}',
                            style: Theme.of(
                              context,
                            ).textTheme.headlineSmall?.copyWith(
                              color: data.isDay ? Colors.black : Colors.white,
                            ),
                          ),
                          Icon(
                            _getWeatherIcon(
                              data.weather!.weatherDescription ?? '',
                              data.isDay,
                            ),
                            color:
                                data.isDay
                                    ? Colors.orangeAccent
                                    : Colors.blue[100],
                            size: 64,
                          ),
                          Text(
                            data.isDay ? '☀️ Daytime' : '🌙 Nighttime',
                            style: Theme.of(
                              context,
                            ).textTheme.bodyLarge?.copyWith(
                              color: data.isDay ? Colors.black : Colors.white,
                            ),
                          ),
                        ],
                        const SizedBox(height: 24),
                        _FrostedCard(
                          radius: 24,
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              children: [
                                if (data.forecast.isNotEmpty) ...[
                                  Text(
                                    '5-Day Forecast',
                                    style: Theme.of(
                                      context,
                                    ).textTheme.titleLarge?.copyWith(
                                      color:
                                          data.isDay
                                              ? Colors.black
                                              : Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  _ForecastList(
                                    forecast: data.forecast,
                                    isDay: data.isDay,
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton(
                          onPressed: _refreshWeather,
                          child: const Text('Refresh Now'),
                        ),
                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                ),
              ),
            ),
      ),
    );
  }
}

class _SearchButton extends StatefulWidget {
  final WidgetRef ref;
  final Color iconColor;

  const _SearchButton({required this.ref, required this.iconColor});

  @override
  State<_SearchButton> createState() => _SearchButtonState();
}

class _SearchButtonState extends State<_SearchButton> {
  void _showCitySearch() async {
    final city = await showSearch<String?>(
      context: context,
      delegate: CitySearchDelegate(),
    );

    if (city != null && city.isNotEmpty) {
      widget.ref
          .read(weatherNotifierProvider.notifier)
          .fetchWeatherByCity(city);
    }
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.search, color: widget.iconColor),
      onPressed: _showCitySearch,
    );
  }
}

class CitySearchDelegate extends SearchDelegate<String?> {
  final List<String> suggestions = [
    'New York',
    'London',
    'Paris',
    'Tokyo',
    'Berlin',
    'Istanbul',
    'Los Angeles',
    'Rome',
    'Toronto',
    'Seoul',
  ];

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(icon: const Icon(Icons.clear), onPressed: () => query = ''),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () => close(context, null),
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    if (query.isEmpty) {
      return const Center(child: Text('Enter a city name'));
    }
    return ListTile(
      title: Text('Search "$query"'),
      onTap: () => close(context, query),
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    final filtered =
        suggestions
            .where((city) => city.toLowerCase().contains(query.toLowerCase()))
            .toList();

    return ListView.builder(
      itemCount: filtered.length,
      itemBuilder: (context, index) {
        final city = filtered[index];
        return ListTile(title: Text(city), onTap: () => close(context, city));
      },
    );
  }
}

class _Background extends StatefulWidget {
  final bool isDay;
  final Widget child;
  final String? weatherDescription;

  const _Background({
    required this.isDay,
    required this.child,
    this.weatherDescription,
  });

  @override
  State<_Background> createState() => _BackgroundState();
}

class _BackgroundState extends State<_Background> {
  VideoPlayerController? _controller;
  String? _currentVideo;

  @override
  void initState() {
    super.initState();
    _initializeVideo();
  }

  @override
  void didUpdateWidget(covariant _Background oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Update video when weather or day/night changes
    if (oldWidget.weatherDescription != widget.weatherDescription ||
        oldWidget.isDay != widget.isDay) {
      _initializeVideo();
    }
  }

  void _initializeVideo() {
    final desc = widget.weatherDescription ?? '';
    final videoPath = getVideoForWeather(desc, widget.isDay);

    // Avoid reloading the same video
    if (_currentVideo == videoPath) return;

    _currentVideo = videoPath;

    // Dispose previous controller
    _controller?.dispose();

    // Create new controller
    final newController =
        VideoPlayerController.asset(videoPath)
          ..setLooping(true)
          ..setVolume(0.0);

    newController.initialize().then((_) {
      if (mounted) {
        newController.play();
        setState(() {});
      }
    });

    _controller = newController;
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        // 🎥 Background video
        if (_controller != null && _controller!.value.isInitialized)
          AnimatedOpacity(
            opacity: 1.0,
            duration: const Duration(seconds: 1),
            child: FittedBox(
              fit: BoxFit.cover,
              child: SizedBox(
                width: _controller!.value.size.width,
                height: _controller!.value.size.height,
                child: VideoPlayer(_controller!),
              ),
            ),
          )
        else
          // 🖼 Fallback background color before the video loads
          Container(
            color:
                widget.isDay
                    ? Colors.lightBlue.shade200
                    : Colors.indigo.shade900,
          ),

        // 🌫 Add a slight overlay for better text contrast
        Container(color: Colors.black.withOpacity(0.35)),

        // 🌤 Your actual content on top
        widget.child,
      ],
    );
  }
}

class _FrostedCard extends StatelessWidget {
  const _FrostedCard({required this.child, this.radius = 16});
  final Widget child;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          width: MediaQuery.of(context).size.width * 0.9,
          height: 400,
          decoration: BoxDecoration(
            color: Colors.grey.withOpacity(0.3),
            borderRadius: BorderRadius.circular(radius),
            border: Border.all(color: Colors.white.withOpacity(0.2)),
          ),
          child: SingleChildScrollView(child: child),
        ),
      ),
    );
  }
}

class _ForecastList extends StatelessWidget {
  final List<ForecastItem> forecast;
  final bool isDay;

  const _ForecastList({required this.forecast, required this.isDay});

  IconData _iconFor(String description) {
    final d = description.toLowerCase();
    if (d.contains('cloud')) return Icons.cloud;
    if (d.contains('rain')) return Icons.beach_access;
    if (d.contains('snow')) return Icons.ac_unit;
    if (d.contains('storm') || d.contains('thunder')) return Icons.flash_on;
    if (d.contains('mist') || d.contains('fog')) return Icons.grain;
    return Icons.wb_sunny;
  }

  @override
  Widget build(BuildContext context) {
    final textColor = isDay ? Colors.black : Colors.white;

    return Column(
      children: List.generate(forecast.length, (index) {
        final item = forecast[index];
        final date = item.time;
        final label =
            '${_dayName(date.weekday)} ${date.hour.toString().padLeft(2, '0')}:00';

        return Container(
          margin: EdgeInsets.only(
            top: index == 0 ? 4 : 8, // small, consistent top spacing
            bottom: 6,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: Colors.grey.withOpacity(0.25),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withOpacity(0.2)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(_iconFor(item.description), color: textColor, size: 30),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: TextStyle(
                        color: textColor,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      item.description,
                      style: TextStyle(
                        color: textColor.withOpacity(0.8),
                        fontSize: 12.5,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                '${item.temp.toStringAsFixed(1)}°C',
                style: TextStyle(
                  color: textColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 16.5,
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  String _dayName(int weekday) {
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return days[weekday - 1];
  }
}

Color getCurrentIconColor(AsyncValue state) {
  if (state is AsyncData) {
    final data = state.value;
    return data.isDay ? Colors.black : Colors.white;
  }
  return Colors.grey;
}

Color getBackgroundColor(AsyncValue state) {
  if (state is AsyncData) {
    final data = state.value;
    return data.isDay ? Colors.blue[200]! : Colors.indigo[700]!;
  }
  return Colors.grey;
}
