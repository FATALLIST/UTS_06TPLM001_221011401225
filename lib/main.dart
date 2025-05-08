import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'dart:convert';
import 'package:permission_handler/permission_handler.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'UTS Aji Cakra Werdana',
      debugShowCheckedModeBanner: false,
      home: const LockScreen(),
    );
  }
}

class LockScreen extends StatefulWidget {
  const LockScreen({super.key});

  @override
  State<LockScreen> createState() => _LockScreenState();
}

class _LockScreenState extends State<LockScreen> {
  String city = "Loading...";
  double currentTemp = 0;
  double minTemp = 0;
  double maxTemp = 0;
  String weatherMain = "Loading...";
  String dateStr = DateFormat('EEEE, MMMM d, yyyy').format(DateTime.now());

  @override
  void initState() {
    super.initState();
    _initLocationAndFetchWeather();
  }

  Future<void> _initLocationAndFetchWeather() async {
    final status = await Permission.location.request();

    if (status.isGranted) {
      _fetchWeather();
    } else {
      setState(() {
        city = "Akses ditolak";
      });
    }
  }

  Future<void> _fetchWeather() async {
    try {
      Position position = await Geolocator.getCurrentPosition(
        // ignore: deprecated_member_use
        desiredAccuracy: LocationAccuracy.high,
      );

      String apiKey =
          'f373bfa1a9f89e6a280ed0b32849b605';
      String url =
          'https://api.openweathermap.org/data/2.5/weather?lat=${position.latitude}&lon=${position.longitude}&appid=$apiKey&units=metric';

      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        setState(() {
          city = data['name'] ?? 'Unknown';
          currentTemp = data['main']['temp'].toDouble();
          minTemp = data['main']['temp_min'].toDouble();
          maxTemp = data['main']['temp_max'].toDouble();
          weatherMain = data['weather'][0]['main'];
        });
      } else {
        setState(() {
          city = "Failed to load data";
        });
      }
    } catch (e) {
      setState(() {
        city = "Error: $e";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset('assets/nothingHappened.jpg', fit: BoxFit.cover),
          // ignore: deprecated_member_use
          Container(color: Colors.black.withOpacity(0.4)),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 80),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  city,
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  dateStr,
                  style: const TextStyle(fontSize: 18, color: Colors.white70),
                ),
                const SizedBox(height: 50),
                Text(
                  "${currentTemp.round()}°C",
                  style: const TextStyle(
                    fontSize: 80,
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Divider(color: Colors.white70, thickness: 1),
                const SizedBox(height: 10),
                Text(
                  weatherMain,
                  style: const TextStyle(fontSize: 24, color: Colors.white),
                ),
                const SizedBox(height: 8),
                Text(
                  "${minTemp.round()}°C / ${maxTemp.round()}°C",
                  style: const TextStyle(fontSize: 18, color: Colors.white70),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}