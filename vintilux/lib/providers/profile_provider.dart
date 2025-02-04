import 'package:flutter/foundation.dart';
import '../models/user_profile_model.dart';

class ProfileProvider with ChangeNotifier {
  UserProfile? _userProfile;

  UserProfile? get userProfile => _userProfile;

  // Simulated user profile data (replace with actual API calls in production)
  void initializeProfile() {
    _userProfile = UserProfile(
      id: '1',
      name: 'John Doe',
      email: 'john.doe@example.com',
      phoneNumber: '+1234567890',
      profilePicture: 'https://via.placeholder.com/150',
      address: '123 Main St, City, Country',
    );
    notifyListeners();
  }

  Future<void> updateProfile({
    String? name,
    String? email,
    String? phoneNumber,
    String? address,
    String? profilePicture,
  }) async {
    if (_userProfile == null) return;

    _userProfile = _userProfile!.copyWith(
      name: name,
      email: email,
      phoneNumber: phoneNumber,
      address: address,
      profilePicture: profilePicture,
    );
    
    notifyListeners();
  }

  void clearProfile() {
    _userProfile = null;
    notifyListeners();
  }
}
