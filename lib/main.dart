import 'package:flutter/material.dart';
import 'package:cheers_travel_app/screens/home_screen.dart';
import 'package:cheers_travel_app/theme/app_theme.dart';
import 'package:cheers_travel_app/services/flight_search_service.dart';

void main() {
  runApp(const CheersTravelApp());
}

class CheersTravelApp extends StatelessWidget {
  const CheersTravelApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Cheers Travel',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      home: const HomeScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

// Test function to call the API
void testFlightSearch() async {
  final flightSearchService = FlightSearchService();
  try {
    final searchParams = {
      'fromAirport': 'MEL',
      'toAirport': 'NRT',
      'departureDate': DateTime(2024, 7, 2).toIso8601String(),
      'returnDate': DateTime(2024, 7, 9).toIso8601String(),
      'adults': 1,
      'children': 0,
      'infants': 0,
      'cabinClass': 'Y',
    };
    
    final response = await flightSearchService.searchFlights(searchParams);
    print('API Response: $response');
  } catch (e) {
    print('Error: $e');
  }
}
