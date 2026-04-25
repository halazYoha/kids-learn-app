import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_profile.dart';

final profileProvider = NotifierProvider<ProfileNotifier, UserProfile?>(() {
  return ProfileNotifier();
});

class ProfileNotifier extends Notifier<UserProfile?> {
  @override
  UserProfile? build() {
    // Initial load is triggered here, but build must return synchronously.
    // For splash screen, we will await the explicit loadProfile() below.
    _loadInitial();
    return null;
  }

  Future<void> _loadInitial() async {
    await loadProfile();
  }

  static const _profileKey = 'user_profile';

  Future<void> loadProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final profileJson = prefs.getString(_profileKey);
    if (profileJson != null) {
      state = UserProfile.fromJson(jsonDecode(profileJson));
    }
  }

  Future<void> saveProfile(UserProfile profile) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_profileKey, jsonEncode(profile.toJson()));
    state = profile;
  }

  Future<void> updateName(String name) async {
    if (state != null) {
      final updated = state!.copyWith(name: name);
      await saveProfile(updated);
    }
  }

  Future<void> updateAvatar(int index) async {
    if (state != null) {
      final updated = state!.copyWith(avatarIndex: index);
      await saveProfile(updated);
    }
  }
}
