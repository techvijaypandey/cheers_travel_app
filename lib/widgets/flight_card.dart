import 'package:flutter/material.dart';
import '../models/flight_search_response.dart';
import 'package:intl/intl.dart';
import '../screens/flight_details_screen.dart';

class FlightCard extends StatelessWidget {
  final FlightItinerary itinerary;
  final VoidCallback onSelect;
  final List<Airline> allAirlines;
  final List<Airport> allAirports;

  const FlightCard({
    Key? key,
    required this.itinerary,
    required this.onSelect,
    required this.allAirlines,
    required this.allAirports,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final outboundSegments = itinerary.sectors.outBound;
    if (outboundSegments.isEmpty) {
      return const SizedBox.shrink();
    }

    final firstOutbound = outboundSegments.first;
    final lastOutbound = outboundSegments.last;
    final totalDuration = _calculateTotalDuration(outboundSegments);

    final airline = allAirlines.firstWhere(
      (element) => element.airlineCode == firstOutbound.airlineCode,
      orElse: () => Airline(airlineCode: firstOutbound.airlineCode, airlineName: firstOutbound.airlineCode, airlineLogoPath: null),
    );

    final departureDate = DateFormat('dd-MM-yyyy').parse(firstOutbound.departure.date);
    final arrivalDate = DateFormat('dd-MM-yyyy').parse(lastOutbound.arrival.date);
    final isOvernight = arrivalDate.isAfter(departureDate);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: InkWell(
        onTap: onSelect,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Airline and Duration
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      if (airline.airlineLogoPath != null && airline.airlineLogoPath!.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: Image.network(
                            airline.airlineLogoPath!,
                            height: 24,
                            width: 24,
                            errorBuilder: (context, error, stackTrace) => const Icon(Icons.flight_takeoff, size: 24),
                          ),
                        ),
                      Text(
                        airline.airlineName,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  Text(
                    'Duration: $totalDuration',
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              
              // Flight Details
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          firstOutbound.departure.time,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          firstOutbound.departure.airportCode,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Column(
                      children: [
                        Container(
                          height: 1,
                          color: Colors.grey,
                        ),
                        const Icon(Icons.flight_takeoff, color: Colors.blue),
                        Container(
                          height: 1,
                          color: Colors.grey,
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Text(
                              lastOutbound.arrival.time,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            if (isOvernight)
                              const Text(
                                ' +1 day',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey,
                                ),
                              ),
                          ],
                        ),
                        Text(
                          lastOutbound.arrival.airportCode,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              
              const Divider(),
              
              // Fare and Availability
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: onSelect,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blueAccent,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      child: Text(
                        'AUD ${itinerary.fareInfo.baseFare.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  SizedBox(
                    width: 100,
                    child: OutlinedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => FlightDetailsScreen(
                              itinerary: itinerary,
                              allAirports: allAirports,
                              allAirlines: allAirlines,
                            ),
                          ),
                        );
                      },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.blueAccent,
                        side: const BorderSide(color: Colors.blueAccent),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      child: const Text(
                        'Details',
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _calculateTotalDuration(List<FlightSegment> segments) {
    if (segments.isEmpty) return 'N/A';
    
    final firstDeparture = segments.first.departure;
    final lastArrival = segments.last.arrival;
    
    // Parse the time strings (HH:mm format)
    final departureTimeParts = firstDeparture.time.split(':');
    final arrivalTimeParts = lastArrival.time.split(':');
    
    if (departureTimeParts.length != 2 || arrivalTimeParts.length != 2) {
      return 'N/A';
    }
    
    final departureHour = int.parse(departureTimeParts[0]);
    final departureMinute = int.parse(departureTimeParts[1]);
    final arrivalHour = int.parse(arrivalTimeParts[0]);
    final arrivalMinute = int.parse(arrivalTimeParts[1]);
    
    // Create DateTime objects with dummy dates to calculate duration correctly, especially for overnight flights
    DateTime departureDateTime = DateTime(2000, 1, 1, departureHour, departureMinute);
    DateTime arrivalDateTime = DateTime(2000, 1, 1, arrivalHour, arrivalMinute);

    if (arrivalDateTime.isBefore(departureDateTime)) {
      arrivalDateTime = arrivalDateTime.add(const Duration(days: 1)); // Add 24 hours for overnight flights
    }
    
    final duration = arrivalDateTime.difference(departureDateTime);
    
    final hours = duration.inHours;
    final minutes = duration.inMinutes % 60;
    
    return '${hours}h ${minutes}m';
  }

  String _getAirlineName(String code) {
    final airlines = {
      'AI': 'Air India',
      '6E': 'IndiGo',
      'SG': 'SpiceJet',
      'UK': 'Vistara',
      'G8': 'GoAir',
      '9W': 'Jet Airways',
      'AK': 'AirAsia',
      'I5': 'AirAsia India',
      'QP': 'Akasa Air',
    };
    return airlines[code] ?? code;
  }
} 