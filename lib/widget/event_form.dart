import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:linktree_clone/constant.dart';
import 'package:linktree_clone/model/event_model.dart';
import 'package:linktree_clone/provider/calendar_provider.dart';
import 'package:provider/provider.dart';

class EventForm extends StatefulWidget {
  final Function onClose;
  final DateTime? fromDate;
  final EventModel? event;
  final String? type;

  const EventForm(
      {super.key,
      required this.onClose,
      this.fromDate,
      this.event,
      this.type = 'create'});

  @override
  State<EventForm> createState() => _EventFormState();
}

class _EventFormState extends State<EventForm> {
  bool _isAllDay = false;
  DateTime _startDate = DateTime.now();
  DateTime _endDate = DateTime.now();
  String _tag = 'green';

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();

  bool _isTitleNotEmpty = false;
  String _notes = "";

  @override
  void initState() {
    super.initState();
    _titleController.addListener(_checkTitle);
    _noteController.addListener(() => _updateNotes(_noteController.text));
    if (widget.fromDate != null) {
      _startDate = widget.fromDate!;
      _endDate = widget.fromDate!;
    }
    if (widget.event != null) {
      final event = widget.event!;
      _titleController.text = event.title;
      _startDate = event.startTime;
      _endDate = event.endTime;
      _tag = event.tag;
      _notes = event.note ?? "";
    }
  }

  void _checkTitle() {
    setState(() {
      _isTitleNotEmpty = _titleController.text.isNotEmpty;
    });
  }

  void _updateNotes(String value) {
    setState(() {
      _notes = value;
    });
  }

