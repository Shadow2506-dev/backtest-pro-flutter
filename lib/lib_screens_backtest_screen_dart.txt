=== lib/screens/backtest_screen.dart ===

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../widgets/candlestick_chart.dart';
import '../widgets/toolbar.dart';
import '../widgets/navigation_controls.dart';
import '../widgets/trade_panel.dart';
import '../widgets/trade_journal.dart';
import '../widgets/bottom_actions.dart';

class BacktestScreen extends StatelessWidget {
  const BacktestScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppProvider>(
      builder: (context, provider, child) {
        return Scaffold(
          backgroundColor: provider.isDarkMode ? const Color(0xFF0a0a0a) : Colors.grey.shade50,
          appBar: AppBar(
            backgroundColor: provider.isDarkMode ? const Color(0xFF16213e) : Colors.blue.shade700,
            title: Row(
              children: [
                const Icon(Icons.candlestick_chart, color: Colors.white),
                const SizedBox(width: 8),
                Text(
                  provider.currentDataset?.tickerSymbol ?? 'Backtest Pro',
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                ),
                if (provider.currentDataset != null) ...[
                  const SizedBox(width: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.white24,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      provider.currentDataset!.assetType,
                      style: const TextStyle(fontSize: 11, color: Colors.white),
                    ),
                  ),
                ],
              ],
            ),
            actions: [
              if (provider.currentDataset != null)
                Padding(
                  padding: const EdgeInsets.only(right: 16),
                  child: Center(
                    child: Text(
                      provider.currentPrice.toStringAsFixed(5),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'monospace',
                      ),
                    ),
                  ),
                ),
            ],
          ),
          body: Column(
            children: [
              Expanded(
                flex: 3,
                child: Container(
                  margin: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: provider.isDarkMode ? Colors.white12 : Colors.black12,
                    ),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const CandlestickChart(),
                ),
              ),
              const ChartToolbar(),
              const NavigationControls(),
              const TradePanel(),
              if (provider.trades.isNotEmpty)
                const Expanded(
                  flex: 1,
                  child: TradeJournal(),
                ),
              const BottomActions(),
            ],
          ),
        );
      },
    );
  }
}
