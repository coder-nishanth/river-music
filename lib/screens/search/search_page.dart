import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:River/core/utils/service_locator.dart';
import 'package:River/screens/search/cubit/search_cubit.dart';
import 'package:River/utils/internet_guard.dart';
import 'package:loading_indicator_m3e/loading_indicator_m3e.dart';

import '../../services/media_player.dart';
import '../../utils/adaptive_widgets/adaptive_widgets.dart';
import '../../utils/bottom_modals.dart';
import '../../ytmusic/ytmusic.dart';

class SearchPage extends StatelessWidget {
  const SearchPage({super.key, required this.query});
  final String query;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => SearchCubit(sl()),
      child: _SearchPage(query: query),
    );
  }
}

class _SearchPage extends StatefulWidget {
  final String query;
  const _SearchPage({required this.query});

  @override
  State<_SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<_SearchPage> {
  late ScrollController _scrollController;
  bool _autoSearched = false;
  List<Map<String, dynamic>> _suggestions = [];
  bool _suggestionsLoaded = false;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(_scrollListener);
    _fetchSuggestions();
  }

  Future<void> _fetchSuggestions() async {
    try {
      final suggestions = await GetIt.I<YTMusic>().getSearchSuggestions(widget.query);
      if (mounted) {
        setState(() {
          _suggestions = suggestions;
          _suggestionsLoaded = true;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() => _suggestionsLoaded = true);
      }
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_autoSearched) {
      _autoSearched = true;
      context.read<SearchCubit>().search(widget.query);
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _scrollListener() async {
    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent) {
      await context.read<SearchCubit>().fetchNext();
    }
  }

  @override
  Widget build(BuildContext context) {
    return InternetGuard(
      onInternetRestored: () {
        context.read<SearchCubit>().search(widget.query);
      },
      child: Scaffold(
        appBar: PreferredSize(
          preferredSize: const AdaptiveAppBar().preferredSize,
          child: LayoutBuilder(builder: (context, constraints) {
            return AdaptiveAppBar(
              title: Text(widget.query),
              automaticallyImplyLeading:
                  (constraints.maxWidth <= 400) ? false : true,
            );
          }),
        ),
        body: BlocBuilder<SearchCubit, SearchState>(
          builder: (context, state) {
            switch (state) {
              case SearchLoading():
                return _suggestionsLoaded && _suggestions.isEmpty
                    ? const Center(child: SizedBox())
                    : _buildResults(state);
              case SearchError():
                return _suggestionsLoaded && _suggestions.isEmpty
                    ? Center(child: Text(state.message ?? ''))
                    : _buildResults(state);
              case SearchSuccess():
                return _buildResults(state);
            }
          },
        ),
      ),
    );
  }

  Widget _buildResults(SearchState state) {
    final typedSuggestions = _suggestions.where((s) => s['type'] != 'TEXT').toList();
    final hasSections = state is SearchSuccess && state.sections.isNotEmpty;

    Widget body = Column(
      children: [
        if (typedSuggestions.isNotEmpty)
          ...typedSuggestions.map((item) => _SearchListTile(item: item)),
        if (state is SearchSuccess)
          ...state.sections.map((section) => _SearchSectionItem(section: section)),
        if (state is SearchSuccess && state.loadingMore)
          const Center(child: ExpressiveLoadingIndicator())
      ],
    );

    if (Platform.isWindows && (typedSuggestions.isNotEmpty || hasSections)) {
      body = Center(
        child: Adaptivecard(
          borderRadius: BorderRadius.circular(8),
          child: body,
        ),
      );
    }

    return SingleChildScrollView(
      controller: _scrollController,
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 1000),
          padding: const EdgeInsets.all(8),
          child: body,
        ),
      ),
    );
  }
}

class _SearchSectionItem extends StatelessWidget {
  const _SearchSectionItem({required this.section});
  final Map<String, dynamic> section;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (section['title'] != null)
          AdaptiveListTile(
            contentPadding:
                const EdgeInsets.symmetric(vertical: 4, horizontal: 4),
            title: Text(
              section['title'],
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),
        ...(section['contents'] as List? ?? []).map((item) {
          return _SearchListTile(item: item);
        })
      ],
    );
  }
}

class _SearchListTile extends StatelessWidget {
  const _SearchListTile({required this.item});
  final Map item;

  @override
  Widget build(BuildContext context) {
    return AdaptiveListTile(
      onSecondaryTap: () {
        if (item['videoId'] != null) {
          Modals.showSongBottomModal(context, item);
        } else if (item['endpoint'] != null) {
          Modals.showPlaylistBottomModal(context, item);
        }
      },
      onTap: () async {
        if (item['videoId'] != null) {
          await GetIt.I<MediaPlayer>().playSong(Map.from(item));
        } else if (item['endpoint'] != null && item['videoId'] == null) {
          context.push(
            '/browse',
            extra: {'endpoint': item['endpoint']},
          );
        }
      },
      onLongPress: () {
        if (item['videoId'] != null) {
          Modals.showSongBottomModal(context, item);
        } else if (item['endpoint'] != null) {
          Modals.showPlaylistBottomModal(context, item);
        }
      },
      dense: false,
      title: Text(
        item['title'],
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: item['subtitle'] != null
          ? Text(
              item['subtitle'],
              maxLines: 1,
              style: TextStyle(color: Colors.grey.withValues(alpha: 0.9)),
              overflow: TextOverflow.ellipsis,
            )
          : null,
      leading: item['thumbnails'] != null && item['thumbnails'].isNotEmpty
          ? ClipRRect(
              borderRadius: BorderRadius.circular(
                  ['ARTIST', 'PROFILE'].contains(item['type']) ? 30 : 3),
              child: Image.network(
                item['thumbnails'].first['url'],
                width: 50,
              ))
          : null,
      trailing: item['videoId'] == null && item['endpoint'] != null
          ? const Icon(CupertinoIcons.chevron_right)
          : null,
    );
  }
}
