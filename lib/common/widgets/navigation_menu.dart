import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:provider/provider.dart';
import 'package:aaliyahs_collection_estore/features/personalization/controllers/user_controller.dart';
import 'package:aaliyahs_collection_estore/features/shop/controllers/product_controller.dart';
import 'package:aaliyahs_collection_estore/features/shop/controllers/cart_controller.dart';
import 'package:aaliyahs_collection_estore/features/shop/controllers/favorite_controller.dart';
import 'package:aaliyahs_collection_estore/features/personalization/controllers/notification_controller.dart';
import 'package:aaliyahs_collection_estore/utils/device/connectivity_controller.dart';
import 'package:aaliyahs_collection_estore/features/personalization/controllers/accessibility_controller.dart';
import 'package:aaliyahs_collection_estore/features/shop/controllers/navigation_controller.dart';
import 'package:quickalert/quickalert.dart';

import 'package:aaliyahs_collection_estore/features/shop/screens/cart/cart_screen.dart';
import 'package:aaliyahs_collection_estore/features/shop/screens/favorites/favorites_screen.dart';
import 'package:aaliyahs_collection_estore/features/shop/screens/home/home_screen.dart';
import 'package:aaliyahs_collection_estore/features/shop/screens/product/product_screen.dart';
import 'package:aaliyahs_collection_estore/features/personalization/screens/profile_screen.dart';

import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'package:aaliyahs_collection_estore/utils/constants/motion_constants.dart';

class NavigationMenu extends StatefulWidget {
  const NavigationMenu({super.key});

  @override
  State<NavigationMenu> createState() => _NavigationMenuState();
}

class _NavigationMenuState extends State<NavigationMenu> {
  bool _isRailCollapsed = false; // M3 Expressive: Manual rail toggle state

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<UserController>(context, listen: false).fetchUserProfile();
      Provider.of<ProductController>(context, listen: false).fetchHomeData(); 
      
