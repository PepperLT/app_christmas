import '../../../../core/widget/shareable_scaffold.dart';
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../app/app_routes.dart';
import '../../../../core/widget/app_menu_button.dart';
import '../../../../core/widget/christmas_drawer.dart';
import '../../domain/entity/advent_day.dart';
import '../bindings/advent_calendar_binding.dart';
import '../controller/advent_calendar_controller.dart';
import '../widgets/advent_day_tile.dart';
import '../widgets/advent_reward_dialog.dart';

class AdventCalendarPage extends StatefulWidget {
  const AdventCalendarPage({super.key});

  // Can be registered in the app's route list without changing this feature.
  static GetPage<dynamic> get route => GetPage(
    name: AppRoutes.adventCalendar,
    page: () => const AdventCalendarPage(),
    binding: AdventCalendarBinding(),
  );

  @override
  State<AdventCalendarPage> createState() => _AdventCalendarPageState();
}

class _AdventCalendarPageState extends State<AdventCalendarPage>
    with WidgetsBindingObserver {
  late final AdventCalendarController controller;
  Timer? _midnightTimer;
  bool _showingReward = false;

  @override
  void initState() {
    super.initState();
    controller = Get.find<AdventCalendarController>();
    WidgetsBinding.instance.addObserver(this);
    controller.refreshProgress();
    _scheduleRefresh();
  }

  void _scheduleRefresh() {
    _midnightTimer?.cancel();
    final now = DateTime.now();
    final tomorrow = DateTime(now.year, now.month, now.day + 1);
    _midnightTimer = Timer(tomorrow.difference(now), () {
      if (!mounted) return;
      controller.refreshProgress();
      _scheduleRefresh();
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      controller.refreshProgress();
      _scheduleRefresh();
    }
  }

  @override
  void dispose() {
    _midnightTimer?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  Future<void> _openDay(AdventDay day) async {
    if (_showingReward || controller.isClaiming.value) return;
    _showingReward = true;
    try {
      controller.refreshProgress();
      var newlyClaimed = false;
      if (!controller.isClaimed(day.day)) {
        newlyClaimed = await controller.claimDay(day.day);
        if (!mounted) return;
        if (!newlyClaimed) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                controller.errorMessage.value ??
                    'Chỉ được nhận quà đúng ngày, không nhận bù.',
              ),
            ),
          );
          return;
        }
      }
      if (!mounted) return;
      await showDialog<void>(
        context: context,
        builder: (_) =>
            AdventRewardDialog(day: day, isNewlyClaimed: newlyClaimed),
      );
    } finally {
      _showingReward = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return ShareableScaffold(
      drawer: const ChristmasDrawer(
        activeItem: ChristmasMenuItem.adventCalendar,
        routes: christmasMenuRoutes,
      ),
      drawerScrimColor: Colors.black54,
      backgroundColor: const Color(0xFFFFF7F3),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFFF7F3),
        surfaceTintColor: Colors.transparent,
        foregroundColor: const Color(0xFF602729),
        centerTitle: true,
        title: const Text(
          'My Advent Calendar',
          style: TextStyle(fontSize: 21, fontWeight: FontWeight.w800),
        ),
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
            constraints: const BoxConstraints(maxWidth: 520),
            child: CustomScrollView(
              slivers: [
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                  sliver: SliverToBoxAdapter(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const _DecemberBanner(),
                        const SizedBox(height: 14),
                        Obx(
                          () => _AdventProgress(
                            claimedCount: controller.claimedCount,
                            dayCount: controller.days.length,
                            totalStars: controller.totalStars,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  sliver: SliverGrid(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 5,
                          crossAxisSpacing: 6,
                          mainAxisSpacing: 8,
                        ),
                    delegate: SliverChildBuilderDelegate((context, index) {
                      final day = controller.days[index];
                      return Obx(
                        () => AdventDayTile(
                          day: day,
                          isClaimed: controller.isClaimed(day.day),
                          canClaim: controller.canClaimToday(day.day),
                          isMissed: controller.isMissed(day.day),
                          onTap: () => _openDay(day),
                        ),
                      );
                    }, childCount: controller.days.length),
                  ),
                ),
                const SliverPadding(
                  padding: EdgeInsets.fromLTRB(20, 16, 20, 24),
                  sliver: SliverToBoxAdapter(
                    child: Text(
                      'Mỗi ô quà chỉ mở vào đúng ngày, từ 1 đến 25/12.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 13,
                        height: 1.4,
                        color: Color(0xFF80524B),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _DecemberBanner extends StatelessWidget {
  const _DecemberBanner();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFAF303D), Color(0xFF791E32)],
        ),
      ),
      child: const Padding(
        padding: EdgeInsets.symmetric(horizontal: 18, vertical: 20),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '1–25 THÁNG 12',
                    style: TextStyle(
                      color: Color(0xFFFFDE9E),
                      fontSize: 12,
                      letterSpacing: 1.6,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'December',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 34,
                      height: 1.12,
                      fontFamily: 'serif',
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(width: 12),
            DecoratedBox(
              decoration: BoxDecoration(
                color: Color(0x24FFFFFF),
                shape: BoxShape.circle,
              ),
              child: Padding(
                padding: EdgeInsets.all(12),
                child: Icon(
                  Icons.card_giftcard_rounded,
                  color: Color(0xFFFFDE9E),
                  size: 29,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AdventProgress extends StatelessWidget {
  const _AdventProgress({
    required this.claimedCount,
    required this.dayCount,
    required this.totalStars,
  });

  final int claimedCount;
  final int dayCount;
  final int totalStars;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF0DDD5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 12,
            runSpacing: 6,
            children: [
              Text(
                'Đã nhận $claimedCount/$dayCount quà',
                style: const TextStyle(
                  color: Color(0xFF602729),
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                '★ $totalStars sao',
                style: const TextStyle(
                  color: Color(0xFF825411),
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: dayCount == 0
                  ? 0.0
                  : (claimedCount / dayCount).clamp(0.0, 1.0).toDouble(),
              semanticsLabel: 'Tiến độ nhận quà',
              minHeight: 6,
              backgroundColor: const Color(0xFFF8E5DF),
              color: const Color(0xFFAF303D),
            ),
          ),
        ],
      ),
    );
  }
}
