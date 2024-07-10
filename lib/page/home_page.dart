import 'package:flutter/material.dart';
import 'package:linktree_clone/widget/calendar.dart';

class HomePage extends StatefulWidget {
  static const pageRoute = '/event';

  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        Expanded(child: CustomCalendar()),
      ],
    );
  }
}
