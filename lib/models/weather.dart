class CurrentWeather {
  final double temperature;
  final double feelsLike;
  final int humidity;
  final double windSpeed;
  final int weatherCode;
  final bool isDay;

  CurrentWeather({
    required this.temperature,
    required this.feelsLike,
    required this.humidity,
    required this.windSpeed,
    required this.weatherCode,
    required this.isDay,
  });

  factory CurrentWeather.fromJson(Map<String, dynamic> json) {
    final current = json['current'];
    return CurrentWeather(
      temperature: (current['temperature_2m'] as num).toDouble(),
      feelsLike: (current['apparent_temperature'] as num).toDouble(),
      humidity: (current['relative_humidity_2m'] as num).toInt(),
      windSpeed: (current['wind_speed_10m'] as num).toDouble(),
      weatherCode: (current['weather_code'] as num).toInt(),
      isDay: (current['is_day'] as num) == 1,
    );
  }

  String get description => weatherDescription(weatherCode, isDay);
  String get icon => weatherIcon(weatherCode, isDay);
}

class DailyForecast {
  final DateTime date;
  final double tempMax;
  final double tempMin;
  final int weatherCode;
  final double precipProbability;

  DailyForecast({
    required this.date,
    required this.tempMax,
    required this.tempMin,
    required this.weatherCode,
    required this.precipProbability,
  });

  String get description => weatherDescription(weatherCode, true);
  String get icon => weatherIcon(weatherCode, true);
}

class HourlyForecast {
  final DateTime time;
  final double temperature;
  final int weatherCode;
  final bool isDay;

  HourlyForecast({
    required this.time,
    required this.temperature,
    required this.weatherCode,
    required this.isDay,
  });

  String get icon => weatherIcon(weatherCode, isDay);
}

class WeatherData {
  final CurrentWeather current;
  final List<DailyForecast> daily;
  final List<HourlyForecast> hourly;

  WeatherData({
    required this.current,
    required this.daily,
    required this.hourly,
  });

  factory WeatherData.fromJson(Map<String, dynamic> json) {
    final current = CurrentWeather.fromJson(json);

    final dailyData = json['daily'];
    final daily = <DailyForecast>[];
    final dates = dailyData['time'] as List;
    for (var i = 0; i < dates.length; i++) {
      daily.add(DailyForecast(
        date: DateTime.parse(dates[i]),
        tempMax: (dailyData['temperature_2m_max'][i] as num).toDouble(),
        tempMin: (dailyData['temperature_2m_min'][i] as num).toDouble(),
        weatherCode: (dailyData['weather_code'][i] as num).toInt(),
        precipProbability:
            (dailyData['precipitation_probability_max'][i] as num).toDouble(),
      ));
    }

    final hourlyData = json['hourly'];
    final hourly = <HourlyForecast>[];
    final times = hourlyData['time'] as List;
    final now = DateTime.now();
    for (var i = 0; i < times.length && hourly.length < 24; i++) {
      final time = DateTime.parse(times[i]);
      if (time.isAfter(now)) {
        hourly.add(HourlyForecast(
          time: time,
          temperature: (hourlyData['temperature_2m'][i] as num).toDouble(),
          weatherCode: (hourlyData['weather_code'][i] as num).toInt(),
          isDay: (hourlyData['is_day'][i] as num) == 1,
        ));
      }
    }

    return WeatherData(current: current, daily: daily, hourly: hourly);
  }
}

String weatherDescription(int code, bool isDay) {
  switch (code) {
    case 0:
      return 'Clear sky';
    case 1:
      return 'Mainly clear';
    case 2:
      return 'Partly cloudy';
    case 3:
      return 'Overcast';
    case 45:
    case 48:
      return 'Foggy';
    case 51:
    case 53:
    case 55:
      return 'Drizzle';
    case 61:
    case 63:
    case 65:
      return 'Rain';
    case 66:
    case 67:
      return 'Freezing rain';
    case 71:
    case 73:
    case 75:
      return 'Snow';
    case 77:
      return 'Snow grains';
    case 80:
    case 81:
    case 82:
      return 'Rain showers';
    case 85:
    case 86:
      return 'Snow showers';
    case 95:
      return 'Thunderstorm';
    case 96:
    case 99:
      return 'Thunderstorm with hail';
    default:
      return 'Unknown';
  }
}

String weatherIcon(int code, bool isDay) {
  switch (code) {
    case 0:
      return isDay ? '☀️' : '🌙';
    case 1:
    case 2:
      return isDay ? '⛅' : '☁️';
    case 3:
      return '☁️';
    case 45:
    case 48:
      return '🌫️';
    case 51:
    case 53:
    case 55:
      return '🌦️';
    case 61:
    case 63:
    case 65:
      return '🌧️';
    case 66:
    case 67:
      return '🌨️';
    case 71:
    case 73:
    case 75:
    case 77:
      return '❄️';
    case 80:
    case 81:
    case 82:
      return '🌧️';
    case 85:
    case 86:
      return '🌨️';
    case 95:
    case 96:
    case 99:
      return '⛈️';
    default:
      return '🌡️';
  }
}
