import 'dart:io';

class Environment {
  static String apiUrl =
      Platform.isAndroid ? 'http://192.168.0.7:8000/api' : 'localhost:3000/api';
  static String socketUrl =
      Platform.isAndroid ? 'http://192.168.0.7:8000' : 'localhost:3000';
}
