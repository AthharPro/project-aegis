import 'package:flutter/material.dart';

class SeverityPage extends StatelessWidget {
  final int severity;
  final ValueChanged<int> onSeveritySelected;
  final VoidCallback onBack;

  const SeverityPage({
    super.key,
    required this.severity,
    required this.onSeveritySelected,
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
            'Severity Level',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 4),
          Text(
            'Select the severity of the incident',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Colors.grey[600],
                ),
          ),
          const SizedBox(height: 16),

          // Vertical Severity Tiles
          Expanded(
            child: ListView(
              physics: const NeverScrollableScrollPhysics(),
              children: [
                _buildSeverityTile(
                  level: 5,
                  label: 'Critical',
                  icon: Icons.warning,
                  color: Colors.red,
                ),
                const SizedBox(height: 10),
                _buildSeverityTile(
                  level: 4,
                  label: 'High',
                  icon: Icons.error_outline,
                  color: Colors.deepOrange,
                ),
                const SizedBox(height: 10),
                _buildSeverityTile(
                  level: 3,
                  label: 'Moderate',
                  icon: Icons.warning_amber,
                  color: Colors.orange,
                ),
                const SizedBox(height: 10),
                _buildSeverityTile(
                  level: 2,
                  label: 'Minor',
                  icon: Icons.info_outline,
                  color: Colors.lightGreen,
                ),
                const SizedBox(height: 10),
                _buildSeverityTile(
                  level: 1,
                  label: 'Low',
                  icon: Icons.check_circle_outline,
                  color: Colors.green,
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

  Widget _buildSeverityTile({
    required int level,
    required String label,
    required IconData icon,
    required Color color,
  }) {
    final isSelected = severity == level;

    return InkWell(
      onTap: () => onSeveritySelected(level),
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
                    label,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: isSelected ? color : Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Level $level',
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
