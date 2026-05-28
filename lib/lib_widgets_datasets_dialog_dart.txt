=== lib/widgets/datasets_dialog.dart ===

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';

class DatasetsDialog extends StatelessWidget {
  const DatasetsDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppProvider>(
      builder: (context, provider, child) {
        return AlertDialog(
          title: const Text('Datasets'),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: provider.datasets.length,
              itemBuilder: (context, index) {
                final dataset = provider.datasets[index];
                final isActive = provider.currentDataset?.id == dataset.id;

                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: isActive ? Colors.blue : Colors.grey,
                    child: Text(
                      dataset.assetType.substring(0, 1),
                      style: const TextStyle(color: Colors.white, fontSize: 12),
                    ),
                  ),
                  title: Text(
                    dataset.name,
                    style: TextStyle(
                      fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                  subtitle: Text('${dataset.candles.length} bars | ${dataset.assetType}'),
                  trailing: isActive
                    ? const Icon(Icons.check_circle, color: Colors.green)
                    : null,
                  onTap: () {
                    provider.switchDataset(dataset.id);
                    Navigator.pop(context);
                  },
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }
}
