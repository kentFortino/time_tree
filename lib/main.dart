import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:linktree_clone/firebase_options.dart';
import 'package:linktree_clone/page/event_detail_page.dart';
import 'package:linktree_clone/page/home_page.dart';
import 'package:linktree_clone/page/login_page.dart';
import 'package:linktree_clone/page/main_page.dart';
import 'package:linktree_clone/provider/calendar_provider.dart';
import 'package:linktree_clone/provider/user_provider.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (context) => UserProvider()),
      ChangeNotifierProvider(
        create: (context) => CalendarProvider(),
      )
    ],
    child: const MyApp(),
  ));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return MaterialApp(
      title: 'TimeTree Clone',
      theme: ThemeData(
        textTheme: GoogleFonts.interTextTheme(textTheme),
      ),

      darkTheme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: Colors.black,
      ),
      themeMode: ThemeMode.dark,
      //DarkMode
      initialRoute: LoginPage.pageRoute,
      routes: {
        MainPage.pageRoute: (context) => const MainPage(),
        HomePage.pageRoute: (context) => const HomePage(),
        LoginPage.pageRoute: (context) => const LoginPage(),
        EventDetailPage.pageRoute: (context) => const EventDetailPage(),
      },
    );
  }
}
