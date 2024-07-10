import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:linktree_clone/constant.dart';
import 'package:linktree_clone/model/event_model.dart';
import 'package:linktree_clone/provider/calendar_provider.dart';
import 'package:linktree_clone/provider/user_provider.dart';
import 'package:linktree_clone/widget/event_form.dart';
import 'package:provider/provider.dart';

class EventDetailPage extends StatefulWidget {
  static const pageRoute = '/event_detail';

  const EventDetailPage({super.key});

  @override
  State<EventDetailPage> createState() => _EventDetailPageState();
}

class _EventDetailPageState extends State<EventDetailPage> {
  void _showEventForm(BuildContext context, EventModel event) {
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
                type: 'edit',
                event: event,
                onClose: () => Navigator.of(context)
                  ..pop()
                  ..pop(),
              ),
            );
          },
        );
      },
    );
  }

  void _showCupertinoActionSheet(BuildContext context, String eventId) {
    final calendarProvider = context.read<CalendarProvider>();
    showCupertinoModalPopup<void>(
      context: context,
      builder: (BuildContext context) => CupertinoActionSheet(
        actions: <CupertinoActionSheetAction>[
          CupertinoActionSheetAction(
              child: const Text('Edit'),
              onPressed: () => _showEventForm(
                    context,
                    calendarProvider.events
                        .firstWhere((event) => event.id == eventId),
                  )),
          CupertinoActionSheetAction(
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
            onPressed: () async {
              await calendarProvider.deleteEvent(eventId);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Event deleted')),
                );
                Navigator.of(context)
                  ..pop()
                  ..pop();
              }
              // Handle delete action
            },
          ),
        ],
        cancelButton: CupertinoActionSheetAction(
          child: const Text('Cancel'),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final String eventId = ModalRoute.of(context)?.settings.arguments as String;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Consumer<UserProvider>(
          builder: (context, userProvider, child) {
            return Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircleAvatar(
                  backgroundImage: userProvider.isLoading
                      ? null
                      : NetworkImage(userProvider.user?.photoURL ?? ""),
                ),
              ],
            );
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.more_horiz, color: Colors.white),
            onPressed: () => _showCupertinoActionSheet(context, eventId),
          ),
        ],
      ),
      body: Consumer<CalendarProvider>(
        builder: (context, calendarProvider, child) {
          if (calendarProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          final findEvent = calendarProvider.events.where(
            (event) => event.id == eventId,
          );
          if (findEvent.isEmpty) {
            return const Center(child: Text('Event not found'));
          }
          final event = findEvent.first;

          final color = tagColor[event.tag] ?? Colors.green;
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Text(
                    event.title,
                    style: TextStyle(
                      color: color,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          DateFormat('EEE, d MMM yyyy').format(event.startTime),
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold),
                        ),
                        Text(
                          DateFormat('HH.mm').format(event.startTime),
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    Icon(
                      Icons.chevron_right_rounded,
                      size: 40,
                      color: color,
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          DateFormat('EEE, d MMM yyyy').format(event.endTime),
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold),
                        ),
                        Text(
                          DateFormat('HH.mm').format(event.endTime),
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                ListTile(
                  leading: Icon(Icons.calendar_today, color: color),
                  title: Text(calendarProvider.calendar?.name ?? "",
                      style: const TextStyle(color: Colors.white)),
                ),
                ListTile(
                  leading: Icon(CupertinoIcons.tag, color: color),
                  title: Text(event.tag,
                      style: const TextStyle(color: Colors.white)),
                ),
                Divider(color: Colors.grey.shade700),
              ],
            ),
          );
        },
      ),
    );
  }
}
