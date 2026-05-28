=== lib/widgets/navigation_controls.dart ===

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';

class NavigationControls extends StatelessWidget {
  const NavigationControls({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppProvider>(
      builder: (context, provider, child) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          color: provider.isDarkMode ? const Color(0xFF0f3460) : Colors.grey.shade200,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Bar: ${provider.currentBarIndex + 1} / ${provider.totalBars}',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: provider.isDarkMode ? Colors.white70 : Colors.black87,
                ),
              ),
              Row(
                children: [
                  ElevatedButton.icon(
                    onPressed: provider.currentBarIndex > 0 ? provider.goToPreviousBar : null,
                    icon: const Icon(Icons.arrow_back_ios, size: 16),
                    label: const Text('PREV'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      textStyle: const TextStyle(fontSize: 12),
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton.icon(
                    onPressed: provider.currentBarIndex < provider.totalBars - 1 ? provider.goToNextBar : null,
                    icon: const Icon(Icons.arrow_forward_ios, size: 16),
                    label: const Text('NEXT'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      textStyle: const TextStyle(fontSize: 12),
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton.icon(
                    onPressed: provider.totalBars > 0 ? provider.goToLatest : null,
                    icon: const Icon(Icons.last_page, size: 16),
                    label: const Text('LATEST'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      textStyle: const TextStyle(fontSize: 12),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
