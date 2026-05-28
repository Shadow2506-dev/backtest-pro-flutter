=== lib/providers/app_provider.dart ===

import 'dart:math';
import 'package:flutter/material.dart';
import '../models/candle.dart';
import '../models/dataset.dart';
import '../models/drawing.dart';
import '../models/trade.dart';
import '../services/csv_service.dart';
import '../services/storage_service.dart';

enum ToolMode { cursor, trend, hLine, vLine, box, fib }

class AppProvider extends ChangeNotifier {
  bool _isDarkMode = true;
  bool get isDarkMode => _isDarkMode;

  void toggleTheme() {
    _isDarkMode = !_isDarkMode;
    notifyListeners();
  }

  Dataset? _currentDataset;
  Dataset? get currentDataset => _currentDataset;
  List<Dataset> _datasets = [];
  List<Dataset> get datasets => _datasets;

  int _currentBarIndex = 0;
  int get currentBarIndex => _currentBarIndex;
  int get totalBars => _currentDataset?.candles.length ?? 0;

  Candle? get currentCandle {
    if (_currentDataset == null || _currentBarIndex >= _currentDataset!.candles.length) return null;
    return _currentDataset!.candles[_currentBarIndex];
  }

  double get currentPrice => currentCandle?.close ?? 0;

  ToolMode _toolMode = ToolMode.cursor;
  ToolMode get toolMode => _toolMode;

  void setToolMode(ToolMode mode) {
    _toolMode = mode;
    if (mode != ToolMode.cursor) {
      deselectAllDrawings();
    }
    notifyListeners();
  }

  List<Drawing> get drawings => _currentDataset?.drawings ?? [];

  Drawing? _selectedDrawing;
  Drawing? get selectedDrawing => _selectedDrawing;

  List<Trade> _trades = [];
  List<Trade> get trades => _trades;
  Trade? _openTrade;
  Trade? get openTrade => _openTrade;

  double get openPnl => _openTrade?.calculatePnl(currentPrice) ?? 0;

  TradeStats get tradeStats => TradeStats.fromTrades(_trades);

  Drawing? _tempDrawing;
  Drawing? get tempDrawing => _tempDrawing;

  bool _isDragging = false;
  int? _draggedHandleIndex;
  Offset? _dragStart;

  Future<void> loadDatasetFromText(String text, String name) async {
    final dataset = CsvService.loadFromText(text, name);
    await _activateDataset(dataset);
  }

  Future<void> loadDatasetFromFile(String path) async {
    final dataset = await CsvService.loadFromFile(path);
    await _activateDataset(dataset);
  }

  Future<void> _activateDataset(Dataset dataset) async {
    final existing = _datasets.where((d) => d.id == dataset.id).firstOrNull;
    if (existing != null) {
      _currentDataset = existing;
    } else {
      dataset.drawings = await StorageService.loadDrawings(dataset.id);
      _datasets.add(dataset);
      _currentDataset = dataset;
    }
    _currentBarIndex = _currentDataset!.candles.length - 1;
    notifyListeners();
  }

  void switchDataset(String datasetId) {
    final dataset = _datasets.where((d) => d.id == datasetId).firstOrNull;
    if (dataset != null) {
      _currentDataset = dataset;
      _currentBarIndex = dataset.candles.length - 1;
      notifyListeners();
    }
  }

  void goToPreviousBar() {
    if (_currentBarIndex > 0) {
      _currentBarIndex--;
      notifyListeners();
    }
  }

  void goToNextBar() {
    if (_currentDataset != null && _currentBarIndex < _currentDataset!.candles.length - 1) {
      _currentBarIndex++;
      notifyListeners();
    }
  }

  void goToLatest() {
    if (_currentDataset != null) {
      _currentBarIndex = _currentDataset!.candles.length - 1;
      notifyListeners();
    }
  }

  void startDrawing(double bar, double price) {
    if (_currentDataset == null) return;

    final id = StorageService.generateId();
    final snappedBar = bar.roundToDouble();
    final snappedPrice = _snapToPrice(price);

    switch (_toolMode) {
      case ToolMode.trend:
      case ToolMode.box:
      case ToolMode.fib:
        _tempDrawing = Drawing(
          id: id,
          type: _toolMode == ToolMode.trend ? DrawingType.trend :
                _toolMode == ToolMode.box ? DrawingType.box : DrawingType.fib,
          startBar: snappedBar,
          startPrice: snappedPrice,
          endBar: snappedBar,
          endPrice: snappedPrice,
          datasetId: _currentDataset!.id,
        );
        break;
      case ToolMode.hLine:
        _tempDrawing = Drawing.horizontalLine(
          id: id,
          price: snappedPrice,
          barIndex: snappedBar,
          datasetId: _currentDataset!.id,
        );
        break;
      case ToolMode.vLine:
        _tempDrawing = Drawing.verticalLine(
          id: id,
          barIndex: snappedBar,
          price: snappedPrice,
          datasetId: _currentDataset!.id,
        );
        break;
      default:
        return;
    }
    notifyListeners();
  }

  void updateDrawing(double bar, double price) {
    if (_tempDrawing == null) return;

    final snappedBar = bar.roundToDouble();
    final snappedPrice = _snapToPrice(price);

    _tempDrawing = _tempDrawing!.copyWith(
      endBar: snappedBar,
      endPrice: snappedPrice,
    );
    notifyListeners();
  }

