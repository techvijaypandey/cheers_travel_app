import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:cheers_travel_app/models/airport.dart';

class AirportService {
  static const String baseUrl = 'https://dbutility.cheerstravel.com.au';
  static const String websiteId = '1001';

  Future<List<Airport>> searchAirports(String query) async {
    if (query.isEmpty) return [];

    try {
      final response = await http.get(
        Uri.parse('$baseUrl/FlightAutoComplete/?code=$query&WebsiteID=$websiteId'),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        print('API Response data: $data'); // Debug log
        final List<Airport> airports = data.map((json) => Airport.fromJson(json)).toList();
        print('Parsed airports: ${airports.length}'); // Debug log
        return airports;
      } else {
        print('API Error: ${response.statusCode} - ${response.body}'); // Debug log
        throw Exception('Failed to load airports');
      }
    } catch (e) {
      print('Error searching airports: $e');
      return [];
    }
  }
} 