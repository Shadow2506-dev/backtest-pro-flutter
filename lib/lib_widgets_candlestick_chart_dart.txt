=== lib/widgets/candlestick_chart.dart ===

import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/candle.dart';
import '../models/drawing.dart';
import '../providers/app_provider.dart';

class CandlestickChart extends StatefulWidget {
  const CandlestickChart({super.key});

  @override
  State<CandlestickChart> createState() => _CandlestickChartState();
}

class _CandlestickChartState extends State<CandlestickChart> {
  @override
  Widget build(BuildContext context) {
    return Consumer<AppProvider>(
      builder: (context, provider, child) {
        final dataset = provider.currentDataset;
        if (dataset == null) {
          return Container(
            color: provider.isDarkMode ? const Color(0xFF1a1a2e) : Colors.white,
            child: const Center(
              child: Text('Load CSV data to start', style: TextStyle(color: Colors.grey)),
            ),
          );
        }

        return GestureDetector(
          onTapDown: (details) => _handleTapDown(details, provider),
          onPanStart: (details) => _handlePanStart(details, provider),
          onPanUpdate: (details) => _handlePanUpdate(details, provider),
          onPanEnd: (_) => _handlePanEnd(provider),
          child: CustomPaint(
            size: Size.infinite,
            painter: CandlestickPainter(
              dataset: dataset,
              currentBarIndex: provider.currentBarIndex,
              drawings: provider.drawings,
              tempDrawing: provider.tempDrawing,
              selectedDrawing: provider.selectedDrawing,
              isDarkMode: provider.isDarkMode,
              toolMode: provider.toolMode,
            ),
          ),
        );
      },
    );
  }

  void _handleTapDown(TapDownDetails details, AppProvider provider) {
    final box = context.findRenderObject() as RenderBox;
    final localPos = box.globalToLocal(details.globalPosition);
    final chartSize = box.size;

    final dataset = provider.currentDataset!;
    final bar = _pixelToBar(localPos.dx, chartSize.width, dataset.candles.length);
    final price = _pixelToPrice(localPos.dy, chartSize.height, dataset.minPrice, dataset.maxPrice);

    if (provider.toolMode == ToolMode.cursor) {
      if (provider.selectedDrawing != null) {
        final handles = provider.selectedDrawing!.getHandles();
        for (int i = 0; i < handles.length; i++) {
          final handlePixel = _dataToPixel(handles[i].dx, handles[i].dy, chartSize, dataset);
          if ((localPos - handlePixel).distance < 15) {
            provider.startHandleDrag(i, localPos);
            return;
          }
        }

        if (provider.selectedDrawing!.containsPoint(
            bar, price, 1.5, dataset.priceRange / 50)) {
          provider.startDrawingMove(localPos);
          return;
        }
      }

      provider.deselectAllDrawings();
      for (var drawing in provider.drawings.reversed) {
        if (drawing.containsPoint(bar, price, 1.5, dataset.priceRange / 50)) {
          provider.selectDrawing(drawing);
          return;
        }
      }
    } else {
      provider.startDrawing(bar, price);
    }
  }

  void _handlePanStart(DragStartDetails details, AppProvider provider) {}

  void _handlePanUpdate(DragUpdateDetails details, AppProvider provider) {
    final box = context.findRenderObject() as RenderBox;
    final localPos = box.globalToLocal(details.globalPosition);
    final chartSize = box.size;
    final dataset = provider.currentDataset!;

    final bar = _pixelToBar(localPos.dx, chartSize.width, dataset.candles.length);
    final price = _pixelToPrice(localPos.dy, chartSize.height, dataset.minPrice, dataset.maxPrice);

    if (provider.tempDrawing != null) {
      provider.updateDrawing(bar, price);
    } else if (provider.selectedDrawing != null) {
      provider.updateHandleDrag(bar, price);
    }
  }

  void _handlePanEnd(AppProvider provider) {
    if (provider.tempDrawing != null) {
      provider.finishDrawing();
    } else {
      provider.endHandleDrag();
      provider.endDrawingMove();
    }
  }

  double _pixelToBar(double x, double width, int barCount) {
    final padding = width * 0.05;
    final chartWidth = width - padding * 2;
    return ((x - padding) / chartWidth) * barCount;
  }

  double _pixelToPrice(double y, double height, double minPrice, double maxPrice) {
    final padding = height * 0.05;
    final chartHeight = height - padding * 2;
    final priceRange = maxPrice - minPrice;
    final ratio = (y - padding) / chartHeight;
    return maxPrice - ratio * priceRange;
  }

