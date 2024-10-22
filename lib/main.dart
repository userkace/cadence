import 'dart:convert';
import 'package:cadence/views/filter.dart';
import 'package:cadence/views/profile.dart';
import 'package:flutter/services.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import './views/event.dart';
import 'package:flutter/cupertino.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import 'package:cadence/event_data.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => EventData(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Cadence',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Cadence'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<Map<String, dynamic>> _events = [];
  List<Map<String, dynamic>> _filteredEvents = [];
  List<String> _countries = [];

  @override
  void initState() {
    super.initState();
    _loadEvents();
    _getUniqueCountries();
  }

  void _getUniqueCountries() {
    setState(() {
      _countries = countryCodes.values.toList()
        ..sort(); // Use values from countryCodes map
    });
  }

  void _applyFilters(
      String? selectedCountry, DateTimeRange? selectedDateRange) {
    setState(() {
      _filteredEvents = _events.where((event) {
        final countryCode =
            event['geo']?['address']?['country_code'] as String?;
        final eventDate = DateTime.tryParse(event['start_local'] ?? '');

        final countryMatch = selectedCountry == null ||
            (countryCode != null &&
                countryCodes[countryCode] == selectedCountry);
        final dateMatch = selectedDateRange == null ||
            (eventDate != null &&
                eventDate.isAfter(selectedDateRange.start) &&
                eventDate.isBefore(selectedDateRange.end));

        return countryMatch && dateMatch;
      }).toList();
    });
  }

  Future<void> _loadEvents() async {
    try {
      final events = await _readJsonLines('assets/all.jsonl');
      events.sort((a, b) {
        final dateA = DateTime.tryParse(a['start_local'] ?? '');
        final dateB = DateTime.tryParse(b['start_local'] ?? '');
        return (dateA ?? DateTime(0)).compareTo(dateB ?? DateTime(0));
      });
      setState(() {
        _events = events;
        _filteredEvents = events;
      });
    } catch (e) {
      print('Error loading events: $e');
    }
  }

  Future<List<Map<String, dynamic>>> _readJsonLines(String url) async {
    final response = await rootBundle.loadString(url);
    try {
      final contents = await rootBundle.loadString(url);
      final lines = contents.split('\n');
      final jsonLines = lines
          .map((line) {
            try {
              return jsonDecode(line) as Map<String, dynamic>;
            } catch (e) {
              print('Error parsing JSON line: $e');
              return null;
            }
          })
          .whereType<Map<String, dynamic>>()
          .toList();
      return jsonLines;
    } catch (e) {
      throw Exception('Failed to load JSON Lines from asset: $url');
    }
  }

  static const Map<String, String> countryCodes = {
    'AE': 'United Arab Emirates',
    'PH': 'Philippines',
    'JP': 'Japan',
    'SG': 'Singapore',
  };

  void _filterEvents(String query) {
    setState(() {
      if (query.isEmpty) {
        // If search is empty, show all events (including those with null geo)
        _filteredEvents = _events;
      } else {
        // If search is not empty, apply filtering and sorting
        _filteredEvents = _events.where((event) {
          final title = event['title']?.toLowerCase() ?? '';
          final country =
              event['geo']?['address']?['country_code']?.toLowerCase() ?? '';
          final date = DateFormat('EEEE MMMM dd yyyy hh mm a')
                  .format(DateTime.parse(event['start_local']))
                  .toLowerCase() ??
              '';

          // Check if query is empty or if event matches search criteria and has geo data
          return query.isEmpty ||
              (title.contains(query.toLowerCase()) ||
                  country.contains(query.toLowerCase()) ||
                  date.contains(query.toLowerCase()));
        }).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          toolbarHeight: kToolbarHeight,
          backgroundColor: Theme.of(context).colorScheme.surface,
          title: Text(
            widget.title,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 32,
            ),
          ),
          scrolledUnderElevation: 0,
          actions: [
            IconButton(
                onPressed: () => {
                      showModalBottomSheet(
                        context: context,
                        builder: (context) => EventFilter(
                          onFilterChanged: _applyFilters,
                          initialCountries:
                              _countries, // Pass unique countries to filter
                        ),
                      )
                    },
                icon: const Icon(
                  Icons.filter_alt_rounded,
                  size: 30,
                )),
            IconButton(
                onPressed: () => {
                      Navigator.push(
                        context,
                        CupertinoPageRoute(
                            builder: (context) => const Profile()),
                      ),
                    },
                icon: const Icon(
                  Icons.account_circle_rounded,
                  size: 30,
                )),
          ],
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(64), // Adjust height as needed
            child: SearchBar(
              onSearch: _filterEvents,
            ),
          ),
        ),
        body: ListView.builder(
          itemCount: _filteredEvents.length, // Use filtered list length
          itemBuilder: (context, index) {
            final jsonLine = _filteredEvents[index];
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
        )
    );
  }
}

class SearchBar extends StatelessWidget {
  const SearchBar({super.key, required this.onSearch});

  final void Function(String) onSearch;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
      child: CupertinoSearchTextField(
        onChanged: onSearch, // Trigger callback on search query change
      ),
    );
  }
}
