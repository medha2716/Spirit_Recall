import 'dart:math' as math;

class SequenceGenerator {
  static math.Random? _random;

  /// Initialize with a seed for reproducible sequences
  static void initialize({int? seed}) {
    _random = math.Random(seed);
  }

  /// Generate a random sequence of block IDs for the given span length
  /// blockIds should be 0-8 (for 9 blocks)
  static List<int> generateSequence(int spanLength, {int maxBlockId = 8}) {
    if (_random == null) {
      initialize(); // Initialize with no seed if not already done
    }

    if (spanLength <= 0 || spanLength > maxBlockId + 1) {
      throw ArgumentError('Invalid span length: $spanLength');
    }

    List<int> sequence = [];
    Set<int> usedBlocks = {};

    // Generate unique block IDs for the sequence
    while (sequence.length < spanLength) {
      int blockId = _random!.nextInt(maxBlockId + 1);
      if (!usedBlocks.contains(blockId)) {
        sequence.add(blockId);
        usedBlocks.add(blockId);
      }
    }

    return sequence;
  }

  /// Generate a sequence allowing repeated blocks (if needed for future variants)
  static List<int> generateSequenceWithRepeats(int spanLength, {int maxBlockId = 8}) {
    if (_random == null) {
      initialize();
    }

    return List.generate(spanLength, (_) => _random!.nextInt(maxBlockId + 1));
  }

  /// Get the reverse of a sequence (for backward recall mode)
  static List<int> reverseSequence(List<int> sequence) {
    return sequence.reversed.toList();
  }
}