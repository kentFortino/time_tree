import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:linktree_clone/model/calendar_model.dart';
import 'package:linktree_clone/model/event_model.dart';

class CalendarProvider extends ChangeNotifier {
  CalendarProvider() {
    _getInitialData();
  }

  final _db = FirebaseFirestore.instance;
  final _user = FirebaseAuth.instance;
  CalendarModel? _calendar;

  CalendarModel? get calendar => _calendar;

  set setCalendar(CalendarModel calendar) {
    _calendar = calendar;
    notifyListeners();
  }

  final List<EventModel> _events = [];

  List<EventModel> get events => _events;

  bool _isLoading = false;

  bool get isLoading => _isLoading;

  String _errorMessage = "";

  String get errorMessage => _errorMessage;

  set _setErrorMessage(String errorMessage) {
    _errorMessage = errorMessage;
    notifyListeners();
  }

  set setLoading(bool val) {
    _isLoading = val;
    notifyListeners();
  }

  Future<void> _getInitialData() async {
    try {
      setLoading = true;

      // Fetch the user's calendar
      final calendarSnapshot = await _db
          .collection('calendars')
          .where("createdBy", isEqualTo: _user.currentUser!.uid)
          .get();

      if (calendarSnapshot.docs.isNotEmpty) {
        final calendarDoc = calendarSnapshot.docs.first;
        _calendar = CalendarModel.fromJson(calendarDoc.data());
        notifyListeners();

        // Fetch events associated with the calendar
        final eventSnapshot = await _db
            .collection('events')
            .where("calendarId", isEqualTo: _calendar!.id)
            .get();

        _events.clear();
        for (var doc in eventSnapshot.docs) {
          _events.add(EventModel.fromJson(doc.data()));
        }
        notifyListeners();
      }
    } catch (e) {
      _setErrorMessage = e.toString();
    } finally {
      setLoading = false;
    }
  }

  Future<void> addEvent(EventModel event) async {
    try {
      setLoading = true;
      event.id = _db.collection('events').doc().id;
      event.calendarId = _calendar?.id ?? "tidak ada";
      event.createdBy = _user.currentUser!.uid;
      await _db.collection('events').add(event.toJson());

      _events.add(event);
      notifyListeners();
    } catch (e) {
      _setErrorMessage = e.toString();
    } finally {
      setLoading = false;
    }
  }

  Future<void> editEvent(EventModel event) async {
    try {
      setLoading = true;

      // Query the document based on the id field
      QuerySnapshot querySnapshot =
          await _db.collection('events').where("id", isEqualTo: event.id).get();

      if (querySnapshot.docs.isNotEmpty) {
        // Get the document reference
        DocumentReference docRef = querySnapshot.docs.first.reference;

        // Update the document
        await docRef.update(event.toJson());

        // Update the event in the local list
        final index = _events.indexWhere((e) => e.id == event.id);
        if (index != -1) {
          _events[index] = event;
          notifyListeners();
        } else {
          _setErrorMessage = 'Event not found in the local list';
        }
      } else {
        _setErrorMessage = 'Event not found in Firestore';
      }
    } catch (e) {
      _setErrorMessage = e.toString();
    } finally {
      setLoading = false;
    }
  }

  Future<void> deleteEvent(String eventId) async {
    try {
      setLoading = true;
      await _db.collection('events').doc(eventId).delete();

      _events.removeWhere((e) => e.id == eventId);
      notifyListeners();
    } catch (e) {
      _setErrorMessage = e.toString();
    } finally {
      setLoading = false;
    }
  }
}
