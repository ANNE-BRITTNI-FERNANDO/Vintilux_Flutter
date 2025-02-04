import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:geolocator/geolocator.dart';
import 'package:camera/camera.dart';
import 'package:battery_plus/battery_plus.dart';
import 'package:permission_handler/permission_handler.dart';


class DeviceServices {
  static final DeviceServices _instance = DeviceServices._internal();
  factory DeviceServices() => _instance;
  DeviceServices._internal();

  final Connectivity _connectivity = Connectivity();
  final Battery _battery = Battery();
  StreamSubscription<ConnectivityResult>? _connectivitySubscription;
  StreamSubscription<BatteryState>? _batterySubscription;

  // Network Connectivity
  Future<bool> checkInternetConnection() async {
    final result = await _connectivity.checkConnectivity();
    return result != ConnectivityResult.none;
  }

  Stream<ConnectivityResult> get connectivityStream => _connectivity.onConnectivityChanged;

  // Location Services
  Future<Position?> getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return null;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return null;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return null;
    }

    try {
      return await Geolocator.getCurrentPosition();
    } catch (e) {
      return null;
    }
  }

  // Camera Services
  Future<List<CameraDescription>> getCameras() async {
    try {
      final status = await Permission.camera.request();
      if (status.isGranted) {
        return await availableCameras();
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  // Battery Services
  Future<int> getBatteryLevel() async {
    try {
      return await _battery.batteryLevel;
    } catch (e) {
      return -1;
    }
  }

  Stream<BatteryState> get batteryStateStream => _battery.onBatteryStateChanged;

  // Initialize all services
  Future<void> initializeServices() async {
    // Start listening to connectivity changes
    _connectivitySubscription = connectivityStream.listen((result) {
      // Handle connectivity changes
    });

    // Start listening to battery changes
    _batterySubscription = batteryStateStream.listen((state) {
      // Handle battery state changes
    });
  }

  // Dispose services
  void dispose() {
    _connectivitySubscription?.cancel();
    _batterySubscription?.cancel();
  }
}
