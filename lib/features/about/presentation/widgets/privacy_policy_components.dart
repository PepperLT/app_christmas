import 'package:flutter/material.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import 'package:markdown/markdown.dart' as md;

import '../privacy_policy_document.dart';
import 'about_style.dart';

class PolicyMarkdown extends StatelessWidget {
  const PolicyMarkdown({
    super.key,
    required this.data,
    required this.onOpenLink,
  });
  final String data;
  final ValueChanged<String> onOpenLink;

  @override
  Widget build(BuildContext context) => MarkdownBody(
    data: data,
    extensionSet: md.ExtensionSet.gitHubWeb,
    onTapLink: (_, href, _) {
      if (href != null) onOpenLink(href);
    },
    styleSheet: MarkdownStyleSheet.fromTheme(Theme.of(context)).copyWith(
      p: AboutStyle.body,
      a: const TextStyle(
        color: AboutStyle.accent,
        decoration: TextDecoration.underline,
      ),
      h1: AboutStyle.heading,
      h2: AboutStyle.heading.copyWith(fontSize: 20),
      strong: const TextStyle(fontWeight: FontWeight.w700),
      blockSpacing: 12,
      listBullet: AboutStyle.body,
    ),
    softLineBreak: true,
  );
}

class PolicyHeaderCard extends StatelessWidget {
  const PolicyHeaderCard({super.key, required this.document});
  final PrivacyPolicyDocument document;

  @override
  Widget build(BuildContext context) => Container(
    decoration: AboutStyle.card.copyWith(
      gradient: const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFFFFFDF7), Color(0xFFFFE8E2)],
      ),
    ),
    padding: const EdgeInsets.all(24),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Icon(
          Icons.verified_user_outlined,
          color: AboutStyle.accent,
          size: 48,
        ),
        const SizedBox(height: 16),
        Text(
          document.metadata('Application') ?? 'Christmas Countdown',
          textAlign: TextAlign.center,
          style: AboutStyle.heading,
        ),
        const SizedBox(height: 8),
        const Text(
          'Privacy Policy',
          textAlign: TextAlign.center,
          style: AboutStyle.body,
        ),
      ],
    ),
  );
}

class PolicySectionTile extends StatelessWidget {
  const PolicySectionTile({
    super.key,
    required this.section,
    required this.index,
    required this.linkDefinitions,
    required this.onOpenLink,
  });
  final PrivacyPolicySection section;
  final int index;
  final String linkDefinitions;
  final ValueChanged<String> onOpenLink;

  static const _icons = [
    Icons.description_outlined,
    Icons.person_outline,
    Icons.smartphone,
    Icons.cloud_outlined,
    Icons.share_outlined,
    Icons.layers_outlined,
    Icons.delete_outline,
    Icons.family_restroom,
    Icons.shield_outlined,
    Icons.update,
  ];

  @override
  Widget build(BuildContext context) => ExpansionTile(
    key: PageStorageKey('policy-section-$index-${section.title}'),
    tilePadding: const EdgeInsets.all(16),
    childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
    expandedCrossAxisAlignment: CrossAxisAlignment.stretch,
    iconColor: AboutStyle.accent,
    collapsedIconColor: AboutStyle.primary,
    shape: const Border(),
    collapsedShape: const Border(),
    title: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AboutStyle.accent.withValues(alpha: .06),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Icon(
            index < _icons.length ? _icons[index] : Icons.description_outlined,
            color: AboutStyle.accent,
            size: 24,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                RegExp(r'^\d+[.)]\s').hasMatch(section.title)
                    ? section.title
                    : '${index + 1}. ${section.title}',
                style: const TextStyle(
                  color: AboutStyle.primary,
                  fontSize: 17,
                  height: 1.4,
                  fontWeight: FontWeight.w700,
                ),
              ),
              if (section.summary.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  section.summary,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AboutStyle.body.copyWith(fontSize: 14),
                ),
              ],
            ],
          ),
        ),
      ],
    ),
    children: [
      PolicyMarkdown(
        data: '${section.markdown}\n\n$linkDefinitions',
        onOpenLink: onOpenLink,
      ),
    ],
  );
}

class PolicyContactCard extends StatelessWidget {
  const PolicyContactCard({
    super.key,
    required this.email,
    required this.onEmail,
    required this.onCopy,
  });
  final String email;
  final VoidCallback onEmail;
  final VoidCallback onCopy;

  @override
  Widget build(BuildContext context) => Container(
    decoration: AboutStyle.card,
    padding: const EdgeInsets.all(16),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Icon(Icons.mail_outline, color: AboutStyle.accent, size: 32),
        const SizedBox(height: 12),
        const Text(
          'Contact Us',
          textAlign: TextAlign.center,
          style: AboutStyle.heading,
        ),
        const SizedBox(height: 8),
        const Text(
          'Have questions about your privacy?',
          textAlign: TextAlign.center,
          style: AboutStyle.body,
        ),
        const SizedBox(height: 12),
        TextButton(
          onPressed: onEmail,
          style: TextButton.styleFrom(foregroundColor: AboutStyle.accent),
          child: Text('Email: $email', textAlign: TextAlign.center),
        ),
        TextButton.icon(
          onPressed: onCopy,
          icon: const Icon(Icons.copy_outlined),
          label: const Text('Copy email address'),
          style: TextButton.styleFrom(foregroundColor: AboutStyle.primary),
        ),
      ],
    ),
  );
}
