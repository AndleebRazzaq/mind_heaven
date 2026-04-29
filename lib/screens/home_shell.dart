import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'journal_screen.dart';
import 'analytics_screen.dart';
import 'learn_cbt_screen.dart';
import 'profile_screen.dart';
import 'home_screen.dart';

class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _currentIndex = 2; // AI Journal is the default/center tab

  static const List<Widget> _screens = [
    HomeScreen(),
    LearnCbtScreen(),
    JournalScreen(), // Used for New
    AnalyticsScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        titleSpacing: 16,
        title: const _TopLogo(),
      ),
      body: _screens[_currentIndex],
      bottomNavigationBar: _CustomBottomNavBar(
        selectedIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
      ),
    );
  }
}

class _TopLogo extends StatelessWidget {
  const _TopLogo();
  static const String _logoAsset = 'assets/logo/reframed_logo.png';

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 32,
      height: 32,
      padding: const EdgeInsets.all(2), // Optional padding if needed
      child: Image.asset(
        _logoAsset,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) => const Icon(
          Icons.psychology_outlined,
          color: Color(0xFFB4C6FC),
          size: 24,
        ),
      ),
    );
  }
}

class _CustomBottomNavBar extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onTap;

  const _CustomBottomNavBar({required this.selectedIndex, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).padding.bottom;
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF14161B),
        border: Border(top: BorderSide(color: Colors.white10, width: 1)),
      ),
      padding: EdgeInsets.only(bottom: bottomInset, top: 8),
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              _NavBarItem(
                icon: Icons.home_outlined,
                activeIcon: Icons.home,
                label: 'Home',
                isSelected: selectedIndex == 0,
                onTap: () => onTap(0),
              ),
              _NavBarItem(
                icon: Icons.menu_book_outlined,
                activeIcon: Icons.menu_book,
                label: 'Learn',
                isSelected: selectedIndex == 1,
                onTap: () => onTap(1),
              ),
              const SizedBox(width: 60),
              _NavBarItem(
                icon: Icons.insights_outlined,
                activeIcon: Icons.insights,
                label: 'Insights',
                isSelected: selectedIndex == 3,
                onTap: () => onTap(3),
              ),
              _NavBarItem(
                icon: Icons.person_outline,
                activeIcon: Icons.person,
                label: 'Profile',
                isSelected: selectedIndex == 4,
                onTap: () => onTap(4),
              ),
            ],
          ),
          Positioned(
            top: -24,
            child: GestureDetector(
              onTap: () => onTap(2),
              behavior: HitTestBehavior.opaque,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: const BoxDecoration(
                      color: Color(0xFFB4C6FC),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.auto_awesome,
                      color: Colors.black,
                      size: 28,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'AI Journal',
                    style: TextStyle(color: Colors.white, fontSize: 12),
                  ),
                  const SizedBox(height: 2),
                ],
              ),
            ),
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
  final String emoji;
  final bool isCenterCTA;

  const _NavItemData({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.emoji,
    this.isCenterCTA = false,
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
    const bubbleSize = 64.0;
    const centerBubbleSize = 72.0;
    const totalHeight = 110.0;
    const background = Color(0xFF14161B);
    const inactive = Color(0xFF9CA3AF);

    return SizedBox(
      height: totalHeight + bottomInset,
      child: Padding(
        padding: EdgeInsets.fromLTRB(12, 0, 12, bottomInset + 10),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final width = constraints.maxWidth;
            final cell = width / items.length;

            // Find center CTA item
            int centerIndex = -1;
            for (int i = 0; i < items.length; i++) {
              if (items[i].isCenterCTA) {
                centerIndex = i;
                break;
              }
            }

            final centerBubbleLeft =
                (cell * centerIndex) + (cell - centerBubbleSize) / 2;

            return Stack(
              clipBehavior: Clip.none,
              children: [
                // Background bar
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
                        // Skip center CTA item in row (it's positioned absolutely above)
                        if (items[index].isCenterCTA) {
                          return Expanded(child: SizedBox());
                        }

                        final isSelected = index == selectedIndex;
                        return Expanded(
                          child: Semantics(
                            label: items[index].label,
                            selected: isSelected,
                            button: true,
                            child: InkWell(
                              onTap: () => onTap(index),
                              borderRadius: BorderRadius.circular(20),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    items[index].icon,
                                    color: isSelected
                                        ? Colors.transparent
                                        : inactive,
                                    size: 24,
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
                        );
                      }),
                    ),
                  ),
                ),

                // Center CTA bubble with glow effect
                AnimatedPositioned(
                  duration: const Duration(milliseconds: 420),
                  curve: Curves.easeOutQuart,
                  left: centerBubbleLeft - 6,
                  top: selectedIndex == centerIndex ? -8 : 0,
                  child: GestureDetector(
                    onTap: () => onTap(centerIndex),
                    child: Column(
                      children: [
                        // Glow effect
                        if (selectedIndex == centerIndex)
                          Container(
                            width: centerBubbleSize + 16,
                            height: centerBubbleSize + 16,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: activeColor.withValues(alpha: 0.4),
                                  blurRadius: 24,
                                  spreadRadius: 2,
                                ),
                                BoxShadow(
                                  color: activeColor.withValues(alpha: 0.2),
                                  blurRadius: 40,
                                  spreadRadius: 8,
                                ),
                              ],
                            ),
                          ),
                        const SizedBox(height: 4),
                        // Bubble
                        Container(
                          width: centerBubbleSize,
                          height: centerBubbleSize,
                          decoration: BoxDecoration(
                            color: activeColor,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0x44000000),
                                blurRadius: 20,
                                offset: const Offset(0, 8),
                              ),
                              if (selectedIndex == centerIndex)
                                BoxShadow(
                                  color: activeColor.withValues(alpha: 0.3),
                                  blurRadius: 16,
                                  offset: const Offset(0, -2),
                                ),
                            ],
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                items[centerIndex].emoji,
                                style: const TextStyle(fontSize: 28),
                              ),
                            ],
                          ),
                        ),
                      ],
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

class _NavBarItem extends StatelessWidget {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _NavBarItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = isSelected
        ? const Color(0xFFB4C6FC)
        : const Color(0xFF9CA3AF);
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 64,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(isSelected ? activeIcon : icon, color: color, size: 26),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
          ],
        ),
      ),
    );
  }
}
