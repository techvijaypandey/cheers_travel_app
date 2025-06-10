import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/flight_search_response.dart';
import '../widgets/flight_card.dart';
import '../services/flight_search_service.dart';

class FlightResultsScreen extends StatefulWidget {
  final FlightSearchResponse searchResults;

  const FlightResultsScreen({
    Key? key,
    required this.searchResults,
  }) : super(key: key);

  @override
  State<FlightResultsScreen> createState() => _FlightResultsScreenState();
}

class _FlightResultsScreenState extends State<FlightResultsScreen> {
  List<FlightItinerary> _directFlights = [];
  List<FlightItinerary> _connectingFlights = [];
  DateTime _selectedDate = DateTime.now();
  List<DateTime> _dateRange = [];
  Map<DateTime, double> _dateMinFares = {};
  bool _isLoadingFlights = false;

  @override
  void initState() {
    super.initState();
    // Parse the initial departure date from searchResults
    final initialDepartureDateString = widget.searchResults.flightFareSearchRQ.segments.first.date;
    _selectedDate = DateFormat('dd-MM-yyyy').parse(initialDepartureDateString);
    _generateDateRange();
    _categorizeFlights(widget.searchResults.data);
    _updateMinFareForDate(_selectedDate, widget.searchResults.data);
  }

  void _generateDateRange() {
    _dateRange.clear();
    // Generate dates 3 days before and 3 days after the selected date
    for (int i = -3; i <= 3; i++) {
      _dateRange.add(_selectedDate.add(Duration(days: i)));
    }
    // Sort the dates to ensure they are in chronological order
    _dateRange.sort((a, b) => a.compareTo(b));
  }

  void _categorizeFlights(List<FlightItinerary> itineraries) {
    _directFlights.clear();
    _connectingFlights.clear();
    for (var itinerary in itineraries) {
      if (itinerary.sectors.outBound.length == 1) {
        _directFlights.add(itinerary);
      } else {
        _connectingFlights.add(itinerary);
      }
    }
  }

  void _updateMinFareForDate(DateTime date, List<FlightItinerary> itineraries) {
    if (itineraries.isNotEmpty) {
      final minFare = itineraries.map((e) => e.fareInfo.baseFare).reduce((a, b) => a < b ? a : b);
      _dateMinFares[date] = minFare;
    }
  }

