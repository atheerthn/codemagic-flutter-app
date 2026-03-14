import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/weather.dart';
import '../models/city.dart';
import '../services/weather_service.dart';
import '../services/storage_service.dart';
import '../widgets/hourly_forecast_card.dart';
import '../widgets/daily_forecast_card.dart';
import '../widgets/weather_detail_card.dart';
import 'search_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _weatherService = WeatherService();
  final _storageService = StorageService();

  WeatherData? _weather;
  City _city = const City(
    name: 'London',
    country: 'United Kingdom',
    latitude: 51.5074,
    longitude: -0.1278,
  );
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadSavedCity();
  }

  Future<void> _loadSavedCity() async {
    final saved = await _storageService.getLastCity();
    if (saved != null) {
      _city = saved;
    }
    _fetchWeather();
  }

  Future<void> _fetchWeather() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final weather = await _weatherService.getWeather(
        _city.latitude,
        _city.longitude,
      );
      setState(() {
        _weather = weather;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  Future<void> _openSearch() async {
    final city = await Navigator.push<City>(
      context,
      MaterialPageRoute(builder: (_) => const SearchScreen()),
    );
    if (city != null) {
      setState(() => _city = city);
      await _storageService.saveLastCity(city);
      _fetchWeather();
    }
  }

  @override
  void dispose() {
    _weatherService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: _fetchWeather,
        child: CustomScrollView(
          slivers: [
            SliverAppBar.large(
              title: Text(_city.name),
              actions: [
                IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: _openSearch,
                ),
                IconButton(
                  icon: const Icon(Icons.settings),
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const SettingsScreen()),
                  ).then((_) => _fetchWeather()),
                ),
              ],
            ),
            if (_loading)
              const SliverFillRemaining(
                child: Center(child: CircularProgressIndicator()),
              )
            else if (_error != null)
              SliverFillRemaining(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.cloud_off, size: 64, color: Colors.grey),
                      const SizedBox(height: 16),
                      Text(_error!, style: theme.textTheme.bodyLarge),
                      const SizedBox(height: 16),
                      FilledButton.icon(
                        onPressed: _fetchWeather,
                        icon: const Icon(Icons.refresh),
                        label: const Text('Retry'),
                      ),
                    ],
                  ),
                ),
              )
            else if (_weather != null)
              ..._buildWeatherContent(theme),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildWeatherContent(ThemeData theme) {
    final w = _weather!;
    final now = DateFormat('EEEE, MMM d • h:mm a').format(DateTime.now());

    return [
      // Current weather hero
      SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: [
              Text(now, style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              )),
              const SizedBox(height: 8),
              Text(
                w.current.icon,
                style: const TextStyle(fontSize: 80),
              ),
              Text(
                '${w.current.temperature.round()}°',
                style: theme.textTheme.displayLarge?.copyWith(
                  fontWeight: FontWeight.w300,
                  fontSize: 96,
                ),
              ),
              Text(
                w.current.description,
                style: theme.textTheme.headlineSmall,
              ),
              Text(
                'Feels like ${w.current.feelsLike.round()}°',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),

      // Weather details row
      SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              Expanded(child: WeatherDetailCard(
                icon: Icons.water_drop,
                label: 'Humidity',
                value: '${w.current.humidity}%',
              )),
              const SizedBox(width: 8),
              Expanded(child: WeatherDetailCard(
                icon: Icons.air,
                label: 'Wind',
                value: '${w.current.windSpeed.round()} km/h',
              )),
            ],
          ),
        ),
      ),

      const SliverToBoxAdapter(child: SizedBox(height: 24)),

      // Hourly forecast
      SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text('Hourly Forecast', style: theme.textTheme.titleMedium),
        ),
      ),
      const SliverToBoxAdapter(child: SizedBox(height: 8)),
      SliverToBoxAdapter(
        child: SizedBox(
          height: 120,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: w.hourly.length,
            itemBuilder: (_, i) => HourlyForecastCard(forecast: w.hourly[i]),
          ),
        ),
      ),

      const SliverToBoxAdapter(child: SizedBox(height: 24)),

      // 7-day forecast
      SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text('7-Day Forecast', style: theme.textTheme.titleMedium),
        ),
      ),
      const SliverToBoxAdapter(child: SizedBox(height: 8)),
      SliverList(
        delegate: SliverChildBuilderDelegate(
          (_, i) => DailyForecastCard(forecast: w.daily[i]),
          childCount: w.daily.length,
        ),
      ),
      const SliverToBoxAdapter(child: SizedBox(height: 32)),
    ];
  }
}
