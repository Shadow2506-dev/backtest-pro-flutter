=== lib/widgets/bottom_actions.dart ===

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import 'load_csv_dialog.dart';
import 'datasets_dialog.dart';

class BottomActions extends StatelessWidget {
  const BottomActions({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppProvider>(
      builder: (context, provider, child) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          color: provider.isDarkMode ? const Color(0xFF0f3460) : Colors.grey.shade200,
          child: SafeArea(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  onPressed: () => showDialog(
                    context: context,
                    builder: (ctx) => const LoadCsvDialog(),
                  ),
                  icon: const Icon(Icons.upload_file, size: 18),
                  label: const Text('LOAD CSV'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: provider.datasets.isNotEmpty
                    ? () => showDialog(
                        context: context,
                        builder: (ctx) => const DatasetsDialog(),
                      )
                    : null,
                  icon: const Icon(Icons.folder_open, size: 18),
                  label: Text('DATASETS (${provider.datasets.length})'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: provider.toggleTheme,
                  icon: Icon(
                    provider.isDarkMode ? Icons.wb_sunny : Icons.nights_stay,
                    size: 18,
                  ),
                  label: Text(provider.isDarkMode ? 'DAY' : 'NIGHT'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
