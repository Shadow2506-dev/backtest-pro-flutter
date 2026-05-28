=== lib/services/storage_service.dart ===

import 'dart:convert';
import 'dart:math';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/drawing.dart';

class StorageService {
  static const String _drawingsPrefix = 'drawings_';

  static Future<void> saveDrawings(String datasetId, List<Drawing> drawings) async {
    final prefs = await SharedPreferences.getInstance();
    final data = drawings.map((d) => {
      'id': d.id,
      'type': d.type.index,
      'startBar': d.startBar,
      'startPrice': d.startPrice,
      'endBar': d.endBar,
      'endPrice': d.endPrice,
    }).toList();
    await prefs.setString('$_drawingsPrefix$datasetId', jsonEncode(data));
  }

  static Future<List<Drawing>> loadDrawings(String datasetId) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = prefs.getString('$_drawingsPrefix$datasetId');
    if (jsonStr == null) return [];

    try {
      final List<dynamic> data = jsonDecode(jsonStr);
      return data.map((d) => Drawing(
        id: d['id'],
        type: DrawingType.values[d['type']],
        startBar: d['startBar'],
        startPrice: d['startPrice'],
        endBar: d['endBar'],
        endPrice: d['endPrice'],
        datasetId: datasetId,
      )).toList();
    } catch (e) {
      return [];
    }
  }

  static Future<void> clearDrawings(String datasetId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('$_drawingsPrefix$datasetId');
  }

  static String generateId() {
    final random = Random();
    return '${DateTime.now().millisecondsSinceEpoch}_${random.nextInt(10000)}';
  }
}
