import 'package:flutter/material.dart';
import 'package:get/get.dart';

enum ChristmasMenuItem {
  home('Home', Icons.home_outlined),
  countdown('Countdown', Icons.timer_outlined),
  music('Music', Icons.music_note_rounded),
  adventCalendar('Advent Calendar', Icons.calendar_month_outlined),
  bubbleBox('Bubble Box', Icons.sports_esports_outlined),
  premium('Premium', Icons.workspace_premium_outlined),
  wallpapers('Wallpapers', Icons.image_outlined),
  settings('Settings', Icons.settings_outlined),
  help('Help', Icons.help_outline),
  about('About', Icons.info_outline),
  share('Share', Icons.share_outlined);

  const ChristmasMenuItem(this.label, this.icon);

  final String label;
  final IconData icon;
}

class ChristmasDrawer extends StatelessWidget {
  const ChristmasDrawer({
    super.key,
    required this.activeItem,
    required this.routes,
    this.onShare,
  });

  final ChristmasMenuItem activeItem;
  final Map<ChristmasMenuItem, String> routes;
  final VoidCallback? onShare;

  void _selectItem(BuildContext context, ChristmasMenuItem item) {
    if (item == ChristmasMenuItem.share) {
      // Register the request before pop synchronously reports drawer closure.
      onShare?.call();
      Navigator.of(context).pop();
      return;
    }

    Navigator.of(context).pop();

    if (item == activeItem) return;

    final route = routes[item];
    if (route != null) {
      Get.offNamed(route);
    }
  }

  @override
  Widget build(BuildContext context) {
    const accent = Color(0xFF9E2634);

    return Drawer(
      width: MediaQuery.sizeOf(context).width * 0.70,
      backgroundColor: const Color(0xFFF7A6AA),
      shape: const RoundedRectangleBorder(),
      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(8, 16, 8, 16),
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(8, 8, 8, 20),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 28,
                    backgroundColor: Color(0xFFFFD6C6),
                    child: Text('🎅', style: TextStyle(fontSize: 34)),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Christmas\nCountdown',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontStyle: FontStyle.italic,
                        fontWeight: FontWeight.bold,
                        height: 1.1,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 20),
            for (final item in ChristmasMenuItem.values)
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: ListTile(
                  dense: true,
                  visualDensity: VisualDensity.compact,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  selected: item == activeItem,
                  selectedTileColor: const Color(0xFFFFEEEC),
                  selectedColor: accent,
                  iconColor: accent,
                  textColor: const Color(0xFF48252A),
                  leading: Icon(item.icon, size: 35),
                  title: Text(
                    item.label,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  onTap:
                      item == activeItem ||
                          routes.containsKey(item) ||
                          (item == ChristmasMenuItem.share && onShare != null)
                      ? () => _selectItem(context, item)
                      : null,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
