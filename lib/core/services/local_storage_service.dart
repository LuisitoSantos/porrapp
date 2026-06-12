import 'package:shared_preferences/shared_preferences.dart';

class LocalStorageService {
  static const userIdKey = 'user_id';
  static const usernameKey = 'username';

  Future<void> saveUser({
    required String id,
    required String username,
  }) async {
    final prefs =
        await SharedPreferences.getInstance();

    await prefs.setString(
      userIdKey,
      id,
    );

    await prefs.setString(
      usernameKey,
      username,
    );
  }

  Future<String?> getUserId() async {
    final prefs =
        await SharedPreferences.getInstance();

    return prefs.getString(
      userIdKey,
    );
  }

  Future<String?> getUsername() async {
    final prefs =
        await SharedPreferences.getInstance();

    return prefs.getString(
      usernameKey,
    );
  }

  Future<void> clearUser() async {

  final prefs =
      await SharedPreferences.getInstance();

  await prefs.remove(
    userIdKey,
  );

  await prefs.remove(
    usernameKey,
  );
}
}

class CurrentUser {

  static Future<String> getId() async {
    return await LocalStorageService()
        .getUserId() ?? '';
  }
}