import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'dart:convert';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:core';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({Key? key}) : super(key: key);

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDate;

  Map<String, List> mySelectedEvents = {};
  final titleController = TextEditingController();
  final desController = TextEditingController();
  Future<void> scheduleNotifications() async {
    tz.initializeTimeZones();
    final now = DateTime.now();
    for (final dateStr in mySelectedEvents.keys) {
      final date = DateTime.parse(dateStr);
      for (final event in mySelectedEvents[dateStr]!) {
        final eventTime = tz.TZDateTime.from(date.add(const Duration(hours: 9)),
            tz.local); // set the time to 9am in local time zone
        if (eventTime.isAfter(now)) {
          // schedule the notification
          await FlutterLocalNotificationsPlugin().zonedSchedule(
            event.hashCode,
            event['eventTitle'] as String,
            event['eventDesc'] as String,
            eventTime,
            const NotificationDetails(
              android: AndroidNotificationDetails(
                'channel_id',
                'channel_name',
                importance: Importance.high,
              ),
            ),
            androidAllowWhileIdle: true,
            uiLocalNotificationDateInterpretation:
                UILocalNotificationDateInterpretation.absoluteTime,
            matchDateTimeComponents: DateTimeComponents.time,
          );
        }
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _selectedDate = _focusedDay;
    loadPreviousEvents();
    scheduleNotifications();
  }

  loadPreviousEvents() async {
    final prefs = await SharedPreferences.getInstance();
    final eventsString = prefs.getString('events');
    if (eventsString != null) {
      mySelectedEvents = Map<String, List>.from(jsonDecode(eventsString));
    } else {
      mySelectedEvents = {};
    }
  }

  _saveEvents() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('events', jsonEncode(mySelectedEvents));
  }

  List<dynamic> _listOfDayEvents(DateTime dateTime) {
    final events = mySelectedEvents[DateFormat('yyyy-MM-dd').format(dateTime)];
    return events ?? [];
  }

  void _deleteEvent(Map<String, dynamic> event) {
    setState(() {
      final events =
          mySelectedEvents[DateFormat('yyyy-MM-dd').format(_selectedDate!)];
      if (events != null) {
        events.remove(event);
        if (events.isEmpty) {
          mySelectedEvents
              .remove(DateFormat('yyyy-MM-dd').format(_selectedDate!));
        }
      }
      _saveEvents();
    });
  }

  _showAddEventsDialog() async {
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(
          'Adauga o noua activitate',
          textAlign: TextAlign.center,
        ),
        content: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              textCapitalization: TextCapitalization.words,
              decoration: const InputDecoration(labelText: 'Title'),
            ),
            TextField(
              controller: desController,
              textCapitalization: TextCapitalization.words,
              decoration: const InputDecoration(labelText: 'Description'),
            )
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
              child: const Text('Add Event'),
              onPressed: () {
                if (titleController.text.isEmpty &&
                    desController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Required title and description'),
                      duration: Duration(seconds: 2),
                    ),
                  );
                  return;
                } else {
                  if (kDebugMode) {
                    print(titleController.text);
                  }
                  if (kDebugMode) {
                    print(desController.text);
                    setState(() {
                      if (mySelectedEvents[DateFormat('yyyy-MM-dd')
                              .format(_selectedDate!)] !=
                          null) {
                        mySelectedEvents[
                                DateFormat('yyyy-MM-dd').format(_selectedDate!)]
                            ?.add({
                          "eventTitle": titleController.text,
                          "eventDescp": desController.text,
                        });
                      } else {
                        mySelectedEvents[
                            DateFormat('yyyy-MM-dd').format(_selectedDate!)] = [
                          {
                            "eventTitle": titleController.text,
                            "eventDescp": desController.text,
                          }
                        ];
                      }
                    });
                    _saveEvents();
                    titleController.clear();
                    desController.clear();
                    Navigator.pop(context);
                    return;
                  }
                }
              })
        ],
      ),
    );
  }

  HeaderStyle headerStyle = const HeaderStyle(
    titleTextStyle: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
  );
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Calendar Activitati'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            TableCalendar(
              headerStyle: headerStyle,
              firstDay: DateTime(2023),
              lastDay: DateTime(2024),
              focusedDay: _focusedDay,
              calendarFormat: _calendarFormat,
              onDaySelected: (selectedDay, focusedDay) {
                if (!isSameDay(_selectedDate, selectedDay)) {
                  // Call `setState()` when updating the selected day
                  setState(() {
                    _selectedDate = selectedDay;
                    _focusedDay = focusedDay;
                  });
                }
              },
              selectedDayPredicate: (day) {
                return isSameDay(_selectedDate, day);
              },
              onFormatChanged: (format) {
                if (_calendarFormat != format) {
                  // Call `setState()` when updating calendar format
                  setState(() {
                    _calendarFormat = format;
                    _focusedDay = _selectedDate!;
                  });
                }
              },
              onPageChanged: (focusedDay) {
                // No need to call `setState()` here
                _focusedDay = focusedDay;
              },
              eventLoader: _listOfDayEvents,
            ),
            ..._listOfDayEvents(_selectedDate!).map(
              (myEvents) => ListTile(
                leading: const Icon(
                  Icons.done,
                  color: Colors.redAccent,
                ),
                title: Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Text('Event Title:   ${myEvents['eventTitle']}'),
                ),
                subtitle: Text('Description:   ${myEvents['eventDesc']}'),
                trailing: IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () => _deleteEvent(myEvents),
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddEventsDialog(),
        label: const Text(
          'Adauga Activitate',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18.0,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.red,
      ),
    );
  }
}
