=== lib/services/csv_service.dart ===

import 'dart:convert';
import 'dart:io';
import 'package:csv/csv.dart';
import 'package:crypto/crypto.dart';
import '../models/candle.dart';
import '../models/dataset.dart';

class CsvService {
  static Future<Dataset> loadFromFile(String filePath) async {
    final file = File(filePath);
    final content = await file.readAsString();
    return _parseCsv(content, filePath.split('/').last);
  }

  static Dataset loadFromText(String text, String name) {
    return _parseCsv(text, name);
  }

  static Dataset _parseCsv(String csvText, String fileName) {
    String delimiter = ',';
    if (csvText.contains(';') && !csvText.contains(',')) {
      delimiter = ';';
    }

    final rows = const CsvToListConverter(
      fieldDelimiter: delimiter,
      eol: '\n',
    ).convert(csvText);

    if (rows.isEmpty || rows.length < 2) {
      throw Exception('CSV must have header and at least 2 data rows');
    }

    int headerRow = 0;
    for (int i = 0; i < rows.length; i++) {
      final first = rows[i][0].toString().toLowerCase();
      if (first.contains('date') || first.contains('time')) {
        headerRow = i;
        break;
      }
    }

    final candles = <Candle>[];
    for (int i = headerRow + 1; i < rows.length; i++) {
      if (rows[i].length < 6) continue;
      try {
        candles.add(Candle.fromCsvRow(rows[i], i - headerRow - 1));
      } catch (e) {
        continue;
      }
    }

    if (candles.length < 2) {
      throw Exception('Need at least 2 valid candles');
    }

    final bytes = utf8.encode(csvText);
    final hash = md5.convert(bytes);
    final id = hash.toString();

    return Dataset(
      id: id,
      name: fileName,
      assetType: Dataset.detectAssetType(fileName),
      candles: candles,
    );
  }

  static String generateSampleData() {
    return '''Date,Open,High,Low,Close,Volume
2024-01-01,1.1000,1.1050,1.0980,1.1030,15000
2024-01-02,1.1030,1.1080,1.1010,1.1060,18000
2024-01-03,1.1060,1.1100,1.1040,1.1085,22000
2024-01-04,1.1085,1.1120,1.1060,1.1100,20000
2024-01-05,1.1100,1.1150,1.1080,1.1130,25000
2024-01-08,1.1130,1.1180,1.1110,1.1160,21000
2024-01-09,1.1160,1.1200,1.1140,1.1185,23000
2024-01-10,1.1185,1.1220,1.1160,1.1200,19000
2024-01-11,1.1200,1.1180,1.1140,1.1150,24000
2024-01-12,1.1150,1.1130,1.1090,1.1110,26000
2024-01-15,1.1110,1.1160,1.1090,1.1140,18000
2024-01-16,1.1140,1.1190,1.1120,1.1170,20000
2024-01-17,1.1170,1.1210,1.1150,1.1190,22000
2024-01-18,1.1190,1.1230,1.1170,1.1215,21000
2024-01-19,1.1215,1.1250,1.1190,1.1240,25000
2024-01-22,1.1240,1.1280,1.1220,1.1260,23000
2024-01-23,1.1260,1.1240,1.1200,1.1220,20000
2024-01-24,1.1220,1.1200,1.1160,1.1180,24000
2024-01-25,1.1180,1.1220,1.1160,1.1200,22000
2024-01-26,1.1200,1.1240,1.1180,1.1225,19000''';
  }
}
