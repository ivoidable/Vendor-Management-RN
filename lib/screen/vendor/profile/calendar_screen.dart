import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import 'package:vendor/helper/database.dart';
import 'package:vendor/main.dart';
import 'package:vendor/model/event.dart';

class VendorCalendarScreen extends StatelessWidget {
  List<Appointment> appointments = [];

  VendorCalendarScreen({super.key});

  Future<List<Event>> sheeshManWtf() async {
    var events = await DatabaseService().getAllEventsVendor();
    for (var event in events) {
      // Get days between start date and end date
      int days = event.endDate.difference(event.startDate).inDays + 1;
      appointments.add(Appointment(
          startTime: event.startDate,
          endTime: event.endDate,
          subject: event.name,
          color: Colors.green));
    }
    return events;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder(
        future: sheeshManWtf(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Text('${snapshot.error}'),
            );
          } else {
            return SfCalendar(
              view: CalendarView.month,
              dataSource: MeetingDataSource(appointments),
              // by default the month appointment display mode set as Indicator, we can
              // change the display mode as appointment using the appointment display
              // mode property
              monthViewSettings: const MonthViewSettings(
                  appointmentDisplayMode:
                      MonthAppointmentDisplayMode.appointment),
            );
          }
        },
      ),
    );
  }
}

class MeetingDataSource extends CalendarDataSource {
  /// Creates a meeting data source, which used to set the appointment
  /// collection to the calendar
  MeetingDataSource(List<Appointment> source) {
    appointments = source;
  }
}
