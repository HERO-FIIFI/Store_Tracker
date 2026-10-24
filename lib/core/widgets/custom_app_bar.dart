import 'package:flutter/material.dart';
import 'package:store_tracker/core/styles/app_colors.dart';
import 'package:store_tracker/core/styles/app_text_styles.dart';

/// Custom app bar with extended functionality
/// 
/// Features:
/// - Automatic back button handling
/// - Flexible title/content positioning
/// - Built-in actions layout
/// - Support for search mode
/// - Theming consistency
class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String? title;
  final Widget? titleWidget;
  final bool showBackButton;
  final VoidCallback? onBackPressed;
  final List<Widget> actions;
  final Widget? leading;
  final bool centerTitle;
  final double elevation;
  final Color? backgroundColor;
  final bool automaticallyImplyLeading;
  final PreferredSizeWidget? bottom;
  final double toolbarHeight;
  final bool showDivider;
  final bool isSearchMode;
  final Widget? searchField;
  final EdgeInsetsGeometry? padding;

  const CustomAppBar({
    super.key,
    this.title,
    this.titleWidget,
    this.showBackButton = true,
    this.onBackPressed,
    this.actions = const [],
    this.leading,
    this.centerTitle = false,
    this.elevation = 0,
    this.backgroundColor,
    this.automaticallyImplyLeading = true,
    this.bottom,
    this.toolbarHeight = kToolbarHeight,
    this.showDivider = true,
    this.isSearchMode = false,
    this.searchField,
    this.padding,
  }) : assert(title == null || titleWidget == null, 
             'Cannot provide both title and titleWidget');

  @override
  Size get preferredSize => Size.fromHeight(
        toolbarHeight + (bottom?.preferredSize.height ?? 0),
      );

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final appBarTheme = theme.appBarTheme;
    final canPop = Navigator.canPop(context);

    return AppBar(
      key: key,
      leading: _buildLeading(context, canPop),
      automaticallyImplyLeading: automaticallyImplyLeading,
      title: isSearchMode ? searchField : _buildTitle(context),
      actions: _buildActions(),
      centerTitle: centerTitle,
      elevation: elevation,
      backgroundColor: backgroundColor ?? appBarTheme.backgroundColor ?? theme.scaffoldBackgroundColor,
      toolbarHeight: toolbarHeight,
      bottom: showDivider
          ? const _Divider()
          : bottom,
      titleSpacing: 0,
      flexibleSpace: _buildFlexibleSpace(),
    );
  }

  Widget? _buildLeading(BuildContext context, bool canPop) {
    if (leading != null) return leading;
    if (!showBackButton || !canPop) return null;

    return IconButton(
      icon: const Icon(Icons.arrow_back_rounded),
      onPressed: onBackPressed ?? () => Navigator.maybePop(context),
      color: AppColors.primary,
    );
  }

  Widget _buildTitle(BuildContext context) {
    if (titleWidget != null) return titleWidget!;

    return Padding(
      padding: padding ?? EdgeInsets.zero,
      child: Text(
        title ?? '',
        style: AppTextStyles.appBarTitle,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  List<Widget> _buildActions() {
    if (isSearchMode && searchField != null) return actions;

    return [
      if (actions.length <= 2) ...actions,
      if (actions.length > 2)
        PopupMenuButton(
          itemBuilder: (context) => actions
              .map((action) => PopupMenuItem(
                    child: action,
                  ))
              .toList(),
          icon: const Icon(Icons.more_vert),
        ),
    ];
  }

  Widget? _buildFlexibleSpace() {
    if (backgroundColor != null && backgroundColor!.alpha == 0) {
      return null;
    }

    return Container(
      decoration: BoxDecoration(
        gradient: backgroundColor == null
            ? LinearGradient(
                colors: [
                  Theme.of(context).colorScheme.primary.withOpacity(0.1),
                  Colors.transparent,
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              )
            : null,
      ),
    );
  }
}

class _Divider extends StatelessWidget implements PreferredSizeWidget {
  const _Divider();

  @override
  Widget build(BuildContext context) {
    return const Divider(
      height: 1,
      thickness: 1,
      color: AppColors.divider,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(1);
}

/// App bar with search functionality
class SearchAppBar extends StatefulWidget implements PreferredSizeWidget {
  final String? initialQuery;
  final ValueChanged<String>? onQueryChanged;
  final VoidCallback? onClosePressed;
  final List<Widget> actions;
  final String hintText;
  final double toolbarHeight;

  const SearchAppBar({
    super.key,
    this.initialQuery,
    this.onQueryChanged,
    this.onClosePressed,
    this.actions = const [],
    this.hintText = 'Search...',
    this.toolbarHeight = kToolbarHeight,
  });

  @override
  Size get preferredSize => Size.fromHeight(toolbarHeight);

  @override
  State<SearchAppBar> createState() => _SearchAppBarState();
}

class _SearchAppBarState extends State<SearchAppBar> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialQuery);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CustomAppBar(
      isSearchMode: true,
      searchField: _buildSearchField(),
      actions: widget.actions,
      toolbarHeight: widget.toolbarHeight,
    );
  }

  Widget _buildSearchField() {
    return TextField(
      controller: _controller,
      autofocus: true,
      decoration: InputDecoration(
        hintText: widget.hintText,
        border: InputBorder.none,
        suffixIcon: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () {
            _controller.clear();
            widget.onClosePressed?.call();
          },
        ),
      ),
      onChanged: widget.onQueryChanged,
    );
  }
}

/// App bar with tabs
class TabbedAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Tab> tabs;
  final List<Widget> actions;
  final TabController? controller;

  const TabbedAppBar({
    super.key,
    required this.title,
    required this.tabs,
    this.actions = const [],
    this.controller,
  });

  @override
  Size get preferredSize => Size.fromHeight(
        kToolbarHeight + (tabs.isNotEmpty ? 48 : 0),
      );

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(title),
      actions: actions,
      bottom: tabs.isNotEmpty
          ? TabBar(
              tabs: tabs,
              controller: controller,
              indicatorColor: AppColors.primary,
              labelColor: AppColors.primary,
              unselectedLabelColor: AppColors.grey,
              labelStyle: AppTextStyles.tabLabel,
            )
          : null,
    );
  }
}

// Example Usage:
/*
// Basic app bar
CustomAppBar(
  title: 'Dashboard',
  actions: [
    IconButton(icon: Icon(Icons.notifications), onPressed: () {}),
    IconButton(icon: Icon(Icons.settings), onPressed: () {}),
  ],
)

// Search app bar
SearchAppBar(
  hintText: 'Search products...',
  onQueryChanged: (query) => filterProducts(query),
)

// Tabbed app bar
TabbedAppBar(
  title: 'Reports',
  tabs: [
    Tab(text: 'Daily'),
    Tab(text: 'Weekly'),
    Tab(text: 'Monthly'),
  ],
  controller: _tabController,
)
*/