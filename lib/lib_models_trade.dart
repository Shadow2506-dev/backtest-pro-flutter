=== lib/models/trade.dart ===

enum TradeDirection { buy, sell }

class Trade {
  final String id;
  final TradeDirection direction;
  final double entryPrice;
  final double? exitPrice;
  final DateTime entryTime;
  final DateTime? exitTime;
  final double lots;
  final double? pips;
  final double? usdPnl;

  Trade({
    required this.id,
    required this.direction,
    required this.entryPrice,
    this.exitPrice,
    required this.entryTime,
    this.exitTime,
    required this.lots,
    this.pips,
    this.usdPnl,
  });

  bool get isOpen => exitPrice == null;
  bool get isClosed => exitPrice != null;
  bool get isWin => (usdPnl ?? 0) > 0;

  double calculatePips(double currentPrice) {
    if (direction == TradeDirection.buy) {
      return currentPrice - entryPrice;
    } else {
      return entryPrice - currentPrice;
    }
  }

  double calculatePnl(double currentPrice) {
    double pipValue = lots * 10;
    return calculatePips(currentPrice) * 10000 * pipValue;
  }

  Trade close(double price, DateTime time) {
    double finalPips = direction == TradeDirection.buy
        ? price - entryPrice
        : entryPrice - price;
    double pipValue = lots * 10;
    double finalPnl = finalPips * 10000 * pipValue;

    return Trade(
      id: id,
      direction: direction,
      entryPrice: entryPrice,
      exitPrice: price,
      entryTime: entryTime,
      exitTime: time,
      lots: lots,
      pips: finalPips,
      usdPnl: finalPnl,
    );
  }
}

class TradeStats {
  final int totalTrades;
  final int winningTrades;
  final int losingTrades;
  final double totalPnl;
  final double winRate;
  final double avgWin;
  final double avgLoss;

  TradeStats({
    required this.totalTrades,
    required this.winningTrades,
    required this.losingTrades,
    required this.totalPnl,
    required this.winRate,
    required this.avgWin,
    required this.avgLoss,
  });

  factory TradeStats.fromTrades(List<Trade> trades) {
    final closed = trades.where((t) => t.isClosed).toList();
    if (closed.isEmpty) {
      return TradeStats(
        totalTrades: 0,
        winningTrades: 0,
        losingTrades: 0,
        totalPnl: 0,
        winRate: 0,
        avgWin: 0,
        avgLoss: 0,
      );
    }

    final wins = closed.where((t) => t.isWin).toList();
    final losses = closed.where((t) => !t.isWin).toList();

    double totalPnl = closed.fold(0, (sum, t) => sum + (t.usdPnl ?? 0));
    double avgWin = wins.isEmpty ? 0 : wins.fold(0, (sum, t) => sum + (t.usdPnl ?? 0)) / wins.length;
    double avgLoss = losses.isEmpty ? 0 : losses.fold(0, (sum, t) => sum + (t.usdPnl ?? 0)) / losses.length;

    return TradeStats(
      totalTrades: closed.length,
      winningTrades: wins.length,
      losingTrades: losses.length,
      totalPnl: totalPnl,
      winRate: (wins.length / closed.length) * 100,
      avgWin: avgWin,
      avgLoss: avgLoss,
    );
  }
}
