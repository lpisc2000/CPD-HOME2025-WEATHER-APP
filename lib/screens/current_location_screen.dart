import 'package:flutter/material.dart';
import '../services/location_service.dart';
import '../services/weather_service.dart';
import '../services/notification_service.dart';
import '../widgets/weather_card.dart';

class CurrentLocationScreen extends StatefulWidget {
  const CurrentLocationScreen({super.key});

  @override
  State<CurrentLocationScreen> createState() => _CurrentLocationScreenState();
}

class _CurrentLocationScreenState extends State<CurrentLocationScreen> {
  Map<String, dynamic>? _weatherData;

  @override
  void initState() {
    super.initState();
    _fetchWeather();
  }

  void _fetchWeather() async {
    final location = await LocationService().getCurrentLocation();

    final data = await WeatherService().getWeatherByLocation(
      location.latitude,
      location.longitude,
    );

    final cityName = await WeatherService().getCityNameFromCoordinates(
      location.latitude,
      location.longitude,
    );

    data['resolvedAddress'] = cityName;

    await NotificationService().showNotification(
      "Weather Update",
      "Current temp: ${data['currentConditions']['temp']}°C",
    );

    setState(() => _weatherData = data);
  }

  String formatAddress(String address) {
    final parts = address.split(',');
    String firstPart = parts.isNotEmpty ? parts[0].trim() : '';

    if (firstPart.contains('+')) {
      final plusSplit = firstPart.split(' ');
      plusSplit.removeWhere((word) => word.contains('+'));
      firstPart = plusSplit.join(' ').trim();
    }

    final country = parts.length > 1 ? parts[1].trim() : '';
    return (firstPart.isNotEmpty && country.isNotEmpty)
        ? '$firstPart, $country'
        : firstPart.isNotEmpty
            ? firstPart
            : 'Your Location';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text("📍Weather For Current Location"),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.white, 
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF1E3C72), Color(0xFF2A5298)], 
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: _weatherData == null
                ? const Center(child: CircularProgressIndicator(color: Colors.white))
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: 10),

                      // City Name Header
                      Text(
                        formatAddress(_weatherData!['resolvedAddress'] ?? ''),
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          shadows: [
                            Shadow(
                              blurRadius: 4,
                              color: Colors.black26,
                              offset: Offset(1, 1),
                            )
                          ],
                        ),
                      ),

                      const SizedBox(height: 12),

                      //Forecast Section Title
                      Container(
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(30),
                          color: const Color(0xFF1E3C72),
                        ),
                        child: const Text(
                          "10-Day Forecast",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),

                      const SizedBox(height: 10),

                      // Weather Forecast Cards
                      Expanded(
                        child: ListView.builder(
                          itemCount: 10,
                          itemBuilder: (context, index) {
                            final day = _weatherData!['days'][index];
                            return WeatherCard(
                              data: {
                                'currentConditions': day,
                                'resolvedAddress': _weatherData!['resolvedAddress'],
                              },
                            );
                          },
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}
