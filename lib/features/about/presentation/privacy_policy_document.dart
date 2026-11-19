import 'package:markdown/markdown.dart' as md;

/// Presentation-only grouping. The original Markdown is retained for rendering.
class PrivacyPolicyDocument {
  PrivacyPolicyDocument._({
    required this.source,
    required this.introduction,
    required this.sections,
  });

  final String source;
  final String introduction;
  final List<PrivacyPolicySection> sections;

  factory PrivacyPolicyDocument.parse(String source) {
    final lines = source.replaceAll('\r\n', '\n').split('\n');
    final introduction = <String>[];
    final sections = <PrivacyPolicySection>[];
    final body = <String>[];
    String? title;
    String? fence;
    var fenceLength = 0;

    void finish() {
      if (title != null) {
        sections.add(
          PrivacyPolicySection(title: title, markdown: body.join('\n')),
        );
        body.clear();
      }
    }

    for (final line in lines) {
      final marker = RegExp(r'^ {0,3}(`{3,}|~{3,})(.*)$').firstMatch(line);
      final insideFence = fence != null;
      if (marker != null) {
        final run = marker.group(1)!;
        if (fence == null) {
          fence = run[0];
          fenceLength = run.length;
        } else if (run[0] == fence &&
            run.length >= fenceLength &&
            marker.group(2)!.trim().isEmpty) {
          fence = null;
        }
      }
      final heading = !insideFence && marker == null
          ? RegExp(r'^ {0,3}##[ \t]+(.+?)\s*#*\s*$').firstMatch(line)
          : null;
      if (heading != null) {
        finish();
        title = heading.group(1)!;
      } else if (title == null) {
        introduction.add(line);
      } else {
        body.add(line);
      }
    }
    finish();
    return PrivacyPolicyDocument._(
      source: source,
      introduction: introduction.join('\n'),
      sections: List.unmodifiable(sections),
    );
  }

  String? metadata(String label) {
    final pattern = RegExp(
      r'^[ \t]*(?:\*\*|__)?' +
          RegExp.escape(label) +
          r'(?:\*\*|__)?\s*:\s*(?:\*\*|__)?[ \t]*(.*)$',
      multiLine: true,
      caseSensitive: false,
    );
    final value = pattern.firstMatch(introduction)?.group(1)?.trim();
    return value == null || value.isEmpty ? null : value;
  }

  String? get email => RegExp(
    r'[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,}',
    caseSensitive: false,
  ).firstMatch(source)?.group(0);

  bool get isDraft => RegExp(
    r'^draft\b',
    caseSensitive: false,
  ).hasMatch(metadata('Publication status') ?? '');

  /// Header metadata is already shown above; preserve every other intro line.
  String get introductionDetails => introduction
      .split('\n')
      .where((line) {
        if (RegExp(
          r'^ {0,3}#\s+Privacy Policy\s*#*\s*$',
          caseSensitive: false,
        ).hasMatch(line)) {
          return false;
        }
        for (final label in [
          'Application',
          'Android package',
          'Last updated',
        ]) {
          final field = RegExp(
            r'^[ \t]*(?:\*\*|__)?' +
                RegExp.escape(label) +
                r'(?:\*\*|__)?\s*:\s*(?:\*\*|__)?[ \t]*(.*)$',
            caseSensitive: false,
          );
          if (field.hasMatch(line) && metadata(label) != null) return false;
        }
        return true;
      })
      .join('\n');

  /// UI-only omission; the source and publication metadata remain unchanged.
  String get introductionWithoutPublicationStatus => introductionDetails
      .split(RegExp(r'\n[ \t]*\n'))
      .where(
        (paragraph) => !RegExp(
          r'^\s*(?:\*\*|__)?Publication status(?:\*\*|__)?\s*:',
          caseSensitive: false,
        ).hasMatch(paragraph),
      )
      .join('\n\n');

  /// Keep document-wide reference links working when rendering separate sections.
  String get linkDefinitions => RegExp(
    r'^ {0,3}\[[^\]\n]+\]:[^\n]*(?:\n[ \t]+[^\n]*)*',
    multiLine: true,
  ).allMatches(source).map((match) => match.group(0)!).join('\n');
}

class PrivacyPolicySection {
  const PrivacyPolicySection({required this.title, required this.markdown});
  final String title;
  final String markdown;

  String get summary {
    final nodes = md.Document(
      extensionSet: md.ExtensionSet.gitHubWeb,
    ).parseLines(markdown.split('\n'));
    for (final node in nodes) {
      if (node is md.Element && node.tag == 'p') return node.textContent;
    }
    return nodes.isEmpty ? '' : nodes.first.textContent;
  }
}
