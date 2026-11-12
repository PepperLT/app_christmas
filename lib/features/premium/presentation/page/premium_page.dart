import 'package:flutter/material.dart';

import '../../../../app/app_routes.dart';
import '../../../../core/widget/app_menu_button.dart';
import '../../../../core/widget/christmas_drawer.dart';
import '../../../../core/widget/shareable_scaffold.dart';
import '../widgets/premium_components.dart';

class PremiumPage extends StatelessWidget {
  const PremiumPage({super.key});

  @override
  Widget build(BuildContext context) => ShareableScaffold(
    backgroundColor: const Color(0xFFFBE6E1),
    drawer: const ChristmasDrawer(
      activeItem: ChristmasMenuItem.premium,
      routes: christmasMenuRoutes,
    ),
    drawerScrimColor: Colors.black54,
    appBar: AppBar(
      title: const Text(
        'Premium',
        style: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w800,
          color: Color(0xFF24212B),
        ),
      ),
      centerTitle: true,
      backgroundColor: PremiumStyle.background,
      surfaceTintColor: Colors.transparent,
      foregroundColor: PremiumStyle.wine,
      leadingWidth: 64,
      leading: Builder(
        builder: (drawerContext) => Center(
          child: AppMenuButton(
            onPressed: () => Scaffold.of(drawerContext).openDrawer(),
          ),
        ),
      ),
    ),
    body: SafeArea(
      top: false,
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480),
          child: Container(
            margin: const EdgeInsets.fromLTRB(10, 8, 10, 12),
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              color: PremiumStyle.background,
              borderRadius: BorderRadius.circular(30),
              border: Border.all(color: Colors.white, width: 2),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x189C544F),
                  blurRadius: 18,
                  offset: Offset(0, 6),
                ),
              ],
            ),
            child: const SingleChildScrollView(child: PremiumContent()),
          ),
        ),
      ),
    ),
  );
}
