import 'package:flutter/material.dart';

class SongProgress extends StatefulWidget {
  const SongProgress({
    super.key,
    required this.position,
    required this.duration,
    required this.enabled,
    required this.onSeek,
  });

  final Duration position;
  final Duration duration;
  final bool enabled;
  final ValueChanged<Duration> onSeek;

  @override
  State<SongProgress> createState() => _SongProgressState();
}

class _SongProgressState extends State<SongProgress> {
  double? _dragMilliseconds;

  @override
  void didUpdateWidget(covariant SongProgress oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!widget.enabled) _dragMilliseconds = null;
  }

  String _format(Duration duration) {
    final minutes = duration.inMinutes.toString().padLeft(2, '0');
    final seconds = (duration.inSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    final max = widget.duration.inMilliseconds.toDouble();
    final value =
        (_dragMilliseconds ?? widget.position.inMilliseconds.toDouble()).clamp(
          0.0,
          max > 0 ? max : 0.0,
        );
    final enabled = widget.enabled && max > 0;
    return Column(
      children: [
        Slider(
          value: value,
          max: max > 0 ? max : 1,
          label: _format(Duration(milliseconds: value.round())),
          onChanged: enabled
              ? (value) {
                  setState(() => _dragMilliseconds = value);
                }
              : null,
          onChangeEnd: enabled
              ? (value) {
                  widget.onSeek(Duration(milliseconds: value.round()));
                  if (mounted) setState(() => _dragMilliseconds = null);
                }
              : null,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(_format(Duration(milliseconds: value.round()))),
            Text(_format(widget.duration)),
          ],
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}
