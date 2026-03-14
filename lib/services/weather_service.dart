import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/weather.dart';
import '../models/city.dart';

class WeatherService {
  static const _baseUrl = 'https://api.open-meteo.com/v1';
  static const _geocodeUrl = 'https://geocoding-api.open-meteo.com/v1';

  final http.Client _client;

  WeatherService({http.Client? client}) : _client = client ?? http.Client();

  Future<WeatherData> getWeather(double lat, double lon) async {
    final url = Uri.parse(
      '$_baseUrl/forecast?latitude=$lat&longitude=$lon'
      '&current=temperature_2m,relative_humidity_2m,apparent_temperature,'
      'is_day,weather_code,wind_speed_10m'
      '&hourly=temperature_2m,weather_code,is_day'
      '&daily=weather_code,temperature_2m_max,temperature_2m_min,'
      'precipitation_probability_max'
      '&timezone=auto&forecast_days=7',
    );

    final response = await _client.get(url);
    if (response.statusCode != 200) {
      throw WeatherException('Failed to fetch weather: ${response.statusCode}');
    }

    final json = jsonDecode(response.body) as Map<String, dynamic>;
    return WeatherData.fromJson(json);
  }

  Future<List<City>> searchCity(String query) async {
    if (query.trim().isEmpty) return [];

    final url = Uri.parse(
      '$_geocodeUrl/search?name=${Uri.encodeComponent(query)}'
      '&count=5&language=en&format=json',
    );

    final response = await _client.get(url);
    if (response.statusCode != 200) {
      throw WeatherException('Failed to search cities: ${response.statusCode}');
    }

    final json = jsonDecode(response.body) as Map<String, dynamic>;
    final results = json['results'] as List?;
    if (results == null) return [];

    return results
        .map((r) => City.fromJson(r as Map<String, dynamic>))
        .toList();
  }

  void dispose() => _client.close();
}

class WeatherException implements Exception {
  final String message;
  WeatherException(this.message);

  @override
  String toString() => message;
}
