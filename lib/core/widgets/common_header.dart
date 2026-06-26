import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../../generated/l10n.dart';
import '../../services/media_player.dart';
import '../../ytmusic/ytmusic.dart';

class CommonHeader extends StatefulWidget {
  const CommonHeader({super.key});
  @override
  State<CommonHeader> createState() => _CommonHeaderState();
}

class _CommonHeaderState extends State<CommonHeader> {
  TextEditingController? _controller;

  void _navigateToSearch(String query) async {
    if (query.trim().isEmpty) return;
    if (Hive.box('SETTINGS').get('SEARCH_HISTORY', defaultValue: true)) {
      await Hive.box('SEARCH_HISTORY').delete(query.toLowerCase());
      await Hive.box('SEARCH_HISTORY').put(query.toLowerCase(), query);
    }
    if (mounted) {
      context.push('/search', extra: query.trim());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 44,
      constraints: const BoxConstraints(maxWidth: 400),
      child: TypeAheadField(
        hideOnEmpty: true,
        hideOnError: true,
        suggestionsCallback: (query) async {
          if (query.isEmpty) {
            return Hive.box('SEARCH_HISTORY')
                .values
                .toList()
                .map((el) => {
                      'type': 'TEXT',
                      'query': el,
                      'isHistory': true,
                    })
                .toList();
          }
          try {
            return await GetIt.I<YTMusic>().getSearchSuggestions(query);
          } catch (e) {
            return [];
          }
        },
        builder: (context, controller, focusNode) {
          _controller ??= controller;
          return Container(
            decoration: BoxDecoration(
              color: Colors.grey.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const SizedBox(width: 12),
                Icon(
                  Icons.search,
                  color: Colors.white.withValues(alpha: 0.6),
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: controller,
                    focusNode: focusNode,
                    style: const TextStyle(color: Colors.white, fontSize: 15),
                    textInputAction: TextInputAction.search,
                    onSubmitted: (query) {
                      _navigateToSearch(query);
                    },
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText: S.of(context).Search_River,
                      hintStyle: TextStyle(
                        color: Colors.white.withValues(alpha: 0.5),
                        fontSize: 15,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
          constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.5),
          decorationBuilder: null,
        itemBuilder: (context, value) {
          if (value['type'] == 'TEXT') {
            return SizedBox(
              height: 36,
              child: ClipRect(
                child: GestureDetector(
                  onTap: () => _navigateToSearch(value['query'] ?? ''),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Row(
                      children: [
                        if (value['isHistory'] != null)
                          Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: Icon(Icons.history, size: 18, color: Colors.white.withValues(alpha: 0.5)),
                          ),
                        Text(value['query'] ?? '', style: const TextStyle(color: Colors.white, fontSize: 14)),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }
          return SizedBox(
            height: 36,
            child: ClipRect(child: _SuggestionTile(item: value)),
          );
        },
        onSelected: (value) {},
      ),
    );
  }
}

class _SuggestionTile extends StatelessWidget {
  final Map item;
  const _SuggestionTile({required this.item});

  @override
  Widget build(BuildContext context) {
    final hasThumb = item['thumbnails'] != null &&
        (item['thumbnails'] as List).isNotEmpty;
    return GestureDetector(
      onTap: () {
        if (item['videoId'] != null) {
          GetIt.I<MediaPlayer>().playSong(Map.from(item));
        } else if (item['endpoint'] != null) {
          // navigate via context - skip for suggestions
        }
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        child: Row(
          children: [
            if (hasThumb)
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: Image.network(
                  item['thumbnails'].first['url'],
                  width: 28,
                  height: 28,
                  fit: BoxFit.cover,
                ),
              ),
            if (hasThumb) const SizedBox(width: 8),
            Expanded(
              child: Text(
                item['title'] ?? '',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: Colors.white, fontSize: 14),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
