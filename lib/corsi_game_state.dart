import 'sequence_generator.dart';

enum GamePhase {
  READY,
  PRESENTING,
  AWAIT_RESPONSE,
  EVAL,
  FEEDBACK,
  NEXT,
  COMPLETED
}

enum RecallMode {
  FORWARD,
  BACKWARD // For future use
}

class TrialResult {
  final int spanLength;
  final int trialNumber;
  final List<int> presentedSequence;
  final List<int> playerResponse;
  final bool isCorrect;
  final String? errorType; // 'omission', 'intrusion', 'order'
  final DateTime timestamp;

  TrialResult({
    required this.spanLength,
    required this.trialNumber,
    required this.presentedSequence,
    required this.playerResponse,
    required this.isCorrect,
    this.errorType,
    required this.timestamp,
  });

  @override
  String toString() {
    return 'Trial(span=$spanLength, trial=$trialNumber, presented=$presentedSequence, '
           'response=$playerResponse, correct=$isCorrect, error=$errorType)';
  }
}

class CorsiGameState {
  // Game configuration
  static const int N_BLOCKS = 9;
  static const int SPAN_MIN = 2;
  static const int SPAN_MAX = 9;
  static const int TRIALS_PER_SPAN = 2;
  static const int PRESENTATION_DELAY_MS = 1000;
  static const int MIN_INTERTAP_MS = 200;

  // Current game state
  RecallMode mode = RecallMode.FORWARD;
  GamePhase currentPhase = GamePhase.READY;

  // Current trial data
  int currentSpan = SPAN_MIN;
  int currentTrialAtSpan = 0; // 0 or 1 for the two trials per span
  int correctTrialsAtCurrentSpan = 0;

  List<int> currentSequence = [];
  List<int> playerResponse = [];
  int currentPresentationIndex = 0;

  // Results tracking
  List<TrialResult> allResults = [];
  int longestCorrectSpan = 0;

  // Timing
  DateTime? lastTapTime;

  void reset() {
    currentPhase = GamePhase.READY;
    currentSpan = SPAN_MIN;
    currentTrialAtSpan = 0;
    correctTrialsAtCurrentSpan = 0;
    currentSequence.clear();
    playerResponse.clear();
    currentPresentationIndex = 0;
    allResults.clear();
    longestCorrectSpan = 0;
    lastTapTime = null;
  }

  void startNewTrial() {
    currentPhase = GamePhase.READY;
    currentSequence = SequenceGenerator.generateSequence(currentSpan);
    playerResponse.clear();
    currentPresentationIndex = 0;

    print('Starting trial ${currentTrialAtSpan + 1}/2 for span $currentSpan');
    print('Sequence: $currentSequence');
  }

  void startPresentation() {
    currentPhase = GamePhase.PRESENTING;
    currentPresentationIndex = 0;
  }

  void advancePresentation() {
    currentPresentationIndex++;
    if (currentPresentationIndex >= currentSequence.length) {
      currentPhase = GamePhase.AWAIT_RESPONSE;
    }
  }

  bool canAcceptInput() {
    return currentPhase == GamePhase.AWAIT_RESPONSE;
  }

  bool addPlayerResponse(int blockId) {
    if (!canAcceptInput()) return false;

    // Debounce check
    final now = DateTime.now();
    if (lastTapTime != null) {
      final timeDiff = now.difference(lastTapTime!).inMilliseconds;
      if (timeDiff < MIN_INTERTAP_MS) {
        return false; // Ignore too-quick taps
      }
    }
    lastTapTime = now;

    // Don't accept more responses than the sequence length
    if (playerResponse.length >= currentSequence.length) {
      return false;
    }

    playerResponse.add(blockId);

    // Auto-submit when we have enough responses
    if (playerResponse.length == currentSequence.length) {
      evaluateResponse();
    }

    return true;
  }

