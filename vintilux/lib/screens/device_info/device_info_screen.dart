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
    bool isAvailable = true,
    VoidCallback? onRefresh,
  }) {
    return Card(
      color: Theme.of(context).cardColor,
      elevation: 4,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(icon, color: Theme.of(context).colorScheme.primary),
                    const SizedBox(width: 8),
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                  ],
                ),
                if (onRefresh != null)
                  IconButton(
                    icon: const Icon(Icons.refresh),
                    onPressed: onRefresh,
                    color: Theme.of(context).colorScheme.primary,
                  ),
              ],
            ),
            const SizedBox(height: 12),
            if (!isAvailable)
              Text(
                'This feature is only available in the mobile app',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.error,
                  fontStyle: FontStyle.italic,
                ),
              )
            else
              ...details.map(
                (detail) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Text(
                    detail,
                    style: TextStyle(
                      fontSize: 16,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
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
          : SingleChildScrollView(
              child: Column(
                children: [
                  if (_error.isNotEmpty)
                    Container(
                      margin: const EdgeInsets.all(16),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.errorContainer,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.info_outline,
                            color: Theme.of(context).colorScheme.onErrorContainer,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              _error,
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.onErrorContainer,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  _buildInfoCard(
                    title: 'System Time',
                    icon: Icons.access_time,
                    details: [
                      'Current Time: ${DateTime.now().toLocal().toString().split('.')[0]}',
                      'Date: ${DateTime.now().toLocal().toString().split(' ')[0]}',
                      'Time Zone: ${DateTime.now().timeZoneName}',
                    ],
                  ),
                  _buildInfoCard(
                    title: 'Battery Status',
                    icon: Icons.battery_full,
                    details: [
                      'Battery Level: ${_batteryLevel >= 0 ? '$_batteryLevel%' : 'Unknown'}',
                      'Status: ${_getBatteryStateString(_batteryState)}',
                    ],
                  ),
                  _buildInfoCard(
                    title: 'Location',
                    icon: Icons.location_on,
                    details: _locationError.isNotEmpty
                        ? [_locationError]
                        : [
                            if (_currentPosition != null) ...[
                              'Latitude: ${_currentPosition!.latitude}',
                              'Longitude: ${_currentPosition!.longitude}',
                              if (_currentAddress != null)
                                'Address: $_currentAddress',
                              'Accuracy: ${_currentPosition!.accuracy.toStringAsFixed(2)} meters',
                            ],
                          ],
                    onRefresh: _getCurrentLocation,
                  ),
                  _buildInfoCard(
                    title: 'Contacts',
                    icon: Icons.contacts,
                    isAvailable: !kIsWeb,
                    details: kIsWeb
                        ? []
                        : [
                            'Total Contacts: ${_contacts.length}',
                            if (_contacts.isNotEmpty)
                              'Last Updated: ${DateTime.now().toString().split('.')[0]}',
                          ],
                  ),
                  _buildInfoCard(
                    title: 'Web Browser Info',
                    icon: Icons.web,
                    details: [
                      'Platform: ${kIsWeb ? 'Web Browser' : 'Mobile App'}',
                    ],
                  ),
                ],
              ),
            ),
    );
  }
}
