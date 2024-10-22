import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:intl/intl.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import 'package:cadence/event_data.dart';

import 'event.dart';

class PurchasedEventsScreen extends StatelessWidget {
  const PurchasedEventsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final eventData = Provider.of<EventData>(context);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: Navigator.of(context).pop,
          icon: const Icon(
              Icons.arrow_back_ios
          ),
        ),
        title: const Text('Purchased Events'),
        centerTitle: true,
      ),
      body: ListView.builder(
        itemCount: eventData.purchasedEvents.length, // Use filtered list length
        itemBuilder: (context, index) {
          final jsonLine = eventData.purchasedEvents[index];
          final venue =
          jsonLine['entities'] != null && jsonLine['entities'].isNotEmpty
              ? jsonLine['entities'][0]['name'] + ', '
              : '';
          final country =
          jsonLine['geo'] != null && jsonLine['geo']['address'] != null
              ? jsonLine['geo']['address']['country_code']
              : 'N/A';
          final date = jsonLine['start_local'] != null
              ? DateFormat('MMM d, yyyy h:mm a')
              .format(DateTime.parse(jsonLine['start_local']))
              : 'N/A';
          final coordinates = jsonLine['geo']?['geometry']?['coordinates'];
          final initialLocation =
          coordinates != null && coordinates.length == 2
              ? LatLng(coordinates[1], coordinates[0])
              : const LatLng(45.521563, -122.677433);

          return Padding(
            padding:
            const EdgeInsets.symmetric(horizontal: 12.0, vertical: 0),
            child: Card(
              shadowColor: Colors.transparent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16.0),
              ),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    SizedBox(
                      width: 60,
                      height: 60, // Adjust the height as needed
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16.0),
                        child: AbsorbPointer(
                          child: FlutterMap(
                            options: MapOptions(
                              initialCenter: initialLocation,
                              initialZoom: 18.0,
                            ),
                            children: [
                              TileLayer(
                                urlTemplate:
                                'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: ListTile(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  Event(eventData: jsonLine),
                            ),
                          );
                        },
                        title: Text(
                          jsonLine['title'] ?? 'N/A',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('$venue${countryCodes[country] ?? country}'),
                            Text('$date'),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
  static const Map<String, String> countryCodes = {
    'AE': 'United Arab Emirates',
    'PH': 'Philippines',
    'JP': 'Japan',
    'SG': 'Singapore',
  };
}