  void evaluateResponse() {
    currentPhase = GamePhase.EVAL;

    String? errorType;
    bool isCorrect = false;

    // Check length
    if (playerResponse.length != currentSequence.length) {
      errorType = playerResponse.length < currentSequence.length ? 'omission' : 'intrusion';
    } else {
      // Check order
      List<int> expectedResponse = mode == RecallMode.FORWARD
          ? currentSequence
          : SequenceGenerator.reverseSequence(currentSequence);

      isCorrect = _listsEqual(playerResponse, expectedResponse);
      if (!isCorrect) {
        errorType = 'order';
      }
    }

    // Record the result
    final result = TrialResult(
      spanLength: currentSpan,
      trialNumber: currentTrialAtSpan + 1,
      presentedSequence: List.from(currentSequence),
      playerResponse: List.from(playerResponse),
      isCorrect: isCorrect,
      errorType: errorType,
      timestamp: DateTime.now(),
    );

    allResults.add(result);

    if (isCorrect) {
      correctTrialsAtCurrentSpan++;
      if (currentSpan > longestCorrectSpan) {
        longestCorrectSpan = currentSpan;
      }
    }

    print('Result: ${result.toString()}');

    currentPhase = GamePhase.FEEDBACK;
  }

  void moveToNextTrial() {
    currentTrialAtSpan++;

    // Check if we've completed both trials at this span
    if (currentTrialAtSpan >= TRIALS_PER_SPAN) {
      // Apply stop rule: stop if zero correct trials at this span
      if (correctTrialsAtCurrentSpan == 0) {
        currentPhase = GamePhase.COMPLETED;
        print('Game completed! Final span: ${currentSpan - 1}, Longest correct: $longestCorrectSpan');
        return;
      }

      // Move to next span
      currentSpan++;
      currentTrialAtSpan = 0;
      correctTrialsAtCurrentSpan = 0;

      // Check if we've reached maximum span
      if (currentSpan > SPAN_MAX) {
        currentPhase = GamePhase.COMPLETED;
        print('Game completed! Reached maximum span. Longest correct: $longestCorrectSpan');
        return;
      }
    }

    currentPhase = GamePhase.NEXT;
  }

  bool _listsEqual(List<int> a, List<int> b) {
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }

  String getPhaseTitle() {
    switch (currentPhase) {
      case GamePhase.READY:
        return 'Sequence Length: $currentSpan - Ready';
      case GamePhase.PRESENTING:
        return 'Sequence Length: $currentSpan - Showing Sequence...';
      case GamePhase.AWAIT_RESPONSE:
        return 'Sequence Length: $currentSpan - Your Turn! Tap the squares';
      case GamePhase.EVAL:
      case GamePhase.FEEDBACK:
        return 'Sequence Length: $currentSpan - Evaluating...';
      case GamePhase.NEXT:
        return 'Sequence Length: $currentSpan - Next Trial';
      case GamePhase.COMPLETED:
        return 'Test Completed! Longest span: $longestCorrectSpan';
    }
  }

  String getInstructions() {
    switch (currentPhase) {
      case GamePhase.READY:
        return 'Get Ready'; //Trial ${currentTrialAtSpan + 1} of 2
      case GamePhase.PRESENTING:
        return 'Watch the sequence carefully...';
      case GamePhase.AWAIT_RESPONSE:
        return 'Tap the squares in the same order'; //(${playerResponse.length}/${currentSequence.length})
      case GamePhase.FEEDBACK:
        final lastResult = allResults.isNotEmpty ? allResults.last : null;
        return lastResult?.isCorrect == true ? 'Correct!' : 'Incorrect';
      case GamePhase.COMPLETED:
        return 'Your longest span was $longestCorrectSpan blocks';
      default:
        return '';
    }
  }

  int? getCurrentlyHighlightedBlock() {
    if (currentPhase == GamePhase.PRESENTING && currentPresentationIndex < currentSequence.length) {
      return currentSequence[currentPresentationIndex];
    }
    return null;
  }

  bool shouldShowSparkles() {
    return currentPhase == GamePhase.FEEDBACK &&
           allResults.isNotEmpty &&
           allResults.last.isCorrect;
  }

  List<int> getSparkleSequence() {
    if (shouldShowSparkles() && allResults.isNotEmpty) {
      return allResults.last.presentedSequence;
    }
    return [];
  }
}