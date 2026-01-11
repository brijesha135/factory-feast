import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:audioplayers/audioplayers.dart';
import 'config.dart';

class OrderService {
  static final OrderService _instance = OrderService._internal();
  factory OrderService() => _instance;
  OrderService._internal();

  final ValueNotifier<List<dynamic>> pendingOrders = ValueNotifier([]);
  final ValueNotifier<List<dynamic>> completedOrders = ValueNotifier([]);
  final ValueNotifier<bool> isLoading = ValueNotifier(true);

  Timer? _refreshTimer;
  final AudioPlayer _audioPlayer = AudioPlayer();
  final Set<String> _notifiedOrderIds = {};

  void startPolling() {
    _refreshTimer?.cancel();
    fetchOrders();
    _refreshTimer = Timer.periodic(const Duration(seconds: 10), (timer) => _silentRefresh());
  }

  void stopPolling() {
    _refreshTimer?.cancel();
    _audioPlayer.dispose();
    isLoading.value = true;
  }

  Future<void> fetchOrders() async {
    isLoading.value = true;
    try {
      final url = '${Config.apiUrl}factory/orders/getAll?DB=${Config.clientCode}';
      debugPrint("[DEBUG] OrderService Fetching: $url");

      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final List<dynamic> parsed = json.decode(response.body);
        _processOrders(parsed, playSound: false);
      } else {
        debugPrint("[DEBUG] Fetch Failed: ${response.statusCode}");
      }
    } catch (e) {
      debugPrint('[DEBUG] Fetch Error: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _silentRefresh() async {
    try {
      final url = '${Config.apiUrl}factory/orders/getAll?DB=${Config.clientCode}';
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final List<dynamic> parsed = json.decode(response.body);
        _processOrders(parsed, playSound: true);
      }
    } catch (e) {
      debugPrint('[DEBUG] Polling Error: $e');
    }
  }

  void _processOrders(List<dynamic> parsed, {bool playSound = false}) {

    final newPending = parsed.where((o) =>
    (o['workflowStatus'] ?? 'PLACED').toString().toUpperCase() != 'COMPLETED' &&
        (o['workflowStatus'] ?? '').toString().toUpperCase() != 'CANCELLED'
    ).toList();

    final newCompleted = parsed.where((o) =>
    (o['workflowStatus'] ?? '').toString().toUpperCase() == 'COMPLETED'
    ).toList();

    bool hasNewOrder = false;
    for (var order in newPending) {
      final id = order['manifestId'].toString();
      if (!_notifiedOrderIds.contains(id)) {
        hasNewOrder = true;
        _notifiedOrderIds.add(id);
      }
    }

    if (playSound && hasNewOrder && _notifiedOrderIds.length > newPending.length) {
      _triggerNotification();
    }

    pendingOrders.value = newPending;
    completedOrders.value = newCompleted;
  }

  void _triggerNotification() async {
    try {
      await _audioPlayer.stop();
      await _audioPlayer.play(AssetSource('sounds/notification.mp3'));
      debugPrint("New Order Notification Sound Played");
    } catch (e) {
      debugPrint("Audio Playback Error: $e");
    }
  }
}