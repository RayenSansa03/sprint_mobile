import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_colors.dart';
import 'weather_models.dart';

class WeatherDetailScreen extends StatelessWidget {
  final LocationWeather weather;

  const WeatherDetailScreen({super.key, required this.weather});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          _buildSliverAppBar(context),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildAgriAdvice(),
                  const SizedBox(height: 32),
                  _buildMainWeather(),
                  const SizedBox(height: 48),
                  const Text(
                    'PRÉVISIONS HORAIRES',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildHourlyForecast(),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSliverAppBar(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 0,
      floating: true,
      backgroundColor: AppColors.background,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black, size: 20),
        onPressed: () => Navigator.pop(context),
      ),
      title: Text(
        weather.name,
        style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildAgriAdvice() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.primary.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          const CircleAvatar(
            backgroundColor: AppColors.primary,
            child: Icon(Icons.lightbulb_outline, color: Colors.white),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'CONSEIL AGRICOLE',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  weather.weatherCode.agriAdvice,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.black87,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMainWeather() {
    return Center(
      child: Column(
        children: [
          FaIcon(
            weather.weatherCode.weatherIcon,
            size: 100,
            color: AppColors.primary,
          ),
          const SizedBox(height: 24),
          Text(
            '${weather.temperature.round()}°',
            style: const TextStyle(
              fontSize: 80,
              fontWeight: FontWeight.w200,
              letterSpacing: -2,
            ),
          ),
          Text(
            weather.weatherCode.description.toUpperCase(),
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              letterSpacing: 2,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHourlyForecast() {
    return SizedBox(
      height: 150,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: weather.hourlyForecasts.length,
        itemBuilder: (context, index) {
          final forecast = weather.hourlyForecasts[index];
          final time = DateTime.parse(forecast.time);
          final isCurrentHour = time.hour == DateTime.now().hour;

          return Container(
            width: 80,
            margin: const EdgeInsets.only(right: 12),
            decoration: BoxDecoration(
              color: isCurrentHour ? AppColors.primary : Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                if (!isCurrentHour)
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  DateFormat('HH:mm').format(time),
                  style: TextStyle(
                    color: isCurrentHour ? Colors.white70 : Colors.grey,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 12),
                FaIcon(
                  forecast.weatherCode.weatherIcon,
                  color: isCurrentHour ? Colors.white : AppColors.primary,
                  size: 24,
                ),
                const SizedBox(height: 12),
                Text(
                  '${forecast.temperature.round()}°',
                  style: TextStyle(
                    color: isCurrentHour ? Colors.white : Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
