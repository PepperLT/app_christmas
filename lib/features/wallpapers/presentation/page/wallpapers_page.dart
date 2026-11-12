import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../app/app_routes.dart';
import '../../../../core/widget/app_menu_button.dart';
import '../../../../core/widget/christmas_drawer.dart';
import '../../../../core/widget/shareable_scaffold.dart';
import '../../data/wallpaper_service.dart';
import '../controllers/wallpapers_controller.dart';
import '../../../premium/presentation/widgets/premium_dialog.dart';

class WallpapersPage extends GetView<WallpapersController> {
  const WallpapersPage({super.key});

  Future<void> _preview(
    BuildContext context,
    String asset,
    String label,
  ) async {
    await showDialog<void>(
      context: context,
      builder: (dialogContext) => Dialog(
        clipBehavior: Clip.antiAlias,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 400),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 20, right: 4, top: 4),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        label,
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                    ),
                    IconButton(
                      tooltip: 'Đóng',
                      onPressed: () => Navigator.pop(dialogContext),
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
              ),
              Flexible(
                child: Stack(
                  alignment: Alignment.topCenter,
                  children: [
                    Image.asset(
                      asset,
                      width: double.infinity,
                      fit: BoxFit.contain,
                      errorBuilder: (_, error, stack) => const SizedBox(
                        height: 180,
                        child: Center(child: Text('Không thể tải ảnh')),
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.all(20),
                      child: Text(
                        'Christmas\nCountdown',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Color(0xFF9E3546),
                          fontSize: 28,
                          fontWeight: FontWeight.w800,
                          shadows: [Shadow(color: Colors.white, blurRadius: 6)],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Obx(
                  () => Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (controller.error.value != null)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Text(
                            controller.error.value!,
                            style: const TextStyle(color: Colors.red),
                          ),
                        ),
                      FilledButton(
                        onPressed: controller.saving.value
                            ? null
                            : () async {
                                if (!controller.service.canUse(asset)) {
                                  await showPremiumDialog(dialogContext);
                                  return;
                                }
                                final applied = await controller.apply(asset);
                                if (!dialogContext.mounted || !applied) return;
                                Navigator.pop(dialogContext);
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Đã đổi ảnh nền Countdown'),
                                    ),
                                  );
                                }
                              },
                        child: Text(
                          controller.saving.value
                              ? 'Đang lưu…'
                              : 'Dùng cho Countdown',
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) => ShareableScaffold(
    backgroundColor: const Color(0xFFFFF7F3),
    drawer: const ChristmasDrawer(
      activeItem: ChristmasMenuItem.wallpapers,
      routes: christmasMenuRoutes,
    ),
    drawerScrimColor: Colors.black54,
    appBar: AppBar(
      title: const Text(
        'Wallpapers',
        style: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w800,
          color: Color.fromARGB(255, 167, 77, 95),
        ),
      ),
      centerTitle: true,
      leadingWidth: 64,
      leading: Builder(
        builder: (drawerContext) => Center(
          child: AppMenuButton(
            onPressed: () => Scaffold.of(drawerContext).openDrawer(),
          ),
        ),
      ),
    ),
    body: Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 720),
        child: GridView.builder(
          padding: const EdgeInsets.all(16),
          gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
            maxCrossAxisExtent: 240,
            childAspectRatio: .6,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
          ),
          itemCount: WallpaperService.assets.length,
          itemBuilder: (context, index) {
            final asset = WallpaperService.assets[index];
            final label = index == 0 ? 'Mặc định' : 'Giáng sinh $index';
            return Obx(() {
              final selected = controller.service.selectedAsset.value == asset;
              return Semantics(
                selected: selected,
                child: Card(
                  clipBehavior: Clip.antiAlias,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                    side: BorderSide(
                      color: selected
                          ? const Color(0xFFB4232B)
                          : const Color(0xFFF0DDD5),
                      width: selected ? 2 : 1,
                    ),
                  ),
                  child: InkWell(
                    onTap: () => _preview(context, asset, label),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Expanded(
                          child: Image.asset(
                            asset,
                            fit: BoxFit.cover,
                            cacheWidth: 480,
                            errorBuilder: (_, error, stack) => const Center(
                              child: Icon(Icons.broken_image_outlined),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(10),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  label,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              if (selected)
                                const Icon(
                                  Icons.check_circle,
                                  color: Color(0xFFB4232B),
                                  size: 20,
                                ),
                              if (WallpaperService.isPremium(asset) &&
                                  !controller.service.canUse(asset))
                                const Tooltip(
                                  message: 'Premium',
                                  child: Icon(
                                    Icons.lock_rounded,
                                    color: Color(0xFF996319),
                                    size: 20,
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            });
          },
        ),
      ),
    ),
  );
}
