import 'package:flutter/material.dart';
import 'package:linktree_clone/page/home_page.dart';
import 'package:linktree_clone/page/login_page.dart';
import 'package:linktree_clone/provider/user_provider.dart';
import 'package:linktree_clone/widget/event_form.dart';
import 'package:provider/provider.dart';

class MainPage extends StatefulWidget {
  static const pageRoute = '/main';

  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  void _showBottomDrawer(BuildContext context) {
    showModalBottomSheet(
      isScrollControlled: true,
      elevation: 10,
      context: context,
      builder: (context) {
        return DraggableScrollableSheet(
          expand: false,
          maxChildSize: 0.95,
          initialChildSize: 0.95,
          minChildSize: 0.95,
          builder: (context, scrollController) {
            return SizedBox(
              width: double.infinity,
              child: EventForm(
                onClose: () => Navigator.of(context).pop(),
              ),
            );
          },
        );
      },
    );
  }

  void _showDrawer(BuildContext context) {
    _scaffoldKey.currentState?.openDrawer();
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = context.watch<UserProvider>();
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        centerTitle: false,
        automaticallyImplyLeading: false,
        title: GestureDetector(
          onTap: () => _showDrawer(context),
          child: CircleAvatar(
            radius: 20,
            backgroundImage: userProvider.isLoading
                ? null
                : userProvider.user?.photoURL == null
                    ? null
                    : NetworkImage(userProvider.user?.photoURL ?? ""),
            child: userProvider.user?.photoURL == null
                ? const Icon(Icons.person)
                : null,
          ),
        ),
      ),
      drawer: Drawer(
        child: ListView(
          children: [
            DrawerHeader(
              child: Column(
                children: [
                  Expanded(
                    child: CircleAvatar(
                      radius: 50,
                      child: userProvider.isLoading
                          ? const CircularProgressIndicator()
                          : userProvider.user?.photoURL == null
                              ? const Icon(Icons.person)
                              : Image.network(
                                  userProvider.user?.photoURL ?? ""),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(userProvider.user?.displayName ?? ""),
                  Text(userProvider.user?.email ?? ""),
                ],
              ),
            ),
            ListTile(
              title: const Text('Logout'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  LoginPage.pageRoute,
                  (route) => false,
                );
              },
            ),
          ],
        ),
      ),
      body: const HomePage(),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_month),
            label: 'Events',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add),
            label: 'Create',
          ),
        ],
        currentIndex: 0,
        selectedItemColor: Colors.blue,
        onTap: (value) {
          if (value == 0) return;
          _showBottomDrawer(context);
        },
      ),
    );
  }
}
