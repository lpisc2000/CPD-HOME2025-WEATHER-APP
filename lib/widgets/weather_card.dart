import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../utils/weather_icon_helper.dart';

class WeatherCard extends StatelessWidget {
  final Map<String, dynamic> data;

  const WeatherCard({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final current = data['currentConditions'];
    final icon = getWeatherIcon(current['icon']);

    String? dateLabel;
    final rawDate = current['datetime'];
    if (rawDate != null && rawDate.toString().contains('-')) {
      try {
        final parsed = DateTime.parse(rawDate);
        dateLabel = DateFormat('EEEE, MMM d').format(parsed);
      } catch (e) {
        dateLabel = null;
      }
    }

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 4,
      color: Colors.white.withOpacity(0.9),
      margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        child: Row(
          children: [
            Icon(icon, size: 36, color: Colors.blueAccent),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (dateLabel != null)
                    Text(
                      dateLabel,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey,
                      ),
                    ),
                  const SizedBox(height: 4),
                  Text(
                    "${current['temp']}°C",
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text("Condition: ${current['conditions']}"),
                  Text("Humidity: ${current['humidity']}%"),
                  Text("Wind: ${current['windspeed']} km/h"),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
