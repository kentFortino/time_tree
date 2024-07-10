import 'package:flutter/material.dart';
import 'package:linktree_clone/page/main_page.dart';
import 'package:linktree_clone/provider/user_provider.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:provider/provider.dart';

class LoginPage extends StatelessWidget {
  static const pageRoute = '/login';

  const LoginPage({super.key});

  void _showBottomSheet(BuildContext context) {
    final userProvider = context.read<UserProvider>();

    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.all(16.0),
          height: 200,
          width: double.infinity,
          child: Center(
            child: SizedBox(
              width: MediaQuery.of(context).size.width * 0.8,
              child: TextButton(
                style: TextButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  backgroundColor: const Color.fromRGBO(46, 204, 135, 1),
                ),
                onPressed: () async {
                  await userProvider.login();

                  if (context.mounted) {
                    Navigator.of(context).pop();
                    Navigator.pushNamedAndRemoveUntil(
                        context, MainPage.pageRoute, (route) => false);
                  }
                },
                child: const Text(
                  'continue via google',
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = context.watch<UserProvider>();
    return Scaffold(
      body: ModalProgressHUD(
        inAsyncCall: userProvider.isLoading,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                "assets/TT_g_v.png",
                width: 150,
              ),
              SizedBox(
                width: MediaQuery.of(context).size.width * 0.5,
                child: TextButton(
                  style: TextButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    backgroundColor: const Color.fromRGBO(46, 204, 135, 1),
                  ),
                  onPressed: () {
                    _showBottomSheet(context);
                  },
                  child: const Text(
                    'Login',
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ),
              ),
              if (userProvider.errorMessage.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    userProvider.errorMessage,
                    style: const TextStyle(color: Colors.red),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
