import 'dart:convert';
import 'package:flutter/services.dart';

class Config {
  static Map<String, dynamic>? _config;

  static Future<void> load() async {
    final String configString = await rootBundle.loadString('assets/config.json');
    _config = json.decode(configString);
  }

  static String get apiUrl => _config?['apiUrl'] ?? 'http://192.168.1.40:8090/api/v1/';

  static String get clientCode => _config?['CLIENTCODE'] ?? 'artisan_cafe';
  static String get db => clientCode;

  static String get brand => "FACTORY FEAST";
  static String get logoPath => _config?['LOGO_PATH'] ?? 'assets/images/artisian.png';
  static String get posTitle => _config?['POS_TITLE'] ?? 'FACTORY FEAST PRO';

  static String get factoryName => _config?['FACTORY_DETAILS']?['name'] ?? 'FACTORY FEAST UNIT 1';
  static String get factoryAddress1 => _config?['FACTORY_DETAILS']?['addressLine1'] ?? 'Industrial Area, Mumbai';

  static String get customerName => _config?['CUSTOMER_DETAILS']?['name'] ?? 'ARTISAN CAFE OUTLET';
}