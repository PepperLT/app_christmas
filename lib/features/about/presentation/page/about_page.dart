import 'package:flutter/material.dart';

import '../../../../app/app_routes.dart';
import '../../../../core/widget/app_menu_button.dart';
import '../../../../core/widget/christmas_drawer.dart';
import '../../../../core/widget/shareable_scaffold.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  static const _wine = Color(0xFF632333);
  static const _muted = Color(0xFF51454A);

  @override
  Widget build(BuildContext context) => ShareableScaffold(
    backgroundColor: const Color(0xFFF8F5F2),
    drawer: const ChristmasDrawer(
      activeItem: ChristmasMenuItem.about,
      routes: christmasMenuRoutes,
    ),
    drawerScrimColor: Colors.black54,
    appBar: AppBar(
      title: const Text('About', style: TextStyle(fontWeight: FontWeight.w800)),
      centerTitle: true,
      foregroundColor: _wine,
      backgroundColor: const Color(0xFFF8F5F2),
      surfaceTintColor: Colors.transparent,
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
        constraints: const BoxConstraints(maxWidth: 620),
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                clipBehavior: Clip.antiAlias,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(32),
                  border: Border.all(color: const Color(0xFFE8D7C4)),
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFFFFFDF7), Color(0xFFFFEEE4)],
                  ),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x10632333),
                      blurRadius: 24,
                      offset: Offset(0, 10),
                    ),
                  ],
                ),
                child: Stack(
                  alignment: Alignment.center,
                  fit: StackFit.passthrough,
                  children: [
                    Positioned(
                      top: -65,
                      right: -65,
                      child: Container(
                        width: 180,
                        height: 180,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Color(0xFFF8E2D8),
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: -80,
                      left: -60,
                      child: Container(
                        width: 180,
                        height: 180,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Color(0xFFF4E7D3),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 30,
                      ),
                      child: Column(
                        children: [
                          SizedBox(
                            height: 150,
                            width: 210,
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                Container(
                                  width: 138,
                                  height: 138,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.white.withValues(alpha: .8),
                                    border: Border.all(
                                      color: const Color(0xFFEED9B7),
                                    ),
                                  ),
                                ),
                                Image.asset(
                                  'assets/images/jingle_bells.png',
                                  width: 128,
                                  height: 128,
                                  fit: BoxFit.contain,
                                  excludeFromSemantics: true,
                                ),
                                const Positioned(
                                  left: 5,
                                  top: 26,
                                  child: Icon(
                                    Icons.auto_awesome,
                                    color: Color(0xFFB87A23),
                                    size: 22,
                                  ),
                                ),
                                const Positioned(
                                  right: 8,
                                  bottom: 22,
                                  child: Icon(
                                    Icons.auto_awesome,
                                    color: Color(0xFFB87A23),
                                    size: 16,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 14),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF3E2CE),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Text(
                              'A LITTLE CHRISTMAS MAGIC',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Color(0xFF71481C),
                                letterSpacing: 1.1,
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          const SizedBox(height: 18),
                          const Text(
                            'Christmas\nCountdown',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: _wine,
                              fontSize: 36,
                              height: 1.15,
                              letterSpacing: -.8,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 18),
                          const SizedBox(
                            width: 42,
                            child: Divider(
                              color: Color(0xFFBE866A),
                              thickness: 2,
                            ),
                          ),
                          const SizedBox(height: 14),
                          const Text(
                            'Một chút háo hức, một chút ấm áp.\nGiáng sinh đến gần hơn mỗi ngày.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: _muted,
                              fontSize: 17,
                              height: 1.65,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),
              const Text(
                'Niềm vui \ntrong những ngày chờ đợi',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: _wine,
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'Christmas Countdown mang không khí lễ hội đến những khoảnh khắc thường ngày: đếm ngược đến Giáng sinh, mở quà Advent và thư giãn cùng âm nhạc, trò chơi nhỏ.',
                style: TextStyle(color: _muted, fontSize: 17, height: 1.7),
              ),
              const SizedBox(height: 22),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: const Color(0xFFF0DDD7)),
                ),
                child: const Column(
                  children: [
                    _Feature(
                      icon: Icons.timer_outlined,
                      title: 'Chờ đón Giáng sinh',
                      description:
                          'Đếm từng ngày, giờ, phút và giây đến mùa lễ hội.',
                      color: Color(0xFFA73E4C),
                    ),
                    Divider(
                      height: 1,
                      indent: 66,
                      endIndent: 20,
                      color: Color(0xFFE7DEDA),
                    ),
                    _Feature(
                      icon: Icons.card_giftcard_rounded,
                      title: 'Một món quà mỗi ngày',
                      description:
                          'Khám phá Advent Calendar từ ngày 1 đến 25/12.',
                      color: Color(0xFF98601A),
                    ),
                    Divider(
                      height: 1,
                      indent: 66,
                      endIndent: 20,
                      color: Color(0xFFE7DEDA),
                    ),
                    _Feature(
                      icon: Icons.music_note_rounded,
                      title: 'Giai điệu & niềm vui',
                      description:
                          'Nghe nhạc Giáng sinh và chơi gộp vật phẩm Bubble Box.',
                      color: Color(0xFF316B55),
                    ),
                    Divider(
                      height: 1,
                      indent: 66,
                      endIndent: 20,
                      color: Color(0xFFE7DEDA),
                    ),
                    _Feature(
                      icon: Icons.wallpaper_rounded,
                      title: 'Giáng sinh theo cách của bạn',
                      description:
                          'Chọn ảnh nền Countdown và bật tuyết rơi trong Settings.',
                      color: Color(0xFF71508E),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.favorite_rounded,
                    size: 16,
                    color: Color(0xFFD77A80),
                  ),
                  SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      'Made with love for Christmas',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: _wine,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              const Text(
                'Chúc bạn một mùa Giáng sinh an lành.',
                textAlign: TextAlign.center,
                style: TextStyle(color: _muted, fontSize: 15, height: 1.6),
              ),
              const SizedBox(height: 12),
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

class _Feature extends StatelessWidget {
  const _Feature({
    required this.icon,
    required this.title,
    required this.description,
    required this.color,
  });
  final IconData icon;
  final String title;
  final String description;
  final Color color;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.all(20),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: color.withValues(alpha: .10),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(icon, color: color, size: 22),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: AboutPage._wine,
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                description,
                style: const TextStyle(
                  color: AboutPage._muted,
                  fontSize: 15,
                  height: 1.6,
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}
