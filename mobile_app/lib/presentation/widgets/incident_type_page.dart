import 'package:flutter/material.dart';
import '../../data/models/incident_model.dart';

class IncidentTypePage extends StatelessWidget {
  final IncidentType? selectedType;
  final ValueChanged<IncidentType> onTypeSelected;

  const IncidentTypePage({
    super.key,
    required this.selectedType,
    required this.onTypeSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Select Incident Type',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 4),
          Text(
            'Choose the type of emergency you are reporting',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Colors.grey[600],
                ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: GridView.count(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                _buildIncidentTile(
                  context,
                  type: IncidentType.landslide,
                  icon: Icons.landscape,
                  label: 'Landslide',
                  color: Colors.brown,
                ),
                _buildIncidentTile(
                  context,
                  type: IncidentType.flood,
                  icon: Icons.water_damage,
                  label: 'Flood',
                  color: Colors.blue,
                ),
                _buildIncidentTile(
                  context,
                  type: IncidentType.roadBlock,
                  icon: Icons.block,
                  label: 'Road Block',
                  color: Colors.orange,
                ),
                _buildIncidentTile(
                  context,
                  type: IncidentType.powerLineDown,
                  icon: Icons.power_off,
                  label: 'Power Line Down',
                  color: Colors.red,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIncidentTile(
    BuildContext context, {
    required IncidentType type,
    required IconData icon,
    required String label,
    required Color color,
  }) {
    final isSelected = selectedType == type;

    return InkWell(
      onTap: () => onTypeSelected(type),
      child: Container(
        decoration: BoxDecoration(
          color: isSelected
              ? Theme.of(context).colorScheme.secondary.withOpacity(0.1)
              : Colors.grey[100],
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? Theme.of(context).colorScheme.secondary
                : Colors.transparent,
            width: 3,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 48,
              color: isSelected ? Theme.of(context).colorScheme.secondary : color,
            ),
            const SizedBox(height: 8),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                color: isSelected
                    ? Theme.of(context).colorScheme.secondary
                    : Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
