import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'journal_screen.dart';
import 'analytics_screen.dart';
import 'learn_cbt_screen.dart';
import 'profile_screen.dart';

class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _currentIndex = 0;

  static const List<Widget> _screens = [
    JournalScreen(),
    AnalyticsScreen(),
    LearnCbtScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        titleSpacing: 8,
        title: Row(
          children: const [
            _TopLogo(),
            SizedBox(width: 10),
            Text('Reframed'),
          ],
        ),
      ),
      body: _screens[_currentIndex],
      bottomNavigationBar: _AnimatedBumpNavBar(
        selectedIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        items: const [
          _NavItemData(
            icon: Icons.book_outlined,
            activeIcon: Icons.book,
            label: 'Journal',
          ),
          _NavItemData(
            icon: Icons.insights_outlined,
            activeIcon: Icons.insights,
            label: 'Insights',
          ),
          _NavItemData(
            icon: Icons.school_outlined,
            activeIcon: Icons.school,
            label: 'Learn CBT',
          ),
          _NavItemData(
            icon: Icons.person_outline,
            activeIcon: Icons.person,
            label: 'Profile',
          ),
        ],
        activeColor: theme.colorScheme.primary,
      ),
    );
  }
}

class _TopLogo extends StatelessWidget {
  const _TopLogo();
  static const String _logoAsset = 'assets/logo/reframed_logo.svg';

  @override
  Widget build(BuildContext context) {
    return ClipOval(
      child: Container(
        width: 30,
        height: 30,
        color: const Color(0xFF111318),
        child: SvgPicture.asset(
          _logoAsset,
          fit: BoxFit.cover,
          placeholderBuilder: (_) => const Icon(
            Icons.psychology_outlined,
            size: 18,
            color: Color(0xFF60A5FA),
          ),
        ),
      ),
    );
  }
}

class _NavItemData {
  final IconData icon;
  final IconData activeIcon;
  final String label;

  const _NavItemData({
    required this.icon,
    required this.activeIcon,
    required this.label,
  });
}

class _AnimatedBumpNavBar extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onTap;
  final List<_NavItemData> items;
  final Color activeColor;

  const _AnimatedBumpNavBar({
    required this.selectedIndex,
    required this.onTap,
    required this.items,
    required this.activeColor,
  });

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).padding.bottom;
    const barHeight = 70.0;
    const bubbleSize = 54.0;
    const totalHeight = 98.0;
    const background = Color(0xFF14161B);
    const inactive = Color(0xFF9CA3AF);

    return SizedBox(
      height: totalHeight + bottomInset,
      child: Padding(
        padding: EdgeInsets.fromLTRB(16, 0, 16, bottomInset + 10),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final width = constraints.maxWidth;
            final cell = width / items.length;
            final bubbleLeft = (cell * selectedIndex) + (cell - bubbleSize) / 2;

            return Stack(
              clipBehavior: Clip.none,
              children: [
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: Container(
                    height: barHeight,
                    decoration: BoxDecoration(
                      color: background,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x33000000),
                          blurRadius: 16,
                          offset: Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Row(
                      children: List.generate(items.length, (index) {
                        final isSelected = index == selectedIndex;
                        return Expanded(
                          child: Semantics(
                            label: items[index].label,
                            selected: isSelected,
                            button: true,
                            child: InkWell(
                              onTap: () => onTap(index),
                              borderRadius: BorderRadius.circular(20),
                              child: AnimatedScale(
                                duration: const Duration(milliseconds: 320),
                                curve: Curves.easeOutBack,
                                scale: isSelected ? 0.86 : 1,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      items[index].icon,
                                      color: isSelected ? Colors.transparent : inactive,
                                    ),
                                    const SizedBox(height: 2),
                                    AnimatedDefaultTextStyle(
                                      duration: const Duration(milliseconds: 220),
                                      style: TextStyle(
                                        fontSize: 10,
                                        color: isSelected
                                            ? Colors.transparent
                                            : const Color(0xFF7D8594),
                                      ),
                                      child: Text(items[index].label),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      }),
                    ),
                  ),
                ),
                AnimatedPositioned(
                  duration: const Duration(milliseconds: 420),
                  curve: Curves.easeOutQuart,
                  left: bubbleLeft - 12,
                  top: 0,
                  child: IgnorePointer(
                    child: Container(
                      width: 78,
                      height: 34,
                      decoration: const BoxDecoration(
                        color: Color(0xFF07090D),
                        borderRadius: BorderRadius.vertical(
                          bottom: Radius.circular(26),
                        ),
                      ),
                    ),
                  ),
                ),
                AnimatedPositioned(
                  duration: const Duration(milliseconds: 420),
                  curve: Curves.easeOutQuart,
                  left: bubbleLeft,
                  top: 2,
                  child: Container(
                    width: bubbleSize,
                    height: bubbleSize,
                    decoration: BoxDecoration(
                      color: activeColor,
                      shape: BoxShape.circle,
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x44000000),
                          blurRadius: 14,
                          offset: Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Icon(
                      items[selectedIndex].activeIcon,
                      color: Colors.black,
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
