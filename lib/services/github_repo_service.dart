import 'dart:math';

import 'package:http/http.dart' as http;
import 'dart:convert';

class GitHubRepoService {
  static const _baseUrl = 'https://api.github.com';
  static const _userAgent = 'RiverMusic';
  final _client = http.Client();
  int _lastFetchDay = -1;
  Map<String, dynamic>? _cachedRepo;

  Future<Map<String, dynamic>?> getRepoOfTheDay() async {
    final today = DateTime.now().millisecondsSinceEpoch ~/ Duration.millisecondsPerDay;

    if (_cachedRepo != null && _lastFetchDay == today) {
      return _cachedRepo;
    }

    try {
      final response = await _client.get(
        Uri.parse('$_baseUrl/search/repositories?q=stars:>100&sort=stars&order=desc&per_page=100'),
        headers: {
          'Accept': 'application/vnd.github.v3+json',
          'User-Agent': _userAgent,
        },
      );

      if (response.statusCode != 200) return null;

      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final items = data['items'] as List;

      if (items.isEmpty) return null;

      final random = Random(today);
      final repo = items[random.nextInt(items.length)] as Map<String, dynamic>;

      _cachedRepo = {
        'title': repo['full_name'],
        'description': repo['description'] ?? 'No description',
        'url': repo['html_url'],
        'stars': repo['stargazers_count'],
        'language': repo['language'],
        'owner': repo['owner']?['login'],
        'ownerAvatar': repo['owner']?['avatar_url'],
        'forks': repo['forks_count'],
      };
      _lastFetchDay = today;
      return _cachedRepo;
    } catch (_) {
      return _cachedRepo;
    }
  }

  void dispose() {
    _client.close();
  }
}
