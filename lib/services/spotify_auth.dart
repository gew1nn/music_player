import 'dart:convert';
import 'package:http/http.dart' as http;

class SpotifyAuth {
  static const String clientId = '24ffa5d6709f460fab3f7e4f06225560';
  static const String clientSecret = 'b84194e8af77483aab3f6339dd20d39f';
  static const String tokenUrl = 'https://accounts.spotify.com/api/token';

  static Future<String?> getAccessToken() async {
    final response = await http.post(
      Uri.parse(tokenUrl),
      headers: {
        'Authorization': 'Basic ${base64Encode(utf8.encode('$clientId:$clientSecret'))}',
        'Content-Type': 'application/x-www-form-urlencoded',
      },
      body: {'grant_type': 'client_credentials'},
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['access_token'];
    } else {
      print('Error getting token: ${response.body}');
      return null;
    }
  }
}
