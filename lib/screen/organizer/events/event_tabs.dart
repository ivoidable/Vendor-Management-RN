import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:vendor/helper/database.dart';
import 'package:vendor/model/event.dart';
import 'package:vendor/model/user.dart';
import 'package:vendor/screen/organizer/events/view_application_screen.dart';

class ViewEventDetailsTab extends StatelessWidget {
  final Event event;

  ViewEventDetailsTab({required this.event});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.amber,
        centerTitle: true,
        title: Text('Event: ${event.name}'),
        actions: [
          IconButton(
            icon: Icon(Icons.edit),
            onPressed: () {
              Get.to(EditEventScreen(event: event));
            },
          ),
          IconButton(
            icon: Icon(Icons.delete),
            onPressed: () {
              DatabaseService().deleteEvent(event.id);
              Get.back();
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                height: 150,
                width: double.infinity,
                child: CarouselView(
                  itemExtent: 150,
                  children: [
                    for (var image in event.images)
                      Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: Image.network(
                          image,
                          width: 150,
                          height: 150,
                          fit: BoxFit.cover,
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(
                height: 24,
              ),
              Text(
                event.name,
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                event.description,
                style: const TextStyle(fontSize: 18),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Vendor Fee: \$${event.vendorFee.toStringAsFixed(2)}',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                  ),
                  Text(
                    'User Fee: \$${event.attendeeFee.toStringAsFixed(2)}',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text(
                    '${DateFormat.yMMMMd().add_jm().format(event.startDate)}',
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.w400),
                  ),
                  Text(
                    '${DateFormat.yMMMMd().add_jm().format(event.endDate)}',
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.w400),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class EventEditController extends GetxController {
  //TODO: Add location & Date Fields
  // The event to be edited, initialized through the constructor
  Rx<Event> event;

  EventEditController(this.event);

  // Method to update fields
  void updateName(String newName) => event.update((e) {
        if (e != null) e.name = newName;
      });

  void updateStartDate(DateTime newDate) => event.update((e) {
        if (e != null) e.startDate = newDate;
      });
  void updateEndDate(DateTime newDate) => event.update((e) {
        if (e != null) e.endDate = newDate;
      });
  // void updateLocation(String newLocation) => event.update((e) {
  //       if (e != null) e.location = newLocation;
  //     });
  void updateVendorFee(double newFee) => event.update((e) {
        if (e != null) e.vendorFee = newFee;
      });
  void updateAttendeeFee(double newFee) => event.update((e) {
        if (e != null) e.attendeeFee = newFee;
      });
  void updateDescription(String newDescription) => event.update((e) {
        if (e != null) e.description = newDescription;
      });

  void saveEvent() {
    DatabaseService().updateEvent(event.value);
  }
}

class EditEventScreen extends StatelessWidget {
  final Event event;
  EditEventScreen({required this.event});

  @override
  Widget build(BuildContext context) {
    EventEditController controller = Get.put(EventEditController(event.obs));
    return Scaffold(
      appBar: AppBar(title: Text('Edit Event')),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              decoration: InputDecoration(labelText: 'Event Name'),
              onChanged: controller.updateName,
              controller:
                  TextEditingController(text: controller.event.value.name),
            ),
            // TextField(
            //   decoration: InputDecoration(labelText: 'Location'),
            //   onChanged: controller.updateLocation,
            //   controller:
            //       TextEditingController(text: controller.event.value.location),
            // ),
            TextField(
              decoration: InputDecoration(labelText: 'Vendor Fee'),
              keyboardType: TextInputType.number,
              onChanged: (value) =>
                  controller.updateVendorFee(double.parse(value)),
              controller: TextEditingController(
                  text: controller.event.value.vendorFee.toString()),
            ),
            TextField(
              decoration: InputDecoration(labelText: 'Attendee Fee'),
              keyboardType: TextInputType.number,
              onChanged: (value) =>
                  controller.updateAttendeeFee(double.parse(value)),
              controller: TextEditingController(
                  text: controller.event.value.attendeeFee.toString()),
            ),
            TextField(
              decoration: InputDecoration(labelText: 'Description'),
              onChanged: controller.updateDescription,
              controller: TextEditingController(
                  text: controller.event.value.description),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => controller.saveEvent(),
              child: Text('Save Changes'),
            ),
          ],
        ),
      ),
    );
  }
}

class ApplicationCard extends StatelessWidget {
  final Application application;
  final VoidCallback onShowDetails;

  const ApplicationCard({
    Key? key,
    required this.application,
    required this.onShowDetails,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Color color;
    String status = "";
    if (application.approved.approved != null) {
      if (application.approved.approved == true) {
        color = Colors.lightGreen;
        status = "Approved";
      } else {
        color = Colors.red;
        status = "Rejected";
      }
    } else {
      color = const Color.fromARGB(255, 180, 211, 226);
      status = "Pending Review";
    }
    return GestureDetector(
      onTap: onShowDetails,
      child: Card(
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        child: Container(
          width: Get.width * .85,
          height: Get.height * 0.12,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: color,
          ),
          child: ListTile(
            leading: application.vendor.logoUrl.isNotEmpty
                ? Image.network(application.vendor.logoUrl, width: 50)
                : const Icon(Icons.business),
            title: Text(application.vendor.businessName),
            subtitle: Text(
              'Application Date: ${application.applicationDate.toLocal()}',
            ),
            trailing: Text(status),
          ),
        ),
      ),
    );
  }
}

class ViewApplicationsScreen extends StatelessWidget {
  final Event event;

  const ViewApplicationsScreen({required this.event});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Applications'),
        centerTitle: true,
        backgroundColor: Colors.amber,
      ),
      //TODO: FUCKING OPTIMIZE THIS SHIT MF
      body: FutureBuilder(
        future: DatabaseService().getApplicationsQuery(event.id),
        builder: (context, snapshot) {
          return Center(
            child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: DatabaseService().getApplicationsStream(event.id),
              initialData: snapshot.data,
              builder: (context, snapshot) {
                if (!snapshot.hasData)
                  return const Center(
                    child: Text("No applications"),
                  );
                List<Application> applications = snapshot.data!.docs.map((doc) {
                  return Application.fromMap(
                    doc.id,
                    doc.data(),
                  );
                }).toList();
                return Padding(
                  padding: EdgeInsets.all(24),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: Colors.grey[300],
                    ),
                    width: Get.width * 0.85,
                    height: Get.height * 0.85,
                    child: ListView.builder(
                      itemCount: applications.length,
                      itemBuilder: (context, index) {
                        final application = applications[index];
                        return ApplicationCard(
                          application: application,
                          onShowDetails: () async {
                            Approval? approval = await Get.to(
                                ViewApplicationScreen(
                                    application: application));
                            application.approved =
                                approval ?? Approval(approved: null);
                            if (approval != null) {
                              if (approval.approved!) {
                                print(application.toMap());
                                DatabaseService().registerVendorForEvent(
                                  event.id,
                                  application.vendorId,
                                  application.id,
                                );
                              } else if (!approval.approved!) {
                                DatabaseService().declineApplication(
                                  event.id,
                                  application.vendorId,
                                  application.id,
                                );
                              }
                            }
                          },
                        );
                      },
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}

class ViewRegisteredVendorsScreen extends StatelessWidget {
  final Event event;

  const ViewRegisteredVendorsScreen({required this.event});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Registered Vendors'),
        centerTitle: true,
        backgroundColor: Colors.amber,
      ),
      body: FutureBuilder(
        future: DatabaseService().getRegisteredVendorsQuery(event.id),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(child: Text("No Registered Vendors"));
          } else if (snapshot.hasError) {
            return Text(snapshot.error.toString());
          } else {
            List<Vendor> vendors = snapshot.data!;
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Container(
                  height: Get.height * 0.85,
                  width: Get.width * 0.85,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: Colors.grey[300],
                  ),
                  child: ListView.builder(
                    itemBuilder: (context, index) {
                      return RegisteredVendorCard(vendor: vendors[index]);
                    },
                    itemCount: snapshot.data!.length,
                  ),
                ),
              ),
            );
          }
        },
      ),
    );
  }
}