  @override
  void dispose() {
    _titleController.removeListener(_checkTitle);
    _noteController.removeListener(() => _updateNotes(_noteController.text));
    _titleController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _selectStartDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _startDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _startDate) {
      setState(() {
        _startDate = picked;
        if (_startDate.isAfter(_endDate)) {
          _endDate = _startDate;
        }
        if (_isAllDay) {
          _endDate = DateTime(picked.year, picked.month, picked.day, 23, 59);
        }
      });
    }
  }

  Future<void> _selectStartTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_startDate),
    );
    if (picked != null) {
      setState(() {
        _startDate = DateTime(_startDate.year, _startDate.month, _startDate.day,
            picked.hour, picked.minute);
      });
    }
  }

  Future<void> _selectEndDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _endDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _endDate) {
      setState(() {
        _endDate = picked;
        if (_isAllDay) {
          _startDate = DateTime(picked.year, picked.month, picked.day, 0, 0);
        }
      });
    }
  }

  Future<void> _selectEndTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_endDate),
    );
    if (picked != null) {
      setState(() {
        _endDate = DateTime(_endDate.year, _endDate.month, _endDate.day,
            picked.hour, picked.minute);
      });
    }
  }

  void _showNoteDrawer(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return DraggableScrollableSheet(
            maxChildSize: 0.90,
            initialChildSize: 0.90,
            expand: false,
            builder: (context, scrollController) {
              return Container(
                color: Colors.grey.shade900,
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: Column(
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
                      const SizedBox(height: 5),
                      Expanded(
                        child: TextField(
                          maxLines: 10,
                          controller: _noteController,
                          style: const TextStyle(color: Colors.white),
                          decoration: const InputDecoration(
                            hintText: 'Note',
                            hintStyle: TextStyle(color: Colors.grey),
                            border: InputBorder.none,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            });
      },
    );
  }

  void _openTagPicker(BuildContext context) {
    showCupertinoModalPopup(
      context: context,
      builder: (context) {
        return CupertinoActionSheet(
          title: const Text('Select Tag'),
          actions: tagColor.keys
              .map(
                (tag) => CupertinoActionSheetAction(
                  onPressed: () {
                    setState(() {
                      _tag = tag;
                    });
                    Navigator.of(context).pop();
                  },
                  child: Text(tag),
                ),
              )
              .toList(),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final calendarProvider = context.read<CalendarProvider>();
    final color = tagColor[_tag];

    final EventModel event = EventModel(
      id: widget.event?.id ?? '',
      title: _titleController.text,
      calendarId: widget.event?.calendarId ?? '',
      createdBy: widget.event?.createdBy ?? '',
      startTime: _startDate,
      endTime: _endDate,
      tag: _tag,
      note: _notes,
      createdAt: widget.event?.createdAt ?? DateTime.now(),
    );

    return Padding(
      padding: const EdgeInsets.all(4.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                onPressed: () => widget.onClose(),
                icon: const Icon(Icons.close),
                color: color,
              ),
              TextButton(
                onPressed: _isTitleNotEmpty
                    ? () async {
                        if (widget.type == 'create') {
                          await calendarProvider.addEvent(event);
                        } else {
                          await calendarProvider.editEvent(event);
                        }

                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Event saved'),
                              duration: Duration(seconds: 2),
                            ),
                          );
                        }
                        widget.onClose();
                      }
                    : null,
                child: const Text('Save'),
              ),
            ],
          ),
          ListTile(
            leading: const SizedBox.shrink(),
            title: TextField(
              controller: _titleController,
              autocorrect: false,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
              decoration: const InputDecoration(
                hintText: 'Title',
                border: InputBorder.none,
                hintStyle: TextStyle(
                  color: Colors.grey,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ),
          ),
          ListTile(
            leading: Icon(
              Icons.calendar_today,
              color: color,
            ),
            title: const Text("All Day", style: TextStyle(color: Colors.white)),
            trailing: Switch(
              value: _isAllDay,
              onChanged: (value) {
                setState(() {
                  _isAllDay = value;
                  if (value) {
                    _startDate = DateTime(_startDate.year, _startDate.month,
                        _startDate.day, 0, 0);
                    _endDate = DateTime(
                        _endDate.year, _endDate.month, _endDate.day, 23, 59);
                  }
                });
              },
              activeColor: color,
            ),
          ),
          const Divider(),
          ListTile(
            leading: const SizedBox.shrink(),
            title: const Text("Starts", style: TextStyle(color: Colors.white)),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextButton(
                  onPressed: () => _selectStartDate(context),
                  child: Text(DateFormat('EEE, MMM d').format(_startDate)),
                ),
                if (!_isAllDay)
                  TextButton(
                    onPressed: () => _selectStartTime(context),
                    child: Text(DateFormat('hh:mm a').format(_startDate)),
                  ),
              ],
            ),
          ),
          const Divider(),
          ListTile(
            leading: const SizedBox.shrink(),
            title: const Text("Ends", style: TextStyle(color: Colors.white)),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextButton(
                  onPressed: () => _selectEndDate(context),
                  child: Text(DateFormat('EEE, MMM d').format(_endDate)),
                ),
                if (!_isAllDay)
                  TextButton(
                    onPressed: () => _selectEndTime(context),
                    child: Text(DateFormat('hh:mm a').format(_endDate)),
                  ),
              ],
            ),
          ),
          const Divider(),
          ListTile(
            onTap: () => _openTagPicker(context),
            leading: Icon(CupertinoIcons.tag, color: color),
            title: Text(_tag, style: const TextStyle(color: Colors.white)),
            trailing: const Icon(CupertinoIcons.right_chevron),
          ),
          const Divider(),
          ListTile(
            onTap: () => _showNoteDrawer(context),
            leading: Icon(Icons.event_note, color: color),
            title: const Text("note", style: TextStyle(color: Colors.white)),
            trailing: _notes.isEmpty
                ? const Icon(CupertinoIcons.right_chevron)
                : IconButton(
                    onPressed: () => _noteController.clear(),
                    icon: const Icon(Icons.close)),
          ),
          _notes.isNotEmpty
              ? Padding(
                  padding: const EdgeInsets.all(8),
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade800),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Text(
                        _notes,
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                )
              : const SizedBox.shrink(),
        ],
      ),
    );
  }
}
