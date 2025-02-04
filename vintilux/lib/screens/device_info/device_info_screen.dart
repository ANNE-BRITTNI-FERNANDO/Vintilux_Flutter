import 'package:flutter/material.dart';
import 'package:battery_plus/battery_plus.dart';
import 'package:contacts_service/contacts_service.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

class DeviceInfoScreen extends StatefulWidget {
  const DeviceInfoScreen({Key? key}) : super(key: key);

  @override
  State<DeviceInfoScreen> createState() => _DeviceInfoScreenState();
}

class _DeviceInfoScreenState extends State<DeviceInfoScreen> {
  final Battery _battery = Battery();
  int _batteryLevel = 0;
  BatteryState _batteryState = BatteryState.unknown;
  List<Contact> _contacts = [];
  Position? _currentPosition;
  String? _currentAddress;
  String _locationError = '';
  bool _isLoading = true;
  String _error = '';

  @override
  void initState() {
    super.initState();
    _initializeDeviceInfo();
  }

  Future<void> _initializeDeviceInfo() async {
    try {
      setState(() => _isLoading = true);

      // Initialize battery info for both web and mobile
      try {
        _batteryLevel = await _battery.batteryLevel;
        _batteryState = await _battery.batteryState;
        _battery.onBatteryStateChanged.listen((state) {
          setState(() => _batteryState = state);
          _updateBatteryLevel();
        });
      } catch (e) {
        print('Battery error: $e');
        _batteryLevel = -1;
        _batteryState = BatteryState.unknown;
      }

      if (!kIsWeb) {
        // Request contacts permission and fetch contacts
        if (await Permission.contacts.request().isGranted) {
          final contacts = await ContactsService.getContacts();
          setState(() => _contacts = contacts.toList());
        }
      }

      // Initialize location
      await _getCurrentLocation();

      setState(() => _isLoading = false);
    } catch (e) {
      setState(() {
        _error = 'Some features may not be available in web browser';
        _isLoading = false;
      });
    }
  }

  Future<void> _getCurrentLocation() async {
    setState(() {
      _locationError = '';
      _currentAddress = null;
    });

    try {
      // Check if location services are enabled
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        setState(() => _locationError = 'Location services are disabled');
        return;
      }

      // Check location permission
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          setState(() => _locationError = 'Location permission denied');
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        setState(() => _locationError = 'Location permissions permanently denied');
        return;
      }

      // Get current position
      setState(() => _isLoading = true);
      
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      // Get address from coordinates
      try {
        List<Placemark> placemarks = await placemarkFromCoordinates(
          position.latitude,
          position.longitude,
        );

        if (placemarks.isNotEmpty) {
          Placemark place = placemarks[0];
          String? city = place.locality?.isNotEmpty == true ? place.locality : place.subAdministrativeArea;
          String? province = place.administrativeArea;
          
          List<String> addressParts = [];
          if (city?.isNotEmpty == true) addressParts.add(city!);
          if (province?.isNotEmpty == true) addressParts.add(province!);
          
          _currentAddress = addressParts.isNotEmpty ? addressParts.join(', ') : null;
        }
      } catch (e) {
        print('Geocoding error: $e');
        _currentAddress = null;
      }

      setState(() {
        _currentPosition = position;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _locationError = 'Error getting location: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _updateBatteryLevel() async {
    if (!kIsWeb) {
      final level = await _battery.batteryLevel;
      setState(() => _batteryLevel = level);
    }
  }

  String _getBatteryStateString(BatteryState state) {
    switch (state) {
      case BatteryState.charging:
        return 'Charging';
      case BatteryState.discharging:
        return 'Discharging';
      case BatteryState.full:
        return 'Full';
      case BatteryState.unknown:
        return 'Unknown';
    }
  }

  Widget _buildInfoCard({
    required String title,
    required IconData icon,
    required List<String> details,
    bool isAvailable = false,
    VoidCallback? onRefresh,
  }) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 24),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                if (onRefresh != null)
                  IconButton(
                    icon: const Icon(Icons.refresh, size: 20),
                    onPressed: onRefresh,
                  ),
                if (!isAvailable)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      'Mobile Only',
                      style: TextStyle(fontSize: 12),
                    ),
                  ),
              ],
            ),
            if (!isAvailable) ...[
              const SizedBox(height: 8),
              Text(
                'This feature is only available in the mobile app',
                style: TextStyle(color: Colors.grey[600]),
              ),
            ] else ...[
              const SizedBox(height: 12),
              ...details.map((detail) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Text(
                      detail,
                      style: TextStyle(
                        color: Colors.grey[800],
                        height: 1.5,
                      ),
                    ),
                  )),
            ],
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Device Information'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _initializeDeviceInfo,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                if (kIsWeb)
                  Container(
                    padding: const EdgeInsets.all(12),
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: Colors.orange[100],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.orange[300]!),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.info_outline, color: Colors.orange),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Some features are only available in the mobile app',
                            style: TextStyle(color: Colors.orange),
                          ),
                        ),
                      ],
                    ),
                  ),
                _buildInfoCard(
                  title: 'System Time',
                  icon: Icons.access_time,
                  isAvailable: true,
                  details: [
                    'Current Time: ${now.hour}:${now.minute}:${now.second}',
                    'Date: ${now.day}/${now.month}/${now.year}',
                    'Time Zone: ${now.timeZoneName}',
                  ],
                ),
                const SizedBox(height: 16),
                _buildInfoCard(
                  title: 'Battery Status',
                  icon: Icons.battery_charging_full,
                  isAvailable: true,
                  details: _batteryLevel < 0 
                      ? ['Battery information not available']
                      : [
                          'Battery Level: $_batteryLevel%',
                          'Status: ${_getBatteryStateString(_batteryState)}',
                        ],
                ),
                const SizedBox(height: 16),
                _buildInfoCard(
                  title: 'Location',
                  icon: Icons.location_on,
                  isAvailable: true,
                  onRefresh: _getCurrentLocation,
                  details: _locationError.isNotEmpty
                      ? [_locationError]
                      : _currentPosition != null
                          ? [
                              'Latitude: ${_currentPosition!.latitude.toStringAsFixed(6)}',
                              'Longitude: ${_currentPosition!.longitude.toStringAsFixed(6)}',
                              if (_currentAddress != null) 'Location: $_currentAddress',
                              'Accuracy: ${_currentPosition!.accuracy.toStringAsFixed(1)} meters',
                            ]
                          : ['Getting location...'],
                ),
                const SizedBox(height: 16),
                _buildInfoCard(
                  title: 'Contacts',
                  icon: Icons.contacts,
                  isAvailable: !kIsWeb,
                  details: _contacts.isEmpty
                      ? ['No contacts available']
                      : _contacts
                          .take(5)
                          .map((contact) =>
                              '${contact.displayName ?? 'No Name'}: ${contact.phones?.firstOrNull?.value ?? 'No Phone'}')
                          .toList(),
                ),
                const SizedBox(height: 16),
                _buildInfoCard(
                  title: 'Web Browser Info',
                  icon: Icons.web,
                  isAvailable: true,
                  details: [
                    'Platform: Web Browser',
                    'User Agent: Chrome',
                    'Window Size: ${MediaQuery.of(context).size.width.toInt()} x ${MediaQuery.of(context).size.height.toInt()}',
                  ],
                ),
              ],
            ),
    );
  }
}