  void finishDrawing() async {
    if (_tempDrawing == null || _currentDataset == null) return;

    if (_tempDrawing!.type == DrawingType.trend ||
        _tempDrawing!.type == DrawingType.box ||
        _tempDrawing!.type == DrawingType.fib) {
      if (_tempDrawing!.startBar == _tempDrawing!.endBar &&
          _tempDrawing!.startPrice == _tempDrawing!.endPrice) {
        _tempDrawing = null;
        notifyListeners();
        return;
      }
    }

    _currentDataset!.drawings.add(_tempDrawing!);
    _selectedDrawing = _tempDrawing;
    _tempDrawing = null;

    await StorageService.saveDrawings(_currentDataset!.id, _currentDataset!.drawings);
    notifyListeners();
  }

  void selectDrawing(Drawing drawing) {
    deselectAllDrawings();
    drawing.isSelected = true;
    _selectedDrawing = drawing;
    notifyListeners();
  }

  void deselectAllDrawings() {
    for (var d in drawings) {
      d.isSelected = false;
    }
    _selectedDrawing = null;
    notifyListeners();
  }

  void deleteSelectedDrawing() async {
    if (_selectedDrawing == null || _currentDataset == null) return;
    _currentDataset!.drawings.removeWhere((d) => d.id == _selectedDrawing!.id);
    _selectedDrawing = null;
    await StorageService.saveDrawings(_currentDataset!.id, _currentDataset!.drawings);
    notifyListeners();
  }

  void clearAllDrawings() async {
    if (_currentDataset == null) return;
    _currentDataset!.drawings.clear();
    _selectedDrawing = null;
    await StorageService.saveDrawings(_currentDataset!.id, []);
    notifyListeners();
  }

  void startHandleDrag(int handleIndex, Offset position) {
    if (_selectedDrawing == null) return;
    _isDragging = true;
    _draggedHandleIndex = handleIndex;
    _dragStart = position;
  }

  void updateHandleDrag(double bar, double price) {
    if (!_isDragging || _selectedDrawing == null || _draggedHandleIndex == null) return;

    final snappedBar = bar.roundToDouble();
    final snappedPrice = _snapToPrice(price);

    switch (_selectedDrawing!.type) {
      case DrawingType.trend:
        if (_draggedHandleIndex == 0) {
          _selectedDrawing!.startBar = snappedBar;
          _selectedDrawing!.startPrice = snappedPrice;
        } else {
          _selectedDrawing!.endBar = snappedBar;
          _selectedDrawing!.endPrice = snappedPrice;
        }
        break;
      case DrawingType.hLine:
        _selectedDrawing!.startPrice = snappedPrice;
        _selectedDrawing!.endPrice = snappedPrice;
        break;
      case DrawingType.vLine:
        _selectedDrawing!.startBar = snappedBar;
        _selectedDrawing!.endBar = snappedBar;
        break;
      case DrawingType.box:
        if (_draggedHandleIndex == 0) {
          _selectedDrawing!.startBar = snappedBar;
          _selectedDrawing!.startPrice = snappedPrice;
        } else if (_draggedHandleIndex == 1) {
          _selectedDrawing!.endBar = snappedBar;
          _selectedDrawing!.startPrice = snappedPrice;
        } else if (_draggedHandleIndex == 2) {
          _selectedDrawing!.startBar = snappedBar;
          _selectedDrawing!.endPrice = snappedPrice;
        } else {
          _selectedDrawing!.endBar = snappedBar;
          _selectedDrawing!.endPrice = snappedPrice;
        }
        break;
      case DrawingType.fib:
        if (_draggedHandleIndex == 0) {
          _selectedDrawing!.startBar = snappedBar;
          _selectedDrawing!.startPrice = snappedPrice;
        } else {
          _selectedDrawing!.endBar = snappedBar;
          _selectedDrawing!.endPrice = snappedPrice;
        }
        break;
    }
    notifyListeners();
  }

  void endHandleDrag() async {
    _isDragging = false;
    _draggedHandleIndex = null;
    _dragStart = null;
    if (_currentDataset != null) {
      await StorageService.saveDrawings(_currentDataset!.id, _currentDataset!.drawings);
    }
  }

  void startDrawingMove(Offset position) {
    _isDragging = true;
    _dragStart = position;
  }

  void moveDrawing(double dBar, double dPrice) {
    if (!_isDragging || _selectedDrawing == null) return;
    _selectedDrawing!.move(dBar, dPrice);
    notifyListeners();
  }

  void endDrawingMove() async {
    _isDragging = false;
    _dragStart = null;
    if (_currentDataset != null) {
      await StorageService.saveDrawings(_currentDataset!.id, _currentDataset!.drawings);
    }
  }

  void openTrade(TradeDirection direction, double lots) {
    if (_openTrade != null) return;

    final trade = Trade(
      id: StorageService.generateId(),
      direction: direction,
      entryPrice: currentPrice,
      entryTime: DateTime.now(),
      lots: lots,
    );
    _openTrade = trade;
    notifyListeners();
  }

  void closeTrade() {
    if (_openTrade == null) return;

    final closed = _openTrade!.close(currentPrice, DateTime.now());
    _trades.add(closed);
    _openTrade = null;
    notifyListeners();
  }

  double _snapToPrice(double price) {
    if (_currentDataset == null) return price;
    double range = _currentDataset!.priceRange;
    double increment = range / 100;
    return (price / increment).round() * increment;
  }

  void reset() {
    _currentDataset = null;
    _currentBarIndex = 0;
    _trades = [];
    _openTrade = null;
    _selectedDrawing = null;
    _tempDrawing = null;
    notifyListeners();
  }
}
