import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class PrivacyPolicyPage extends StatefulWidget {
  const PrivacyPolicyPage({super.key});

  @override
  State<PrivacyPolicyPage> createState() => _PrivacyPolicyPageState();
}

class _PrivacyPolicyPageState extends State<PrivacyPolicyPage> {
  late final Future<String> _policy = rootBundle.loadString(
    'docs/legal/privacy_policy.md',
  );

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Privacy Policy')),
    body: FutureBuilder<String>(
      future: _policy,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(24),
              child: Text(
                'Unable to load the policy. Contact thaivku@gmail.com.',
              ),
            ),
          );
        }
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        return SelectionArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (final paragraph
                    in snapshot.data!.replaceAll('\r\n', '\n').split('\n\n'))
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: Text(
                      paragraph
                          .replaceFirst(RegExp(r'^#{1,2} '), '')
                          .replaceAll('**', '')
                          .trim(),
                      style: paragraph.startsWith('#')
                          ? Theme.of(context).textTheme.titleLarge
                          : Theme.of(context).textTheme.bodyLarge,
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    ),
  );
}
