import 'package:flutter/material.dart';
import 'package:cheers_travel_app/models/airport.dart';
import 'package:cheers_travel_app/widgets/airport_input_field.dart';
import 'package:intl/intl.dart'; // For date formatting
import 'package:cheers_travel_app/widgets/passenger_selection_sheet.dart';

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
  String get _passengerText {
    final total = _adults + _children + _infants;
    final parts = <String>[];
    if (_adults > 0) parts.add('$_adults Adult${_adults > 1 ? 's' : ''}');
    if (_children > 0) parts.add('$_children Child${_children > 1 ? 'ren' : ''}');
    if (_infants > 0) parts.add('$_infants Infant${_infants > 1 ? 's' : ''}');
    return parts.join(', ');
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

  void _showPassengerSelection() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => PassengerSelectionSheet(
        initialAdults: _adults,
        initialChildren: _children,
        initialInfants: _infants,
        onPassengersSelected: (adults, children, infants) {
          setState(() {
            _adults = adults;
            _children = children;
            _infants = infants;
          });
        },
      ),
    );
  }

  Widget _buildPassengerSelection() {
    return GestureDetector(
      onTap: _showPassengerSelection,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Row(
          children: [
            const Icon(Icons.people_outline, color: Colors.grey),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Passengers',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                  ),
                  Text(
                    _passengerText,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildTravelTypeSelector(),
          const SizedBox(height: 16),
          _buildAirportSelection(),
          const SizedBox(height: 16),
          _buildDateSelection(),
          const SizedBox(height: 16),
          _buildPassengerSelection(),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _onSearch,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('Search Flights'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTravelTypeSelector() {
    return SegmentedButton<TravelType>(
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
    );
  }

  Widget _buildAirportSelection() {
    return Stack(
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
    );
  }

  Widget _buildDateSelection() {
    return Row(
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

  void _onSearch() {
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
  }
} 