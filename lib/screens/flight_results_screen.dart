import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/flight_search_response.dart';
import '../widgets/flight_card.dart';

class FlightResultsScreen extends StatelessWidget {
  final FlightSearchResponse searchResults;

  const FlightResultsScreen({
    Key? key,
    required this.searchResults,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (searchResults.status.statusCode != "200") {
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
                  searchResults.status.message,
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

    if (searchResults.data.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Flight Search Results'),
        ),
        body: const Center(
          child: Padding(
            padding: EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.flight_takeoff,
                  color: Colors.grey,
                  size: 48,
                ),
                SizedBox(height: 16),
                Text(
                  'No flights found for your search criteria.',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 8),
                Text(
                  'Try adjusting your search parameters.',
                  style: TextStyle(
                    color: Colors.grey,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
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
          Container(
            padding: const EdgeInsets.all(16),
            color: Theme.of(context).primaryColor.withOpacity(0.1),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${searchResults.data.first.sectors.outBound.first.departure.airportCode} → ${searchResults.data.first.sectors.outBound.last.arrival.airportCode}',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  DateFormat('EEE, MMM d').format(
                    DateFormat('dd-MM-yyyy').parse(
                      searchResults.data.first.sectors.outBound.first.departure.date
                    )
                  ),
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
                  '${searchResults.data.length} flights',
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
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: searchResults.data.length,
              itemBuilder: (context, index) {
                final itinerary = searchResults.data[index];
                return FlightCard(
                  itinerary: itinerary,
                  onSelect: () {
                    // TODO: Handle flight selection
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
} 