=== lib/models/drawing.dart ===

import 'dart:math';
import 'dart:ui';

enum DrawingType { trend, hLine, vLine, box, fib }

class Drawing {
  String id;
  DrawingType type;
  double startBar;
  double startPrice;
  double endBar;
  double endPrice;
  bool isSelected;
  String? datasetId;

  Drawing({
    required this.id,
    required this.type,
    required this.startBar,
    required this.startPrice,
    required this.endBar,
    required this.endPrice,
    this.isSelected = false,
    this.datasetId,
  });

  factory Drawing.horizontalLine({
    required String id,
    required double price,
    required double barIndex,
    String? datasetId,
  }) {
    return Drawing(
      id: id,
      type: DrawingType.hLine,
      startBar: barIndex,
      startPrice: price,
      endBar: barIndex,
      endPrice: price,
      datasetId: datasetId,
    );
  }

  factory Drawing.verticalLine({
    required String id,
    required double barIndex,
    required double price,
    String? datasetId,
  }) {
    return Drawing(
      id: id,
      type: DrawingType.vLine,
      startBar: barIndex,
      startPrice: price,
      endBar: barIndex,
      endPrice: price,
      datasetId: datasetId,
    );
  }

  Drawing copyWith({
    double? startBar,
    double? startPrice,
    double? endBar,
    double? endPrice,
    bool? isSelected,
  }) {
    return Drawing(
      id: id,
      type: type,
      startBar: startBar ?? this.startBar,
      startPrice: startPrice ?? this.startPrice,
      endBar: endBar ?? this.endBar,
      endPrice: endPrice ?? this.endPrice,
      isSelected: isSelected ?? this.isSelected,
      datasetId: datasetId,
    );
  }

  List<Offset> getHandles() {
    switch (type) {
      case DrawingType.trend:
        return [Offset(startBar, startPrice), Offset(endBar, endPrice)];
      case DrawingType.hLine:
        return [Offset(startBar, startPrice)];
      case DrawingType.vLine:
        return [Offset(startBar, startPrice)];
      case DrawingType.box:
        return [
          Offset(startBar, startPrice),
          Offset(endBar, startPrice),
          Offset(startBar, endPrice),
          Offset(endBar, endPrice),
        ];
      case DrawingType.fib:
        return [Offset(startBar, startPrice), Offset(endBar, endPrice)];
    }
  }

  bool containsPoint(double bar, double price, double barTolerance, double priceTolerance) {
    switch (type) {
      case DrawingType.trend:
        return _pointNearLine(bar, price, startBar, startPrice, endBar, endPrice, barTolerance, priceTolerance);
      case DrawingType.hLine:
        return (price - startPrice).abs() < priceTolerance;
      case DrawingType.vLine:
        return (bar - startBar).abs() < barTolerance;
      case DrawingType.box:
        return bar >= min(startBar, endBar) - barTolerance &&
               bar <= max(startBar, endBar) + barTolerance &&
               price >= min(startPrice, endPrice) - priceTolerance &&
               price <= max(startPrice, endPrice) + priceTolerance;
      case DrawingType.fib:
        return _pointNearLine(bar, price, startBar, startPrice, endBar, endPrice, barTolerance, priceTolerance);
    }
  }

  bool _pointNearLine(double px, double py, double x1, double y1, double x2, double y2,
                      double barTol, double priceTol) {
    double dx = x2 - x1;
    double dy = y2 - y1;
    if (dx == 0 && dy == 0) return (px - x1).abs() < barTol && (py - y1).abs() < priceTol;
    double t = ((px - x1) * dx + (py - y1) * dy) / (dx * dx + dy * dy);
    t = t.clamp(0.0, 1.0);
    double nearX = x1 + t * dx;
    double nearY = y1 + t * dy;
    return (px - nearX).abs() < barTol && (py - nearY).abs() < priceTol;
  }

  void move(double dBar, double dPrice) {
    startBar += dBar;
    endBar += dBar;
    startPrice += dPrice;
    endPrice += dPrice;
  }
}
