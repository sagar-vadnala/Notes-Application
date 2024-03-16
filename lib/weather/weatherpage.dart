import 'package:flutter/material.dart';
import 'package:notes_app/weather/models/weather_model.dart';
import 'package:notes_app/weather/service/weather_service.dart';
import 'package:lottie/lottie.dart';

class WeatherPage extends StatefulWidget {
  const WeatherPage({super.key});

  @override
  State<WeatherPage> createState() => _WeatherPageState();
}

class _WeatherPageState extends State<WeatherPage> {

  // api key
  final _weatherService = WeatherService('7b91f36bb0727a927bfaf3848d11ed83');
  Weather? _weather;

  // fetch weather
  _fetchWeather() async {
    //get the current city
    String cityName = await _weatherService.getCurrentCity();

    //get weather from city
    // try {
    //   final weather = await _weatherService.getWeather(cityName);
    //   setState(() {
    //     _weather = weather;
    //   }); 
    // }
    
    // // any error
    // catch (e) {
    //   print(e);
    // }
      if (cityName.isNotEmpty) { // Check if the cityName is not empty
    //get weather from city
    try {
      final weather = await _weatherService.getWeather(cityName);
      setState(() {
        _weather = weather;
      }); 
    }
    
    // any error
    catch (e) {
      print(e);
    }
  } else {
    print('City name is empty');
  }

  }

  // weather animation
  String getWeatherAnimation (String? mainCondition) {
    if (mainCondition == null) return 'assets/sunny1.json';// default to sunny

    switch (mainCondition.toLowerCase()) {
      case 'clouds':
      case 'mist':
      case 'smoke':
      case 'haze':
      case 'dust':
      case 'fog':
        return 'assets/cloud.json';
      case 'rain':
      case 'drizzle':
      case 'shower rain':
        return 'assets/rain.json';
      case 'thunderstrom':
        return 'assets/thunder.json';
      case 'clear':
        return 'assets/sunny1.json';  
      default:
       return 'assets/rain.json';      
    }
  }

  // init state
  @override
  void initState() {
    
    // fetch weather on startup
    _fetchWeather();
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade300,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // city name
            Text(_weather?.cityName ?? "loading city"),

            //animation
            Lottie.asset(getWeatherAnimation(_weather?.mainCondition)),
            //Lottie.asset('assets/thunder.json'),

        
            // temperature
            Text('${_weather?.temperature.round()}°C'),

            // weather condition
            Text(_weather?.mainCondition ?? "")
          ],
        ),
      ),
    );
  }
}