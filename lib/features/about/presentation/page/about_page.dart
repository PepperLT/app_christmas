import 'package:flutter/material.dart';

import '../../../../app/app_routes.dart';
import '../../../../core/widget/app_menu_button.dart';
import '../../../../core/widget/christmas_drawer.dart';
import '../../../../core/widget/shareable_scaffold.dart';
import '../widgets/about_hero_card.dart';
import '../widgets/about_features_section.dart';
import '../widgets/app_information_section.dart';
import '../widgets/about_footer.dart';
import '../widgets/about_style.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) => ShareableScaffold(
    backgroundColor: AboutStyle.background,
    shareErrorMessage: 'Unable to share this image. Please try again.',
    drawer: const ChristmasDrawer(
      activeItem: ChristmasMenuItem.about,
      routes: christmasMenuRoutes,
    ),
    drawerScrimColor: Colors.black54,
    appBar: AppBar(
      title: const Text('About', style: TextStyle(fontWeight: FontWeight.w800)),
      centerTitle: true,
      foregroundColor: AboutStyle.primary,
      backgroundColor: AboutStyle.background,
      surfaceTintColor: Colors.transparent,
      leadingWidth: 64,
      leading: Builder(
        builder: (drawerContext) => Center(
          child: AppMenuButton(
            tooltip: 'Open menu',
            onPressed: () => Scaffold.of(drawerContext).openDrawer(),
          ),
        ),
      ),
    ),
    body: Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 620),
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const AboutHeroCard(),
              const SizedBox(height: 24),
              const Text(
                'The Joy of Christmas',
                textAlign: TextAlign.center,
                style: AboutStyle.heading,
              ),
              const SizedBox(height: 12),
              const Text(
                'Christmas Countdown brings the festive spirit to your everyday life: count down to Christmas, open Advent gifts, and unwind with music and fun mini-games.',
                style: AboutStyle.body,
              ),
              const SizedBox(height: 24),
              const AboutFeaturesSection(),
              const SizedBox(height: 24),
              const AppInformationSection(supportEmail: 'thaivku@gmail.com'),
              const SizedBox(height: 24),
              const AboutFooter(),
              const SizedBox(height: 16),
              Image.asset(
                'assets/images/footer.png',
                fit: BoxFit.contain,
                excludeFromSemantics: true,
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
