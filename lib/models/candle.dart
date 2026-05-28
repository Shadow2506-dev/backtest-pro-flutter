=== lib/models/candle.dart ===

class Candle {
  final DateTime date;
  final double open;
  final double high;
  final double low;
  final double close;
  final int volume;
  final int index;

  Candle({
    required this.date,
    required this.open,
    required this.high,
    required this.low,
    required this.close,
    required this.volume,
    required this.index,
  });

  bool get isBullish => close >= open;
  double get bodyTop => isBullish ? close : open;
  double get bodyBottom => isBullish ? open : close;
  double get bodySize => (close - open).abs();
  double get range => high - low;

  factory Candle.fromCsvRow(List<dynamic> row, int index) {
    return Candle(
      date: DateTime.parse(row[0].toString()),
      open: double.parse(row[1].toString()),
      high: double.parse(row[2].toString()),
      low: double.parse(row[3].toString()),
      close: double.parse(row[4].toString()),
      volume: int.parse(row[5].toString()),
      index: index,
    );
  }
}