class RegisteredVendorCard extends StatelessWidget {
  final Vendor vendor;

  const RegisteredVendorCard({
    Key? key,
    required this.vendor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // if (application.approved.approved != null) {
    //   if (application.approved.approved == true) {
    //     color = Colors.lightGreen;
    //     status = "Approved";
    //   } else {
    //     color = Colors.red;
    //     status = "Rejected";
    //   }
    // } else {
    //   color = const Color.fromARGB(255, 180, 211, 226);
    //   status = "Pending Review";
    // }
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: Container(
        width: Get.width * .85,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: Colors.blueGrey[300],
        ),
        child: ListTile(
          leading: vendor.logoUrl.isNotEmpty
              ? CircleAvatar(
                  radius: 24,
                  backgroundImage: NetworkImage(vendor.logoUrl),
                )
              : const Icon(Icons.person, size: 36),
          title: Wrap(
            direction: Axis.horizontal,
            runAlignment: WrapAlignment.start,
            children: <Widget>[Text(vendor.businessName)],
          ),
          subtitle: Wrap(
            direction: Axis.horizontal,
            runAlignment: WrapAlignment.start,
            children: [
              Text(
                'By ${vendor.name}',
              )
            ],
          ),
          // trailing: RatingWidget(status),
        ),
      ),
    );
  }
}
