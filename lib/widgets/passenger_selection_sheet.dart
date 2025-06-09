import 'package:flutter/material.dart';

class PassengerSelectionSheet extends StatefulWidget {
  final int initialAdults;
  final int initialChildren;
  final int initialInfants;
  final Function(int adults, int children, int infants) onPassengersSelected;

  const PassengerSelectionSheet({
    super.key,
    this.initialAdults = 1,
    this.initialChildren = 0,
    this.initialInfants = 0,
    required this.onPassengersSelected,
  });

  @override
  State<PassengerSelectionSheet> createState() => _PassengerSelectionSheetState();
}

class _PassengerSelectionSheetState extends State<PassengerSelectionSheet> {
  late int _adults;
  late int _children;
  late int _infants;

  @override
  void initState() {
    super.initState();
    _adults = widget.initialAdults;
    _children = widget.initialChildren;
    _infants = widget.initialInfants;
  }

  int get _totalPassengers => _adults + _children + _infants;
  bool get _canAddPassenger => _totalPassengers < 9;
  bool get _canAddInfant => _infants < _adults;

  void _updatePassengers() {
    widget.onPassengersSelected(_adults, _children, _infants);
  }

  Widget _buildPassengerCounter({
    required String title,
    required String subtitle,
    required int value,
    required VoidCallback onIncrement,
    required VoidCallback onDecrement,
    required bool canIncrement,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          Row(
            children: [
              IconButton(
                onPressed: value > 0 ? onDecrement : null,
                icon: const Icon(Icons.remove_circle_outline),
                color: value > 0 ? Theme.of(context).primaryColor : Colors.grey,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12.0),
                child: Text(
                  value.toString(),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              IconButton(
                onPressed: canIncrement ? onIncrement : null,
                icon: const Icon(Icons.add_circle_outline),
                color: canIncrement ? Theme.of(context).primaryColor : Colors.grey,
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Select Passengers',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close),
              ),
            ],
          ),
          const Divider(),
          _buildPassengerCounter(
            title: 'Adults',
            subtitle: '12+ years',
            value: _adults,
            onIncrement: () {
              if (_canAddPassenger) {
                setState(() {
                  _adults++;
                  _updatePassengers();
                });
              }
            },
            onDecrement: () {
              if (_adults > 1) {
                setState(() {
                  _adults--;
                  _updatePassengers();
                });
              }
            },
            canIncrement: _canAddPassenger,
          ),
          _buildPassengerCounter(
            title: 'Children',
            subtitle: '2-11 years',
            value: _children,
            onIncrement: () {
              if (_canAddPassenger) {
                setState(() {
                  _children++;
                  _updatePassengers();
                });
              }
            },
            onDecrement: () {
              if (_children > 0) {
                setState(() {
                  _children--;
                  _updatePassengers();
                });
              }
            },
            canIncrement: _canAddPassenger,
          ),
          _buildPassengerCounter(
            title: 'Infants',
            subtitle: '0-2 years',
            value: _infants,
            onIncrement: () {
              if (_canAddPassenger && _canAddInfant) {
                setState(() {
                  _infants++;
                  _updatePassengers();
                });
              }
            },
            onDecrement: () {
              if (_infants > 0) {
                setState(() {
                  _infants--;
                  _updatePassengers();
                });
              }
            },
            canIncrement: _canAddPassenger && _canAddInfant,
          ),
          const SizedBox(height: 16),
          Text(
            'Maximum 9 passengers allowed',
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 12,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          if (!_canAddInfant && _infants < _adults)
            Text(
              'Number of infants cannot exceed number of adults',
              style: TextStyle(
                color: Colors.red[600],
                fontSize: 12,
              ),
              textAlign: TextAlign.center,
            ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('Done'),
          ),
        ],
      ),
    );
  }
} 