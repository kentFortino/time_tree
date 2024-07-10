import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:linktree_clone/constant.dart';
import 'package:linktree_clone/model/event_model.dart';
import 'package:linktree_clone/page/date_detail_page.dart';
import 'package:linktree_clone/provider/calendar_provider.dart';
import 'package:provider/provider.dart';

class CustomCalendar extends StatefulWidget {
  const CustomCalendar({super.key});

  @override
  State<CustomCalendar> createState() => _CustomCalendarState();
}

class _CustomCalendarState extends State<CustomCalendar> {
  DateTime _focusedDate = DateTime.now();
  DateTime _selectedDate = DateTime.now();
  final _today = DateTime.now();
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _focusedDate.month - 1);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _showBottomDrawer(BuildContext context, DateTime currentDate) {
    showModalBottomSheet(
      isScrollControlled: true,
      context: context,
      backgroundColor: Colors.grey.shade900,
      builder: (context) {
        return DraggableScrollableSheet(
            expand: false,
            initialChildSize: 0.95,
            maxChildSize: 0.95,
            builder: (context, scrollController) {
              return Padding(
                padding: const EdgeInsets.all(8),
                child: SizedBox(
                  width: double.infinity,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Container(
                          width: 50,
                          height: 5,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade600,
                            borderRadius: BorderRadius.circular(50),
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 5,
                      ),
                      Expanded(
                          child: DateDetailPage(
                        date: currentDate,
                        scrollController: scrollController,
                      ))
                    ],
                  ),
                ),
              );
            });
      },
    );
  }

  void _onPageChanged(int page) {
    setState(() {
      _focusedDate = DateTime(_focusedDate.year, page + 1, 1);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildHeader(),
        _buildDaysOfWeek(),
        Expanded(
          child: Consumer<CalendarProvider>(
              builder: (context, calendarProvider, child) {
            if (calendarProvider.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }
            return PageView.builder(
              controller: _pageController,
              onPageChanged: _onPageChanged,
              itemBuilder: (context, index) {
                return _buildDatesForMonth(index + 1, calendarProvider);
              },
            );
          }),
        ),
      ],
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
          icon: const Icon(Icons.chevron_left),
          onPressed: () {
            _pageController.previousPage(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
            );
          },
        ),
        Text(
          DateFormat.yMMMM().format(_focusedDate),
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        IconButton(
          icon: const Icon(Icons.chevron_right),
          onPressed: () {
            _pageController.nextPage(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
            );
          },
        ),
      ],
    );
  }

  Widget _buildDaysOfWeek() {
    final daysOfWeek = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: daysOfWeek.map((day) {
        return Text(
          day,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
        );
      }).toList(),
    );
  }

  Widget _buildDatesForMonth(int month, CalendarProvider calendarProvider) {
    final firstDayOfMonth = DateTime(_focusedDate.year, month, 1);
    final lastDayOfMonth = DateTime(_focusedDate.year, month + 1, 0);
    final daysInMonth = lastDayOfMonth.day;

    final previousMonthLastDay = DateTime(_focusedDate.year, month, 0).day;
    int startDayOffset = firstDayOfMonth.weekday % 7;

    List<Widget> dateWidgets = [];

    for (int i = 0; i < startDayOffset; i++) {
      final date = DateTime(_focusedDate.year, month - 1,
          previousMonthLastDay - startDayOffset + i + 1);
      dateWidgets.add(
        _buildDateCell(date, previousMonthLastDay - startDayOffset + i + 1,
            true, calendarProvider),
      );
    }

    for (int i = 1; i <= daysInMonth; i++) {
      final date = DateTime(_focusedDate.year, month, i);
      dateWidgets.add(
        GestureDetector(
          onTap: () {
            setState(() {
              _selectedDate = date;
            });
          },
          child: _buildDateCell(date, i, false, calendarProvider),
        ),
      );
    }

    int remainingDays = 35 - dateWidgets.length;
    for (int i = 1; i <= remainingDays; i++) {
      final date = DateTime(_focusedDate.year, month + 1, i);
      dateWidgets.add(
        _buildDateCell(date, i, true, calendarProvider),
      );
    }

    return GridView.count(
      crossAxisCount: 7,
      childAspectRatio: 1 / 2,
      children: dateWidgets,
    );
  }

  Widget _buildDateCell(DateTime date, int day, bool isOtherMonth,
      CalendarProvider calendarProvider) {
    bool isToday = date.day == _today.day &&
        date.month == _today.month &&
        date.year == _today.year;

    List<EventModel> eventsForDate = calendarProvider.events.where((event) {
      return event.startTime.year == date.year &&
          event.startTime.month == date.month &&
          event.startTime.day == date.day;
    }).toList();

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedDate = date;
        });
      },
      onDoubleTap: () {
        _showBottomDrawer(context, date);
      },
      child: Container(
        decoration: BoxDecoration(
          color:
              _selectedDate == date ? Colors.grey.shade900 : Colors.transparent,
          border: Border.symmetric(
              horizontal: BorderSide(color: Colors.grey.shade800, width: 0.5)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              isToday
                  ? Container(
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(color: Colors.blueAccent),
                        borderRadius: BorderRadius.circular(50),
                      ),
                      child: Text(
                        day.toString(),
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: isOtherMonth
                              ? Colors.grey.shade600
                              : Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    )
                  : Text(
                      day.toString(),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color:
                            isOtherMonth ? Colors.grey.shade600 : Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
              const SizedBox(
                height: 5,
              ),
              Column(
                children: [
                  ...eventsForDate.take(4).map((event) => Padding(
                        padding: const EdgeInsets.all(1),
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(2),
                          decoration: BoxDecoration(
                            color: tagColor[event.tag],
                            borderRadius: BorderRadius.circular(5),
                          ),
                          child: Text(
                            event.title,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                                fontSize: 10,
                                color: Colors.white,
                                fontWeight: FontWeight.bold),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ))
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
