=== lib/widgets/toolbar.dart ===

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';

class ChartToolbar extends StatelessWidget {
  const ChartToolbar({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppProvider>(
      builder: (context, provider, child) {
        return Container(
          height: 50,
          color: provider.isDarkMode ? const Color(0xFF16213e) : Colors.grey.shade100,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildToolButton(context, ToolMode.cursor, 'Cursor', Icons.mouse, provider),
                _buildToolButton(context, ToolMode.trend, 'Trend', Icons.trending_up, provider),
                _buildToolButton(context, ToolMode.hLine, 'H-Line', Icons.horizontal_rule, provider),
                _buildToolButton(context, ToolMode.vLine, 'V-Line', Icons.vertical_align_center, provider),
                _buildToolButton(context, ToolMode.box, 'Box', Icons.crop_square, provider),
                _buildToolButton(context, ToolMode.fib, 'Fib', Icons.show_chart, provider),
                const VerticalDivider(),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: provider.selectedDrawing != null ? () => provider.deleteSelectedDrawing() : null,
                  tooltip: 'Delete Selected',
                ),
                IconButton(
                  icon: const Icon(Icons.clear_all, color: Colors.orange),
                  onPressed: provider.drawings.isNotEmpty ? () => _confirmClear(context, provider) : null,
                  tooltip: 'Clear All',
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildToolButton(BuildContext context, ToolMode mode, String label, IconData icon, AppProvider provider) {
    final isSelected = provider.toolMode == mode;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Material(
        color: isSelected
            ? (provider.isDarkMode ? Colors.blue.shade700 : Colors.blue.shade100)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
        child: InkWell(
          onTap: () => provider.setToolMode(mode),
          borderRadius: BorderRadius.circular(8),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, size: 20, color: isSelected ? Colors.blue : null),
                Text(label, style: TextStyle(fontSize: 10, color: isSelected ? Colors.blue : null)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _confirmClear(BuildContext context, AppProvider provider) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Clear All Drawings?'),
        content: const Text('This will remove all drawings from the current chart.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              provider.clearAllDrawings();
              Navigator.pop(ctx);
            },
            child: const Text('Clear', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
