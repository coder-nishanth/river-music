import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../themes/text_styles.dart';

class RepoOfTheDayCard extends StatelessWidget {
  final Map<String, dynamic> repo;

  const RepoOfTheDayCard({required this.repo, super.key});

  @override
  Widget build(BuildContext context) {
    final stars = repo['stars'] ?? 0;
    final forks = repo['forks'] ?? 0;
    final language = repo['language'];
    final avatarUrl = repo['ownerAvatar'] ?? '';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Card(
        color: Colors.grey.withValues(alpha: 0.15),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () async {
            final url = Uri.parse(repo['url'] ?? 'https://github.com');
            if (await canLaunchUrl(url)) {
              await launchUrl(url, mode: LaunchMode.externalApplication);
            }
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    width: 56,
                    height: 56,
                    color: Colors.grey.withValues(alpha: 0.3),
                    child: avatarUrl.isNotEmpty
                        ? CachedNetworkImage(
                            imageUrl: avatarUrl,
                            fit: BoxFit.cover,
                          )
                        : const Icon(Icons.code, color: Colors.white70),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Repository of the Day',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.withValues(alpha: 0.8),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        repo['title'] ?? '',
                        style: mediumTextStyle(context).copyWith(fontSize: 16),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (repo['description'] != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          repo['description'],
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey.withValues(alpha: 0.7),
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(Icons.star, size: 16, color: Colors.amber),
                          const SizedBox(width: 4),
                          Text(
                            _formatCount(stars),
                            style: const TextStyle(fontSize: 13),
                          ),
                          const SizedBox(width: 16),
                          if (language != null) ...[
                            const Icon(Icons.circle, size: 12, color: Colors.blue),
                            const SizedBox(width: 4),
                            Text(language, style: const TextStyle(fontSize: 13)),
                            const SizedBox(width: 16),
                          ],
                          const Icon(Icons.call_split, size: 16, color: Colors.grey),
                          const SizedBox(width: 4),
                          Text(
                            _formatCount(forks),
                            style: const TextStyle(fontSize: 13),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.open_in_new, size: 18, color: Colors.white54),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _formatCount(dynamic count) {
    final n = (count is int) ? count : int.tryParse(count.toString()) ?? 0;
    if (n >= 1000) {
      return '${(n / 1000).toStringAsFixed(1)}k';
    }
    return n.toString();
  }
}
