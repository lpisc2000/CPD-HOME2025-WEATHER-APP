import 'package:flutter/material.dart';

// This function takes a weather icon string and returns the corresponding Flutter IconData.
// It uses a switch statement to match the icon string with the appropriate icon.
IconData getWeatherIcon(String icon) {
  switch (icon) {
    case 'clear-day':
      return Icons.wb_sunny;
    case 'clear-night':
      return Icons.nights_stay;
    case 'partly-cloudy-day':
      return Icons.cloud_queue;
    case 'partly-cloudy-night':
      return Icons.cloud;
    case 'rain':
      return Icons.umbrella;
    case 'snow':
      return Icons.ac_unit;
    case 'fog':
      return Icons.blur_on;
    case 'wind':
      return Icons.air;
    case 'cloudy':
      return Icons.cloud;
    default:
      return Icons.help_outline;
  }
}
