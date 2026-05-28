=== lib/models/dataset.dart ===

import 'candle.dart';
import 'drawing.dart';

class Dataset {
  final String id;
  final String name;
  final String assetType;
  final List<Candle> candles;
  List<Drawing> drawings;

  Dataset({
    required this.id,
    required this.name,
    required this.assetType,
    required this.candles,
    this.drawings = const [],
  });

  double get minPrice => candles.map((c) => c.low).reduce((a, b) => a < b ? a : b);
  double get maxPrice => candles.map((c) => c.high).reduce((a, b) => a > b ? a : b);
  double get priceRange => maxPrice - minPrice;
  int get barCount => candles.length;

  String get tickerSymbol {
    if (name.contains('EURUSD')) return 'EURUSD';
    if (name.contains('GBPUSD')) return 'GBPUSD';
    if (name.contains('USDJPY')) return 'USDJPY';
    if (name.contains('BTC')) return 'BTCUSD';
    if (name.contains('ETH')) return 'ETHUSD';
    return 'UNKNOWN';
  }

  static String detectAssetType(String name) {
    final lower = name.toLowerCase();
    if (lower.contains('eur') || lower.contains('gbp') || lower.contains('usd') ||
        lower.contains('jpy') || lower.contains('aud') || lower.contains('cad')) {
      return 'FOREX';
    }
    if (lower.contains('btc') || lower.contains('eth') || lower.contains('crypto')) {
      return 'CRYPTO';
    }
    if (lower.contains('gold') || lower.contains('oil') || lower.contains('silver')) {
      return 'COMMODITIES';
    }
    if (lower.contains('futures') || lower.contains('es') || lower.contains('nq')) {
      return 'FUTURES';
    }
    return 'FOREX';
  }
}
