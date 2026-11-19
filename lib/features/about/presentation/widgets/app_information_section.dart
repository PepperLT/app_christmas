import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import '../page/privacy_policy_page.dart';
import 'about_style.dart';
import 'app_information_tile.dart';

class AppInformationSection extends StatefulWidget {
  const AppInformationSection({super.key, this.supportEmail});

  /// Supply only an approved support address. The existing policy is a draft.
  final String? supportEmail;
  @override
  State<AppInformationSection> createState() => _AppInformationSectionState();
}

class _AppInformationSectionState extends State<AppInformationSection> {
  late final Future<PackageInfo?> _packageInfo = _loadPackageInfo();
  bool _openingEmail = false;

  Future<PackageInfo?> _loadPackageInfo() async {
    try {
      return await PackageInfo.fromPlatform();
    } catch (_) {
      return null;
    }
  }

  Future<void> _contactSupport() async {
    final email = widget.supportEmail?.trim();
    if (_openingEmail || email == null || email.isEmpty) return;
    _openingEmail = true;
    try {
      final opened = await launchUrl(
        Uri(
          scheme: 'mailto',
          path: email,
          query:
              'subject=${Uri.encodeComponent('Christmas Countdown Support')}',
        ),
      );
      if (!opened) _showEmailError();
    } catch (_) {
      _showEmailError();
    } finally {
      _openingEmail = false;
    }
  }

  void _showEmailError() {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Unable to open an email app. Please contact ${widget.supportEmail}.',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) => FutureBuilder<PackageInfo?>(
    future: _packageInfo,
    builder: (context, snapshot) {
      final info = snapshot.data;
      final version = info == null || info.version.isEmpty
          ? null
          : info.version;
      final displayVersion = version == null
          ? (snapshot.connectionState == ConnectionState.done
                ? 'Unavailable'
                : 'Loading…')
          : 'v$version${info!.buildNumber.isEmpty ? '' : ' (${info.buildNumber})'}';
      final tiles = <Widget>[
        AppInformationTile(
          icon: Icons.smartphone,
          title: 'App Version',
          value: displayVersion,
        ),
        AppInformationTile(
          icon: Icons.privacy_tip_outlined,
          title: 'Privacy Policy',
          onTap: () => Navigator.of(context).push<void>(
            MaterialPageRoute<void>(builder: (_) => const PrivacyPolicyPage()),
          ),
        ),
        if (widget.supportEmail?.trim().isNotEmpty ?? false)
          AppInformationTile(
            icon: Icons.mail_outline,
            title: 'Contact & Support',
            onTap: _contactSupport,
          ),
      ];
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'App Information',
            textAlign: TextAlign.center,
            style: AboutStyle.heading,
          ),
          const SizedBox(height: 16),
          DecoratedBox(
            decoration: AboutStyle.card,
            child: Material(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(24),
              clipBehavior: Clip.antiAlias,
              child: Column(
                children: [
                  for (var i = 0; i < tiles.length; i++) ...[
                    if (i > 0)
                      const Divider(
                        height: 1,
                        indent: 16,
                        endIndent: 16,
                        color: AboutStyle.border,
                      ),
                    tiles[i],
                  ],
                ],
              ),
            ),
          ),
        ],
      );
    },
  );
}
