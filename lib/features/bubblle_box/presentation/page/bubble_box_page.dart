import '../../../../core/widget/shareable_scaffold.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../app/app_routes.dart';
import '../../../../core/widget/app_menu_button.dart';
import '../../../../core/widget/christmas_drawer.dart';
import '../../domain/entity/bubble_item.dart';
import '../controller/bubble_box_controller.dart';

class BubbleBoxPage extends GetView<BubbleBoxController> {
  const BubbleBoxPage({super.key});

  String _itemEmoji(BubbleItemType type) => switch (type) {
    BubbleItemType.tree => '🎄',
    BubbleItemType.gift => '🎁',
    BubbleItemType.bell => '🔔',
    BubbleItemType.stocking => '🧦',
    BubbleItemType.snowman => '⛄',
    BubbleItemType.gingerbread => '🍪',
    BubbleItemType.candyCane => '🍬',
    BubbleItemType.reindeer => '🦌',
    BubbleItemType.santa => '🎅',
    BubbleItemType.snowflake => '❄️',
  };

  @override
  Widget build(BuildContext context) {
    const ink = Color(0xFF762C35);
    return ShareableScaffold(
      drawer: const ChristmasDrawer(
        activeItem: ChristmasMenuItem.bubbleBox,
        routes: christmasMenuRoutes,
      ),
      drawerScrimColor: Colors.black54,
      backgroundColor: const Color(0xFFFBE3DF),
      appBar: AppBar(
        leadingWidth: 64,
        leading: Builder(
          builder: (drawerContext) => Center(
            child: AppMenuButton(
              onPressed: () => Scaffold.of(drawerContext).openDrawer(),
            ),
          ),
        ),
        title: const Text(
          'Bubble Box',
          style: TextStyle(fontWeight: FontWeight.w800, fontSize: 22),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFFFFF8F5),
        surfaceTintColor: Colors.transparent,
        foregroundColor: ink,
        elevation: 0,
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400),
            child: Container(
              margin: const EdgeInsets.fromLTRB(10, 8, 10, 10),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(30),
                border: Border.all(color: Colors.white, width: 2),
                gradient: const LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0xFFFFFCFA), Color(0xFFFFF0ED)],
                ),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x18A2474A),
                    blurRadius: 18,
                    offset: Offset(0, 6),
                  ),
                ],
              ),
              clipBehavior: Clip.antiAlias,
              child: Obx(() {
                final cells = controller.cells.toList();
                final selectedIndex = controller.selectedIndex.value;
                final isGameOver = controller.isGameOver.value;
                return SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(12, 12, 12, 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Wrap(
                        alignment: WrapAlignment.spaceBetween,
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          _stat(
                            Icons.star_rounded,
                            'Điểm ván: ${controller.score.value}',
                            const Color(0xFFFFB52E),
                          ),
                          _stat(
                            Icons.auto_awesome_rounded,
                            '${controller.rescuesRemaining.value} lượt cứu',
                            const Color(0xFFEC777C),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFFEFC),
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(color: const Color(0xFFF2DCD8)),
                        ),
                        child: GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: cells.length,
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 4,
                                crossAxisSpacing: 6,
                                mainAxisSpacing: 6,
                              ),
                          itemBuilder: (context, index) {
                            final item = cells[index];
                            final selected = selectedIndex == index;
                            return Semantics(
                              label: item == null
                                  ? 'Ô trống'
                                  : '${item.type.name}, cấp ${item.level}',
                              selected: selected,
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 160),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(16),
                                  gradient: LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: selected
                                        ? [
                                            const Color(0xFFFFD5A9),
                                            const Color(0xFFFFB6A6),
                                          ]
                                        : item == null
                                        ? [
                                            const Color(0xFFFBF4F1),
                                            const Color(0xFFF5EAE7),
                                          ]
                                        : [
                                            const Color(0xFFF8E7E8),
                                            const Color(0xFFEED7DC),
                                          ],
                                  ),
                                  border: Border.all(
                                    color: selected
                                        ? const Color(0xFFDA675D)
                                        : Colors.white,
                                    width: 2,
                                  ),
                                ),
                                child: Material(
                                  color: Colors.transparent,
                                  borderRadius: BorderRadius.circular(16),
                                  clipBehavior: Clip.antiAlias,
                                  child: InkWell(
                                    onTap: isGameOver
                                        ? null
                                        : () => controller.selectCell(index),
                                    child: Padding(
                                      padding: const EdgeInsets.all(4),
                                      child: item == null
                                          ? const Center(
                                              child: Text(
                                                '·',
                                                style: TextStyle(
                                                  color: Color(0xFFD9BFBB),
                                                  fontSize: 26,
                                                ),
                                              ),
                                            )
                                          : Column(
                                              children: [
                                                Expanded(
                                                  child: Center(
                                                    child: FittedBox(
                                                      child: Text(
                                                        _itemEmoji(item.type),
                                                        style: const TextStyle(
                                                          fontSize: 38,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                FittedBox(
                                                  child: Text(
                                                    'Cấp ${item.level}',
                                                    style: const TextStyle(
                                                      color: ink,
                                                      fontSize: 11,
                                                      fontWeight:
                                                          FontWeight.w700,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      Wrap(
                        alignment: WrapAlignment.center,
                        spacing: 12,
                        runSpacing: 12,
                        children: [
                          OutlinedButton.icon(
                            onPressed: controller.canRescue.value
                                ? controller.rescueBoard
                                : null,
                            icon: const Icon(
                              Icons.auto_awesome_rounded,
                              size: 20,
                            ),
                            label: Text(
                              'Cứu bàn (${controller.rescuesRemaining.value} lượt)',
                            ),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: ink,
                              backgroundColor: const Color(0xFFFFE6DF),
                              side: const BorderSide(color: Color(0xFFF2BBB1)),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 16,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(24),
                              ),
                              textStyle: const TextStyle(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          FilledButton.icon(
                            onPressed: controller.newGame,
                            icon: const Icon(Icons.refresh_rounded, size: 22),
                            label: const Text('Ván mới'),
                            style: FilledButton.styleFrom(
                              backgroundColor: const Color(0xFFEA737A),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 22,
                                vertical: 16,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(24),
                              ),
                              textStyle: const TextStyle(
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 18),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFE3DD),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Column(
                          children: [
                            if (isGameOver) ...[
                              const Text(
                                'Hết nước đi',
                                style: TextStyle(
                                  color: ink,
                                  fontSize: 19,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              const SizedBox(height: 6),
                            ],
                            Text(
                              selectedIndex == null
                                  ? 'Chọn một vật phẩm để bắt đầu.'
                                  : 'Chọn vật phẩm cùng loại và cùng cấp để gộp.',
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: ink,
                                height: 1.4,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 4),
                      Image.asset(
                        'assets/images/footer.png',
                        height: 42,
                        fit: BoxFit.fitWidth,
                        excludeFromSemantics: true,
                      ),
                      const SizedBox(height: 8),
                    ],
                  ),
                );
              }),
            ),
          ),
        ),
      ),
    );
  }

  Widget _stat(IconData icon, String label, Color color) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
    decoration: BoxDecoration(
      color: const Color(0xFFFFF0E5),
      borderRadius: BorderRadius.circular(22),
      border: Border.all(color: const Color(0xFFF8DFD7)),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(
            color: Color(0xFF8C333B),
            fontWeight: FontWeight.w800,
            fontSize: 13,
          ),
        ),
      ],
    ),
  );
}
