import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import 'dart:math' as math;

class LayoutPosition {
  final double x;
  final double y;

  LayoutPosition({required this.x, required this.y});
}

class CorsiLayout {
  final String layoutId;
  final List<LayoutPosition> positions;

  CorsiLayout({required this.layoutId, required this.positions});
}

class LayoutService {
  static const String _laptopLayoutsPath = 'assets/data/laptop_layouts.csv';
  static const String _mobileLayoutsPath = 'assets/data/mobile_layouts.csv';

  static List<CorsiLayout> _laptopLayouts = [];
  static List<CorsiLayout> _mobileLayouts = [];
  static bool _isInitialized = false;

  /// Initialize the layout service by loading CSV data
  static Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      _laptopLayouts = await _loadLayoutsFromAsset(_laptopLayoutsPath);
      _mobileLayouts = await _loadLayoutsFromAsset(_mobileLayoutsPath);
      _isInitialized = true;
      print('LayoutService: Successfully loaded ${_laptopLayouts.length} laptop layouts and ${_mobileLayouts.length} mobile layouts');
    } catch (e) {
      print('LayoutService: Error loading layouts: $e');
      _createFallbackLayouts();
    }
  }

  /// Get a random layout based on screen size
  static CorsiLayout getRandomLayout(BuildContext context) {
    if (!_isInitialized) {
      throw Exception('LayoutService not initialized. Call initialize() first.');
    }

    final screenSize = MediaQuery.of(context).size;
    final isWideScreen = screenSize.width > 600;

    final layouts = isWideScreen ? _laptopLayouts : _mobileLayouts;

    if (layouts.isEmpty) {
      throw Exception('No layouts available for ${isWideScreen ? 'laptop' : 'mobile'}');
    }

    final randomIndex = math.Random().nextInt(layouts.length);
    return layouts[randomIndex];
  }

  /// Determine if current screen should use laptop or mobile layout
  static bool isLaptopScreen(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    return screenSize.width > 600;
  }

  /// Get counter position based on screen type
  static Offset getCounterPosition(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isWideScreen = screenSize.width > 600;

    if (isWideScreen) {
      // Laptop: Top right with more margin
      return Offset(screenSize.width - 160, 60);
    } else {
      // Mobile: Top right with less margin
      return Offset(screenSize.width - 100, 50);
    }
  }

  /// Load layouts from CSV asset
  static Future<List<CorsiLayout>> _loadLayoutsFromAsset(String assetPath) async {
    try {
      final csvString = await rootBundle.loadString(assetPath);
      return _parseCsvData(csvString);
    } catch (e) {
      print('Error loading $assetPath: $e');
      return [];
    }
  }

  /// Parse CSV data into CorsiLayout objects
  static List<CorsiLayout> _parseCsvData(String csvData) {
    final lines = csvData.trim().split('\n');
    if (lines.length < 2) return [];

    final layouts = <CorsiLayout>[];

    // Skip header row (index 0)
    for (int i = 1; i < lines.length; i++) {
      final line = lines[i].trim();
      if (line.isEmpty) continue;

      final values = line.split(',');
      if (values.length < 19) continue; // layout_id + 9 squares * 2 coordinates

      try {
        final layoutId = values[0].trim();
        final positions = <LayoutPosition>[];

        // Parse 9 squares (x,y pairs)
        for (int j = 0; j < 9; j++) {
          final xIndex = 1 + (j * 2); // 1, 3, 5, 7, 9, 11, 13, 15, 17
          final yIndex = 2 + (j * 2); // 2, 4, 6, 8, 10, 12, 14, 16, 18

          final x = double.parse(values[xIndex].trim());
          final y = double.parse(values[yIndex].trim());

          positions.add(LayoutPosition(x: x, y: y));
        }

        layouts.add(CorsiLayout(layoutId: layoutId, positions: positions));
      } catch (e) {
        print('Error parsing layout line $i: $e');
        continue;
      }
    }

    return layouts;
  }

  /// Create fallback layouts if CSV loading fails
  static void _createFallbackLayouts() {
    print('LayoutService: Creating fallback layouts');

    // Fallback laptop layout
    _laptopLayouts = [
      CorsiLayout(
        layoutId: 'fallback_laptop',
        positions: [
          LayoutPosition(x: 180, y: 200),
          LayoutPosition(x: 480, y: 160),
          LayoutPosition(x: 780, y: 200),
          LayoutPosition(x: 300, y: 360),
          LayoutPosition(x: 600, y: 320),
          LayoutPosition(x: 900, y: 360),
          LayoutPosition(x: 240, y: 520),
          LayoutPosition(x: 540, y: 560),
          LayoutPosition(x: 840, y: 520),
        ],
      ),
    ];

    // Fallback mobile layout
    _mobileLayouts = [
      CorsiLayout(
        layoutId: 'fallback_mobile',
        positions: [
          LayoutPosition(x: 100, y: 180),
          LayoutPosition(x: 250, y: 150),
          LayoutPosition(x: 180, y: 300),
          LayoutPosition(x: 320, y: 280),
          LayoutPosition(x: 120, y: 420),
          LayoutPosition(x: 260, y: 450),
          LayoutPosition(x: 380, y: 400),
          LayoutPosition(x: 80, y: 570),
          LayoutPosition(x: 300, y: 580),
        ],
      ),
    ];

    _isInitialized = true;
  }

  /// Get all available layouts for debugging
  static Map<String, int> getLayoutCounts() {
    return {
      'laptop': _laptopLayouts.length,
      'mobile': _mobileLayouts.length,
    };
  }
}