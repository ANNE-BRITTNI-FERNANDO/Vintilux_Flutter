import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:camera/camera.dart';
import 'package:battery_plus/battery_plus.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../services/device_services.dart';

class DeviceProvider with ChangeNotifier {
  final DeviceServices _deviceServices = DeviceServices();
  
  bool _isOnline = false;
  Position? _currentLocation;
  List<CameraDescription> _cameras = [];
  int _batteryLevel = -1;
  BatteryState _batteryState = BatteryState.unknown;

  bool get isOnline => _isOnline;
  Position? get currentLocation => _currentLocation;
  List<CameraDescription> get cameras => _cameras;
  int get batteryLevel => _batteryLevel;
  BatteryState get batteryState => _batteryState;

  DeviceProvider() {
    _initializeDeviceState();
  }

  Future<void> _initializeDeviceState() async {
    // Check initial network state
    _isOnline = await _deviceServices.checkInternetConnection();
    
    // Listen to network changes
    _deviceServices.connectivityStream.listen((result) {
      _isOnline = result != ConnectivityResult.none;
      notifyListeners();
    });

    // Get initial location
    _currentLocation = await _deviceServices.getCurrentLocation();
    
    // Get available cameras
    _cameras = await _deviceServices.getCameras();
    
    // Get initial battery state
    _batteryLevel = await _deviceServices.getBatteryLevel();
    
    // Listen to battery changes
    _deviceServices.batteryStateStream.listen((state) {
      _batteryState = state;
      _updateBatteryLevel();
      notifyListeners();
    });

    notifyListeners();
  }

  Future<void> _updateBatteryLevel() async {
    _batteryLevel = await _deviceServices.getBatteryLevel();
    notifyListeners();
  }

  Future<void> refreshLocation() async {
    _currentLocation = await _deviceServices.getCurrentLocation();
    notifyListeners();
  }

  Future<void> refreshCameras() async {
    _cameras = await _deviceServices.getCameras();
    notifyListeners();
  }

  @override
  void dispose() {
    _deviceServices.dispose();
    super.dispose();
  }
}
