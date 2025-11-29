import 'package:flutter/material.dart';
import 'package:projet_best_mlewi/vue/management/management_page.dart';
import 'package:projet_best_mlewi/navigation/manager_guard.dart';
import 'package:projet_best_mlewi/vue/authentification/login.page.dart';
import 'package:projet_best_mlewi/vue/authentification/register.page.dart';
import 'package:projet_best_mlewi/vue/profile/profile_page.dart';
import 'package:projet_best_mlewi/vue/cart/cart_page.dart';
import 'package:projet_best_mlewi/vue/product_detail/product_detail_page.dart';
import 'package:projet_best_mlewi/vue/orders/orders_page.dart';
import 'package:projet_best_mlewi/model/commande.dart';
import 'package:projet_best_mlewi/vue/checkout/checkout_page.dart';
import 'package:projet_best_mlewi/vue/orders/order_detail_page.dart';
import 'package:projet_best_mlewi/navigation/app_router.dart';
import 'package:projet_best_mlewi/vue/blog/blog_list_page.dart';
import 'package:projet_best_mlewi/vue/blog/blog_detail_page.dart';
import 'package:projet_best_mlewi/service/blog_service.dart';
import 'package:projet_best_mlewi/vue/profile/edit_profile_page.dart';
import 'package:projet_best_mlewi/vue/profile/addresses_page.dart';
import 'package:projet_best_mlewi/vue/profile/settings_page.dart';
import 'package:projet_best_mlewi/vue/profile/help_support_page.dart';

class NestedNavigator extends StatefulWidget {
  final PageController pageController;
  final List<Widget> mainPages;

  const NestedNavigator({super.key, required this.pageController, required this.mainPages});

  @override
  State<NestedNavigator> createState() => _NestedNavigatorState();
}

class _NestedNavigatorState extends State<NestedNavigator> {
  // int _selectedIndex = 0; // Removed
  // late PageController _pageController; // Removed
  // late Widget _homePageView; // Removed

  @override
  void initState() {
    super.initState();
    // _pageController = PageController(initialPage: _selectedIndex); // Removed
    // _homePageView = PageView(
    //   controller: _pageController,
    //   onPageChanged: (index) {
    //     setState(() {
    //       _selectedIndex = index;
    //     });
    //   },
    //   children: _mainPages,
    // ); // Removed
  }

  @override
  void dispose() {
    // _pageController.dispose(); // Removed
    super.dispose();
  }

  // final List<Widget> _mainPages = <Widget>[ // Removed
  //   const HomeContentPage(),
  //   const OrdersPage(),
  //   const MapPage(),
  //   const ManagementPage(),
  // ];

  @override
  Widget build(BuildContext context) {
    return Navigator(
      // key: AppRouter.navigatorKey, // Removed to prevent conflict with root navigator
      onGenerateRoute: (settings) {
        Widget page;
        switch (settings.name) {
          case '/':
            page = PageView(
              controller: widget.pageController, // Use the passed controller
              onPageChanged: (index) {
                // The AppShell's _selectedIndex will be updated via onTap in BottomNavigationBar
              },
              children: widget.mainPages, // Use the passed mainPages
            );
            break;
          case '/register':
            page = RegisterPage();
            break;
          case '/login':
            page = LoginPage();
            break;
          case '/profile':
            page = ProfilePage();
            break;
          case '/cart':
            page = CartPage();
            break;
          case '/checkout':
            page = CheckoutPage();
            break;
          case '/orders':
            page = OrdersPage();
            break;
          case '/product_detail':
            final product = settings.arguments as Map<String, dynamic>;
            page = ProductDetailPage(product: product);
            break;
          case '/order_detail':
            final order = settings.arguments as Commande;
            page = OrderDetailPage(order: order);
            break;
          case '/management':
            page = ManagerGuard(child: const ManagementPage());
            break;
          case '/blog':
            page = const BlogListPage();
            break;
          case '/blog/detail':
            final post = settings.arguments as BlogPost;
            page = BlogDetailPage(post: post);
            break;
          case '/profile/edit':
            page = const EditProfilePage();
            break;
          case '/profile/addresses':
            page = const AddressesPage();
            break;
          case '/profile/settings':
            page = const SettingsPage();
            break;
          case '/profile/help':
            page = const HelpSupportPage();
            break;
          default:
            page = const Text('Error: Unknown route');
        }
        return MaterialPageRoute(builder: (context) => page, settings: settings);
      },
    );
  }
}
