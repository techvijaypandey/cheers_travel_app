import 'package:flutter/material.dart';
import 'package:cheers_travel_app/models/airport.dart';
import 'package:cheers_travel_app/widgets/airport_input_field.dart';
import 'package:intl/intl.dart'; // For date formatting
import 'package:cheers_travel_app/widgets/passenger_selection_sheet.dart';
import 'package:cheers_travel_app/widgets/class_selection_sheet.dart';
import 'package:cheers_travel_app/services/flight_search_service.dart';
import 'package:cheers_travel_app/screens/flight_results_screen.dart';

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
  CabinClass _selectedClass = CabinClass.economy;

  final GlobalKey<AirportInputFieldState> _fromAirportKey = GlobalKey();
  final GlobalKey<AirportInputFieldState> _toAirportKey = GlobalKey();

  bool _isSearching = false;

  // Generate a unique search ID
  String _generateSearchId() {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final random = (timestamp % 1000000).toString().padLeft(6, '0');
    return '$timestamp$random';
  }

  // Generate cache key based on search parameters
  String _generateCacheKey() {
    final from = _fromAirport?.airportCode ?? '';
    final to = _toAirport?.airportCode ?? '';
    final depDate = _departureDate != null 
        ? '${_departureDate!.day.toString().padLeft(2, '0')}-${_departureDate!.month.toString().padLeft(2, '0')}-${_departureDate!.year}'
        : '';
    final retDate = _returnDate != null 
        ? '${_returnDate!.day.toString().padLeft(2, '0')}-${_returnDate!.month.toString().padLeft(2, '0')}-${_returnDate!.year}'
        : '';
    
    return 'T=${_travelType == TravelType.roundTrip ? "R" : "O"}|RT=$from|RTA=$to|F=$from|To=$to|Dt=$depDate|Dt1=$retDate|Adt=$_adults|chd=$_children|inf=$_infants|ins=0|Yth=0|Cl=${_selectedClass == CabinClass.economy ? "Y" : _selectedClass == CabinClass.premiumEconomy ? "W" : _selectedClass == CabinClass.business ? "C" : "F"}|ON=$from|DN=$to|OT=$from|DiT=$to|CCode=Cheers';
  }

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

  void _showClassSelection() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ClassSelectionSheet(
        selectedClass: _selectedClass,
        onClassSelected: (cabinClass) {
          setState(() {
            _selectedClass = cabinClass;
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

  Widget _buildClassSelection() {
    return GestureDetector(
      onTap: _showClassSelection,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Row(
          children: [
            const Icon(Icons.airline_seat_recline_normal, color: Colors.grey),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Cabin Class',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                  ),
                  Text(
                    _selectedClass.title,
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
    return Form(
      key: _formKey,
      child: Container(
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
            const SizedBox(height: 16),
            _buildClassSelection(),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isSearching ? null : _onSearch,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: _isSearching
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Text('Search Flights'),
              ),
            ),
          ],
        ),
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

  Future<void> _onSearch() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_fromAirport == null || _toAirport == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select both departure and arrival airports')),
      );
      return;
    }

    if (_departureDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a departure date')),
      );
      return;
    }

    if (_travelType == TravelType.roundTrip && _returnDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a return date')),
      );
      return;
    }

    setState(() {
      _isSearching = true;
    });

    try {
      final searchParams = {
        'searchId': _generateSearchId(),
        'companyId': 'Cheers',
        'branchId': _generateSearchId(),
        'sourceMedia': 'Cheers',
        'customerType': 'DIR',
        'alternateAirport': false,
        'journeyType': _travelType == TravelType.roundTrip ? 'R' : 'O',
        'directFlight': false,
        'flexi': false,
        'gds': '1A',
        'flexiType': false,
        'isBaggage': false,
        'currency': 'AUD',
        'maxAmount': 0.0,
        'cabinClass': _selectedClass == CabinClass.economy ? 'Y' : 
                     _selectedClass == CabinClass.premiumEconomy ? 'W' : 
                     _selectedClass == CabinClass.business ? 'C' : 'F',
        'outboundClass': '',
        'inboundClass': '',
        'fareType': '',
        'availableFare': false,
        'refundableFare': false,
        'preferedAirline': '',
        'paxDetails': {
          'adults': _adults,
          'youth': 0,
          'children': _children,
          'infants': _infants,
          'infantOnSeat': 0
        },
        'segments': [
          {
            'origin': _fromAirport!.airportCode,
            'destination': _toAirport!.airportCode,
            'originType': 'C',
            'destinationType': 'C',
            'date': DateFormat('dd-MM-yyyy').format(_departureDate!),
            'time': '',
            'legs': null
          }
        ],
        'isCache': false,
        'continent': null
      };

      // Add return segment for round trips
      if (_travelType == TravelType.roundTrip && _returnDate != null) {
        (searchParams['segments'] as List).add({
          'origin': _toAirport!.airportCode,
          'destination': _fromAirport!.airportCode,
          'originType': 'C',
          'destinationType': 'C',
          'date': DateFormat('dd-MM-yyyy').format(_returnDate!),
          'time': '',
          'legs': null
        });
      }

      final searchService = FlightSearchService();
      final results = await searchService.searchFlights(searchParams);

      if (!mounted) return;

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => FlightResultsScreen(searchResults: results),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error searching flights: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSearching = false;
        });
      }
    }
  }
} 