import 'package:flutter/material.dart';

class VictimCountPage extends StatelessWidget {
  final String victimCountInput;
  final ValueChanged<String> onVictimCountSelected;
  final VoidCallback onBack;

  const VictimCountPage({
    super.key,
    required this.victimCountInput,
    required this.onVictimCountSelected,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Victim Count',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 4),
          Text(
            'Select the approximate number of victims',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[600],
                ),
          ),
          const SizedBox(height: 16),

          // Vertical Range Tiles
          Expanded(
            child: ListView(
              physics: const NeverScrollableScrollPhysics(),
              children: [
                _buildVictimRangeTile(
                  context,
                  range: '0-10',
                  value: 5,
                  icon: Icons.person,
                  color: Colors.green,
                ),
                const SizedBox(height: 10),
                _buildVictimRangeTile(
                  context,
                  range: '10-50',
                  value: 25,
                  icon: Icons.people,
                  color: Colors.orange,
                ),
                const SizedBox(height: 10),
                _buildVictimRangeTile(
                  context,
                  range: '50-100',
                  value: 75,
                  icon: Icons.groups,
                  color: Colors.deepOrange,
                ),
                const SizedBox(height: 10),
                _buildVictimRangeTile(
                  context,
                  range: '100+',
                  value: 105,
                  icon: Icons.group_add,
                  color: Colors.red,
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // Back Button
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: onBack,
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                side: BorderSide(color: Theme.of(context).primaryColor),
              ),
              child: const Text('BACK'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVictimRangeTile(
    BuildContext context, {
    required String range,
    required int value,
    required IconData icon,
    required Color color,
  }) {
    final isSelected = victimCountInput == value.toString();

    return InkWell(
      onTap: () => onVictimCountSelected(value.toString()),
      child: Container(
        padding: const EdgeInsets.all(11),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.15) : Colors.grey[100],
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? color : Colors.transparent,
            width: 3,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(7),
              decoration: BoxDecoration(
                color: color.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: color,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    range,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: isSelected ? color : Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Victims',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              Icon(
                Icons.check_circle,
                color: color,
                size: 20,
              ),
          ],
        ),
      ),
    );
  }
}
