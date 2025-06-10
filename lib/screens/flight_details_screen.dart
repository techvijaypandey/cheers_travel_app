import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/flight_search_response.dart';

class FlightDetailsScreen extends StatelessWidget {
  final FlightItinerary itinerary;

  const FlightDetailsScreen({
    Key? key,
    required this.itinerary,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final totalFare = itinerary.fareInfo.baseFare + itinerary.fareInfo.taxes;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Flight Details'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeaderSummary(context),
            const SizedBox(height: 24),
            
            _buildSectionTitle('Fare Information'),
            _buildDetailRow('Fare Type', itinerary.fareType),
            _buildDetailRow('Refundable', itinerary.refundable ? 'Yes' : 'No'),
            _buildDetailRow('Base Fare', 'AUD ${itinerary.fareInfo.baseFare.toStringAsFixed(2)}'),
            _buildDetailRow('Taxes', 'AUD ${itinerary.fareInfo.taxes.toStringAsFixed(2)}'),
            
            const Divider(height: 32),

            _buildSectionTitle('Flight Segments'),
            ..._buildFlightSegments(itinerary.sectors.outBound, context),

            if (itinerary.sectors.inBound.isNotEmpty) ...[
              const Divider(height: 32),
              _buildSectionTitle('Return Journey'),
              ..._buildFlightSegments(itinerary.sectors.inBound, context),
            ],

            const SizedBox(height: 32),
            _buildCallToActionButton(context, totalFare),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderSummary(BuildContext context) {
    final firstOutbound = itinerary.sectors.outBound.first;
    final lastOutbound = itinerary.sectors.outBound.last;
    final String totalDuration = _calculateTotalDuration(itinerary.sectors.outBound);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '${firstOutbound.departure.airportCode} → ${lastOutbound.arrival.airportCode}',
          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        Text(
          DateFormat('EEE, MMM d, yyyy').format(
            DateFormat('dd-MM-yyyy').parse(firstOutbound.departure.date),
          ),
          style: const TextStyle(fontSize: 16, color: Colors.grey),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '${firstOutbound.airlineCode} Flight',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            Text(
              'Duration: $totalDuration',
              style: const TextStyle(fontSize: 14, color: Colors.grey),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Text(
        title,
        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.blueAccent),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
          Text(
            value,
            style: const TextStyle(fontSize: 16),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildFlightSegments(List<FlightSegment> segments, BuildContext context) {
    List<Widget> segmentWidgets = [];
    for (int i = 0; i < segments.length; i++) {
      final segment = segments[i];
      final isOvernight = _isOvernightFlight(segment);

      segmentWidgets.add(
        Card(
          margin: const EdgeInsets.symmetric(vertical: 8.0),
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${segment.airlineCode} ${segment.fltNum}',
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      'Duration: ${segment.elapsedTime}',
                      style: const TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            segment.departure.time,
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          Text(
                            '${segment.departure.airportCode} ${segment.departure.terminal}',
                            style: const TextStyle(fontSize: 14, color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Column(
                        children: [
                          Container(height: 1, color: Colors.grey),
                          const Icon(Icons.flight_takeoff, color: Colors.blue),
                          Container(height: 1, color: Colors.grey),
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
                                segment.arrival.time,
                                style: const TextStyle(
                                  fontSize: 18, 
                                  fontWeight: FontWeight.bold
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
                            '${segment.arrival.airportCode} ${segment.arrival.terminal}',
                            style: const TextStyle(fontSize: 14, color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const Divider(),
                _buildDetailRow('Aircraft Type', segment.equipType),
                _buildDetailRow('Baggage Allowance', segment.baggageInfo),
                if (segment.noSeats.isNotEmpty)
                  _buildDetailRow('Available Seats', segment.noSeats),
              ],
            ),
          ),
        ),
      );

      // Add layover information if there's a next segment in the same journey (outbound/inbound)
      if (i < segments.length - 1) {
        final currentSegmentArrivalDateTime = DateFormat('dd-MM-yyyy HH:mm').parse('${segment.arrival.date} ${segment.arrival.time}');
        final nextSegmentDepartureDateTime = DateFormat('dd-MM-yyyy HH:mm').parse('${segments[i + 1].departure.date} ${segments[i + 1].departure.time}');
        final layoverDuration = nextSegmentDepartureDateTime.difference(currentSegmentArrivalDateTime);

        final hours = layoverDuration.inHours;
        final minutes = layoverDuration.inMinutes % 60;
        final layoverText = 'Layover: ${hours}h ${minutes}m at ${segment.arrival.airportCode}';

        segmentWidgets.add(
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Row(
              children: [
                const Icon(Icons.access_time, size: 18, color: Colors.grey),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    layoverText,
                    style: const TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                ),
              ],
            ),
          ),
        );
      }
    }
    return segmentWidgets;
  }

  bool _isOvernightFlight(FlightSegment segment) {
    final departureDate = DateFormat('dd-MM-yyyy').parse(segment.departure.date);
    final arrivalDate = DateFormat('dd-MM-yyyy').parse(segment.arrival.date);
    return arrivalDate.isAfter(departureDate);
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

  Widget _buildCallToActionButton(BuildContext context, double totalFare) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: () {
          // TODO: Implement booking/selection logic
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Proceed to booking...')),
          );
        },
        icon: const Icon(Icons.check_circle_outline, color: Colors.white),
        label: Text(
          'Book Flight - AUD ${totalFare.toStringAsFixed(2)}',
          style: const TextStyle(fontSize: 20, color: Colors.white, fontWeight: FontWeight.bold),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blueAccent,
          padding: const EdgeInsets.symmetric(vertical: 16.0),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
        ),
      ),
    );
  }
} 