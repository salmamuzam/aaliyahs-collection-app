import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'package:aaliyahs_collection_estore/features/shop/controllers/cart_controller.dart';
import 'package:aaliyahs_collection_estore/features/shop/controllers/navigation_controller.dart';
import 'package:aaliyahs_collection_estore/common/widgets/navigation_menu.dart';
import 'package:aaliyahs_collection_estore/utils/constants/image_strings.dart';

import 'package:aaliyahs_collection_estore/utils/device/device_utility.dart';
import 'package:aaliyahs_collection_estore/common/widgets/appbar/app_bar_actions.dart';
import 'package:aaliyahs_collection_estore/common/widgets/appbar/flexible_app_bars.dart';
import 'package:aaliyahs_collection_estore/features/shop/screens/product/product_screen.dart';
import 'package:aaliyahs_collection_estore/features/shop/screens/cart/widgets/cart_error_info.dart';

// Modular Cart Widgets
import 'package:aaliyahs_collection_estore/features/shop/screens/cart/widgets/cart_item_card.dart';
import 'package:aaliyahs_collection_estore/features/shop/screens/cart/widgets/cart_bottom_section.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  final ScrollController _scrollController = ScrollController();
  late NavigationController _navigationController;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // M3 Behavior: Scroll to top upon re-selection
      _navigationController = Provider.of<NavigationController>(context, listen: false);
      _navigationController.addListener(_handleNavSelection);
    });
  }

  void _handleNavSelection() {
    if (_navigationController.reselectedIndex == 3 && _scrollController.hasClients) {
      _scrollController.animateTo(
        0, 
        duration: const Duration(milliseconds: 500), 
        curve: Curves.easeInOutQuart
      );
    }
  }

  @override
  void dispose() {
    try {
      _navigationController.removeListener(_handleNavSelection);
    } catch (_) {}
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: _buildAppBar(context),
      body: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: DeviceUtils.maxContentWidth),
          child: Consumer<CartController>(
            builder: (context, provider, child) {
              if (provider.isCartEmpty) {
                return _buildEmptyCart(context);
              }
              return _buildCartContent(context, provider, isDarkMode);
            },
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return PreferredSize(
      preferredSize: const Size.fromHeight(64.0),
      child: Consumer<CartController>(
        builder: (context, cartProvider, child) {
          final itemCount = cartProvider.cart.length;
          
          return AaliyahSmallAppBar(
            title: 'Cart',
            subtitle: itemCount > 0 ? "$itemCount ${itemCount == 1 ? 'item' : 'items'}" : null,
            leading: IconButton(
              onPressed: () => Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const NavigationMenu()),
              ),
              icon: const Icon(Icons.arrow_back_rounded),
            ),
            actions: const [
              FavoriteAppBarAction(),
              SizedBox(width: 8),
            ],
          );
        },
      ),
    );
  }

  Widget _buildCartContent(BuildContext context, CartController provider, bool isDarkMode) {
    final isCompact = DeviceUtils.isCompact;
    final isMedium = DeviceUtils.isMedium;
    
    // Compact & Medium: Supporting pane BELOW
    if (isCompact || isMedium) {
      return Column(
        children: [
          _buildSelectAllHeader(context, provider),
          Expanded(
            child: ListView.separated(
              controller: _scrollController,
              padding: EdgeInsets.symmetric(horizontal: DeviceUtils.m3Margin),
              itemCount: provider.cart.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                return CartItemCard(
                  item: provider.cart[index],
                  index: index,
                  provider: provider,
                );
              },
            ),
          ),
          // Supporting pane below
          CartBottomSection(provider: provider),
        ],
      );
    }
    
    // Expanded+: Supporting pane on RIGHT SIDE (360dp fixed)
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Primary Pane: Cart Items (Flexible)
        Expanded(
          child: Column(
            children: [
              _buildSelectAllHeader(context, provider),
              Expanded(
                child: ListView.separated(
                  controller: _scrollController,
                  padding: EdgeInsets.symmetric(horizontal: DeviceUtils.m3Margin),
                  itemCount: provider.cart.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    return CartItemCard(
                      item: provider.cart[index],
                      index: index,
                      provider: provider,
                    );
                  },
                ),
              ),
            ],
          ),
        ),
        
        // Divider
        VerticalDivider(
          width: DeviceUtils.paneSpacer,
          thickness: 1,
          color: Theme.of(context).colorScheme.outlineVariant,
        ),
        
        // Supporting Pane: Order Summary (Fixed 360dp for expanded)
        Container(
          width: DeviceUtils.paneStandardWidth, // 360dp for expanded
          padding: EdgeInsets.all(DeviceUtils.m3Margin),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Order Summary',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: DeviceUtils.m3Padding(6)),
              const Expanded(child: SizedBox.shrink()),
              CartBottomSection(provider: provider, isInPane: true),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyCart(BuildContext context) {
    final bool isDesktop = DeviceUtils.isExpanded;


    return SingleChildScrollView(
      controller: _scrollController,
      child: Center(
        child: Container(
          constraints: BoxConstraints(maxWidth: isDesktop ? 600 : double.infinity),
          padding: EdgeInsets.all(isDesktop ? 40 : DeviceUtils.m3Margin),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: isDesktop ? 300 : 200, // Reduced from 250
                height: isDesktop ? 200 : 200, // Reduced from 250
                child: Image.asset(emptyCartIllustration, fit: BoxFit.contain),
              ).animate().scale(duration: 400.ms, curve: Curves.easeOutBack).fadeIn(),
              const SizedBox(height: 32),
              ErrorInfo(
                title: 'Your cart is empty', 
                description: "Looks like you haven't added anything yet. Start shopping to find your next favorite item.",
                btnText: 'Start shopping',
                press: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ProductScreen()),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSelectAllHeader(BuildContext context, CartController provider) {
    final colorScheme = Theme.of(context).colorScheme;
    final bool hasSelection = provider.selectedItemIds.isNotEmpty;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: DeviceUtils.m3Margin - 8, vertical: 4), // Adjusted for InkWell padding
      color: colorScheme.surface,
      child: Row(
        children: [
          InkWell(
            onTap: () => provider.toggleAll(provider.allSelectedState == true ? false : true),
            borderRadius: BorderRadius.circular(8),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Semantics(
                    label: 'Select all items',
                    selected: provider.allSelectedState == true,
                    child: Checkbox(
                      value: provider.allSelectedState,
                      tristate: true,
                      onChanged: (val) => provider.toggleAll(val),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'All items (${provider.cart.length})',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ),
          const Spacer(),
          if (hasSelection)
            TextButton.icon(
              onPressed: () => provider.removeSelected(),
              icon: Icon(Icons.delete_sweep_rounded, size: 20, color: colorScheme.error),
              label: Text(
                'Remove (${provider.selectedItemIds.length})',
                style: TextStyle(color: colorScheme.error, fontWeight: FontWeight.bold),
              ),
              style: TextButton.styleFrom(
                foregroundColor: colorScheme.error,
                padding: const EdgeInsets.symmetric(horizontal: 16),
              ),
            ),
        ],
      ),
    );
  }
}
