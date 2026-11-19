import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';
import 'startup_initializer.dart';

class StartupApp extends StatefulWidget {
  const StartupApp({
    super.key,
    required this.initializer,
    required this.appBuilder,
  });
  final StartupInitializer initializer;
  final WidgetBuilder appBuilder;

  @override
  State<StartupApp> createState() => _StartupAppState();
}

class _StartupAppState extends State<StartupApp> {
  bool _busy = true;
  bool _ready = false;
  bool _failed = false;

  @override
  void initState() {
    super.initState();
    _start();
  }

  Future<void> _start() async {
    try {
      await widget.initializer.initialize();
      if (mounted) {
        setState(() {
          _ready = true;
          _busy = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _busy = false;
          _failed = true;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_ready) return widget.appBuilder(context);
    return MaterialApp(
      title: 'Christmas Countdown',
      theme: appTheme,
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (_busy) ...[
                    const CircularProgressIndicator(),
                    const SizedBox(height: 16),
                    const Text(
                      'Starting Christmas Countdown…',
                      textAlign: TextAlign.center,
                    ),
                  ] else if (_failed) ...[
                    const Icon(Icons.error_outline, size: 48),
                    const SizedBox(height: 16),
                    const Text(
                      'Unable to start Christmas Countdown. Please try again.',
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    FilledButton(
                      onPressed: () {
                        if (_busy) return;
                        setState(() {
                          _busy = true;
                          _failed = false;
                        });
                        _start();
                      },
                      child: const Text('Retry'),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
