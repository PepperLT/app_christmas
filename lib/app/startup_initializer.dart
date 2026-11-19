import 'dart:async';
import 'dart:developer' as developer;

class StartupStep {
  const StartupStep(this.name, this.initialize);
  final String name;
  final Future<void> Function() initialize;
}

/// Successful essential steps are never repeated by a subsequent Retry.
class StartupInitializer {
  StartupInitializer({
    required this.essential,
    this.optional = const [],
    required this.onOptionalError,
  });

  final List<StartupStep> essential;
  final List<StartupStep> optional;
  final void Function(String name, Object error, StackTrace stack)
  onOptionalError;
  final Set<int> _completed = {};
  Future<void>? _pending;
  bool _optionalStarted = false;

  Future<void> initialize() => _pending ??= _initialize().whenComplete(() {
    _pending = null;
  });

  Future<void> _initialize() async {
    for (var index = 0; index < essential.length; index++) {
      if (_completed.contains(index)) continue;
      try {
        await essential[index].initialize();
      } catch (error, stack) {
        developer.log(
          '${essential[index].name} initialization failed',
          name: 'startup',
          error: error,
          stackTrace: stack,
        );
        rethrow;
      }
      _completed.add(index);
    }
    if (_optionalStarted) return;
    _optionalStarted = true;
    for (final step in optional) {
      unawaited(_initializeOptional(step));
    }
  }

  Future<void> _initializeOptional(StartupStep step) async {
    try {
      await step.initialize().timeout(const Duration(seconds: 10));
    } catch (error, stack) {
      onOptionalError(step.name, error, stack);
    }
  }
}
