import '../../../../core/widget/shareable_scaffold.dart';
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

    return ShareableScaffold(
      drawer: const ChristmasDrawer(
        activeItem: ChristmasMenuItem.settings,
        routes: christmasMenuRoutes,
      ),
      drawerScrimColor: Colors.black54,
      bottomNavigationBar: SizedBox(
        height: MediaQuery.sizeOf(context).height * 0.3,
        width: double.infinity,
        child: Image.asset(
          'assets/images/footer.png',
          fit: BoxFit.contain,
          alignment: Alignment.bottomCenter,
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
                  Obx(
                    () => SwitchListTile(
                      secondary: const Icon(Icons.ac_unit, color: accent),
                      title: const Text('Snowfall Effect'),
                      value: controller.snowfall.enabled.value,
                      onChanged: controller.snowfall.saving.value
                          ? null
                          : controller.setSnowfall,
                    ),
                  ),
                  Obx(
                    () => SwitchListTile(
                      secondary: const Icon(
                        Icons.volume_up_outlined,
                        color: accent,
                      ),
                      title: const Text('Sound Effects'),
                      value: controller.soundEffects.enabled.value,
                      onChanged: controller.soundEffects.saving.value
                          ? null
                          : controller.setSoundEffects,
                    ),
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