  Offset _dataToPixel(double bar, double price, Size size, dataset) {
    final paddingH = size.width * 0.05;
    final paddingV = size.height * 0.05;
    final chartWidth = size.width - paddingH * 2;
    final chartHeight = size.height - paddingV * 2;
    final priceRange = dataset.maxPrice - dataset.minPrice;

    final x = paddingH + (bar / dataset.candles.length) * chartWidth + (chartWidth / dataset.candles.length / 2);
    final y = paddingV + ((dataset.maxPrice - price) / priceRange) * chartHeight;
    return Offset(x, y);
  }
}

class CandlestickPainter extends CustomPainter {
  final dataset;
  final int currentBarIndex;
  final List<Drawing> drawings;
  final Drawing? tempDrawing;
  final Drawing? selectedDrawing;
  final bool isDarkMode;
  final ToolMode toolMode;

  CandlestickPainter({
    required this.dataset,
    required this.currentBarIndex,
    required this.drawings,
    this.tempDrawing,
    this.selectedDrawing,
    required this.isDarkMode,
    required this.toolMode,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final bgColor = isDarkMode ? const Color(0xFF1a1a2e) : Colors.white;
    canvas.drawRect(Offset.zero & size, Paint()..color = bgColor);

    if (dataset.candles.isEmpty) return;

    final paddingH = size.width * 0.05;
    final paddingV = size.height * 0.05;
    final chartWidth = size.width - paddingH * 2;
    final chartHeight = size.height - paddingV * 2;
    final priceRange = dataset.maxPrice - dataset.minPrice;
    final minPrice = dataset.minPrice;
    final barCount = dataset.candles.length;

    _drawGrid(canvas, size, paddingH, paddingV, chartWidth, chartHeight, priceRange, minPrice);

    final candleWidth = chartWidth / barCount * 0.7;
    final barSpacing = chartWidth / barCount;

    for (int i = 0; i <= currentBarIndex && i < barCount; i++) {
      final candle = dataset.candles[i];
      final x = paddingH + i * barSpacing + barSpacing / 2;

      final yHigh = paddingV + ((dataset.maxPrice - candle.high) / priceRange) * chartHeight;
      final yLow = paddingV + ((dataset.maxPrice - candle.low) / priceRange) * chartHeight;
      final yOpen = paddingV + ((dataset.maxPrice - candle.open) / priceRange) * chartHeight;
      final yClose = paddingV + ((dataset.maxPrice - candle.close) / priceRange) * chartHeight;

      final isBullish = candle.isBullish;
      final bodyTop = min(yOpen, yClose);
      final bodyBottom = max(yOpen, yClose);
      final bodyHeight = max(bodyBottom - bodyTop, 1.0);

      Color candleColor;
      if (isDarkMode) {
        candleColor = isBullish ? const Color(0xFF26a69a) : const Color(0xFFef5350);
      } else {
        candleColor = isBullish ? Colors.green.shade700 : Colors.red.shade700;
      }

      final wickPaint = Paint()
        ..color = candleColor
        ..strokeWidth = 1;
      canvas.drawLine(Offset(x, yHigh), Offset(x, yLow), wickPaint);

      final bodyPaint = Paint()..color = candleColor;
      canvas.drawRect(
        Rect.fromLTWH(x - candleWidth / 2, bodyTop, candleWidth, bodyHeight),
        bodyPaint,
      );

      if (!isDarkMode) {
        canvas.drawRect(
          Rect.fromLTWH(x - candleWidth / 2, bodyTop, candleWidth, bodyHeight),
          Paint()
            ..color = Colors.black54
            ..style = PaintingStyle.stroke
            ..strokeWidth = 0.5,
        );
      }
    }

    for (var drawing in drawings) {
      _drawDrawing(canvas, drawing, paddingH, paddingV, chartWidth, chartHeight, priceRange, minPrice, barCount);
    }

    if (tempDrawing != null) {
      _drawDrawing(canvas, tempDrawing!, paddingH, paddingV, chartWidth, chartHeight, priceRange, minPrice, barCount, isTemp: true);
    }

    if (selectedDrawing != null) {
      _drawHandles(canvas, selectedDrawing!, paddingH, paddingV, chartWidth, chartHeight, priceRange, minPrice, barCount);
    }
  }

  void _drawGrid(Canvas canvas, Size size, double paddingH, double paddingV,
                  double chartWidth, double chartHeight, double priceRange, double minPrice) {
    final gridPaint = Paint()
      ..color = isDarkMode ? Colors.white12 : Colors.black12
      ..strokeWidth = 0.5;

    for (int i = 0; i <= 5; i++) {
      final y = paddingV + (i / 5) * chartHeight;
      canvas.drawLine(
        Offset(paddingH, y),
        Offset(paddingH + chartWidth, y),
        gridPaint,
      );

      final price = dataset.maxPrice - (i / 5) * priceRange;
      final textPainter = TextPainter(
        text: TextSpan(
          text: price.toStringAsFixed(4),
          style: TextStyle(
            color: isDarkMode ? Colors.white54 : Colors.black54,
            fontSize: 10,
          ),
        ),
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();
      textPainter.paint(canvas, Offset(paddingH + chartWidth + 2, y - 6));
    }

    for (int i = 0; i <= 5; i++) {
      final x = paddingH + (i / 5) * chartWidth;
      canvas.drawLine(
        Offset(x, paddingV),
        Offset(x, paddingV + chartHeight),
        gridPaint,
      );
    }
  }

  void _drawDrawing(Canvas canvas, Drawing drawing, double paddingH, double paddingV,
                    double chartWidth, double chartHeight, double priceRange, double minPrice,
                    int barCount, {bool isTemp = false}) {
    final paint = Paint()
      ..color = isTemp ? Colors.yellow : (drawing.isSelected ? Colors.yellow : Colors.blue)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    final fillPaint = Paint()
      ..color = Colors.blue.withOpacity(0.1)
      ..style = PaintingStyle.fill;

    final startX = paddingH + (drawing.startBar / barCount) * chartWidth + (chartWidth / barCount / 2);
    final startY = paddingV + ((dataset.maxPrice - drawing.startPrice) / priceRange) * chartHeight;
    final endX = paddingH + (drawing.endBar / barCount) * chartWidth + (chartWidth / barCount / 2);
    final endY = paddingV + ((dataset.maxPrice - drawing.endPrice) / priceRange) * chartHeight;

    switch (drawing.type) {
      case DrawingType.trend:
        canvas.drawLine(Offset(startX, startY), Offset(endX, endY), paint);
        break;
      case DrawingType.hLine:
        canvas.drawLine(
          Offset(paddingH, startY),
          Offset(paddingH + chartWidth, startY),
          paint,
        );
        break;
      case DrawingType.vLine:
        canvas.drawLine(
          Offset(startX, paddingV),
          Offset(startX, paddingV + chartHeight),
          paint,
        );
        break;
      case DrawingType.box:
        final rect = Rect.fromLTRB(
          min(startX, endX),
          min(startY, endY),
          max(startX, endX),
          max(startY, endY),
        );
        canvas.drawRect(rect, fillPaint);
        canvas.drawRect(rect, paint);
        break;
      case DrawingType.fib:
        _drawFibonacci(canvas, startX, startY, endX, endY, paint);
        break;
    }
  }

  void _drawFibonacci(Canvas canvas, double x1, double y1, double x2, double y2, Paint paint) {
    final levels = [0.0, 0.236, 0.382, 0.5, 0.618, 0.786, 1.0];

    for (var level in levels) {
      final y = y1 + (y2 - y1) * level;
      final levelPaint = Paint()
        ..color = Colors.blue.withOpacity(0.7)
        ..strokeWidth = 1;

      canvas.drawLine(
        Offset(min(x1, x2), y),
        Offset(max(x1, x2), y),
        levelPaint,
      );
    }

    canvas.drawLine(Offset(x1, y1), Offset(x2, y2), paint);
  }

  void _drawHandles(Canvas canvas, Drawing drawing, double paddingH, double paddingV,
                    double chartWidth, double chartHeight, double priceRange, double minPrice, int barCount) {
    final handles = drawing.getHandles();
    final handlePaint = Paint()..color = Colors.white;
    final handleBorderPaint = Paint()
      ..color = Colors.yellow
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    for (var handle in handles) {
      final x = paddingH + (handle.dx / barCount) * chartWidth + (chartWidth / barCount / 2);
      final y = paddingV + ((dataset.maxPrice - handle.dy) / priceRange) * chartHeight;

      canvas.drawRect(
        Rect.fromCenter(center: Offset(x, y), width: 10, height: 10),
        handlePaint,
      );
      canvas.drawRect(
        Rect.fromCenter(center: Offset(x, y), width: 10, height: 10),
        handleBorderPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
