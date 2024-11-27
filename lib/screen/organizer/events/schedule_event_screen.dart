import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:latlong2/latlong.dart';
import 'package:nominatim_flutter/model/request/request.dart';
import 'package:nominatim_flutter/nominatim_flutter.dart';
import 'package:vendor/controller/organizer/create_event_controller.dart';
import 'package:vendor/helper/database.dart';
import 'package:vendor/main.dart';
import 'package:vendor/model/event.dart';

class MapController extends GetxController {
  var mapCenter =
      const LatLng(24.774265, 46.738586).obs; // Default to Riyadh
  var markers = <Marker>[].obs;

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
        mapCenter.value = newLocation;
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

class ScheduleEventScreen extends StatelessWidget {
  ScheduleEventScreen({super.key});

  final CreateEventController controller = CreateEventController();
  final TextEditingController searchController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    MapController mapController = Get.put(MapController());
        return Scaffold(
      appBar: AppBar(
        title: Text(
          "Schedule Event",
          style: TextStyle(color: Colors.blueGrey[700]),
        ),
        centerTitle: true,
        backgroundColor: Colors.amber,
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
                _buildImagePicker(),
                SizedBox(
                  height: Get.height * 0.05,
                ),
                // ImagePicker that adds images from gallery to controller.images
                _buildTextField(
                  label: 'Event Name',
                  onChanged: (value) => controller.name.value = value,
                  format: [],
                ),
                _buildTextField(
                  label: 'Description',
                  onChanged: (value) => controller.description.value = value,
                  maxLines: 3,
                  format: [],
                ),
                _buildTextField(
                  label: 'Vendors Limit',
                  keyboardType: TextInputType.number,
                  onChanged: (value) =>
                      controller.maxVendors.value = int.tryParse(value) ?? 0,
                  format: [FilteringTextInputFormatter.digitsOnly],
                ),
                _buildTextField(
                  label: 'Vendor Fee',
                  keyboardType: TextInputType.number,
                  onChanged: (value) => controller.vendorFee.value =
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
                                  focusColor: Colors.amber,
                                  labelStyle:
                                      const TextStyle(color: Colors.blueGrey),
                                  iconColor: Colors.amber,
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: const BorderSide(
                                      color: Colors.blueGrey,
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: const BorderSide(
                                      color: Colors.amber,
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
                        foregroundColor: Colors.amber,
                      ),
                      onPressed: controller.addQuestion,
                      icon: const Icon(Icons.add),
                      label: const Text('Add Question'),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                TagSelector(tagController: controller),
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
                        backgroundColor: Colors.amber,
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

                          Event event = Event(
                            id: '',
                            organizerId: uid,
                            organizerName: authController.appUser['name'],
                            name: controller.name.value,
                            startDate: controller.startDate.value,
                            endDate: controller.endDate.value,
                            startTime: controller.startTime.value,
                            endTime: controller.endTime.value,
                            latlng: mapController.markers[0].point,
                            vendorFee: controller.vendorFee.value,
                            attendeeFee: controller.userFee.value,
                            maxVendors: controller.maxVendors.value,
                            description: controller.description.value,
                            publicity: Publicity.values[controller.pub.value],
                            isOneDay: controller.selectedChip.value == 0
                                ? true
                                : false,
                            tags: controller.selectedTags.value
                                .map(
                                  (tag) => EventActivity.values
                                      .firstWhere((act) => act.name == tag),
                                )
                                .toList(),
                            
                            images: [],
                            location: '',
                            appliedVendorsId: [],
                            registeredVendorsId: [],
                            declinedVendorsId: [],
                            questions: questions,
                          );
                          var res = await DatabaseService().createEvent(event, controller.images.value);
                          if (res) {
                            controller.dispose();
                          Get.back();
                          Get.snackbar('Success', 'Event Has Been Scheduled',
                              backgroundColor: Colors.lightGreen);
                          } else {
                            Get.snackbar('Failed', 'Failed To Schedule Event',
                                backgroundColor: Colors.red[300]);
                          }
                          
                        }
                      },
                      child: const Text('Create Event'),
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
          focusColor: Colors.amber,
          labelStyle: const TextStyle(color: Colors.blueGrey),
          iconColor: Colors.amber,
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(
              color: Colors.amber,
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
            initialCenter: mapController.mapCenter.value,
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

  Widget _buildImagePicker() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              minimumSize: Size(Get.width / 2, Get.height * 0.05),
              backgroundColor: Colors.amber,
              foregroundColor: Colors.blueGrey[700],
            ),
            onPressed: () => controller.pickImage(ImageSource.gallery),
            icon: const Icon(Icons.add_a_photo),
            label: const Text('Add Image'),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required Function(String) onChanged,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
    required List<TextInputFormatter> format,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        decoration: InputDecoration(
          labelText: label,
          focusColor: Colors.amber,
          labelStyle: const TextStyle(color: Colors.blueGrey),
          iconColor: Colors.amber,
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(
              color: Colors.amber,
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
          'Event Start Date: ${controller.startDate.value.toLocal().toIso8601String() + "at" + controller.startDate.value.toLocal().toIso8601String().split('T')[1].split('.')[0]}'
              .split('T')[0],
        ),
        trailing: const Icon(Icons.calendar_today),
        onTap: () async {
          
          // var picked = await showDateRangePicker(context: context, firstDate: DateTime.now(), lastDate: DateTime(DateTime.now().year + 1));

          DateTime? picked = await showDatePicker(
            context: context,
            initialDate: DateTime.now(),
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
            'Event Duration: ${(controller.startTime.value.hour > 12 ? controller.startTime.value.hour - 12 : controller.startTime.value.hour).toString().padLeft(2, '0')}:${controller.startTime.value.minute.toString().padLeft(2, '0')} - ${(controller.endTime.value.hour > 12 ? controller.endTime.value.hour - 12 : controller.endTime.value.hour).toString().padLeft(2, '0')}:${controller.endTime.value.minute.toString().padLeft(2, '0')}',
          ),
        ),
        trailing: const Icon(Icons.schedule),
        onTap: () async {
          TimeOfDay? pickedTime = await showTimePicker(
            context: context,
            initialTime: TimeOfDay.now(),
          );
          if (pickedTime == null) {
            return;
          }

          TimeOfDay? pickedEndTime = await showTimePicker(
            context: context,
            initialTime: TimeOfDay(hour: pickedTime.hour > 12 ? pickedTime.hour - 12 : pickedTime.hour, minute: pickedTime.minute),
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
          'Event End Date: ${controller.endDate.value.toLocal().toIso8601String()}'
              .split('T')[0],
        ),
        trailing: const Icon(Icons.calendar_today),
        onTap: () async {
          DateTime? picked = await showDatePicker(
            context: context,
            initialDate: controller.endDate.value,
            firstDate: controller.startDate.value.add(const Duration(days: 1)),
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
              selectedColor: Colors.amber,
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
              selected: controller.pub.value == index,
              onSelected: (bool isSelected) {
                if (isSelected) controller.selectPub(index);
              },
              selectedColor: Colors.amber,
              backgroundColor: Colors.grey.shade200,
              labelStyle: TextStyle(
                color: controller.pub.value == index
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

class TagSelector extends StatelessWidget {
  final CreateEventController tagController;
  TagSelector({required this.tagController});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Flexible(
          fit: FlexFit.loose,
          child: Obx(
            () => Wrap(
              children: tagController.selectedTags
                  .map((tag) => Chip(
                        label: Text(tag),
                        deleteIcon: const Icon(Icons.cancel),
                        onDeleted: () => tagController.toggleTag(tag),
                      ))
                  .toList(),
            ),
          ),
        ),
        const SizedBox(height: 12),
        Flexible(
          fit: FlexFit.loose,
          child: DropdownButton<String>(
            hint: const Text("Select Activities"),
            items: tagController.availableTags.map((String tag) {
              return DropdownMenuItem<String>(
                value: tag,
                child: Obx(
                  () => Container(
                    width: Get.width * 0.6,
                    child: CheckboxListTile(
                      title: Text(tag),
                      value: tagController.selectedTags.contains(tag),
                      onChanged: (_) => tagController.toggleTag(tag),
                    ),
                  ),
                ),
              );
            }).toList(),
            onChanged: (_) {},
          ),
        ),
      ],
    );
  }
}
