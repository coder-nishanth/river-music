import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';


import '../../generated/l10n.dart';
import '../../themes/text_styles.dart';
import '../../utils/adaptive_widgets/adaptive_widgets.dart';
import 'widgets/setting_item.dart';
import 'cubit/settings_system_cubit.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => SettingsSystemCubit()..load(),
      child: AdaptiveScaffold(
        appBar: AdaptiveAppBar(
          title: Text(
            S.of(context).Settings,
            style: appBarTitleStyle(),
          ),
          automaticallyImplyLeading: false,
        ),
        body: BlocBuilder<SettingsSystemCubit, SettingsSystemState>(
          builder: (context, state) {
            return Center(
              child: Container(
                constraints: const BoxConstraints(maxWidth: 1000),
                child: ListView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  children: [
                    GroupTitle(title: "Services"),
                    SettingTile(
                      title: "Youtube Music",
                      leading: const Icon(Icons.play_circle_fill),
                      isFirst: true,
                      isLast: true,
                      onTap: () => context.go('/settings/services/ytmusic'),
                    ),
                    GroupTitle(title: "Privacy"),
                    SettingTile(
                      title: "Privacy",
                      leading: const Icon(Icons.privacy_tip),
                      isFirst: true,
                      isLast: true,
                      onTap: () => context.go('/settings/privacy'),
                    ),
                    GroupTitle(title: "About"),
                    SettingTile(
                      title: S.of(context).About,
                      leading: const Icon(Icons.info_rounded),
                      isFirst: true,
                      onTap: () => context.go('/settings/about'),
                    ),
                    SettingTile(
                      title: "Support",
                      leading: const Icon(Icons.favorite_rounded),
                      isLast: true,
                      onTap: () => _showSupportModal(context),
                    ),
                    const SizedBox(height: 100),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

void _showSupportModal(BuildContext context) {
  showModalBottomSheet(
    context: context,
    backgroundColor: const Color(0xFF1A1A1A),
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    builder: (context) => Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Center(
            child: Text(
              'Support',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'UPI ID',
            style: TextStyle(fontSize: 14, color: Colors.grey),
          ),
          const SizedBox(height: 8),
          GestureDetector(
            onTap: () {
              Clipboard.setData(const ClipboardData(text: 'coder-nishanth@airtel'));
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('UPI ID copied!')),
              );
            },
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Row(
                children: [
                  Icon(Icons.copy, size: 18, color: Colors.white70),
                  SizedBox(width: 12),
                  Text(
                    'coder-nishanth@airtel',
                    style: TextStyle(fontSize: 16, color: Colors.white),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Buy Me a Coffee',
            style: TextStyle(fontSize: 14, color: Colors.grey),
          ),
          const SizedBox(height: 8),
          GestureDetector(
            onTap: () async {
              final uri = Uri.parse('https://buymeacoffee.com/nishanth');
              if (await canLaunchUrl(uri)) {
                await launchUrl(uri, mode: LaunchMode.externalApplication);
              }
            },
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Row(
                children: [
                  Icon(Icons.open_in_new, size: 18, color: Colors.white70),
                  SizedBox(width: 12),
                  Text(
                    'buymeacoffee.com/nishanth',
                    style: TextStyle(fontSize: 16, color: Colors.white),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    ),
  );
}