      // Listen to connectivity changes
      _setupConnectivityListener();
    });
  }

  void _setupConnectivityListener() {
    final connectivity = Provider.of<ConnectivityController>(context, listen: false);
    bool lastStatus = connectivity.isConnected;

    connectivity.addListener(() {
      if (lastStatus != connectivity.isConnected) {
        lastStatus = connectivity.isConnected;
        _showConnectivityAlert(connectivity.isConnected);
      }
    });
  }

  void _showConnectivityAlert(bool isOnline) async {
    final productProvider = Provider.of<ProductController>(context, listen: false);
    final colorScheme = Theme.of(context).colorScheme;

    if (!isOnline) {
      // 1. Show OFFLINE LOADING automatically
      QuickAlert.show(
        context: context,
        type: QuickAlertType.loading,
        title: 'OFFLINE',
        text: 'You are offline! Fetching local data!',
        disableBackBtn: true,
      );
      
      // Fetch local data (Controller handles offline check internally)
      await productProvider.fetchHomeData();
      
      // Close the loading alert
      if (mounted) Navigator.pop(context);
    } else {
      // 2. Show ONLINE CONFIRMATION
      QuickAlert.show(
        context: context,
        type: QuickAlertType.confirm,
        title: 'ONLINE',
        text: 'You are online! Do you want to load live data?',
        confirmBtnText: 'Yes',
        cancelBtnText: 'No',
        confirmBtnColor: colorScheme.primary,
        onConfirmBtnTap: () async {
          Navigator.pop(context); // Close confirm dialog
          
          // Show loading while syncing
          QuickAlert.show(
            context: context,
            type: QuickAlertType.loading,
            title: 'SYNCING',
            text: 'Loading live data...',
            disableBackBtn: true,
          );

          await productProvider.fetchHomeData();

          if (mounted) {
            Navigator.pop(context); // Close loading dialog
            
            // Shows success briefly
            QuickAlert.show(
              context: context,
              type: QuickAlertType.success,
              title: 'BACK ONLINE',
              text: 'Data updated successfully!',
              autoCloseDuration: const Duration(seconds: 2),
            );
          }
        },
        onCancelBtnTap: () {
          Navigator.pop(context); // Close and remain with local data
        },
      );
    }
  }

  final List<Widget> _screens = [
    const HomeScreen(),
    const ProductScreen(),
    const FavoriteScreen(),
    const CartScreen(),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Consumer2<AccessibilityController, NavigationController>(
      builder: (context, access, nav, child) {
        final colorScheme = Theme.of(context).colorScheme;
        final bool reduceMotion = access.reduceMotion;
        final int currentIndex = nav.selectedIndex;

        return ResponsiveBuilder(
          builder: (context, sizingInformation) {
            final double width = sizingInformation.screenSize.width;
            
            // M3 Expressive: Flexible nav bar can be used in Compact (<600) and Medium (600-840)
            final bool isCompact = width < 600;
            final bool isMedium = width >= 600 && width < 840;
            final bool useBottomBar = isCompact || isMedium;
            
            if (useBottomBar) {
              return Scaffold(
                body: AnimatedSwitcher(
                  duration: reduceMotion ? AMotion.durationShort4 : AMotion.durationMedium1,
                  switchInCurve: AMotion.easingStandard,
                  switchOutCurve: AMotion.easingStandard,
                  transitionBuilder: (child, animation) {
                    return FadeTransition(opacity: animation, child: child);
                  },
                  child: KeyedSubtree(
                    key: ValueKey<int>(currentIndex),
                    child: _screens[currentIndex],
                  ),
                ),
                bottomNavigationBar: _buildBottomBar(colorScheme, nav, isMedium),
                floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
              );
            }

            // Tablet Landscape & Desktop: Navigation Rail (Large/Expanded)
            return Scaffold(
              body: Row(
                children: [
                  _buildNavigationRail(context, colorScheme, sizingInformation, nav),
                  VerticalDivider(width: 1, thickness: 1, color: colorScheme.outlineVariant),
                  Expanded(
                    child: AnimatedSwitcher(
                      duration: reduceMotion ? AMotion.durationShort4 : AMotion.durationMedium1,
                      switchInCurve: AMotion.easingStandard,
                      switchOutCurve: AMotion.easingStandard,
                      transitionBuilder: (child, animation) {
                        return FadeTransition(opacity: animation, child: child);
                      },
                      child: KeyedSubtree(
                        key: ValueKey<int>(currentIndex),
                        child: _screens[currentIndex],
                      ),
                    ),
                  ),
                ],
              ),
              floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
            );
          },
        );
      },
    );
  }

  Widget _buildNavigationRail(BuildContext context, ColorScheme colorScheme, SizingInformation sizing, NavigationController nav) {
    // M3 Expressive: Combined Width-based and Manual-toggle logic
    final bool isExtended = sizing.screenSize.width > 900 && !_isRailCollapsed;
    final userProvider = Provider.of<UserController>(context, listen: false);

    return NavigationRailTheme(
      data: NavigationRailThemeData(
        indicatorColor: colorScheme.secondaryContainer,
        backgroundColor: colorScheme.surfaceContainerLow, 
        indicatorShape: const StadiumBorder(),
        selectedIconTheme: IconThemeData(color: colorScheme.onSecondaryContainer, size: 24.sp),
        unselectedIconTheme: IconThemeData(color: colorScheme.onSurfaceVariant, size: 24.sp),
        selectedLabelTextStyle: TextStyle(
          fontSize: 14.sp,
          fontWeight: FontWeight.bold,
          color: colorScheme.secondary, 
        ),
        unselectedLabelTextStyle: TextStyle(
          fontSize: 14.sp,
          fontWeight: FontWeight.normal,
          color: colorScheme.onSurfaceVariant,
        ),
      ),
      child: NavigationRail(
        extended: isExtended,
        selectedIndex: nav.selectedIndex,
        onDestinationSelected: (index) => nav.setIndex(index),
        useIndicator: true,
        groupAlignment: -1.0, 
        minWidth: 80,
        minExtendedWidth: 360, // Exact M3 Drawer container width spec
        leading: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16), // Adjusted for FAB
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 0. M3 Expressive: Rail Expansion Toggle
              Padding(
                padding: const EdgeInsets.only(left: 4, bottom: 8),
                child: IconButton(
                  onPressed: () => setState(() => _isRailCollapsed = !_isRailCollapsed),
                  icon: Icon(isExtended ? Icons.menu_open_rounded : Icons.menu_rounded),
                  tooltip: isExtended ? 'Collapse sidebar' : 'Expand sidebar',
                ),
              ),

              // 1. Brand Logo / Header
              Padding(
                padding: const EdgeInsets.only(top: 8, bottom: 24, left: 12),
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: isExtended 
                    ? Row(
                        key: const ValueKey('expanded_brand'),
                        children: [
                          Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              color: colorScheme.primary,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Center(child: Text('A', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold))),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            'AALIYAH\'S',
                            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              letterSpacing: 2,
                              color: colorScheme.primary,
                            ),
                          ),
                        ],
                      )
                    : Container(
                        key: const ValueKey('compact_brand'),
                        width: 48, // Standard rail width touch target
                        height: 32,
                        decoration: BoxDecoration(
                          color: colorScheme.primary,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Center(child: Text('A', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold))),
                      ),
                ),
              ),

              // 2. M3 Expressive: Integrated FAB with Accessibility
              // M3 Accessibility: FAB placed in upper left for large screens (nav rail)
              // Semantics label describes the action being performed
              Padding(
                padding: EdgeInsets.only(left: isExtended ? 12 : 0, bottom: 32),
                child: Semantics(
                  button: true,
                  enabled: true,
                  // M3 Accessibility: Label describes the action
                  label: 'Shop now, browse the latest modest fashion collection',
                  child: isExtended
                      ? FloatingActionButton.extended(
                          elevation: 3, // M3: Enabled state elevation
                          hoverElevation: 4, // M3: Hovered state
                          focusElevation: 3, // M3: Focused state
                          highlightElevation: 3, // M3: Pressed state
                          backgroundColor: colorScheme.primaryContainer,
                          foregroundColor: colorScheme.onPrimaryContainer,
                          tooltip: 'Shop newest modest arrivals',
                          onPressed: () => nav.setIndex(1), // Quick navigate to Shop
                          icon: const Icon(Icons.add_shopping_cart_rounded),
                          label: const Text('SHOP NOW'),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        )
                      : FloatingActionButton(
                          elevation: 3, // M3: Enabled state elevation
                          hoverElevation: 4, // M3: Hovered state
                          focusElevation: 3, // M3: Focused state
                          highlightElevation: 3, // M3: Pressed state
                          backgroundColor: colorScheme.primaryContainer,
                          foregroundColor: colorScheme.onPrimaryContainer,
                          tooltip: 'Shop Now',
                          onPressed: () => nav.setIndex(1),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          child: const Icon(Icons.add_shopping_cart_rounded),
                        ),
                ),
              ),

              if (isExtended) ...[
                Padding(
                  padding: const EdgeInsets.only(left: 12, bottom: 12),
                  child: Semantics(
                    header: true,
                    child: Text(
                      'EXPLORE',
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onSurfaceVariant,
                        letterSpacing: 1.1,
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
        trailing: Expanded(
          child: Align(
            alignment: Alignment.bottomLeft, // Rail items are start-aligned
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (isExtended) ...[
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 28),
                    child: Divider(height: 1),
                  ),
                  const SizedBox(height: 16),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 28),
                    child: Semantics(
                      header: true,
                      child: Text(
                        'ACCOUNT',
                        style: Theme.of(context).textTheme.labelMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: nav.selectedIndex == 4 ? colorScheme.secondary : colorScheme.onSurfaceVariant,
                          letterSpacing: 1.1,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
                Padding(
                  padding: const EdgeInsets.only(bottom: 24, left: 16, right: 16),
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    child: isExtended 
                      ? AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          key: const ValueKey('expanded_user'),
                          decoration: BoxDecoration(
                            color: nav.selectedIndex == 4 ? colorScheme.secondaryContainer : Colors.transparent,
                            borderRadius: BorderRadius.circular(28), // Matches indicator shape
                          ),
                          child: Semantics(
                            label: 'Profile, account settings',
                            selected: nav.selectedIndex == 4,
                            button: true,
                            child: InkWell(
                              onTap: () => nav.setIndex(4),
                              borderRadius: BorderRadius.circular(28),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                              child: Row(
                                children: [
                                  CircleAvatar(
                                    radius: 18,
                                    backgroundColor: nav.selectedIndex == 4 ? colorScheme.onSecondaryContainer : colorScheme.surfaceContainerHigh,
                                    backgroundImage: (userProvider.user?.profilePicture ?? '').isNotEmpty 
                                      ? NetworkImage(userProvider.user!.profilePicture) 
                                      : null,
                                    child: (userProvider.user?.profilePicture ?? '').isEmpty 
                                      ? Icon(
                                          nav.selectedIndex == 4 ? Icons.person_rounded : Icons.person_outline_rounded, 
                                          size: 20,
                                          color: nav.selectedIndex == 4 ? colorScheme.secondaryContainer : colorScheme.primary,
                                        ) 
                                      : null,
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      userProvider.user?.fullName ?? 'Guest',
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                        fontWeight: nav.selectedIndex == 4 ? FontWeight.bold : FontWeight.normal,
                                        color: nav.selectedIndex == 4 ? colorScheme.onSecondaryContainer : colorScheme.onSurface,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ))
                      : AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          key: const ValueKey('compact_user'),
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: nav.selectedIndex == 4 ? colorScheme.secondaryContainer : Colors.transparent,
                            shape: BoxShape.circle,
                          ),
                          child: IconButton(
                            onPressed: () => nav.setIndex(4),
                            icon: CircleAvatar(
                              radius: 12,
                              backgroundColor: nav.selectedIndex == 4 ? colorScheme.onSecondaryContainer : colorScheme.surfaceContainerHigh,
                              backgroundImage: (userProvider.user?.profilePicture ?? '').isNotEmpty 
                                ? NetworkImage(userProvider.user!.profilePicture) 
                                : null,
                              child: (userProvider.user?.profilePicture ?? '').isEmpty 
                                ? Icon(
                                    nav.selectedIndex == 4 ? Icons.person_rounded : Icons.person_outline_rounded, 
                                    size: 14,
                                    color: nav.selectedIndex == 4 ? colorScheme.secondaryContainer : colorScheme.primary,
                                  ) 
                                : null,
                            ),
                          ),
                        ),
                  ),
                ),
              ],
            ),
          ),
        ),
        destinations: [
          _buildRailDestination(
            isExtended: isExtended,
            icon: Icons.home_outlined, 
            selectedIcon: Icons.home_rounded, 
            label: 'Home', 
            semanticLabel: 'Home, explore collection',
            showBadge: nav.selectedIndex != 0 && Provider.of<NotificationController>(context).unreadCount > 0,
            badgeCount: Provider.of<NotificationController>(context).unreadCount,
          ),
          _buildRailDestination(
            isExtended: isExtended,
            icon: Icons.storefront_outlined, 
            selectedIcon: Icons.storefront_rounded, 
            label: 'Shop', 
            semanticLabel: 'Shop, browse products',
          ),
          _buildRailDestination(
            isExtended: isExtended,
            icon: Icons.favorite_border_rounded, 
            selectedIcon: Icons.favorite_rounded, 
            label: 'Wishlist', 
            semanticLabel: 'Wishlist, saved items',
            showBadge: nav.selectedIndex != 2 && Provider.of<FavoriteController>(context).favorites.isNotEmpty,
            badgeCount: Provider.of<FavoriteController>(context).favorites.length,
          ),
          _buildRailDestination(
            isExtended: isExtended,
            icon: Icons.shopping_bag_outlined, 
            selectedIcon: Icons.shopping_bag_rounded, 
            label: 'Cart', 
            semanticLabel: 'Cart, view my bag',
            showBadge: nav.selectedIndex != 3 && Provider.of<CartController>(context).cart.isNotEmpty,
            badgeCount: Provider.of<CartController>(context).cart.length,
          ),
          _buildRailDestination(
            isExtended: isExtended,
            icon: Icons.person_outline_rounded, 
            selectedIcon: Icons.person_rounded, 
            label: 'Profile', 
            semanticLabel: 'Profile, account settings',
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar(ColorScheme colorScheme, NavigationController nav, bool isMedium) {
    if (isMedium) {
      // M3 Expressive: Horizontal navigation items for Medium windows
      return Container(
        height: 64.h,
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainer,
        ),
        child: SafeArea(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center, // Horizontal items have fixed width, center them
            children: [
              _buildHorizontalNavDestination(nav, 0, Icons.home_outlined, Icons.home_rounded, 'Home', 'Home, explore collection', colorScheme),
              SizedBox(width: 8.w),
              _buildHorizontalNavDestination(nav, 1, Icons.storefront_outlined, Icons.storefront_rounded, 'Shop', 'Shop, browse products', colorScheme),
              SizedBox(width: 8.w),
              _buildHorizontalNavDestination(nav, 2, Icons.favorite_border_rounded, Icons.favorite_rounded, 'Wishlist', 'Wishlist, saved items', colorScheme),
              SizedBox(width: 8.w),
              _buildHorizontalNavDestination(nav, 3, Icons.shopping_bag_outlined, Icons.shopping_bag_rounded, 'Cart', 'Cart, view my bag', colorScheme),
              SizedBox(width: 8.w),
              _buildHorizontalNavDestination(nav, 4, Icons.person_outline_rounded, Icons.person_rounded, 'Profile', 'Profile, account settings', colorScheme),
            ],
          ),
        ),
      );
    }

    // Default Vertical Navigation Bar for Compact windows
    return NavigationBarTheme(
      data: NavigationBarThemeData(
        indicatorColor: colorScheme.secondaryContainer,
        backgroundColor: Colors.transparent, 
        elevation: 0, 
        overlayColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.disabled)) return null;
          if (states.contains(WidgetState.dragged)) return colorScheme.onSurface.withValues(alpha: 0.16);
          if (states.contains(WidgetState.hovered)) return colorScheme.onSurface.withValues(alpha: 0.08);
          if (states.contains(WidgetState.focused) || states.contains(WidgetState.pressed)) {
            return colorScheme.onSurface.withValues(alpha: 0.1);
          }
          return null;
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return IconThemeData(
              color: colorScheme.onSecondaryContainer,
              size: 24.sp,
            );
          }
          return IconThemeData(
            color: colorScheme.onSurfaceVariant,
            size: 22.sp);
        }),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return TextStyle(
              fontSize: 12.sp,
              fontWeight: FontWeight.bold,
              color: colorScheme.secondary, 
            );
          }
          return TextStyle(
            fontSize: 12.sp,
            fontWeight: FontWeight.normal,
            color: colorScheme.onSurfaceVariant,
          );
        }),
      ),
      child: NavigationBar(
        height: 64.h, 
        selectedIndex: nav.selectedIndex,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow, 
        onDestinationSelected: (index) => nav.setIndex(index),
        backgroundColor: colorScheme.surfaceContainer,
        destinations: [
          _buildNavDestination(nav, 0, Icons.home_outlined, Icons.home_rounded, 'Home', 'Home, explore collection', colorScheme),
          _buildNavDestination(nav, 1, Icons.storefront_outlined, Icons.storefront_rounded, 'Shop', 'Shop, browse products', colorScheme),
          _buildNavDestination(nav, 2, Icons.favorite_border_rounded, Icons.favorite_rounded, 'Wishlist', 'Wishlist, saved items', colorScheme),
          _buildNavDestination(nav, 3, Icons.shopping_bag_outlined, Icons.shopping_bag_rounded, 'Cart', 'Cart, view my bag', colorScheme),
          _buildNavDestination(nav, 4, Icons.person_outline_rounded, Icons.person_rounded, 'Profile', 'Profile, account settings', colorScheme),
        ],
      ),
    );
  }

  Widget _buildHorizontalNavDestination(NavigationController nav, int index, IconData icon, IconData selectedIcon, String label, String semanticLabel, ColorScheme colorScheme) {
    final bool isSelected = nav.selectedIndex == index;
    
    return Semantics(
      selected: isSelected,
      button: true,
      label: semanticLabel,
      child: InkWell(
        onTap: () {
          // M3 Behavior: Light haptic feedback on tab selection
          HapticFeedback.lightImpact();
          nav.setIndex(index);
        },
        borderRadius: BorderRadius.circular(32),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? colorScheme.secondaryContainer : Colors.transparent,
            borderRadius: BorderRadius.circular(32),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildNumberedIcon(nav, index, isSelected ? selectedIcon : icon, isSelected, colorScheme),
              if (isSelected) 
                Padding(
                  padding: const EdgeInsets.only(left: 8),
                  child: Text(
                    label,
                    style: TextStyle(
                      color: colorScheme.secondary,
                      fontWeight: FontWeight.bold,
                      fontSize: 12.sp,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNumberedIcon(NavigationController nav, int index, IconData icon, bool isSelected, ColorScheme colorScheme) {
    // Helper to generate the correct Icon with selection-aware coloring
    Widget buildIcon(IconData i) => Icon(
      i, 
      color: isSelected ? colorScheme.onSecondaryContainer : colorScheme.onSurfaceVariant
    );

    if (index == 0) {
      return Consumer<NotificationController>(
        builder: (context, provider, _) {
          final count = provider.unreadCount;
          final showBadge = nav.selectedIndex != 0 && count > 0;
          return Semantics(
            label: showBadge ? 'Internal notifications, ${count > 999 ? '999+' : '$count'} unread' : 'Internal notifications',
            child: Badge(
              isLabelVisible: showBadge,
              label: Text(count > 999 ? '999+' : count.toString()),
              child: buildIcon(icon),
            ),
          );
        },
      );
    } else if (index == 2) {
      return Consumer<FavoriteController>(
        builder: (context, provider, _) {
          final count = provider.favorites.length;
          final showBadge = nav.selectedIndex != 2 && count > 0;
          return Semantics(
            label: showBadge ? 'My Wishlist, ${count > 999 ? '999+' : '$count'} items' : 'My Wishlist',
            child: Badge(
              isLabelVisible: showBadge,
              label: Text(count > 999 ? '999+' : count.toString()),
              alignment: AlignmentDirectional.topEnd,
              child: buildIcon(icon),
            ),
          );
        },
      );
    } else if (index == 3) {
      return Consumer<CartController>(
        builder: (context, provider, _) {
          final count = provider.cart.length;
          final showBadge = nav.selectedIndex != 3 && count > 0;
          return Semantics(
            label: showBadge ? 'Shopping Cart, ${count > 999 ? '999+' : '$count'} items' : 'Shopping Cart',
            child: Badge(
              isLabelVisible: showBadge,
              label: Text(count > 999 ? '999+' : count.toString()),
              alignment: AlignmentDirectional.topEnd,
              child: buildIcon(icon),
            ),
          );
        },
      );
    }
    return buildIcon(icon);
  }

  NavigationDestination _buildNavDestination(NavigationController nav, int index, IconData icon, IconData selectedIcon, String label, String semanticLabel, ColorScheme colorScheme) {
    return NavigationDestination(
      icon: _buildNumberedIcon(nav, index, icon, false, colorScheme),
      selectedIcon: _buildNumberedIcon(nav, index, selectedIcon, true, colorScheme),
      label: label,
      tooltip: semanticLabel,
    );
  }

  NavigationRailDestination _buildRailDestination({
    required bool isExtended,
    required IconData icon,
    required IconData selectedIcon,
    required String label,
    required String semanticLabel,
    bool showBadge = false,
    int? badgeCount,
  }) {
    final String countText = badgeCount != null && badgeCount > 999 ? '999+' : (badgeCount?.toString() ?? '');
    
    // Helper to get color without context since we are inside a method
    // But we need context for Theme. We can access 'context' if it's a State method.
    // Yes, this is inside _NavigationMenuState.
    final colorScheme = Theme.of(context).colorScheme;

    return NavigationRailDestination(
      icon: isExtended 
          ? Icon(icon, color: colorScheme.onSurfaceVariant)
          : Semantics(
              label: showBadge ? '$semanticLabel, $countText items' : semanticLabel,
              child: Badge(
                isLabelVisible: showBadge,
                label: Text(countText),
                alignment: AlignmentDirectional.topEnd,
                child: Icon(icon, color: colorScheme.onSurfaceVariant),
              ),
            ),
      selectedIcon: Icon(selectedIcon, color: colorScheme.onSecondaryContainer), 
      label: Text(label), // Label must be a Widget, usually Text
      padding: const EdgeInsets.symmetric(vertical: 4), 
    );
  }
}