  Future<void> _searchFlightsByDate(DateTime newDate) async {
    setState(() {
      _isLoadingFlights = true;
      _selectedDate = newDate;
      _directFlights.clear();
      _connectingFlights.clear();
    });

    final searchService = FlightSearchService();
    final currentSearchParams = widget.searchResults.flightFareSearchRQ;

    // Create a new search parameters map, updating only the date
    final Map<String, dynamic> newSearchParams = {
      'searchId': currentSearchParams.searchId,
      'companyId': currentSearchParams.companyId,
      'branchId': currentSearchParams.branchId,
      'sourceMedia': currentSearchParams.sourceMedia,
      'customerType': currentSearchParams.customerType,
      'alternateAirport': currentSearchParams.alternateAirport,
      'journeyType': currentSearchParams.journeyType,
      'directFlight': currentSearchParams.directFlight,
      'flexi': currentSearchParams.flexi,
      'gds': currentSearchParams.gds,
      'flexiType': currentSearchParams.flexiType,
      'isBaggage': currentSearchParams.isBaggage,
      'currency': currentSearchParams.currency,
      'maxAmount': currentSearchParams.maxAmount,
      'cabinClass': currentSearchParams.cabinClass,
      'outboundClass': currentSearchParams.outboundClass,
      'inboundClass': currentSearchParams.inboundClass,
      'fareType': currentSearchParams.fareType,
      'availableFare': currentSearchParams.availableFare,
      'refundableFare': currentSearchParams.refundableFare,
      'preferedAirline': currentSearchParams.preferedAirline,
      'paxDetails': {
        'adults': currentSearchParams.paxDetails.adults,
        'youth': currentSearchParams.paxDetails.youth,
        'children': currentSearchParams.paxDetails.children,
        'infants': currentSearchParams.paxDetails.infants,
        'infantOnSeat': currentSearchParams.paxDetails.infantOnSeat,
      },
      'segments': currentSearchParams.segments.map((segment) {
        // Only update the date for the relevant segment
        if (segment.origin == currentSearchParams.segments.first.origin &&
            segment.destination == currentSearchParams.segments.first.destination) {
          return {
            'origin': segment.origin,
            'destination': segment.destination,
            'originType': segment.originType,
            'destinationType': segment.destinationType,
            'date': DateFormat('dd-MM-yyyy').format(newDate),
            'time': segment.time,
            'legs': segment.legs
          };
        } else {
          return {
            'origin': segment.origin,
            'destination': segment.destination,
            'originType': segment.originType,
            'destinationType': segment.destinationType,
            'date': segment.date, // Keep original date for return segment
            'time': segment.time,
            'legs': segment.legs
          };
        }
      }).toList(),
      'isCache': false,
      'continent': currentSearchParams.continent,
    };

    try {
      final newResults = await searchService.searchFlights(newSearchParams);
      if (mounted) {
        setState(() {
          _categorizeFlights(newResults.data);
          _updateMinFareForDate(newDate, newResults.data);
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error searching flights for ${DateFormat('EEE, MMM d').format(newDate)}: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingFlights = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.searchResults.status.statusCode != "200" && !_isLoadingFlights && _dateMinFares[_selectedDate] == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Flight Search Results'),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.error_outline,
                  color: Colors.red,
                  size: 48,
                ),
                const SizedBox(height: 16),
                Text(
                  widget.searchResults.status.message,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      );
    }

    // Initial state or when loading flights for a new date
    if (_isLoadingFlights || (_directFlights.isEmpty && _connectingFlights.isEmpty && !_isLoadingFlights && _dateMinFares[_selectedDate] == null)) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Flight Search Results'),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(),
              const SizedBox(height: 16),
              Text(_isLoadingFlights ? 'Searching for flights...' : 'No flights found for this date.'),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Flight Search Results'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () {
              // TODO: Implement filtering
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Date Selection Bar
          Container(
            height: 80,
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _dateRange.length,
              itemBuilder: (context, index) {
                final date = _dateRange[index];
                final isSelected = date.day == _selectedDate.day &&
                    date.month == _selectedDate.month &&
                    date.year == _selectedDate.year;
                final minFare = _dateMinFares[date];
                return GestureDetector(
                  onTap: () => _searchFlightsByDate(date),
                  child: Container(
                    width: 100,
                    margin: const EdgeInsets.symmetric(horizontal: 4.0),
                    decoration: BoxDecoration(
                      color: isSelected ? Theme.of(context).primaryColor : Colors.white,
                      borderRadius: BorderRadius.circular(8.0),
                      border: Border.all(
                        color: isSelected ? Theme.of(context).primaryColor : Colors.grey.shade300,
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          DateFormat('EEE').format(date),
                          style: TextStyle(
                            color: isSelected ? Colors.white : Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          DateFormat('MMM d').format(date),
                          style: TextStyle(
                            color: isSelected ? Colors.white : Colors.black,
                          ),
                        ),
                        Text(
                          minFare != null ? 'AUD ${minFare.toStringAsFixed(0)}' : 'AUD XXX', 
                          style: TextStyle(
                            color: isSelected ? Colors.white : Colors.grey,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            color: Theme.of(context).primaryColor.withOpacity(0.1),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${widget.searchResults.flightFareSearchRQ.segments.first.origin} → ${widget.searchResults.flightFareSearchRQ.segments.first.destination}',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  DateFormat('EEE, MMM d').format(_selectedDate),
                  style: TextStyle(
                    color: Theme.of(context).primaryColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${_directFlights.length + _connectingFlights.length} flights',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextButton.icon(
                  onPressed: () {
                    // TODO: Implement sorting
                  },
                  icon: const Icon(Icons.sort),
                  label: const Text('Sort'),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                if (_directFlights.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Text(
                      'Direct flights (${_directFlights.length})',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ...
                _directFlights.map((itinerary) {
                  return FlightCard(
                    itinerary: itinerary,
                    allAirlines: widget.searchResults.airlines,
                    allAirports: widget.searchResults.airports,
                    onSelect: () {
                      // TODO: Handle flight selection
                    },
                  );
                }).toList(),
                if (_connectingFlights.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Text(
                      'Connecting flights (${_connectingFlights.length})',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ...
                _connectingFlights.map((itinerary) {
                  return FlightCard(
                    itinerary: itinerary,
                    allAirlines: widget.searchResults.airlines,
                    allAirports: widget.searchResults.airports,
                    onSelect: () {
                      // TODO: Handle flight selection
                    },
                  );
                }).toList(),
              ],
            ),
          ),
        ],
      ),
    );
  }
} 