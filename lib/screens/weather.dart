import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class WeatherPage extends StatefulWidget {
  const WeatherPage({super.key});

  @override
  State<WeatherPage> createState() => _WeatherPageState();
}

class _WeatherPageState extends State<WeatherPage> {
  Map<String, dynamic>? _weather;

  Future<void> _fetchWeather() async {
    final url = Uri.parse('https://api.open-meteo.com/v1/forecast?latitude=18.4861&longitude=-69.9312&current_weather=true&timezone=America%2FSanto_Domingo');
    final res = await http.get(url);
    if (res.statusCode == 200) {
      setState(() {
        _weather = json.decode(res.body)['current_weather'];
      });
    } else {
      setState(() {
        _weather = null;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchWeather();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: _weather == null
              ? const Center(child: CircularProgressIndicator())
              : Column(
                  children: [
                    Text(
                      'Clima - Santo Domingo (RD)',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Temperatura: ${_weather!['temperature']} °C',
                      style: const TextStyle(fontSize: 20),
                    ),
                    const SizedBox(height: 8),
                    Text('Velocidad del viento: ${_weather!['windspeed']} m/s'),
                    const SizedBox(height: 8),
                    Text(
                      'Dirección del viento: ${_weather!['winddirection']}°',
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Condición: ${_weatherDescription(_weather!['weathercode'])}',
                    ),
                  ],
              ),
        ),
      ),
    );
  }

  String _weatherDescription(int code) {
    if (code == 0) return 'Cielo despejado';
    if (code == 1 || code == 2 || code == 3) return 'Parcialmente nublado';
    if (code >= 45 && code <= 48) return 'Niebla';
    if (code >= 51 && code <= 67) return 'Lluvia ligera/moderada';
    if (code >= 71 && code <= 77) return 'Nieve/Granizo';
    if (code >= 80 && code <= 82) return 'Chubascos';
    if (code >= 95 && code <= 99) return 'Tormenta';
    return 'Desconocido';
  }
}