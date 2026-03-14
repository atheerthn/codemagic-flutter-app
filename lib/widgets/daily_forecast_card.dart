import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/weather.dart';

class DailyForecastCard extends StatelessWidget {
  final DailyForecast forecast;

  const DailyForecastCard({super.key, required this.forecast});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isToday = DateUtils.isSameDay(forecast.date, DateTime.now());

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Card(
        elevation: 0,
        color: theme.colorScheme.surfaceContainerHighest,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              SizedBox(
                width: 80,
                child: Text(
                  isToday
                      ? 'Today'
                      : DateFormat('EEE, d').format(forecast.date),
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: isToday ? FontWeight.bold : null,
                  ),
                ),
              ),
              Text(forecast.icon, style: const TextStyle(fontSize: 24)),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  forecast.description,
                  style: theme.textTheme.bodySmall,
                ),
              ),
              if (forecast.precipProbability > 0) ...[
                Icon(
                  Icons.water_drop,
                  size: 14,
                  color: theme.colorScheme.primary,
                ),
                Text(
                  '${forecast.precipProbability.round()}%',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.primary,
                  ),
                ),
                const SizedBox(width: 12),
              ],
              Text(
                '${forecast.tempMax.round()}°',
                style: theme.textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 4),
              Text(
                '${forecast.tempMin.round()}°',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
