import 'package:flutter/material.dart';
import 'package:my_shop_app/helpers/custom_route.dart';
import 'package:my_shop_app/providers/auth.dart';
import 'package:my_shop_app/providers/cart.dart';
import 'package:my_shop_app/providers/orders.dart';
import 'package:my_shop_app/screens/auth_screen.dart';
import 'package:my_shop_app/screens/cart_screen.dart';
import 'package:my_shop_app/screens/edit_product_screen.dart';
import 'package:my_shop_app/screens/orders_screen.dart';
import 'package:my_shop_app/screens/user_products_screen.dart';
import 'package:my_shop_app/widgets/splash_screen.dart';
import 'package:provider/provider.dart';

import 'package:my_shop_app/screens/product_detail_screen.dart';
import 'package:my_shop_app/screens/products_overview_screen.dart';
import './providers/products.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
        providers: [
          ChangeNotifierProvider(
            create: (ctx) => Auth(),
          ),
          ChangeNotifierProxyProvider<Auth, Products>(
            create: null,
            update: (ctx, auth, previousProducts) => Products(
              auth.token,
              auth.userId,
              previousProducts == null ? [] : previousProducts.items,
            ),
          ),
          ChangeNotifierProxyProvider<Auth, Orders>(
            create: null,
            update: (ctx, auth, previousOrders) => Orders(
              auth.token,
              previousOrders == null ? [] : previousOrders.orders,
              auth.userId,
            ),
          ),
          ChangeNotifierProvider(
            create: (ctx) => Cart(),
          ),
        ],
        child: Consumer<Auth>(
          builder: (ctx, auth, _) => MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'My Shop',
            theme: ThemeData(
              primarySwatch: Colors.purple,
              accentColor: Colors.deepOrange,
              fontFamily: 'Lato',
              pageTransitionsTheme: PageTransitionsTheme(builders: {
                TargetPlatform.android: CustomPageTransitionBuilder(),
                TargetPlatform.iOS: CustomPageTransitionBuilder(),
              }),
            ),
            home: auth.isAuth
                ? ProductsOverviewScreen()
                : FutureBuilder(
                    future: auth.tryAutoLogin(),
                    builder: (ctx, authResult) =>
                        authResult.connectionState == ConnectionState.waiting
                            ? SplashScreen()
                            : AuthScreen()),
            routes: {
              '/product-detail': (ctx) => ProductDetailScreen(),
              '/cart': (ctx) => CartScreen(),
              '/orders': (ctx) => OrdersScreen(),
              '/user-products': (ctx) => UserProductsScreen(),
              '/edit-product': (ctx) => EditProductScreen(),
              '/auth': (ctx) => AuthScreen(),
            },
          ),
        ));
  }
}
