import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

import '../privacy_policy_document.dart';
import '../widgets/about_style.dart';
import '../widgets/privacy_policy_components.dart';

class PrivacyPolicyPage extends StatefulWidget {
  const PrivacyPolicyPage({super.key});

  @override
  State<PrivacyPolicyPage> createState() => _PrivacyPolicyPageState();
}

class _PrivacyPolicyPageState extends State<PrivacyPolicyPage> {
  AssetBundle? _bundle;
  Future<PrivacyPolicyDocument>? _policy;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final bundle = DefaultAssetBundle.of(context);
    if (!identical(bundle, _bundle)) {
      _bundle = bundle;
      _policy = _loadPolicy();
    }
  }

  Future<PrivacyPolicyDocument> _loadPolicy() async {
    final source = await _bundle!.loadString(
      'docs/legal/privacy_policy.md',
      cache: false,
    );
    if (source.trim().isEmpty) throw const FormatException('Empty policy');
    return PrivacyPolicyDocument.parse(source);
  }

  void _notify(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _openLink(String href) async {
    final uri = Uri.tryParse(href);
    if (uri == null || !['https', 'http', 'mailto'].contains(uri.scheme)) {
      _notify('Unable to open this link.');
      return;
    }
    try {
      if (!await launchUrl(uri)) {
        _notify('Unable to open this link. You can copy it from the policy.');
      }
    } catch (_) {
      _notify('Unable to open this link. You can copy it from the policy.');
    }
  }

  Future<void> _copyEmail(String email) async {
    try {
      await Clipboard.setData(ClipboardData(text: email));
      _notify('Email address copied.');
    } catch (_) {
      _notify('Unable to copy the email address.');
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: AboutStyle.background,
    appBar: AppBar(
      title: const Text(
        'Privacy Policy',
        style: TextStyle(fontWeight: FontWeight.w800),
      ),
      centerTitle: true,
      foregroundColor: AboutStyle.primary,
      backgroundColor: AboutStyle.background,
      surfaceTintColor: Colors.transparent,
    ),
    body: SafeArea(
      top: false,
      child: FutureBuilder<PrivacyPolicyDocument>(
        future: _policy,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.description_outlined,
                      color: AboutStyle.accent,
                      size: 48,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Unable to load the privacy policy. Please try again.',
                      textAlign: TextAlign.center,
                      style: AboutStyle.body,
                    ),
                    const SizedBox(height: 16),
                    FilledButton(
                      onPressed: () => setState(() {
                        _policy = _loadPolicy();
                      }),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            );
          }
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final document = snapshot.data!;
          final definitions = document.linkDefinitions;
          return Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 720),
              child: SelectionArea(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      PolicyHeaderCard(document: document),
                      if (document.introductionWithoutPublicationStatus
                          .trim()
                          .isNotEmpty) ...[
                        const SizedBox(height: 16),
                        Container(
                          decoration: AboutStyle.card,
                          padding: const EdgeInsets.all(16),
                          child: PolicyMarkdown(
                            data:
                                '${document.introductionWithoutPublicationStatus}\n\n$definitions',
                            onOpenLink: _openLink,
                          ),
                        ),
                      ],
                      if (document.sections.isNotEmpty) ...[
                        const SizedBox(height: 16),
                        DecoratedBox(
                          decoration: AboutStyle.card,
                          child: Column(
                            children: [
                              for (
                                var index = 0;
                                index < document.sections.length;
                                index++
                              ) ...[
                                if (index > 0)
                                  const Divider(
                                    height: 1,
                                    indent: 16,
                                    endIndent: 16,
                                    color: AboutStyle.border,
                                  ),
                                PolicySectionTile(
                                  section: document.sections[index],
                                  index: index,
                                  linkDefinitions: definitions,
                                  onOpenLink: _openLink,
                                ),
                              ],
                            ],
                          ),
                        ),
                      ],
                      if (document.email case final email?) ...[
                        const SizedBox(height: 24),
                        PolicyContactCard(
                          email: email,
                          onEmail: () => _openLink(
                            Uri(scheme: 'mailto', path: email).toString(),
                          ),
                          onCopy: () => _copyEmail(email),
                        ),
                      ],
                      const SizedBox(height: 16),
                      Image.asset(
                        'assets/images/footer.png',
                        fit: BoxFit.contain,
                        excludeFromSemantics: true,
                        errorBuilder: (_, _, _) => const SizedBox.shrink(),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    ),
  );
}
