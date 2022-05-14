// import 'package:http/http.dart' as http;
import 'dart:convert';
import '.env.dart';
import 'package:weather/weather.dart';

class Getweather {
  Future<Weather> getweather(double lat, double long) async {
    WeatherFactory wf = new WeatherFactory(weatherapikey); //calls api with key
    Weather w = await wf.currentWeatherByLocation(lat, long);

    return w;
  }
}
