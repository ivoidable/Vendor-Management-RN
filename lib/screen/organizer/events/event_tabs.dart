import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:latlong2/latlong.dart';
import 'package:nominatim_flutter/model/request/request.dart';
import 'package:nominatim_flutter/nominatim_flutter.dart';
import 'package:vendor/helper/database.dart';
import 'package:vendor/helper/helper_widgets.dart';
import 'package:vendor/main.dart';
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
        backgroundColor: Get.theme.colorScheme.primary,
        centerTitle: true,
        title: Text('Event: ${event.name}'),
        actions: [
          IconButton(
            icon: Icon(Icons.edit),
            onPressed: () {
              Get.to(EditEventScreen(event));
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

class MapController extends GetxController {
  List<Marker> markers;
  MapController(this.markers);


  void addMarker(LatLng point) {
    markers.clear();
    markers.add(
      Marker(point: point, child: const Icon(Icons.location_pin, color: Colors.red, size: 40),)
    );
  }

  Future<void> searchLocation(String query) async {
    try {
      final searchRequest = SearchRequest(
        query: query,
        limit: 5,
        addressDetails: true,
        extraTags: true,
        nameDetails: true,
      );
      final searchResult = await NominatimFlutter.instance.search(
        searchRequest: searchRequest,
        language: 'en-US,en;q=0.5',
      );
      if (!searchResult.isEmpty) {
        var newLocation = LatLng(
          double.parse(searchResult[0].lat!),
          double.parse(searchResult[0].lon!),
        );
        markers.clear();
        markers.add(
          Marker(
            point: newLocation,
            child: const Icon(Icons.location_pin, color: Colors.red, size: 40),
          ),
        );
      }
    } catch (e) {
      Get.snackbar("Error", "Location not found.");
    }
  }

  Future<List<String>> getSuggestions(String query) async {
    final searchRequest = SearchRequest(
      query: query,
      limit: 5,
      addressDetails: true,
      extraTags: true,
      nameDetails: true,
    );
    final searchResult = await NominatimFlutter.instance.search(
      searchRequest: searchRequest,
      language: 'en-US,en;q=0.5', // Specify the desired language(s) here
    );
    return searchResult.map((location) => location.displayName!).toList();
  }
}

class EventEditController extends GetxController {
  late Rx<Event> event;
  EventEditController(Event events) {
    event = Rx<Event>(events);
    questions.value = List.generate(event.value.questions.length, (index) => TextEditingController(text: event.value.questions[index].question));
    selectedTags.value = event.value.tags.map((tag) => tag.name).toList();
    selectedChip.value = event.value.isOneDay ? 0 : 1;
  }
  var selectedTags = <String>[].obs;

  var selectedChip = 0.obs;
  void selectChip(int index) {
    selectedChip.value = index; // Update the selected chip
  }

  void selectPub(int index) {
    event.value.publicity = Publicity.values[index];
  }

  var availableTags = Activity.values.map((str) => str.name).toList().obs;

  void toggleTag(String tag) {
    if (selectedTags.contains(tag)) {
      selectedTags.remove(tag);
    } else {
      selectedTags.add(tag);
    }
  }

  void setStartTime(TimeOfDay pickedTime, TimeOfDay endTimes) {
    event.value.startTime = pickedTime;
    event.value.endTime = endTimes;
    update();
  }

  void setStartDate(DateTime pickedDate) {
    event.value.startDate = pickedDate;
  }

  void setEndDate(DateTime pickedDate) {
    event.value.endDate = pickedDate;
  }

  var questions = <TextEditingController>[].obs;

  void addQuestion() {
    questions.add(TextEditingController());
  }

  void removeQuestion(int index) {
    questions.removeAt(index);
  }

  @override
  void onClose() {
    for (var controller in questions) {
      controller.dispose(); // Clean up controllers
    }
    super.onClose();
  }

  void updateEvent() {
    // Add questions
    event.value.questions = questions.map((controller) => Question(question: controller.text, answer: "")).toList();
    DatabaseService().updateEvent(event.value);
  }
}


class EditEventScreen extends StatelessWidget {
  Event event;
  EditEventScreen(this.event);

  final TextEditingController searchController = TextEditingController();
  late EventEditController controller;
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    controller = EventEditController(event);
    MapController mapController = Get.put(MapController([Marker(
      point: event.latlng,
      child: const Icon(Icons.location_pin, color: Colors.red, size: 40),
    )]));
        return Scaffold(
      appBar: AppBar(
        title: Text(
          "Schedule Event",
          style: TextStyle(color: Colors.blueGrey[700]),
        ),
        centerTitle: true,
        backgroundColor: Get.theme.colorScheme.primary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  height: Get.height * 0.13,
                ),
                SizedBox(
                  height: Get.height * 0.05,
                ),
                // ImagePicker that adds images from gallery to controller.images
                _buildTextField(
                  label: 'Event Name',
                  ini: controller.event.value.name,
                  onChanged: (value) => controller.event.value.name = value,
                  format: [],
                ),
                _buildTextField(
                  label: 'Description',
                  ini: controller.event.value.description,
                  onChanged: (value) => controller.event.value.description = value,
                  maxLines: 3,
                  format: [],
                ),
                _buildTextField(
                  label: 'Vendors Limit',
                  ini: controller.event.value.maxVendors.toString(),
                  keyboardType: TextInputType.number,
                  onChanged: (value) =>
                      controller.event.value.maxVendors = int.tryParse(value) ?? 0,
                  format: [FilteringTextInputFormatter.digitsOnly],
                ),
                _buildTextField(
                  label: 'Vendor Fee',
                  ini: controller.event.value.vendorFee.toString(),
                  keyboardType: TextInputType.number,
                  onChanged: (value) => controller.event.value.vendorFee =
                      double.tryParse(value) ?? 0.0,
                  format: [FilteringTextInputFormatter.digitsOnly],
                ),
                const SizedBox(height: 8),
                _buildMapSearch(mapController),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildMap(mapController),
                  ],
                ),
                Obx(() {
                  return Column(children: [
                    chipSelec(),
                  _buildStartDatePicker(context),
                  controller.selectedChip.value == 1
                      ? _buildEndDatePicker(context)
                      : Container(),
                    _buildTimeofDay(context)
                    ],);
                }),
                const SizedBox(
                  height: 12,
                ),
                pubSelection(),
                const SizedBox(
                  height: 12,
                ),

                Obx(
                  () => ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: controller.questions.length,
                    itemBuilder: (context, index) {
                      return Row(
                        children: [
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: TextFormField(
                                decoration: InputDecoration(
                                  labelText: 'Enter your question',
                                  focusColor: Get.theme.colorScheme.primary,
                                  labelStyle:
                                      const TextStyle(color: Colors.blueGrey),
                                  iconColor: Get.theme.colorScheme.primary,
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: const BorderSide(
                                      color: Colors.blueGrey,
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide(
                                      color: Get.theme.colorScheme.primary,
                                      width: 3,
                                    ),
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                controller: controller.questions[index],
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Question cannot be empty';
                                  }
                                  return null;
                                },
                              ),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () => controller.removeQuestion(index),
                          ),
                        ],
                      );
                    },
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        minimumSize: Size(Get.width / 2, Get.height * 0.05),
                        backgroundColor: Colors.blueGrey[700],
                        foregroundColor: Get.theme.colorScheme.primary,
                      ),
                      onPressed: controller.addQuestion,
                      icon: const Icon(Icons.add),
                      label: const Text('Add Question'),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                EventTagSelector(tagController: controller),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        minimumSize: Size(Get.width / 2, Get.height * 0.05),
                        backgroundColor: Get.theme.colorScheme.primary,
                        foregroundColor: Colors.blueGrey[700],
                      ),
                      onPressed: () async {
                        if (_formKey.currentState!.validate()) {
                          String uid = authController.uid;
                          List<Question> questions = controller.questions.value
                              .map((questionController) {
                            return Question(
                                question: questionController.text, answer: '');
                          }).toList();

                          if (mapController.markers.length == 0) {
                            Get.snackbar('Failed', 'Please choose event location',
                              backgroundColor: Colors.red[300]);
                            return;
                          }

                          

                          // DatabaseService().sendNotification(
                          //   [authController.appUser['fcm_token']],
                          //   'New Event',
                          //   'Accepted',
                          // );
                          var res = await DatabaseService().updateEvent(controller.event.value);
                          if (res) {
                            controller.dispose();
                          Get.back();
                          Get.snackbar('Success', 'Event Has Been Updated',
                              backgroundColor: Colors.lightGreen);
                          } else {
                            Get.snackbar('Failed', 'Failed To Update Event',
                                backgroundColor: Colors.red[300]);
                          }
                          
                        }
                      },
                      child: const Text('Update Event'),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 24,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMapSearch(MapController mapController) {
    return TypeAheadField<String>(
      textFieldConfiguration: TextFieldConfiguration(
        decoration: InputDecoration(
          labelText: 'Search Location...',
          focusColor: Get.theme.colorScheme.primary,
          labelStyle: const TextStyle(color: Colors.blueGrey),
          iconColor: Get.theme.colorScheme.primary,
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color: Get.theme.colorScheme.primary,
              width: 3,
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(
              color: Colors.blueGrey,
            ),
          ),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
      suggestionsCallback: (query) => mapController.getSuggestions(query),
      itemBuilder: (context, suggestion) => ListTile(
        title: Text(suggestion),
      ),
      onSuggestionSelected: (suggestion) {
        mapController.searchLocation(suggestion);
      },
    );
  }

  Widget _buildMap(MapController mapController) {
    return Container(
      height: Get.height * 0.3,
      width: Get.width * 0.9,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.grey,
        ),
      ),
      child: Obx(
        () => FlutterMap(
          options: MapOptions(
            initialCenter: controller.event.value.latlng,
            initialZoom: 13.0,
            onTap: (tapPosition, point) => mapController.addMarker(point),
          ),
          children: [
            TileLayer(
              urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
              subdomains: ['a', 'b', 'c'],
            ),
            MarkerLayer(markers: mapController.markers),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required Function(String) onChanged,
    String? ini,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
    required List<TextInputFormatter> format,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        decoration: InputDecoration(
          labelText: label,
          focusColor: Get.theme.colorScheme.primary,
          labelStyle: const TextStyle(color: Colors.blueGrey),
          iconColor: Get.theme.colorScheme.primary,
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color: Get.theme.colorScheme.primary,
              width: 3,
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(
              color: Colors.blueGrey,
            ),
          ),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
        keyboardType: keyboardType,
        maxLines: maxLines,
        initialValue: ini,
        inputFormatters: format,
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please enter $label';
          }
          return null;
        },
        onChanged: onChanged,
      ),
    );
  }

  Widget _buildStartDatePicker(BuildContext context) {
      return ListTile(
        title: Text(
          'Event Start Date: ${controller.event.value.startDate.toLocal().toIso8601String() + "at" + controller.event.value.startDate.toLocal().toIso8601String().split('T')[1].split('.')[0]}'
              .split('T')[0],
        ),
        trailing: const Icon(Icons.calendar_today),
        onTap: () async {
          
          // var picked = await showDateRangePicker(context: context, firstDate: DateTime.now(), lastDate: DateTime(DateTime.now().year + 1));

          DateTime? picked = await showDatePicker(
            context: context,
            initialDate: controller.event.value.startDate,
            firstDate: DateTime.now(),
            lastDate: DateTime(DateTime.now().year + 1),
          );
          if (picked != null) {
            controller.setStartDate(picked);
          }
        },
      );
  }

  Widget _buildTimeofDay(BuildContext context) {
      return ListTile(
        title: Obx(
          () => Text(
            'Event Duration: ${(controller.event.value.startTime.hour > 12 ? controller.event.value.startTime.hour - 12 : controller.event.value.startTime.hour).toString().padLeft(2, '0')}:${controller.event.value.startTime.minute.toString().padLeft(2, '0')} - ${(controller.event.value.endTime.hour > 12 ? controller.event.value.endTime.hour - 12 : controller.event.value.endTime.hour).toString().padLeft(2, '0')}:${controller.event.value.endTime.minute.toString().padLeft(2, '0')}',
          ),
        ),
        trailing: const Icon(Icons.schedule),
        onTap: () async {
          TimeOfDay? pickedTime = await showTimePicker(
            context: context,
            initialTime: controller.event.value.startTime,
          );
          if (pickedTime == null) {
            return;
          }

          TimeOfDay? pickedEndTime = await showTimePicker(
            context: context,
            initialTime: controller.event.value.endTime,
          );
          if (pickedEndTime != null) {
            controller.setStartTime(pickedTime, pickedEndTime);
          }
        },
      );
  }

  Widget _buildEndDatePicker(BuildContext context) {
      return ListTile(
        title: Text(
          'Event End Date: ${controller.event.value.endDate.toLocal().toIso8601String()}'
              .split('T')[0],
        ),
        trailing: const Icon(Icons.calendar_today),
        onTap: () async {
          DateTime? picked = await showDatePicker(
            context: context,
            initialDate: controller.event.value.endDate,
            firstDate: controller.event.value.startDate.add(const Duration(days: 1)),
            lastDate: DateTime(DateTime.now().year + 1),
          );
          if (picked != null) {
            controller.setEndDate(picked);
          }
        },
      );
  }

  // Widget _buildMaxVendorsSlider() {


  Widget chipSelec() {
    final List<String> options = ['One Day', 'Multiple Day'];
    return Wrap(
      spacing: 12.0,
      children: options.asMap().entries.map(
        (entry) {
          final int index = entry.key;
          final String label = entry.value;
          return Obx(
            () => ChoiceChip(
              label: Text(label),
              selected: controller.selectedChip.value == index,
              onSelected: (bool isSelected) {
                if (isSelected) controller.selectChip(index);
              },
              selectedColor: Get.theme.colorScheme.primary,
              backgroundColor: Colors.grey.shade200,
              labelStyle: TextStyle(
                color: controller.selectedChip.value == index
                    ? Colors.white
                    : Colors.black,
              ),
            ),
          );
        },
      ).toList(),
    );
  }

  Widget pubSelection() {
    final List<String> options = ['Public', 'Vendor Only', 'Private'];
    return Wrap(
      spacing: 12.0,
      children: options.asMap().entries.map(
        (entry) {
          final int index = entry.key;
          final String label = entry.value;
          return Obx(
            () => ChoiceChip(
              label: Text(label),
              selected: controller.event.value.publicity.index == index,
              onSelected: (bool isSelected) {
                if (isSelected) controller.selectPub(index);
              },
              selectedColor: Get.theme.colorScheme.primary,
              backgroundColor: Colors.grey.shade200,
              labelStyle: TextStyle(
                color: controller.event.value.publicity.index == index
                    ? Colors.white
                    : Colors.black,
              ),
            ),
          );
        },
      ).toList(),
    );
  }

  // return Obx(() {
  //   return Column(
  //     crossAxisAlignment: CrossAxisAlignment.start,
  //     children: [
  //       Text(
  //         'Max Vendors: ${controller.maxVendors.value}',
  //         style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
  //       ),
  //       RangeSlider(
  //         values: RangeValues(0, 500),
  //         min: 0,
  //         max: 500,
  //         divisions: 5,
  //         labels: RangeLabels(
  //           '0',
  //           controller.maxVendors.value.toString(),
  //         ),
  //         onChanged: (RangeValues values) {
  //           controller.maxVendors.value = values.end.toInt();
  //         },
  //       ),
  //     ],
  //   );
  // });
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
        backgroundColor: Get.theme.colorScheme.primary,
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
        backgroundColor: Get.theme.colorScheme.primary,
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
