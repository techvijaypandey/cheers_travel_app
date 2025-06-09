import 'package:flutter/material.dart';
import 'package:cheers_travel_app/models/airport.dart';
import 'package:cheers_travel_app/services/airport_service.dart';

class AirportSelectionScreen extends StatefulWidget {
  const AirportSelectionScreen({super.key});

  @override
  State<AirportSelectionScreen> createState() => _AirportSelectionScreenState();
}

class _AirportSelectionScreenState extends State<AirportSelectionScreen> {
  final AirportService _airportService = AirportService();

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Airport'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Autocomplete<Airport>(
            fieldViewBuilder: (
              BuildContext context,
              TextEditingController fieldTextEditingController,
              FocusNode fieldFocusNode,
              VoidCallback onFieldSubmitted,
            ) {
              return TextFormField(
                controller: fieldTextEditingController,
                focusNode: fieldFocusNode,
                decoration: const InputDecoration(
                  labelText: 'Search airport or city',
                  hintText: 'e.g., Sydney or SYD',
                  prefixIcon: Icon(Icons.search),
                  border: OutlineInputBorder(),
                ),
              );
            },
            optionsBuilder: (TextEditingValue textEditingValue) async {
              if (textEditingValue.text.isEmpty) {
                return const Iterable<Airport>.empty();
              }
              final results = await _airportService.searchAirports(textEditingValue.text);
              return results;
            },
            displayStringForOption: (Airport airport) => '${airport.cityName}, ${airport.airportName} (${airport.airportCode}), ${airport.countryName}',
            onSelected: (Airport airport) {
              Navigator.pop(context, airport);
            },
            optionsViewBuilder: (BuildContext context, AutocompleteOnSelected<Airport> onSelected, Iterable<Airport> options) {
              print('Options received in optionsViewBuilder: ${options.length}');
              print('First option if any: ${options.isNotEmpty ? options.first : "No options"}');
              return Material(
                  elevation: 4.0,
                  child: ListView.builder(
                      padding: EdgeInsets.zero,
                      itemCount: options.length,
                      itemBuilder: (BuildContext context, int index) {
                        final Airport option = options.elementAt(index);
                        print('Building list item for: ${option.airportName}');
                        return GestureDetector(
                          onTap: () {
                            onSelected(option);
                          },
                          child: ListTile(
                            title: Text(option.airportName),
                          ),
                        );
                      },
                    ),
                );
            },
          ),
        ),
      ),
    );
  }
} 