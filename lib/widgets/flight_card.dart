import 'package:flutter/material.dart';
import '../models/flight_search_response.dart';

class FlightCard extends StatelessWidget {
  final FlightItinerary itinerary;
  final VoidCallback onSelect;

  const FlightCard({
    Key? key,
    required this.itinerary,
    required this.onSelect,
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
                  Text(
                    _getAirlineName(firstOutbound.airlineCode),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
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
                        Text(
                          lastOutbound.arrival.time,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
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
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Available Seats: ${firstOutbound.noSeats}',
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.green,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Fare Type: ${itinerary.fareType}',
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                  Text(
                    '${itinerary.fareInfo.baseFare.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
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
    
    // Calculate duration in minutes
    int departureMinutes = departureHour * 60 + departureMinute;
    int arrivalMinutes = arrivalHour * 60 + arrivalMinute;
    
    // Handle overnight flights
    if (arrivalMinutes < departureMinutes) {
      arrivalMinutes += 24 * 60; // Add 24 hours
    }
    
    final durationMinutes = arrivalMinutes - departureMinutes;
    final hours = durationMinutes ~/ 60;
    final minutes = durationMinutes % 60;
    
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