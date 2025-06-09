import 'package:flutter/material.dart';
import 'package:cheers_travel_app/models/airport.dart';
import 'package:cheers_travel_app/widgets/airport_input_field.dart';
import 'package:intl/intl.dart'; // For date formatting

enum TravelType {
  oneWay,
  roundTrip,
  multiCity,
}

class FlightSearchForm extends StatefulWidget {
  const FlightSearchForm({super.key});

  @override
  State<FlightSearchForm> createState() => _FlightSearchFormState();
}

class _FlightSearchFormState extends State<FlightSearchForm> {
  final _formKey = GlobalKey<FormState>();
  
  Airport? _fromAirport;
  Airport? _toAirport;
  TravelType _travelType = TravelType.roundTrip;
  DateTime? _departureDate;
  DateTime? _returnDate;
  int _adults = 1;
  int _children = 0;
  int _infants = 0;
  String _class = 'Economy';

  final GlobalKey<AirportInputFieldState> _fromAirportKey = GlobalKey();
  final GlobalKey<AirportInputFieldState> _toAirportKey = GlobalKey();

  // Helper for displaying dates
  String _formatDate(DateTime? date) {
    return date == null ? 'Select date' : DateFormat('dd/MM/yyyy').format(date);
  }

  // Helper for displaying passenger summary
  String get _passengerSummary {
    final passengers = <String>[];
    if (_adults > 0) {
      passengers.add('$_adults Adult');
    }
    if (_children > 0) {
      passengers.add('$_children Child');
    }
    if (_infants > 0) {
      passengers.add('$_infants Infant');
    }
    if (passengers.isEmpty) return 'Add passenger';
    return passengers.join(', ');
  }

