import 'package:flutter_test/flutter_test.dart';
import 'package:codemagic_flutter_app/models/weather.dart';
import 'package:codemagic_flutter_app/models/city.dart';

void main() {
  group('weatherDescription', () {
    test('returns Clear sky for code 0', () {
      expect(weatherDescription(0, true), 'Clear sky');
    });

    test('returns Partly cloudy for code 2', () {
      expect(weatherDescription(2, true), 'Partly cloudy');
    });

    test('returns Rain for code 61', () {
      expect(weatherDescription(61, true), 'Rain');
    });

    test('returns Thunderstorm for code 95', () {
      expect(weatherDescription(95, true), 'Thunderstorm');
    });

    test('returns Unknown for unrecognized code', () {
      expect(weatherDescription(999, true), 'Unknown');
    });
  });

  group('weatherIcon', () {
    test('returns sun for clear day', () {
      expect(weatherIcon(0, true), '☀️');
    });

    test('returns moon for clear night', () {
      expect(weatherIcon(0, false), '🌙');
    });

    test('returns rain icon for rain', () {
      expect(weatherIcon(63, true), '🌧️');
    });
  });

  group('CurrentWeather.fromJson', () {
    test('parses JSON correctly', () {
      final json = {
        'current': {
          'temperature_2m': 22.5,
          'apparent_temperature': 21.0,
          'relative_humidity_2m': 65,
          'wind_speed_10m': 12.3,
          'weather_code': 2,
          'is_day': 1,
        },
      };

      final weather = CurrentWeather.fromJson(json);
      expect(weather.temperature, 22.5);
      expect(weather.feelsLike, 21.0);
      expect(weather.humidity, 65);
      expect(weather.windSpeed, 12.3);
      expect(weather.weatherCode, 2);
      expect(weather.isDay, true);
      expect(weather.description, 'Partly cloudy');
    });
  });

  group('City', () {
    test('fromJson and toJson roundtrip', () {
      final json = {
        'name': 'Tokyo',
        'country': 'Japan',
        'latitude': 35.6762,
        'longitude': 139.6503,
      };

      final city = City.fromJson(json);
      expect(city.name, 'Tokyo');
      expect(city.country, 'Japan');
      expect(city.toJson(), json);
    });
  });
}
