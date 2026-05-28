=== lib/widgets/trade_panel.dart ===

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../models/trade.dart';

class TradePanel extends StatelessWidget {
  const TradePanel({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppProvider>(
      builder: (context, provider, child) {
        final stats = provider.tradeStats;
        final openTrade = provider.openTrade;
        final currentPrice = provider.currentPrice;

        return Container(
          padding: const EdgeInsets.all(12),
          color: provider.isDarkMode ? const Color(0xFF16213e) : Colors.grey.shade100,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: openTrade == null ? () => provider.openTrade(TradeDirection.buy, 0.1) : null,
                      icon: const Icon(Icons.trending_up, color: Colors.white),
                      label: const Text('BUY', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green.shade600,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: openTrade == null ? () => provider.openTrade(TradeDirection.sell, 0.1) : null,
                      icon: const Icon(Icons.trending_down, color: Colors.white),
                      label: const Text('SELL', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red.shade600,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: openTrade != null ? provider.closeTrade : null,
                      icon: const Icon(Icons.close, color: Colors.white),
                      label: const Text('CLOSE', style: TextStyle(color: Colors.white)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange.shade600,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: provider.isDarkMode ? const Color(0xFF1a1a2e) : Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: provider.isDarkMode ? Colors.white12 : Colors.black12),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildStat('Total P&L', '\$${stats.totalPnl.toStringAsFixed(2)}',
                          stats.totalPnl >= 0 ? Colors.green : Colors.red, provider),
                        _buildStat('Win Rate', '${stats.winRate.toStringAsFixed(1)}%',
                          Colors.blue, provider),
                        _buildStat('Trades', '${stats.totalTrades}',
                          Colors.grey, provider),
                      ],
                    ),
                    if (openTrade != null) ...[
                      const Divider(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            openTrade.direction == TradeDirection.buy ? Icons.arrow_upward : Icons.arrow_downward,
                            color: openTrade.direction == TradeDirection.buy ? Colors.green : Colors.red,
                            size: 16,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Open: ${openTrade.entryPrice.toStringAsFixed(5)} | Current: ${currentPrice.toStringAsFixed(5)} | P&L: \$${provider.openPnl.toStringAsFixed(2)}',
                            style: TextStyle(
                              fontSize: 12,
                              color: provider.openPnl >= 0 ? Colors.green : Colors.red,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStat(String label, String value, Color valueColor, AppProvider provider) {
    return Column(
      children: [
        Text(label, style: TextStyle(fontSize: 11, color: provider.isDarkMode ? Colors.white54 : Colors.black54)),
        const SizedBox(height: 2),
        Text(value, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: valueColor)),
      ],
    );
  }
}
