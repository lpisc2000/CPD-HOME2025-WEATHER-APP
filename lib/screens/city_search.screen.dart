import 'package:flutter/material.dart';
import '../services/weather_service.dart';
import '../widgets/weather_card.dart';

class CitySearchScreen extends StatefulWidget {
  const CitySearchScreen({super.key});

  @override
  State<CitySearchScreen> createState() => _CitySearchScreenState();
}

class _CitySearchScreenState extends State<CitySearchScreen> {
  final TextEditingController _controller = TextEditingController();
  Map<String, dynamic>? _weatherData;
  bool _isLoading = false;
  String? _error;

  void _searchCityWeather() async {
    final city = _controller.text.trim();
    if (city.isEmpty) return;

    setState(() {
      _isLoading = true;
      _error = null;
      _weatherData = null;
    });

    try {
      final data = await WeatherService().getWeatherByCity(city);
      setState(() => _weatherData = data);
    } catch (e) {
      setState(() {
        _error =
            'Could not fetch weather for "$city". Please check the city name.';
      });
    } finally {
      setState(() => _isLoading = false);
    }
  }

  String capitalize(String input) {
    if (input.isEmpty) return input;
    return input
        .split(',')
        .map((part) {
          final trimmed = part.trim();
          return trimmed.isNotEmpty
              ? '${trimmed[0].toUpperCase()}${trimmed.substring(1)}'
              : '';
        })
        .join(', ');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text("🌍 Search Weather"),
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
            padding: const EdgeInsets.all(24.0),
            child: Column(
              children: [
                // Search Field
                TextField(
                  controller: _controller,
                  textInputAction: TextInputAction.search,
                  onSubmitted: (_) => _searchCityWeather(),
                  decoration: InputDecoration(
                    hintText: "Search a city (e.g. Paris, Tokyo)",
                    prefixIcon: const Icon(Icons.location_city),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 14,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.search),
                      onPressed: _searchCityWeather,
                    ),
                  ),
                ),
                const SizedBox(height: 30),

                if (_isLoading)
                  const CircularProgressIndicator()
                else if (_error != null)
                  Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Text(
                      _error!,
                      style: const TextStyle(color: Colors.red, fontSize: 16),
                      textAlign: TextAlign.center,
                    ),
                  )
                else if (_weatherData != null)
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        //City Name
                        Text(
                          capitalize(_weatherData!['resolvedAddress'] ?? ''),
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
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),

                        //Forecast Section Title
                        Container(
                          margin: const EdgeInsets.symmetric(vertical: 8),
                          padding: const EdgeInsets.symmetric(
                            vertical: 6,
                            horizontal: 12,
                          ),
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

                        //Forecast List
                        Expanded(
                          child: ListView.builder(
                            itemCount: 10,
                            itemBuilder: (context, index) {
                              final day = _weatherData!['days'][index];
                              return WeatherCard(
                                data: {
                                  'currentConditions': day,
                                  'resolvedAddress':
                                      _weatherData!['resolvedAddress'],
                                },
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  )
                else
                  const Spacer(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
