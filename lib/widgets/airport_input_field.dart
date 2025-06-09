import 'package:flutter/material.dart';
import 'package:cheers_travel_app/models/airport.dart';
import 'package:cheers_travel_app/screens/airport_selection_screen.dart';

class AirportInputField extends StatefulWidget {
  final String labelText;
  final String hintText;
  final IconData icon;
  final ValueChanged<Airport?> onAirportSelected;
  final Airport? initialAirport;

  const AirportInputField({
    super.key,
    required this.labelText,
    required this.hintText,
    required this.icon,
    required this.onAirportSelected,
    this.initialAirport,
  });

  @override
  State<AirportInputField> createState() => AirportInputFieldState();
}

class AirportInputFieldState extends State<AirportInputField> {
  Airport? _selectedAirport;

  @override
  void initState() {
    super.initState();
    _selectedAirport = widget.initialAirport;
  }

  // Method to allow parent to update the displayed airport (for swap functionality)
  void setAirport(Airport? airport) {
    setState(() {
      _selectedAirport = airport;
    });
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return InkWell(
      onTap: () async {
        final Airport? selectedAirport = await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const AirportSelectionScreen(),
          ),
        );
        if (selectedAirport != null) {
          setState(() {
            _selectedAirport = selectedAirport;
            widget.onAirportSelected(selectedAirport);
          });
        } else if (_selectedAirport != null && selectedAirport == null) {
          // If user navigates back without selecting, clear the current selection.
          setState(() {
            _selectedAirport = null;
            widget.onAirportSelected(null);
          });
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade400),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(widget.icon, color: Theme.of(context).colorScheme.primary),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.labelText,
                    style: textTheme.labelSmall?.copyWith(
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  if (_selectedAirport == null)
                    Text(
                      widget.hintText,
                      style: textTheme.titleMedium?.copyWith(
                        color: Colors.grey.shade500,
                      ),
                    ) 
                  else ...[
                    Text(
                      _selectedAirport!.cityName,
                      style: textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      _selectedAirport!.airportName,
                      style: textTheme.bodyMedium?.copyWith(color: Colors.grey.shade700),
                    ),
                  ],
                ],
              ),
            ),
            if (_selectedAirport != null)
              Text(
                _selectedAirport!.airportCode,
                style: textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.primary),
              ),
          ],
        ),
      ),
    );
  }
} 