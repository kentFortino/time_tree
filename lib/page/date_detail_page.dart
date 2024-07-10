import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:linktree_clone/constant.dart';
import 'package:linktree_clone/page/event_detail_page.dart';
import 'package:linktree_clone/provider/calendar_provider.dart';
import 'package:linktree_clone/widget/event_form.dart';
import 'package:provider/provider.dart';

class DateDetailPage extends StatelessWidget {
  final DateTime date;
  final ScrollController scrollController;

  const DateDetailPage(
      {super.key, required this.date, required this.scrollController});

  void _showEventForm(BuildContext context) {
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
                fromDate: date,
                onClose: () => Navigator.of(context).pop(),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<CalendarProvider>(
        builder: (context, calendarProvider, child) {
          if (calendarProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          final filteredEvent = calendarProvider.events.where((event) {
            return event.startTime.year == date.year &&
                event.startTime.month == date.month &&
                event.startTime.day == date.day;
          }).toList();
          final events = filteredEvent
            ..sort((a, b) => a.startTime.compareTo(b.startTime));

          return Container(
            color: Colors.grey.shade900,
            child: CustomScrollView(
              controller: scrollController,
              slivers: [
                SliverAppBar(
                  pinned: true,
                  expandedHeight: 40.0,
                  backgroundColor: Colors.grey.shade900,
                  automaticallyImplyLeading: false,
                  flexibleSpace: FlexibleSpaceBar(
                    titlePadding: const EdgeInsets.all(0),
                    // Remove default padding
                    title: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              DateFormat('EEEE, d MMM').format(date),
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          IconButton(
                            onPressed: () => _showEventForm(context),
                            icon: const Icon(
                              Icons.add,
                              size: 30,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (BuildContext context, int index) {
                      if (events.isEmpty) {
                        return Center(
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              'No events',
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.grey.shade500,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        );
                      }

                      final event = events[index];
                      final isAllDay =
                          event.startTime.hour == 0 && event.endTime.hour == 23;
                      return InkWell(
                        onTap: () => Navigator.pushNamed(
                          context,
                          EventDetailPage.pageRoute,
                          arguments: event.id,
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(8),
                          child: Row(
                            children: [
                              SizedBox(
                                width: 60,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      isAllDay
                                          ? 'All Day'
                                          : DateFormat('HH.mm')
                                              .format(event.startTime),
                                      style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w700),
                                    ),
                                    if (!isAllDay)
                                      Text(
                                        DateFormat('HH.mm')
                                            .format(event.endTime),
                                        style: TextStyle(
                                            color: Colors.grey.shade500,
                                            fontWeight: FontWeight.w700),
                                      ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 5),
                              Container(
                                height: 40,
                                width: 3,
                                color:
                                    tagColor[event.tag] ?? Colors.grey.shade500,
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                flex: 3,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      event.title,
                                      style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                    childCount: events.isEmpty ? 1 : events.length,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
