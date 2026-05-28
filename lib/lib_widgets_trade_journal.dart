=== lib/widgets/trade_journal.dart ===

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../models/trade.dart';
import 'package:intl/intl.dart';

class TradeJournal extends StatelessWidget {
  const TradeJournal({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppProvider>(
      builder: (context, provider, child) {
        final closedTrades = provider.trades.where((t) => t.isClosed).toList().reversed.toList();

        if (closedTrades.isEmpty) {
          return Container(
            padding: const EdgeInsets.all(16),
            color: provider.isDarkMode ? const Color(0xFF1a1a2e) : Colors.white,
            child: const Center(child: Text('No trades yet', style: TextStyle(color: Colors.grey))),
          );
        }

        return Container(
          height: 150,
          color: provider.isDarkMode ? const Color(0xFF1a1a2e) : Colors.white,
          child: ListView.builder(
            itemCount: closedTrades.length,
            itemBuilder: (context, index) {
              final trade = closedTrades[index];
              final isWin = trade.isWin;

              return ListTile(
                dense: true,
                leading: Icon(
                  trade.direction == TradeDirection.buy ? Icons.arrow_upward : Icons.arrow_downward,
                  color: trade.direction == TradeDirection.buy ? Colors.green : Colors.red,
                  size: 20,
                ),
                title: Text(
                  '${trade.direction == TradeDirection.buy ? 'BUY' : 'SELL'} @ ${trade.entryPrice.toStringAsFixed(5)}',
                  style: TextStyle(fontSize: 13, color: provider.isDarkMode ? Colors.white : Colors.black87),
                ),
                subtitle: Text(
                  'Closed @ ${trade.exitPrice?.toStringAsFixed(5) ?? ''} | ${DateFormat('MM/dd HH:mm').format(trade.exitTime!)}',
                  style: TextStyle(fontSize: 11, color: provider.isDarkMode ? Colors.white54 : Colors.black54),
                ),
                trailing: Text(
                  '\$${trade.usdPnl?.toStringAsFixed(2) ?? '0.00'}',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: isWin ? Colors.green : Colors.red,
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}
