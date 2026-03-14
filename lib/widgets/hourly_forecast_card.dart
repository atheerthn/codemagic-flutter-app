import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/weather.dart';

class HourlyForecastCard extends StatelessWidget {
  final HourlyForecast forecast;

  const HourlyForecastCard({super.key, required this.forecast});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: 72,
      margin: const EdgeInsets.only(right: 8),
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Text(
            DateFormat('h a').format(forecast.time),
            style: theme.textTheme.bodySmall,
          ),
          Text(forecast.icon, style: const TextStyle(fontSize: 24)),
          Text(
            '${forecast.temperature.round()}°',
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
