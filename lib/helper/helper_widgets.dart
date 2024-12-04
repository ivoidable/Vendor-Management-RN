import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:vendor/main.dart';
import 'package:vendor/model/event.dart';
import 'package:vendor/screen/organizer/events/event_tabs.dart';
import 'package:vendor/screen/organizer/events/view_event_screen.dart';


class EventCard extends StatelessWidget {
  final Event event;
  final VoidCallback? onTap;

  EventCard({required this.event, this.onTap});
  
  @override
  Widget build(BuildContext context) {
    String status = event.getStatus(authController.uid);
    return GestureDetector(
      onTap: () => onTap ?? Get.to(() => ViewEventScreen(event: event)),
      child: Container(
        height: Get.height * 0.3,
        width: Get.width * 0.88,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: Colors.grey[300],
          border: Border.all(
            color: Colors.grey[700]!,
            width: 2,
          ),
        ),
        child: Column(
          children: [
            Expanded(
              flex: 3,
              child: Stack(children: [
              ClipRRect(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(12),
                ),
                child: Image.network(event.images.first),
              ),
              Positioned(
                top: 8,
                left: 8,
                child: Container(
                  padding: const EdgeInsets.all(12.0),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: Colors.white,
                  ),
                  child: Text(DateFormat('d MMM').format(event.startDate)),
                  ),
                  )
                  ],),),
            Wrap(
              children: [Container(
                padding: EdgeInsets.all(8),
                child: Column(
                  children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Text(event.name, style: TextStyle(fontWeight: FontWeight.bold),),
                    Spacer(),
                    Text(status),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                  Text(event.startDate.hour.toString() + ":" + event.startDate.minute.toString() + " - " + event.endDate.hour.toString() + ":" + event.endDate.minute.toString()),
                  Spacer(),
                  Icon(Icons.location_on),
                  Text(event.location),
                ],),
                            ]),
              )]),
          ],
        ),
      ),
    );
  }
  

}


class EventTagSelector extends StatelessWidget {
  final EventEditController tagController;
  EventTagSelector({required this.tagController});

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
