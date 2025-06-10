import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/flight_search_response.dart';

class FlightDetailsScreen extends StatelessWidget {
  final FlightItinerary itinerary;
  final List<Airport> allAirports;
  final List<Airline> allAirlines;

  const FlightDetailsScreen({
    Key? key,
    required this.itinerary,
    required this.allAirports,
    required this.allAirlines,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final totalFare = itinerary.fareInfo.baseFare + itinerary.fareInfo.taxes;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Flight Details'),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
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

                  if (itinerary.sectors.outBound.length > 1 || itinerary.sectors.inBound.length > 1) 
                    _buildInfoAlertBox(context, itinerary),
                  const SizedBox(height: 24),

                  _buildSectionTitle('Flight Segments'),
                  ..._buildFlightSegments(itinerary.sectors.outBound, context),

                  if (itinerary.sectors.inBound.isNotEmpty) ...[
                    const Divider(height: 32),
                    _buildSectionTitle('Return Journey'),
                    ..._buildFlightSegments(itinerary.sectors.inBound, context),
                  ],

                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
          // Sticky button at the bottom
          _buildCallToActionButton(context, totalFare),
        ],
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
        Padding(
          padding: const EdgeInsets.only(left: 16.0, right: 16.0, top: 16.0), // Increased top padding
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Timeline indicator
              SizedBox(
                width: 24, // Adjusted width for timeline
                child: Column(
                  children: [
                    CustomPaint(
                      painter: _TimelinePainter(
                        isFirst: i == 0,
                        isLast: i == segments.length - 1 && itinerary.sectors.inBound.isEmpty,
                        hasLayover: i < segments.length - 1,
                      ),
                      child: Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          color: Colors.blueAccent,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      DateFormat('EEE dd MMM').format(DateFormat('dd-MM-yyyy').parse(segment.departure.date)),
                      style: const TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                    Text(
                      segment.departure.time,
                      style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      '${_getAirportName(segment.departure.airportCode)}',
                      style: const TextStyle(fontSize: 16),
                    ),
                    if (segment.departure.terminal.isNotEmpty)
                      Text(
                        'Terminal: ${segment.departure.terminal}',
                        style: const TextStyle(fontSize: 14, color: Colors.grey),
                      ),
                    const SizedBox(height: 16),
                    Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _getAirlineName(segment.airlineCode),
                              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${segment.airlineCode}${segment.fltNum} | ${segment.equipType}',
                              style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Duration: ${segment.elapsedTime} | ${segment.cabinClass.name}',
                              style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                            ),
                            const SizedBox(height: 16),
                            _buildAmenitiesRow(context),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Text(
                          segment.arrival.time,
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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
                      '${_getAirportName(segment.arrival.airportCode)} ${segment.arrival.terminal}',
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 8),
                  ],
                ),
              ),
            ],
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
        final layoverText = 'Layover: ${hours}h ${minutes}m at ${_getAirportName(segment.arrival.airportCode)}';

        segmentWidgets.add(
          Padding(
            padding: const EdgeInsets.only(left: 40.0, bottom: 8.0), // Adjusted padding to align with timeline
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

  Widget _buildAmenitiesRow(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildAmenityItem(context, Icons.dinner_dining, 'Snack and refreshments'), // Changed icon to dinner_dining
        _buildAmenityItem(context, Icons.chair_alt, 'Standard reclining seat'), // Changed icon to chair_alt
        _buildAmenityItem(context, Icons.airline_seat_legroom_extra, '2-2 layout'), // Changed icon to airline_seat_legroom_extra
      ],
    );
  }

  Widget _buildAmenityItem(BuildContext context, IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Icon(icon, size: 18, color: Colors.grey[700]),
          const SizedBox(width: 8),
          Text(text, style: const TextStyle(fontSize: 14, color: Colors.grey)),
        ],
      ),
    );
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

  String _getAirportName(String airportCode) {
    final airport = allAirports.firstWhere(
      (element) => element.airportCode == airportCode,
      orElse: () => Airport(airportCode: airportCode, airportName: airportCode, cityCode: '', cityName: '', countryCode: '', countryName: ''),
    );
    return '${airport.cityName}, ${airport.airportName}';
  }

  String _getAirlineName(String airlineCode) {
    final airline = allAirlines.firstWhere(
      (element) => element.airlineCode == airlineCode,
      orElse: () => Airline(airlineCode: airlineCode, airlineName: airlineCode, airlineLogoPath: null),
    );
    return airline.airlineName;
  }

  Widget _buildInfoAlertBox(BuildContext context, FlightItinerary itinerary) {
    // Assuming the alert box is only for outbound connecting flights for now
    // You can extend this logic for inbound if needed
    final isConnectingOutbound = itinerary.sectors.outBound.length > 1;
    
    if (!isConnectingOutbound) return const SizedBox.shrink();

    final firstOutbound = itinerary.sectors.outBound.first;
    final lastOutbound = itinerary.sectors.outBound.last;
    final totalLayoverTime = _calculateTotalLayoverDuration(itinerary.sectors.outBound);

    String message = 'Your '
        '${_getAirportName(firstOutbound.departure.airportCode).split(',').first} - '
        '${_getAirportName(lastOutbound.arrival.airportCode).split(',').first} trip includes a stop in '
        '${_getAirportName(firstOutbound.arrival.airportCode).split(',').first} '
        'and a total layover time of $totalLayoverTime.';

    return Container(
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(8.0),
        border: Border.all(color: Colors.blue.shade200),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline, color: Colors.blue.shade800),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: TextStyle(color: Colors.blue.shade800, fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  String _calculateTotalLayoverDuration(List<FlightSegment> segments) {
    Duration totalDuration = Duration.zero;
    for (int i = 0; i < segments.length - 1; i++) {
      final currentSegmentArrivalDateTime = DateFormat('dd-MM-yyyy HH:mm').parse('${segments[i].arrival.date} ${segments[i].arrival.time}');
      final nextSegmentDepartureDateTime = DateFormat('dd-MM-yyyy HH:mm').parse('${segments[i + 1].departure.date} ${segments[i + 1].departure.time}');
      totalDuration += nextSegmentDepartureDateTime.difference(currentSegmentArrivalDateTime);
    }

    final hours = totalDuration.inHours;
    final minutes = totalDuration.inMinutes % 60;
    if (hours == 0 && minutes == 0) return 'N/A';
    return '${hours}h ${minutes}m';
  }
}

class _TimelinePainter extends CustomPainter {
  final bool isFirst;
  final bool isLast;
  final bool hasLayover;

  _TimelinePainter({
    required this.isFirst,
    required this.isLast,
    required this.hasLayover,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.grey[400]! // Lighter grey for the line
      ..strokeWidth = 2;

    const double dotRadius = 5.0;
    final dotCenterY = size.height / 2;

    // Draw the line above the dot
    if (!isFirst) {
      canvas.drawLine(
        Offset(size.width / 2, 0),
        Offset(size.width / 2, dotCenterY - dotRadius),
        paint,
      );
    }

    // Draw the dot
    canvas.drawCircle(
      Offset(size.width / 2, dotCenterY),
      dotRadius,
      Paint()..color = Colors.blueAccent,
    );

    // Draw the line below the dot
    if (!isLast) {
      canvas.drawLine(
        Offset(size.width / 2, dotCenterY + dotRadius),
        Offset(size.width / 2, size.height),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}