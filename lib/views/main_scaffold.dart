import 'package:flutter/material.dart';
import 'package:sandwich_shop/views/app_styles.dart';

class MainScaffold extends StatelessWidget {
  final Widget child;
  final String title;

  const MainScaffold({super.key, required this.child, required this.title});

  Widget _buildDrawer(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(color: Theme.of(context).primaryColor),
            child: const Text('Sandwich Shop', style: TextStyle(color: Colors.white, fontSize: 20)),
          ),
          ListTile(
            leading: const Icon(Icons.home),
            title: const Text('Home'),
            onTap: () {
              Navigator.popUntil(context, (route) => route.isFirst);
            },
          ),
          ListTile(
            leading: const Icon(Icons.shopping_cart),
            title: const Text('Cart'),
            onTap: () {
              Navigator.pop(context);
              // Let existing UI handle viewing cart via View Cart button from OrderScreen
            },
          ),
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: const Text('About'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/about');
            },
          ),
          ListTile(
            leading: const Icon(Icons.person),
            title: const Text('Profile'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/profile');
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      final bool isWide = constraints.maxWidth >= 900;

      if (isWide) {
        // Permanent side navigation
        return Scaffold(
          body: Row(
            children: [
              SizedBox(
                width: 240,
                child: Material(
                  elevation: 2,
                  child: _buildDrawer(context),
                ),
              ),
              Expanded(
                child: Scaffold(
                  appBar: AppBar(
                    title: Text(title, style: heading1),
                  ),
                  body: child,
                ),
              ),
            ],
          ),
        );
      }

      // Mobile/tablet: hidden drawer accessible from AppBar action
      return Scaffold(
        appBar: AppBar(
          title: Text(title, style: heading1),
          actions: [
            IconButton(
              icon: const Icon(Icons.menu),
              tooltip: 'Open navigation menu',
              onPressed: () {
                Scaffold.of(context).openDrawer();
              },
            ),
          ],
        ),
        drawer: _buildDrawer(context),
        body: child,
      );
    });
  }
}
