import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../app/app_routes.dart';
import '../../../../core/widget/app_menu_button.dart';
import '../../../../core/widget/christmas_drawer.dart';
import '../controllers/settings_controller.dart';

class SettingsPage extends GetView<SettingsController> {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    const accent = Color(0xFFB4232B);

    return Scaffold(
      drawer: const ChristmasDrawer(
        activeItem: ChristmasMenuItem.settings,
        routes: christmasMenuRoutes,
      ),
      drawerScrimColor: Colors.black54,
      bottomNavigationBar: SizedBox(
        height: MediaQuery.sizeOf(context).height * 0.3,
        width: double.infinity,
        child: ClipRect(
          child: Image.asset(
            'assets/images/footer_0.png',
            fit: BoxFit.cover,
            alignment: Alignment.bottomCenter,
          ),
        ),
      ),
      appBar: AppBar(
        leadingWidth: 64,
        leading: Builder(
          builder: (drawerContext) => Center(
            child: AppMenuButton(
              onPressed: () => Scaffold.of(drawerContext).openDrawer(),
            ),
          ),
        ),
        centerTitle: true,
        foregroundColor: accent,
        title: const Text('Settings'),
      ),
      body: SafeArea(
        top: false,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Card(
              clipBehavior: Clip.antiAlias,
              child: Column(
                children: [
                  Obx(
                    () => SwitchListTile(
                      secondary: const Icon(Icons.music_note, color: accent),
                      title: const Text('Music'),
                      value: controller.playMusic,
                      onChanged: controller.setPlayMusic,
                    ),
                  ),
                  for (final (icon, label, enabled) in const [
                    (Icons.volume_up_outlined, 'Sound Effects', true),
                    (Icons.ac_unit, 'Snowfall Effect', true),
                    (Icons.notifications_outlined, 'Notifications', false),
                  ])
                    SwitchListTile(
                      secondary: Icon(icon, color: accent),
                      title: Text(label),
                      value: enabled,
                      onChanged: null,
                    ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            const Card(
              child: Column(
                children: [
                  ListTile(
                    leading: Icon(Icons.language, color: accent),
                    title: Text('Language'),
                    trailing: Text('English  ›'),
                  ),
                  Divider(height: 1),
                  ListTile(
                    leading: Icon(Icons.light_mode_outlined, color: accent),
                    title: Text('Theme'),
                    trailing: Text('Light  ›'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
