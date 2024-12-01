import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vendor/model/user.dart';
import 'package:vendor/screen/organizer/events/event_tabs.dart';

class EventCard extends StatelessWidget {
  final String name;
  final List<String> images;
  final int vendors;
  final int maxVendors;
  final VoidCallback onClick;

  const EventCard({
    required this.name,
    required this.images,
    required this.vendors,
    required this.maxVendors,
    required this.onClick,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onClick,
      child: Card(
        shape: RoundedRectangleBorder(
          side: BorderSide(
            color: Get.theme.colorScheme.primary,
          ),
          borderRadius: BorderRadius.circular(12.0),
        ),
        margin: const EdgeInsets.symmetric(vertical: 8.0),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(12.0), bottom: Radius.circular(12.0)),
                child: Image.network(
                  images[0],
                  width: double.infinity,
                  height: 150,
                  fit: BoxFit.cover,
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(
                        fontSize: 20.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8.0),
                    Text(
                      'Vendors: $vendors / $maxVendors',
                      style: const TextStyle(fontSize: 16.0),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class VendorCard extends StatelessWidget {
  final Vendor vendor;
  final Function() onClick;

  const VendorCard({
    required this.vendor,
    required this.onClick,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onClick,
      child: Card(
        shape: RoundedRectangleBorder(
          side: BorderSide(
            color: Get.theme.colorScheme.primary,
          ),
          borderRadius: BorderRadius.circular(12.0),
        ),
        margin: const EdgeInsets.symmetric(vertical: 8.0),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(12.0), bottom: Radius.circular(12.0)),
                child: Image.network(
                  vendor.logoUrl,
                  width: double.infinity,
                  height: 150,
                  fit: BoxFit.cover,
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      vendor.businessName,
                      style: const TextStyle(
                        fontSize: 20.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8.0),
                    Text(
                      'By ${vendor.name}',
                      style: const TextStyle(fontSize: 16.0),
                    ),
                  ],
                ),
              ),
            ],
          ),
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
