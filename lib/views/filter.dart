import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class EventFilter extends StatefulWidget {
  const EventFilter({
    super.key,
    required this.onFilterChanged,
    required this.initialCountries,
  });

  final void Function(
      String? selectedCountry, DateTimeRange? selectedDateRange)
  onFilterChanged;
  final List<String> initialCountries;

  @override
  State<EventFilter> createState() => _EventFilterState();
}

class _EventFilterState extends State<EventFilter> {
  String? _selectedCountry;
  DateTimeRange? _selectedDateRange;
  DateTime _startDate = DateTime.now();
  DateTime _endDate = DateTime.now().add(const Duration(days: 7));

  @override
  void initState() {
    super.initState();
    _selectedCountry = widget.initialCountries.isNotEmpty
        ? widget.initialCountries[0]
        : null;
  }

  void _handleCountryChange(String? value) {
    setState(() {
      _selectedCountry = value;
    });
    widget.onFilterChanged(_selectedCountry, _selectedDateRange);
  }

  void _handleDateRangeChange(DateTimeRange? newDateRange) {
    setState(() {
      _selectedDateRange = newDateRange;
    });
    widget.onFilterChanged(_selectedCountry, _selectedDateRange);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 46, vertical: 16),
          child: Column( // Use a Column to arrange widgets vertically
            children: [
              const Text('Country'), // Your Text widget
              CupertinoPicker(
                itemExtent: 32.0,
                onSelectedItemChanged: (int index) {
                  if (index == 0) {
                    _handleCountryChange(null);
                  } else {
                    _handleCountryChange(widget.initialCountries[index - 1]);
                  }
                },
                children: [
                  const Text('All'),
                  ...widget.initialCountries
                      .map((countryName) => Text(countryName))
                      .toList(),
                ],
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              const Text('Start Date'),
              SizedBox(
                height: 150, // Adjust height as needed
                child: CupertinoDatePicker(
                  mode: CupertinoDatePickerMode.date,
                  initialDateTime: _startDate,
                  onDateTimeChanged: (DateTime newDate) {
                    setState(() {
                      _startDate = newDate;
                      _handleDateRangeChange(DateTimeRange(start: _startDate, end: _endDate));
                    });
                  },
                ),
              ),
              const SizedBox(height: 16), // Add spacing between pickers
              const Text('End Date'),
              SizedBox(
                height: 150, // Adjust height as needed
                child: CupertinoDatePicker(
                  mode: CupertinoDatePickerMode.date,
                  initialDateTime: _endDate,
                  onDateTimeChanged: (DateTime newDate) {
                    setState(() {
                      _endDate = newDate;
                      _handleDateRangeChange(DateTimeRange(start: _startDate, end: _endDate));
                    });
                  },
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}