import 'package:csv/csv.dart';
import 'package:flutter/services.dart' show rootBundle;

/// Loads CSV assets bundled under `assets/csv/`.
///
/// Port of HearifyV1/Utils/CSVLoader.swift — the Swift version parsed a
/// hardcoded 3-column (firstWord, lastWord, category) schema. Here we return
/// the raw rows so each feature can project them to its own model.
class CsvLoader {
  CsvLoader._();

  static Future<List<List<String>>> load(String assetName) async {
    final path = assetName.endsWith('.csv')
        ? 'assets/csv/$assetName'
        : 'assets/csv/$assetName.csv';
    final raw = await rootBundle.loadString(path);
    final rows = const CsvToListConverter(
      shouldParseNumbers: false,
      eol: '\n',
    ).convert(raw);
    return rows
        .map((row) => row.map((c) => c.toString().trim()).toList())
        .where((row) => row.any((cell) => cell.isNotEmpty))
        .toList();
  }
}
