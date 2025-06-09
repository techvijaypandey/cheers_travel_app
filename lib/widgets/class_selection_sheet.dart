import 'package:flutter/material.dart';

enum CabinClass {
  economy('Economy', 'Standard seating with essential amenities'),
  premiumEconomy('Premium Economy', 'More legroom and enhanced comfort'),
  business('Business', 'Priority service and premium amenities'),
  first('First', 'Luxury experience with exclusive services');

  final String title;
  final String description;
  const CabinClass(this.title, this.description);
}

class ClassSelectionSheet extends StatelessWidget {
  final CabinClass selectedClass;
  final Function(CabinClass) onClassSelected;

  const ClassSelectionSheet({
    super.key,
    required this.selectedClass,
    required this.onClassSelected,
  });

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
                'Select Cabin Class',
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
          ...CabinClass.values.map((cabinClass) => _buildClassOption(
                context,
                cabinClass,
                cabinClass == selectedClass,
              )),
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

  Widget _buildClassOption(
    BuildContext context,
    CabinClass cabinClass,
    bool isSelected,
  ) {
    return InkWell(
      onTap: () {
        onClassSelected(cabinClass);
        Navigator.pop(context);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          color: isSelected ? Theme.of(context).primaryColor.withOpacity(0.1) : null,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(
              isSelected ? Icons.check_circle : Icons.circle_outlined,
              color: isSelected ? Theme.of(context).primaryColor : Colors.grey,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    cabinClass.title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: isSelected ? Theme.of(context).primaryColor : null,
                    ),
                  ),
                  Text(
                    cabinClass.description,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
} 