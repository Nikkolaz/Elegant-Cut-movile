import 'dart:convert';
import 'package:elegant_cut_mobile/src/api/api_middleware.dart';
import 'package:elegant_cut_mobile/src/utils/constants.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FcmApiService {
  final ApiInterceptor _api = ApiInterceptor();

  Future<bool> registerToken(String fcmToken) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getInt('id_usuario') ?? 0;

      final response = await _api.post(
        Uri.parse('${ApiConstants.baseUrl}/fcm/register'),
        body: json.encode({
          'id_usuario': userId,
          'fcm_token': fcmToken,
          'dispositivo': 'android',
        }),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        await prefs.setString('fcm_token', fcmToken);
        return true;
      }
      print('Error registrando FCM token: ${response.statusCode}');
      return false;
    } catch (e) {
      print('FcmApiService error: $e');
      return false;
    }
  }

  Future<bool> unregisterToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final fcmToken = prefs.getString('fcm_token');
      if (fcmToken == null) return true;

      await _api.post(
        Uri.parse('${ApiConstants.baseUrl}/fcm/unregister'),
        body: json.encode({'fcm_token': fcmToken}),
      );

      await prefs.remove('fcm_token');
      return true;
    } catch (e) {
      print('FcmApiService unregister error: $e');
      return false;
    }
  }
}