  void _swapAirports() {
    setState(() {
      final tempAirport = _fromAirport;
      _fromAirport = _toAirport;
      _toAirport = tempAirport;

      // Also update the displayed text in the AirportInputFields directly
      _fromAirportKey.currentState?.setAirport(_fromAirport);
      _toAirportKey.currentState?.setAirport(_toAirport);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Travel Type Selection
          SegmentedButton<TravelType>(
            segments: const <ButtonSegment<TravelType>>[
              ButtonSegment<TravelType>(
                value: TravelType.roundTrip,
                label: Text('Round-Trip'),
                icon: Icon(Icons.loop),
              ),
              ButtonSegment<TravelType>(
                value: TravelType.oneWay,
                label: Text('One-Way'),
                icon: Icon(Icons.arrow_forward),
              ),
              ButtonSegment<TravelType>(
                value: TravelType.multiCity,
                label: Text('Multi-city'),
                icon: Icon(Icons.multiple_stop),
              ),
            ],
            selected: <TravelType>{_travelType},
            onSelectionChanged: (Set<TravelType> newSelection) {
              setState(() {
                _travelType = newSelection.first;
                if (_travelType == TravelType.oneWay) {
                  _returnDate = null;
                }
              });
            },
            style: ButtonStyle(
              backgroundColor: MaterialStateProperty.resolveWith<Color>(
                (Set<MaterialState> states) {
                  if (states.contains(MaterialState.selected)) {
                    return Theme.of(context).colorScheme.primary; // Selected color (should be blue)
                  }
                  return Theme.of(context).colorScheme.surfaceVariant; // Unselected color, slightly grey
                },
              ),
              foregroundColor: MaterialStateProperty.resolveWith<Color>(
                (Set<MaterialState> states) {
                  if (states.contains(MaterialState.selected)) {
                    return Colors.white; // Selected text color
                  }
                  return Theme.of(context).colorScheme.onSurface; // Unselected text color
                },
              ),
              shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              side: MaterialStateProperty.all<BorderSide>(BorderSide.none),
            ),
          ),
          const SizedBox(height: 16),

          // From Airport and To Airport with Swap Button
          Stack(
            children: [
              Column(
                children: [
                  AirportInputField(
                    key: _fromAirportKey,
                    labelText: 'From',
                    hintText: 'Enter departure city or airport',
                    icon: Icons.flight_takeoff,
                    initialAirport: _fromAirport,
                    onAirportSelected: (airport) {
                      setState(() {
                        _fromAirport = airport;
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  AirportInputField(
                    key: _toAirportKey,
                    labelText: 'To',
                    hintText: 'Enter arrival city or airport',
                    icon: Icons.flight_land,
                    initialAirport: _toAirport,
                    onAirportSelected: (airport) {
                      setState(() {
                        _toAirport = airport;
                      });
                    },
                  ),
                ],
              ),
              Positioned(
                right: 0,
                left: 0,
                top: 70, // Adjust position as needed
                child: CircleAvatar(
                  radius: 20,
                  backgroundColor: Theme.of(context).colorScheme.surface,
                  child: IconButton(
                    icon: Icon(Icons.swap_vert, color: Theme.of(context).colorScheme.primary),
                    onPressed: _swapAirports,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Date Pickers
          Row(
            children: [
              Expanded(
                child: _buildDatePickerField(
                  labelText: 'Departure',
                  date: _departureDate,
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: _departureDate ?? DateTime.now(),
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 365 * 2)), // 2 years from now
                    );
                    if (date != null) {
                      setState(() {
                        _departureDate = date;
                        if (_returnDate != null && _returnDate!.isBefore(_departureDate!)) {
                          _returnDate = null;
                        }
                      });
                    }
                  },
                ),
              ),
              if (_travelType == TravelType.roundTrip) ...[
                const SizedBox(width: 16),
                Expanded(
                  child: _buildDatePickerField(
                    labelText: 'Return',
                    date: _returnDate,
                    onTap: () async {
                      final date = await showDatePicker(
                        context: context,
                        initialDate: _returnDate ?? _departureDate ?? DateTime.now(),
                        firstDate: _departureDate ?? DateTime.now(),
                        lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
                      );
                      if (date != null) {
                        setState(() => _returnDate = date);
                      }
                    },
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 16),

          // Consolidated Passenger Selection
          InkWell(
            onTap: () async {
              await showModalBottomSheet(
                context: context,
                builder: (BuildContext context) {
                  return StatefulBuilder(
                    builder: (BuildContext context, StateSetter modalSetState) {
                      return Container(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Select Passengers',
                              style: Theme.of(context).textTheme.headlineSmall,
                            ),
                            const SizedBox(height: 16),
                            _buildPassengerSelector(
                              'Adults',
                              _adults,
                              (count) => modalSetState(() => _adults = count),
                              min: 1,
                            ),
                            _buildPassengerSelector(
                              'Children',
                              _children,
                              (count) => modalSetState(() => _children = count),
                            ),
                            _buildPassengerSelector(
                              'Infants',
                              _infants,
                              (count) => modalSetState(() => _infants = count),
                            ),
                            const SizedBox(height: 24),
                            ElevatedButton(
                              onPressed: () {
                                setState(() {}); // Update main form state
                                Navigator.pop(context);
                              },
                              child: const Text('Done'),
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
              );
            },
            child: InputDecorator(
              decoration: InputDecoration(
                labelText: 'Add passenger',
                prefixIcon: const Icon(Icons.person_outline),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              ),
              child: Row(
                children: [
                  Icon(Icons.person, size: 20, color: Theme.of(context).colorScheme.primary),
                  const SizedBox(width: 4),
                  Text('$_adults', style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(width: 8),
                  Icon(Icons.child_care, size: 20, color: Theme.of(context).colorScheme.primary),
                  const SizedBox(width: 4),
                  Text('$_children', style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(width: 8),
                  Icon(Icons.baby_changing_station, size: 20, color: Theme.of(context).colorScheme.primary),
                  const SizedBox(width: 4),
                  Text('$_infants', style: Theme.of(context).textTheme.titleMedium),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Class Selection
          DropdownButtonFormField<String>(
            value: _class,
            decoration: const InputDecoration(
              labelText: 'Class',
              prefixIcon: Icon(Icons.airline_seat_recline_normal),
            ),
            items: ['Economy', 'Business', 'First Class']
                .map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                })
                .toList(),
            onChanged: (String? newValue) {
              if (newValue != null) {
                setState(() => _class = newValue);
              }
            },
          ),
          const SizedBox(height: 24),

          // Search Button
          ElevatedButton(
            onPressed: () {
              if (_formKey.currentState!.validate()) {
                print('Searching flights...');
                print('From: ${_fromAirport?.airportCode}');
                print('To: ${_toAirport?.airportCode}');
                print('Travel Type: $_travelType');
                print('Departure Date: $_departureDate');
                print('Return Date: $_returnDate');
                print('Adults: $_adults');
                print('Children: $_children');
                print('Infants: $_infants');
                print('Class: $_class');
              }
            },
            child: const Padding(
              padding: EdgeInsets.symmetric(vertical: 16.0),
              child: Text(
                'Search Flights',
                style: TextStyle(fontSize: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDatePickerField({
    required String labelText,
    required DateTime? date,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          border: Border.all(color: Theme.of(context).colorScheme.outline),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              labelText,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                  ),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Expanded(
                  child: Text(
                    _formatDate(date),
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                Icon(
                  Icons.calendar_today,
                  color: Theme.of(context).colorScheme.primary,
                  size: 20,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPassengerSelector(
    String label,
    int count,
    ValueChanged<int> onChanged,
    {int min = 0}
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(label == 'Adults' ? Icons.person : (label == 'Children' ? Icons.child_care : Icons.baby_changing_station)),
          const SizedBox(width: 16),
          Text(label),
          const Spacer(),
          IconButton(
            icon: const Icon(Icons.remove_circle_outline),
            onPressed: () {
              if (count > min) {
                onChanged(count - 1);
              }
            },
          ),
          Text('$count', style: Theme.of(context).textTheme.titleMedium),
          IconButton(
            icon: const Icon(Icons.add_circle_outline),
            onPressed: () {
              onChanged(count + 1);
            },
          ),
        ],
      ),
    );
  }
} 