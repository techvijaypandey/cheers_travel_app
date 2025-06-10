import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/flight_search_response.dart';

class FlightSearchService {
  static const String _baseUrl = 'http://newflightapi.cheerstravel.com.au/API';

  Future<FlightSearchResponse> searchFlights(Map<String, dynamic> searchParams) async {
    try {
      print('Sending search request with params: $searchParams'); // Debug log
      
      final response = await http.post(
        Uri.parse('$_baseUrl/Searchfare'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Access-Control-Allow-Origin': '*',
          'Access-Control-Allow-Methods': 'POST, GET, OPTIONS',
          'Access-Control-Allow-Headers': 'Origin, Content-Type, Accept',
        },
        body: jsonEncode(searchParams),
      );

      print('Response status code: ${response.statusCode}'); // Debug log
      print('Response body: ${response.body}'); // Debug log

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        print('Decoded JSON response: $jsonResponse'); // Debug log
        
        if (jsonResponse is Map<String, dynamic>) {
          // Check if the response contains an error
          if (jsonResponse.containsKey('error') || jsonResponse.containsKey('errorMessage')) {
            throw Exception(jsonResponse['error'] ?? jsonResponse['errorMessage'] ?? 'Unknown error occurred');
          }
          
          return FlightSearchResponse.fromJson(jsonResponse);
        } else {
          throw Exception('Invalid response format: Expected Map<String, dynamic> but got ${jsonResponse.runtimeType}');
        }
      } else if (response.statusCode == 401) {
        throw Exception('Authentication failed. Please check your credentials.');
      } else if (response.statusCode == 403) {
        throw Exception('Access forbidden. Please check your permissions.');
      } else if (response.statusCode == 404) {
        throw Exception('API endpoint not found.');
      } else if (response.statusCode == 500) {
        throw Exception('Server error occurred. Please try again later.');
      } else {
        throw Exception('Failed to search flights: ${response.statusCode} - ${response.body}');
      }
    } on FormatException catch (e) {
      print('JSON parsing error: $e'); // Debug log
      throw Exception('Invalid response format from server: $e');
    } on http.ClientException catch (e) {
      print('Network error: $e'); // Debug log
      throw Exception('Network error occurred: $e');
    } catch (e) {
      print('Error in searchFlights: $e'); // Debug log
      throw Exception('Failed to search flights: $e');
    }
  }
} 