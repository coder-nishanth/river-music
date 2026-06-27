import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:River/ytmusic/ytmusic.dart';
import 'package:River/services/charts_service.dart';
import 'package:River/services/chart_model.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:meta/meta.dart';

part 'home_state.dart';

class HomeCubit extends Cubit<HomeState> {
  final YTMusic _ytMusic;
  HomeCubit(this._ytMusic) : super(HomeLoading());

  Future<void> fetch() async {
    emit(const HomeLoading());
    try {
      final results = await Future.wait([
        _ytMusic.browse(),
        ChartsService().getChartsWithPreviews(),
        _fetchRecommendationsFromHistory(),
        _fetchTrendingSongs(),
      ]);

      final feed = results[0] as Map<String, dynamic>;
      final charts = results[1] as List<ChartURL>;
      final recommendations = results[2] as List<Map<String, dynamic>>;
      final trending = results[3] as List<Map<String, dynamic>>;

      List sections = feed['sections'];

      if (trending.isNotEmpty) {
        sections.insert(0, _createTrendingSection(trending));
      }
      if (charts.isNotEmpty) {
        sections.insert(1, _createChartsSection(charts));
      }
      if (recommendations.isNotEmpty) {
        sections.insert(2, _createForYouSection(recommendations));
      }

      emit(HomeSuccess(
        chips: feed['chips'] ?? [],
        sections: sections,
        continuation: feed['continuation'],
        loadingMore: false,
      ));
    } catch (e, st) {
      emit(HomeError(e.toString(), st.toString()));
    }
  }

  Future<List<Map<String, dynamic>>> _fetchRecommendationsFromHistory() async {
    try {
      final box = Hive.box('SONG_HISTORY');
      final allSongs = box.values
          .where((s) => s is Map && (s as Map)['videoId'] != null)
          .map((s) => Map<String, dynamic>.from(s as Map))
          .toList();

      if (allSongs.isEmpty) return [];

      allSongs.sort((a, b) =>
          ((b['plays'] as int? ?? 0)).compareTo((a['plays'] as int? ?? 0)));
      final topSongs = allSongs.take(3).toList();

      final relatedResults = await Future.wait(
        topSongs.map((song) => _ytMusic.getNextSongList(videoId: song['videoId'], limit: 6)),
      );

      final seen = <String>{};
      final recommendations = <Map<String, dynamic>>[];
      for (final result in relatedResults) {
        for (final song in result) {
          final id = song['videoId'] as String?;
          if (id != null && seen.add(id)) {
            recommendations.add(Map<String, dynamic>.from(song));
          }
          if (recommendations.length >= 20) break;
        }
        if (recommendations.length >= 20) break;
      }

      return recommendations;
    } catch (_) {
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> _fetchTrendingSongs() async {
    try {
      final result = await _ytMusic.browse(body: {'browseId': 'FEmusic_charts'});
      final sections = result['sections'] as List?;
      final allSongs = <String, Map<String, dynamic>>{};
      if (sections != null && sections.isNotEmpty) {
        for (final section in sections) {
          final contents = section['contents'] as List?;
          if (contents != null && contents.isNotEmpty) {
            for (final s in contents) {
              final song = Map<String, dynamic>.from(s);
              final id = song['videoId'] as String?;
              if (id != null && !allSongs.containsKey(id)) {
                song['aspectRatio'] = 1.0;
                allSongs[id] = song;
              }
            }
          }
        }
      }
      if (allSongs.length < 20) {
        try {
          final searchResult = await _ytMusic.search(
            'trending songs india',
            filter: 'songs',
          );
          final searchSections = searchResult['sections'] as List?;
          if (searchSections != null && searchSections.isNotEmpty) {
            final searchContents = searchSections.first['contents'] as List?;
            if (searchContents != null) {
              for (final s in searchContents) {
                final song = Map<String, dynamic>.from(s);
                final id = song['videoId'] as String?;
                if (id != null && !allSongs.containsKey(id)) {
                  song['aspectRatio'] = 1.0;
                  allSongs[id] = song;
                }
              }
            }
          }
        } catch (_) {}
      }
      return allSongs.values.toList();
    } catch (_) {
      return [];
    }
  }

  Map<String, dynamic> _createTrendingSection(List songs) {
    return {
      'title': 'Trending in India',
      'contents': songs,
    };
  }

  Map<String, dynamic> _createForYouSection(List recommendations) {
    return {
      'title': 'Songs for You',
      'contents': recommendations,
      'viewType': 'COLUMN',
      'trailing': {'text': 'Play All'},
    };
  }

  Map<String, dynamic> _createChartsSection(List<ChartURL> charts) {
      return {
          'title': 'Browse Charts',
          'contents': charts.map((chart) => {
              'title': chart.title,
              'subtitle': 'Billboard Chart',
              'thumbnails': [{'url': chart.coverArt ?? 'https://www.billboard.com/wp-content/themes/vip/pmc-billboard-2021/assets/app/icons/icon-512x512.png', 'width': 500, 'height': 500}],
              'chartUrl': chart,
              'aspectRatio': 1.0,
          }).toList(),
      };
  }


  Future<void> refresh() async {
    try {
      final results = await Future.wait([
        _ytMusic.browse(),
        ChartsService().getChartsWithPreviews(),
        _fetchRecommendationsFromHistory(),
        _fetchTrendingSongs(),
      ]);

      final feed = results[0] as Map<String, dynamic>;
      final charts = results[1] as List<ChartURL>;
      final recommendations = results[2] as List<Map<String, dynamic>>;
      final trending = results[3] as List<Map<String, dynamic>>;

      List sections = feed['sections'];

      if (trending.isNotEmpty) {
        sections.insert(0, _createTrendingSection(trending));
      }
      if (charts.isNotEmpty) {
        sections.insert(1, _createChartsSection(charts));
      }
      if (recommendations.isNotEmpty) {
        sections.insert(2, _createForYouSection(recommendations));
      }

      emit(HomeSuccess(
        chips: feed['chips'] ?? [],
        sections: sections,
        continuation: feed['continuation'],
        loadingMore: false,
      ));
    } catch (e, st) {
      emit(HomeError(e.toString(), st.toString()));
    }
  }

  Future<void> fetchNext() async {
    final current = state;
    if (current is! HomeSuccess) return;
    if (current.loadingMore || current.continuation == null) return;
    emit(current.copyWith(loadingMore: true));
    try {
      final feed = await _ytMusic.browseContinuation(
          additionalParams: current.continuation!);
      emit(
        HomeSuccess(
          chips: current.chips,
          sections: [...current.sections, ...feed['sections']],
          continuation: feed['continuation'],
          loadingMore: false,
        ),
      );
    } catch (e, st) {
      emit(HomeError(e.toString(), st.toString()));
    }
  }
}
