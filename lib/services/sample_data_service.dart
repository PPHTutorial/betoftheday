import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/sample_data_model.dart';
import 'data_grouping_service.dart';

/// Service for loading and managing sample data
class SampleDataService {
  static SampleDataService? _instance;
  static SampleDataService get instance {
    _instance ??= SampleDataService._();
    return _instance!;
  }

  SampleDataService._();

  SampleDataModel? _sampleData;
  DataGroupingService? _groupingService;

  SampleDataModel? get sampleData => _sampleData;
  DataGroupingService? get groupingService => _groupingService;

  /// Load sample data from assets
  Future<SampleDataService> loadFromAssets() async {
    try {
      final String jsonString = await rootBundle.loadString('sample.json');
      final List<dynamic> jsonList = json.decode(jsonString);

      // The sample.json appears to be an array, take the first item
      if (jsonList.isNotEmpty) {
        _sampleData =
            SampleDataModel.fromJson(jsonList.first as Map<String, dynamic>);
        _groupingService = DataGroupingService(_sampleData!);
      }

      return this;
    } catch (e) {
      throw Exception('Failed to load sample data: $e');
    }
  }

  /// Load sample data from JSON string
  Future<SampleDataService> loadFromJsonString(String jsonString) async {
    try {
      final List<dynamic> jsonList = json.decode(jsonString);

      if (jsonList.isNotEmpty) {
        _sampleData =
            SampleDataModel.fromJson(jsonList.first as Map<String, dynamic>);
        _groupingService = DataGroupingService(_sampleData!);
      }

      return this;
    } catch (e) {
      throw Exception('Failed to parse sample data: $e');
    }
  }

  /// Load sample data from file path
  Future<SampleDataService> loadFromFile(String filePath) async {
    try {
      // For file loading, you might need to use path_provider or similar
      // For now, this is a placeholder
      throw UnimplementedError('File loading not yet implemented');
    } catch (e) {
      throw Exception('Failed to load sample data from file: $e');
    }
  }

  /// Check if data is loaded
  bool get isLoaded => _sampleData != null;

  /// Get all groupings
  Map<String, dynamic>? getAllGroupings() {
    return _groupingService?.getAllGroupings();
  }
}
