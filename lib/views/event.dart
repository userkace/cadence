import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:intl/intl.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:cadence/event_data.dart';


class Event extends StatelessWidget {
  final Map<String, dynamic> eventData;

  const Event({super.key, required this.eventData});

  @override
  Widget build(BuildContext context) {
    final coordinates = eventData['location'];
    // final coordinates = eventData['geo']?['geometry']?['coordinates'];
    final initialLocation = coordinates != null
        ? LatLng(coordinates[1], coordinates[0])
        : const LatLng(45.521563, -122.677433); // Default location

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: Navigator.of(context).pop,
          icon: const Icon(
              Icons.arrow_back_ios
          ),
        ),
        title: const Text(
            'Event Details',
            style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 24,
        ),
        ),
        centerTitle: true,
        scrolledUnderElevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 225, // Adjust the height as needed
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16.0),
                child: FlutterMap(
                  options: MapOptions(
                    initialCenter: initialLocation,
                    initialZoom: 15.0,
                  ),
                  children: [
                    TileLayer(
                      urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                      subdomains: const ['a', 'b', 'c'],
                    ),
                    MarkerLayer(
                      markers: [
                        Marker(
                          width: 80.0,
                          height: 80.0,
                          point: initialLocation,
                          // builder: (ctx) => const Icon(Icons.location_on, size: 40, color: Colors.red),
                          child: const Icon(CupertinoIcons.location_solid, size: 40, color: Colors.red),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              eventData['title'] ?? 'Event Details',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 24,
              ),
            ),
            const SizedBox(height: 16),
            Visibility(
              visible: eventData['entities'] != null &&
                  eventData['entities'].isNotEmpty &&
                  eventData['entities'][0]['name'] != null,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Venue', style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),),
                  // Check if entities list is not empty before accessing elements
                  if (eventData['entities'].isNotEmpty)
                    Text('${eventData['entities'][0]['name']}',
                        style: const TextStyle(
                          fontSize: 16,
                        )),
                  const SizedBox(height: 16),
                ],
              ),
            ),
            const Text('Address', style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),),
            Text('${eventData['geo']?['address']?['formatted_address'] ?? 'N/A'}',
                style: const TextStyle(
                  fontSize: 16,
                )),
            const SizedBox(height: 16),
            const Text('Date', style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),),
            Text(DateFormat('EEEE').format(DateTime.parse(eventData['start_local']))),
            Text(DateFormat('MMM d, yyyy').format(DateTime.parse(eventData['start_local'])),
                style: const TextStyle(
                  fontSize: 16,
                )),
            Text(DateFormat('h:mm a').format(DateTime.parse(eventData['start_local']))),

            // Add more fields as needed
            const SizedBox(height: 24), // Add some spacing

            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [

                  CupertinoButton(
                    onPressed: () {
                      Provider.of<EventData>(context, listen: false).saveEvent(eventData);
                      print('Save button pressed');
                    },
                    color: CupertinoColors.systemGrey,
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                        Icon(Icons.bookmark_add_rounded),
                          SizedBox(width: 10),
                        Text('Save')
                      ],)
                  ),
                  SizedBox(height: 8),
                  CupertinoButton(
                    onPressed: () {
                      Provider.of<EventData>(context, listen: false).purchaseEvent(eventData);
                      print('Save button pressed');
                    },
                    color: CupertinoColors.systemPink,
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                        Icon(Icons.add_shopping_cart_rounded),
                          SizedBox(width: 14),
                        Text('Buy')
                      ],)
                                    ),
              ],
            ),

          ],
        ),

      ),
    );
  }
}