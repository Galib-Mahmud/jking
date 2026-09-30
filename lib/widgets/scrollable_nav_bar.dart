import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../config/constants.dart';

class NavTabItem {
  final String id;
  final String label;
  final IconData icon;
  final Color accentColor;

  const NavTabItem({
    required this.id,
    required this.label,
    required this.icon,
    required this.accentColor,
  });
}

class ScrollableNavBar extends StatefulWidget {
  final String activeTab;
  final ValueChanged<String> onTabSelected;

  static const List<NavTabItem> tabs = [
    NavTabItem(
      id: 'home',
      label: 'Mission Control',
      icon: Icons.space_dashboard_rounded,
      accentColor: AppConfig.cyan,
    ),
    NavTabItem(
      id: 'story',
      label: 'Story',
      icon: Icons.auto_stories_rounded,
      accentColor: AppConfig.amber,
    ),
    NavTabItem(
      id: 'learn',
      label: 'Learn',
      icon: Icons.school_rounded,
      accentColor: AppConfig.green,
    ),
    NavTabItem(
      id: 'practice',
      label: 'Practice',
      icon: Icons.bolt_rounded,
      accentColor: AppConfig.magenta,
    ),
    NavTabItem(
      id: 'service',
      label: 'Service Mode',
      icon: Icons.handyman_rounded,
      accentColor: AppConfig.amber,
    ),
    NavTabItem(
      id: 'cases',
      label: 'Case Files',
      icon: Icons.folder_special_rounded,
      accentColor: AppConfig.cyan,
    ),
    NavTabItem(
      id: 'ask',
      label: 'Ask Empathia',
      icon: Icons.psychology_rounded,
      accentColor: AppConfig.magenta,
    ),
    NavTabItem(
      id: 'glossary',
      label: 'Glossary',
      icon: Icons.menu_book_rounded,
      accentColor: AppConfig.green,
    ),
  ];

  const ScrollableNavBar({
    super.key,
    required this.activeTab,
    required this.onTabSelected,
  });

  @override
  State<ScrollableNavBar> createState() => _ScrollableNavBarState();
}

class _ScrollableNavBarState extends State<ScrollableNavBar> {
  final ScrollController _scrollController = ScrollController();
  final Map<String, GlobalKey> _itemKeys = {};

  @override
  void initState() {
    super.initState();
    for (final tab in ScrollableNavBar.tabs) {
      _itemKeys[tab.id] = GlobalKey();
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToActiveTab();
    });
  }

  @override
  void didUpdateWidget(covariant ScrollableNavBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.activeTab != widget.activeTab) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollToActiveTab();
      });
    }
  }

  void _scrollToActiveTab() {
    final key = _itemKeys[widget.activeTab];
    if (key?.currentContext != null) {
      Scrollable.ensureVisible(
        key!.currentContext!,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOutCubic,
        alignment: 0.5,
      );
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppConfig.primaryBg.withValues(alpha: 0.98),
        border: const Border(
          top: BorderSide(color: AppConfig.cardBorder, width: 1.2),
        ),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 72,
          child: ListView.separated(
            controller: _scrollController,
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            itemCount: ScrollableNavBar.tabs.length,
            separatorBuilder: (context, index) => const SizedBox(width: 10),
            itemBuilder: (context, index) {
              final tab = ScrollableNavBar.tabs[index];
              final isActive = widget.activeTab == tab.id;

              return KeyedSubtree(
                key: _itemKeys[tab.id],
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.easeInOut,
                  decoration: BoxDecoration(
                    color: isActive ? tab.accentColor : AppConfig.cardBg,
                    borderRadius: BorderRadius.circular(26),
                    border: Border.all(
                      color: isActive
                          ? tab.accentColor
                          : AppConfig.cardBorder.withValues(alpha: 0.9),
                      width: 1.2,
                    ),
                    boxShadow: isActive
                        ? [
                            BoxShadow(
                              color: tab.accentColor.withValues(alpha: 0.45),
                              blurRadius: 14,
                              offset: const Offset(0, 3),
                            ),
                          ]
                        : null,
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(26),
                      onTap: () {
                        HapticFeedback.lightImpact();
                        widget.onTabSelected(tab.id);
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 10,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              tab.icon,
                              size: 24,
                              color: isActive
                                  ? AppConfig.primaryBg
                                  : tab.accentColor,
                            ),
                            const SizedBox(width: 10),
                            Text(
                              tab.label,
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: isActive
                                    ? FontWeight.w800
                                    : FontWeight.w700,
                                letterSpacing: 0.5,
                                color: isActive
                                    ? AppConfig.primaryBg
                                    : AppConfig.lightText,
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
      ),
    );
  }
}
