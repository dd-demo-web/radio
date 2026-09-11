import 'dart:convert';
import 'package:http/http.dart' as http;

import '../models/schedule.dart';
import '../models/track_metadata.dart';
import 'radio_config.dart';

class RadioApiService {
  final http.Client _client;

  RadioApiService({http.Client? client}) : _client = client ?? http.Client();

  Future<TrackMetadata> fetchCurrentTrack() async {
    final response = await _client
        .get(
          Uri.parse(RadioConfig.metadataUrl),
          headers: const {
            'Accept': '*/*',
            'Origin': 'https://play.xdevel.com',
            'Referer': 'https://play.xdevel.com/',
          },
        )
        .timeout(const Duration(seconds: 10));

    if (response.statusCode != 200) {
      throw Exception('Errore metadata: HTTP ${response.statusCode}');
    }
    final data = jsonDecode(response.body) as Map<String, dynamic>;
    return TrackMetadata.fromJson(data);
  }

  Future<WeeklySchedule> fetchWeeklySchedule() async {
    final response = await _client
        .get(Uri.parse(RadioConfig.scheduleUrl))
        .timeout(const Duration(seconds: 10));

    if (response.statusCode != 200) {
      throw Exception('Errore palinsesto: HTTP ${response.statusCode}');
    }
    final data = jsonDecode(response.body) as Map<String, dynamic>;
    return WeeklySchedule.fromJson(data);
  }

  void dispose() => _client.close();
}
