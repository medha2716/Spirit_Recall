// import 'dart:async';
// import 'dart:math';
// import 'package:flutter/material.dart';
// import 'package:just_audio/just_audio.dart';
// import 'package:flame/flame.dart';
// import 'package:flame/game.dart';
// import 'package:flame/components.dart';
// import 'package:flame/events.dart';
// import 'package:flame/extensions.dart';
// import 'package:flame/particles.dart';
// import 'package:flame/effects.dart';
// import 'package:flutter/services.dart';

// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   await Flame.device.fullScreen();
//   await Flame.device.setOrientation(DeviceOrientation.portraitUp);
//   runApp(MyApp());
// }

// class MyApp extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       debugShowCheckedModeBanner: false,
//       title: 'Spirit Simon Game',
//       theme: ThemeData(
//         primarySwatch: Colors.blue,
//         visualDensity: VisualDensity.adaptivePlatformDensity,
//       ),
//       home: GameScreen(),
//     );
//   }
// }

// class GameScreen extends StatefulWidget {
//   @override
//   _GameScreenState createState() => _GameScreenState();
// }

// class _GameScreenState extends State<GameScreen> {
//   late SpiritSimonGame _game;

//   @override
//   void initState() {
//     super.initState();
//     _game = SpiritSimonGame();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.black,
//       body: Stack(
//         children: [
//           GameWidget(game: _game),
//           Positioned(
//             top: 40,
//             left: 0,
//             right: 0,
//             child: GameInfoOverlay(game: _game),
//           ),
//           // The key fix - make sure we're using ValueListenableBuilder
//           // to properly respond to game state changes
//           ValueListenableBuilder<GameState>(
//             valueListenable: _game.gameStateNotifier,
//             builder: (context, gameState, _) {
//               if (gameState == GameState.idle ||
//                   gameState == GameState.gameOver ||
//                   gameState == GameState.gameWon) {
//                 return Positioned.fill(
//                   child: GameMenuOverlay(game: _game),
//                 );
//               } else {
//                 return SizedBox.shrink(); // Don't show menu during gameplay
//               }
//             },
//           ),
//         ],
//       ),
//     );
//   }
// }

// class GameInfoOverlay extends StatelessWidget {
//   final SpiritSimonGame game;

//   const GameInfoOverlay({required this.game});

//   @override
//   Widget build(BuildContext context) {
//     return ValueListenableBuilder<GameState>(
//       valueListenable: game.gameStateNotifier,
//       builder: (context, gameState, _) {
//         if (gameState == GameState.idle) return SizedBox.shrink();

//         return Column(
//           children: [
//             Text(
//               'Score: ${game.score}',
//               style: TextStyle(color: Colors.white, fontSize: 24),
//             ),
//             SizedBox(height: 8),
//             Text(
//               'Round: ${game.round} of 7',
//               style: TextStyle(color: Colors.white, fontSize: 24),
//             ),
//             SizedBox(height: 8),
//             if (gameState == GameState.playerTurn)
//               Text(
//                 'Your turn - Free the spirits by repeating the sequence! '
//                 '(${game.currentPosition}/${game.sequence.length})',
//                 style: TextStyle(color: Colors.white70, fontSize: 16),
//                 textAlign: TextAlign.center,
//               ),
//             if (gameState == GameState.playing && game.sequence.isNotEmpty)
//               Text(
//                 'Watch the sequence...',
//                 style: TextStyle(color: Colors.white70, fontSize: 16),
//               ),
//             if (gameState != GameState.idle &&
//                 gameState != GameState.playing &&
//                 gameState != GameState.playerTurn &&
//                 gameState != GameState.gameOver &&
//                 gameState != GameState.gameWon)
//               Text(
//                 'Get ready for next sequence...',
//                 style: TextStyle(color: Colors.white70, fontSize: 16),
//               ),
//           ],
//         );
//       },
//     );
//   }
// }

// class GameMenuOverlay extends StatelessWidget {
//   final SpiritSimonGame game;

//   const GameMenuOverlay({required this.game});

//   @override
//   Widget build(BuildContext context) {
//     return ValueListenableBuilder<GameState>(
//       valueListenable: game.gameStateNotifier,
//       builder: (context, gameState, _) {
//         return Container(
//           color: Colors.black.withOpacity(0.7),
//           child: Center(
//             child: Container(
//               width: 300,
//               padding: EdgeInsets.all(24),
//               decoration: BoxDecoration(
//                 color: Colors.black87,
//                 borderRadius: BorderRadius.circular(16),
//               ),
//               child: Column(
//                 mainAxisSize: MainAxisSize.min,
//                 children: [
//                   if (gameState == GameState.gameWon) ...[
//                     Text(
//                       'Congratulations!',
//                       style: TextStyle(color: Colors.white, fontSize: 24),
//                     ),
//                     SizedBox(height: 16),
//                     Text(
//                       'You freed all the spirits!',
//                       style: TextStyle(color: Colors.white, fontSize: 18),
//                     ),
//                     SizedBox(height: 8),
//                     Text(
//                       'Final Score: ${game.score}',
//                       style: TextStyle(color: Colors.white, fontSize: 18),
//                     ),
//                   ] else if (gameState == GameState.gameOver) ...[
//                     Text(
//                       'Game Over!',
//                       style: TextStyle(color: Colors.white, fontSize: 24),
//                     ),
//                     SizedBox(height: 16),
//                     Text(
//                       'Score: ${game.score}',
//                       style: TextStyle(color: Colors.white, fontSize: 18),
//                     ),
//                     SizedBox(height: 8),
//                     Text(
//                       'Round: ${game.round}',
//                       style: TextStyle(color: Colors.white, fontSize: 18),
//                     ),
//                   ] else ...[
//                     Text(
//                       'Free the trapped spirits by repeating the patterns!',
//                       style: TextStyle(color: Colors.white, fontSize: 18),
//                       textAlign: TextAlign.center,
//                     ),
//                   ],
//                   SizedBox(height: 24),
//                   ElevatedButton(
//                     onPressed: () {
//                       game.startGame();
//                     },
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: Colors.green,
//                       padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
//                     ),
//                     child: Text(
//                       gameState == GameState.gameOver || gameState == GameState.gameWon
//                           ? 'Play Again'
//                           : 'Start Game',
//                       style: TextStyle(fontSize: 18),
//                     ),
//                   ),
//                   SizedBox(height: 16),
//                   Text(
//                     'Spirit Sound:',
//                     style: TextStyle(color: Colors.white, fontSize: 16),
//                   ),
//                   SizedBox(height: 8),
//                   Container(
//                     padding: EdgeInsets.symmetric(horizontal: 12),
//                     decoration: BoxDecoration(
//                       color: Colors.white.withOpacity(0.1),
//                       borderRadius: BorderRadius.circular(8),
//                       border: Border.all(color: Colors.white30),
//                     ),
//                     child: DropdownButton<String>(
//                       value: game.selectedInstrument,
//                       dropdownColor: Colors.black87,
//                       style: TextStyle(color: Colors.white),
//                       underline: SizedBox(),
//                       isExpanded: true,
//                       items: [
//                         DropdownMenuItem(
//                           value: 'piano',
//                           child: Text('Gentle Piano'),
//                         ),
//                         DropdownMenuItem(
//                           value: 'marimba',
//                           child: Text('Marimba Spirits'),
//                         ),
//                         DropdownMenuItem(
//                           value: 'synth',
//                           child: Text('Magic Synth'),
//                         ),
//                       ],
//                       onChanged: (value) {
//                         if (value != null) {
//                           game.setInstrument(value);
//                         }
//                       },
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         );
//       },
//     );
//   }
// }

// enum GameState {
//   idle,
//   playing,
//   playerTurn,
//   gameOver,
//   gameWon,
// }

// class SpiritSimonGame extends FlameGame with TapCallbacks {
//   static const int MAX_ROUNDS = 7;
//   static const double TILE_SIZE = 100.0;
//   static const double TILE_GAP = 20.0;

//   // Game state
//   final List<Color> tileColors = [
//     Color(0xFFFF6B6B), // Pink
//     Color(0xFF4ECDC4), // Teal
//     Color(0xFF45B7D1), // Blue
//     Color(0xFF96CEB4), // Mint
//     Color(0xFFFFEEAD), // Gold
//     Color(0xFFD4A5A5), // Rose
//     Color(0xFF9B59B6), // Purple
//     Color(0xFF3498DB), // Royal Blue
//     Color(0xFFE74C3C),  // Red
//   ];

//   List<SpiritTile> tiles = [];
//   List<int> sequence = [];
//   List<int> playerSequence = [];
//   List<int> correctClicks = [];

//   int currentPosition = 0;
//   int score = 0;
//   int round = 1;
//   bool isPlaying = false;
//   bool gameStarted = false;
//   bool playerTurn = false;
//   int? highlightedTile;

//   String selectedInstrument = 'piano';

//   // Use ValueNotifier for all game state changes
//   final ValueNotifier<GameState> gameStateNotifier = ValueNotifier(GameState.idle);

//   // Audio players
//   late AudioPlayer pianoPlayer;
//   late AudioPlayer marimbaPlayer;
//   late AudioPlayer synthPlayer;
//   late AudioPlayer successPlayer;
//   late AudioPlayer failurePlayer;
//   late AudioPlayer spiritReleasePlayer;

//   // Random generator
//   final Random random = Random();

//   @override
//   Future<void> onLoad() async {
//     await super.onLoad();

//     // Load audio players
//     pianoPlayer = AudioPlayer();
//     marimbaPlayer = AudioPlayer();
//     synthPlayer = AudioPlayer();
//     successPlayer = AudioPlayer();
//     failurePlayer = AudioPlayer();
//     spiritReleasePlayer = AudioPlayer();

//     // Initialize audio
//     await _initAudio();

//     // Create tiles
//     _createTiles();

//     // Set initial state
//     gameStateNotifier.value = GameState.idle;
//   }

//   Future<void> _initAudio() async {
//     // In a real implementation, you would load actual audio files
//     // For this example, we'll just simulate the audio functionality
//   }

//   void _createTiles() {
//     tiles.clear();

//     final gridSize = 3; // 3x3 grid
//     final totalWidth = gridSize * TILE_SIZE + (gridSize - 1) * TILE_GAP;
//     final startX = size.x / 2 - totalWidth / 2 + TILE_SIZE / 2;
//     final startY = size.y / 2 - totalWidth / 2 + TILE_SIZE / 2;

//     for (int i = 0; i < gridSize; i++) {
//       for (int j = 0; j < gridSize; j++) {
//         final index = i * gridSize + j;
//         final position = Vector2(
//           startX + j * (TILE_SIZE + TILE_GAP),
//           startY + i * (TILE_SIZE + TILE_GAP),
//         );

//         final tile = SpiritTile(
//           position: position,
//           size: Vector2(TILE_SIZE, TILE_SIZE),
//           color: tileColors[index],
//           id: index,
//           game: this,
//         );

//         tiles.add(tile);
//         add(tile);
//       }
//     }
//   }

//   // Add this method to your SpiritSimonGame class
//   void markNeedsUpdate() {
//     // Force all tiles to update their visual state
//     for (final tile in tiles) {
//       // Update tile state based on current game conditions
//       tile.isHighlighted = tile.id == highlightedTile;
//       tile.isActive = playerSequence.contains(tile.id);
//       tile.correctClick = correctClicks.contains(tile.id);
//     }
//   }

//   void startGame() {
//     // The key fix: properly set state with our ValueNotifier
//     gameStarted = true;
//     round = 1;
//     score = 0;
//     playerSequence = [];
//     currentPosition = 0;
//     correctClicks = [];

//     // Generate new sequence
//     sequence = _generateRandomSequence(1);
//     isPlaying = true;
//     playerTurn = false;

//     // Update game state - THIS TRIGGERS THE UI CHANGES
//     gameStateNotifier.value = GameState.idle; // Force a change first
//     gameStateNotifier.value = GameState.playing; // Then set the actual value

//     // Play sequence after delay
//     Future.delayed(Duration(milliseconds: 1000), () {
//       playSequence(sequence);
//     });
//   }

//   List<int> _generateRandomSequence(int length) {
//     List<int> newSequence = [];
//     for (int i = 0; i < length; i++) {
//       int newTileId;
//       do {
//         newTileId = random.nextInt(9); // 9 tiles (3x3 grid)
//       } while (newSequence.isNotEmpty &&
//                newTileId == newSequence.last &&
//                tiles.length > 1);

//       newSequence.add(newTileId);
//     }
//     return newSequence;
//   }

//   Future<void> playSequence(List<int> seq) async {
//     isPlaying = true;
//     playerTurn = false;
//     playerSequence = [];
//     currentPosition = 0;
//     correctClicks = [];

//     // Clear any active state from previous rounds
//     for (final tile in tiles) {
//       tile.isActive = false;
//       tile.correctClick = false;
//       tile.spiritReleased = false;
//       if (tile.spirit != null) {
//         tile.spirit!.isReleased = false;
//         tile.spirit!.opacity = 0.9;
//       }
//     }

//     gameStateNotifier.value = GameState.playing;

//     // Clear any highlighted tiles
//     highlightedTile = null;

//     // Play each tile in sequence
//     for (int i = 0; i < seq.length; i++) {
//       highlightedTile = seq[i];
//       _playTileSound(seq[i]);

//       // Make sure to force redraw
//       markNeedsUpdate();

//       await Future.delayed(Duration(milliseconds: 600));
//       highlightedTile = null;

//       // Make sure to force redraw
//       markNeedsUpdate();

//       await Future.delayed(Duration(milliseconds: 300));

//       if (i < seq.length - 1) {
//         await Future.delayed(Duration(milliseconds: 200));
//       }
//     }

//     // Sequence done, player's turn
//     isPlaying = false;
//     playerTurn = true;
//     gameStateNotifier.value = GameState.playerTurn;
//   }

//   void _playTileSound(int tileId) {
//     // In a real implementation, you would play the actual sound here
//     // For example: players[selectedInstrument][tileId].play();
//   }

//   void handleTileClick(int tileId) {
//     // Don't allow clicks if it's not player's turn or game is over
//     if (gameStateNotifier.value != GameState.playerTurn) return;

//     // Play sound for clicked tile
//     _playTileSound(tileId);

//     // Check if the clicked tile matches the current position in the sequence
//     final expectedTile = sequence[currentPosition];

//     if (tileId == expectedTile) {
//       // Correct tile!
//       final newPosition = currentPosition + 1;
//       currentPosition = newPosition;

//       // Add to correct clicks for spirit animation
//       correctClicks.add(tileId);

//       // Add to player sequence for visual feedback
//       playerSequence.add(tileId);

//       // Force the tile to update its state immediately
//       SpiritTile? clickedTile;
//       for (final tile in tiles) {
//         if (tile.id == tileId) {
//           tile.isActive = true;
//           tile.correctClick = true;
//           clickedTile = tile;

//           // Force spirit to release
//           if (tile.spirit != null && !tile.spiritReleased) {
//             tile.spiritReleased = true;
//             tile.spirit!.release();
//             // Uncomment when audio is implemented
//             // spiritReleasePlayer.play();
//           }
//         }
//       }

//       // Force update
//       markNeedsUpdate();

//       // Check if player completed the sequence
//       if (newPosition == sequence.length) {
//         // Player completed the sequence!
//         Future.delayed(Duration(milliseconds: 500), () {
//           // Play success sound
//           // successPlayer.play();
//           score++;
//         });

//         // Check if player completed all rounds
//         if (round == MAX_ROUNDS) {
//           gameStateNotifier.value = GameState.gameWon;
//           return;
//         }

//         // Progress to next round
//         round++;

//         // Generate new sequence
//         Future.delayed(Duration(milliseconds: 1500), () {
//           // Reset state between rounds
//           playerSequence = [];
//           currentPosition = 0;

//           // Generate new sequence with increased length
//           sequence = _generateRandomSequence(round);

//           // Play the new sequence
//           playSequence(sequence);
//         });
//       }
//     } else {
//       // Wrong tile
//       // failurePlayer.play();
//       gameStateNotifier.value = GameState.gameOver;
//     }
//   }

//   void setInstrument(String instrument) {
//     selectedInstrument = instrument;
//     // We don't need to trigger a UI update here as the value hasn't changed
//   }

//   @override
//   void onTapUp(TapUpEvent event) {
//     super.onTapUp(event);

//     print("Tap detected at: ${event.canvasPosition}");

//     // Check if any tile was tapped only during player's turn
//     if (gameStateNotifier.value == GameState.playerTurn) {
//       for (final tile in tiles) {
//         // Debug the hit testing
//         final contains = tile.containsPoint(event.canvasPosition);
//         print("Checking tile ${tile.id}: contains=${contains}");

//         if (contains) {
//           print("Handling click on tile ${tile.id}");
//           handleTileClick(tile.id);
//           break; // Handle only one tile per tap
//         }
//       }
//     } else {
//       print("Tap ignored - not player's turn. Current state: ${gameStateNotifier.value}");
//     }
//   }

//   @override
//   void update(double dt) {
//     super.update(dt);

//     // Update tile visual states - force the update regardless of game state
//     for (final tile in tiles) {
//       // Always update highlight state
//       tile.isHighlighted = tile.id == highlightedTile;

//       // Make sure tiles show player's clicks
//       tile.isActive = playerSequence.contains(tile.id);

//       // Make sure correct clicks are registered for spirit release
//       if (correctClicks.contains(tile.id) && gameStateNotifier.value == GameState.playerTurn) {
//         tile.correctClick = true;
//       }
//     }
//   }
// }

// class SpiritTile extends PositionComponent with HasGameRef<SpiritSimonGame> {
//   final Color color;
//   final int id;
//   final SpiritSimonGame game;

//   bool isHighlighted = false;
//   bool isActive = false;
//   bool correctClick = false;
//   bool spiritReleased = false;

//   Spirit? spirit;

//   SpiritTile({
//     required Vector2 position,
//     required Vector2 size,
//     required this.color,
//     required this.id,
//     required this.game,
//   }) : super(position: position, size: size);

//   @override
//   Future<void> onLoad() async {
//     // Add a spirit to the tile
//     spirit = Spirit(
//       position: Vector2(size.x / 2, size.y / 2),
//       color: color,
//       id: id,
//     );
//     add(spirit!);
//   }

//   @override
//   void render(Canvas canvas) {
//     final rect = Rect.fromLTWH(0, 0, size.x, size.y);

//     // Draw tile background with glow effect
//     final paint = Paint()
//       ..color = isHighlighted
//           ? color // Fully opaque when highlighted
//           : color.withOpacity(0.7)
//       ..style = PaintingStyle.fill;

//     // Add glow effect when highlighted
//     if (isHighlighted) {
//       paint.maskFilter = MaskFilter.blur(BlurStyle.normal, 20);
//     }

//     // Use a rounded rectangle for the tile
//     final rrect = RRect.fromRectAndRadius(rect, Radius.circular(10));
//     canvas.drawRRect(rrect, paint);

//     // Draw tile outline
//     final borderPaint = Paint()
//       ..color = isHighlighted
//           ? Colors.white.withOpacity(0.8)  // Brighter border when highlighted
//           : Colors.white.withOpacity(0.3)
//       ..style = PaintingStyle.stroke
//       ..strokeWidth = isHighlighted ? 3 : 2;  // Thicker border when highlighted
//     canvas.drawRRect(rrect, borderPaint);

//     // Draw inner glow if active
//     if (isActive) {
//       final innerGlowPaint = Paint()
//         ..color = color.withOpacity(0.8)  // Brighter inner glow
//         ..style = PaintingStyle.fill
//         ..maskFilter = MaskFilter.blur(BlurStyle.normal, 15);  // More pronounced blur

//       final innerRect = Rect.fromLTWH(
//         size.x * 0.2, size.y * 0.2, size.x * 0.6, size.y * 0.6);
//       final innerRRect = RRect.fromRectAndRadius(
//         innerRect, Radius.circular(10));
//       canvas.drawRRect(innerRRect, innerGlowPaint);
//     }
//   }

//   @override
//   void update(double dt) {
//     super.update(dt);

//     // Check if the spirit should be released
//     if (correctClick && !spiritReleased && game.gameStateNotifier.value == GameState.playerTurn) {
//       spiritReleased = true;
//       spirit?.release();

//       // Force update to make sure visual effects display
//       game.markNeedsUpdate();

//       // Play spirit release sound (when audio is implemented)
//       // game.spiritReleasePlayer.play();
//     }
//   }
// }

// class Spirit extends PositionComponent {
//   final Color color;
//   final int id;

//   bool isReleased = false;
//   double opacity = 0.9;
//   double spiritScale = 1.0;
//   double releaseTime = 0;

//   // Track if effects have been added to prevent duplicate effects
//   bool effectsAdded = false;

//   Spirit({
//     required Vector2 position,
//     required this.color,
//     required this.id,
//   }) : super(position: position, size: Vector2(30, 30));

//   @override
//   Future<void> onLoad() async {
//     // Add a floating effect to the spirit
//     add(
//       MoveEffect.by(
//         Vector2(0, 5),
//         EffectController(
//           duration: 1.5,
//           reverseDuration: 1.5,
//           infinite: true,
//           curve: Curves.easeInOut,
//         ),
//       ),
//     );
//   }

//   void release() {
//     // Only apply release effects once
//     if (isReleased || effectsAdded) return;

//     isReleased = true;
//     effectsAdded = true;

//     // Remove floating effect
//     removeWhere((component) => component is MoveEffect);

//     // Create more dramatic release effects

//     // Add upward movement with faster movement
//     add(
//       MoveEffect.by(
//         Vector2(0, -150), // Move higher
//         EffectController(
//           duration: 2,
//           curve: Curves.easeOut,
//         ),
//       ),
//     );

//     // Add fade out effect
//     add(
//       OpacityEffect.to(
//         0,
//         EffectController(
//           duration: 2,
//           curve: Curves.easeOut,
//         ),
//         onComplete: () {
//           // Make sure to remove the spirit when completely faded
//           removeFromParent();
//         },
//       ),
//     );

//     // Add scale effect - make it larger
//     add(
//       ScaleEffect.by(
//         Vector2(3, 3),
//         EffectController(
//           duration: 2,
//           curve: Curves.easeOut,
//         ),
//       ),
//     );

//     // Add rotation for more dynamic effect
//     add(
//       RotateEffect.by(
//         0.5, // Rotate a quarter turn
//         EffectController(
//           duration: 2,
//           curve: Curves.easeOut,
//         ),
//       ),
//     );
//   }

//   @override
//   void render(Canvas canvas) {
//     if (isReleased && opacity <= 0) return;

//     // Draw spirit as a glowing circle
//     final paint = Paint()
//       ..color = color.withOpacity(opacity)
//       ..style = PaintingStyle.fill
//       ..maskFilter = MaskFilter.blur(BlurStyle.normal, 10); // Increased glow

//     canvas.drawCircle(Offset(0, 0), 15 * spiritScale, paint);

//     // Draw inner glow - brighter
//     final innerPaint = Paint()
//       ..color = Colors.white.withOpacity(opacity * 0.9) // Brighter inner glow
//       ..style = PaintingStyle.fill
//       ..maskFilter = MaskFilter.blur(BlurStyle.normal, 5);

//     canvas.drawCircle(Offset(0, 0), 5 * spiritScale, innerPaint);

//     // Add sparkling effect when released
//     if (isReleased) {
//       // Draw small particles coming out from the spirit
//       final sparkPaint = Paint()
//         ..color = Colors.white.withOpacity(opacity * 0.8)
//         ..style = PaintingStyle.fill;

//       final random = Random();
//       final sparkCount = 3;

//       for (int i = 0; i < sparkCount; i++) {
//         final angle = random.nextDouble() * 2 * pi;
//         final distance = (15 + releaseTime * 30) * spiritScale;
//         final sparkSize = (3 - releaseTime / 2).clamp(0.5, 3.0);

//         final sparkX = cos(angle) * distance;
//         final sparkY = sin(angle) * distance;

//         canvas.drawCircle(
//           Offset(sparkX, sparkY),
//           sparkSize,
//           sparkPaint
//         );
//       }
//     }
//   }

//   @override
//   void update(double dt) {
//     super.update(dt);

//     if (isReleased) {
//       releaseTime += dt;

//       // Add some horizontal drift as the spirit escapes - more pronounced
//       position.x += sin(releaseTime * 3 + id) * dt * 15;

//       // Add slight vertical wobble too
//       position.y += cos(releaseTime * 5 + id) * dt * 5;

//       // Update the opacity for manual rendering
//       if (opacity > 0) {
//         opacity = max(0, opacity - (dt * 0.5)); // Fade out speed
//       }

//       // Remove when animation is complete
//       if (releaseTime > 3.0) {
//         removeFromParent();
//       }
//     }
//   }
// }

//-----------------------------------------------------___________________________________________________________

// import 'dart:async';
// import 'dart:math';
// import 'package:flutter/material.dart';
// import 'package:just_audio/just_audio.dart';
// import 'package:flame/flame.dart';
// import 'package:flame/game.dart';
// import 'package:flame/components.dart';
// import 'package:flame/events.dart'; // Use TapCallbacks and TapUpInfo
// import 'package:flame/extensions.dart';
// // import 'package:flame/particles.dart'; // Not currently used
// import 'package:flame/effects.dart';
// import 'package:flutter/services.dart';

// // --- Main Application Entry Point ---
// void main() async {
//   // Ensure Flutter bindings are initialized
//   WidgetsFlutterBinding.ensureInitialized();
//   // Set to fullscreen
//   await Flame.device.fullScreen();
//   // Lock orientation to portrait
//   await Flame.device.setOrientation(DeviceOrientation.portraitUp);
//   // Run the app
//   runApp(MyApp());
// }

// // --- Root Application Widget ---
// class MyApp extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       // Hide the debug banner
//       debugShowCheckedModeBanner: false,
//       title: 'Spirit Simon Game',
//       // Basic theme
//       theme: ThemeData(
//         primarySwatch: Colors.blue,
//         visualDensity: VisualDensity.adaptivePlatformDensity,
//       ),
//       // Set the home screen
//       home: GameScreen(),
//     );
//   }
// }

// // --- Game Screen Widget (Hosts the GameWidget and Overlays) ---
// class GameScreen extends StatefulWidget {
//   @override
//   _GameScreenState createState() => _GameScreenState();
// }

// class _GameScreenState extends State<GameScreen> {
//   // Declare the game instance
//   late SpiritSimonGame _game;

//   @override
//   void initState() {
//     super.initState();
//     // Initialize the game instance
//     _game = SpiritSimonGame();
//   }

//   @override
//   void dispose() {
//     // Clean up game resources if the screen is disposed (optional, Flame manages some)
//     // _game.onRemove(); // Consider if needed for specific cleanup beyond Flame's default
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       // Background color for areas outside the game widget (if any)
//       backgroundColor: Colors.black,
//       // Use a Stack to layer the GameWidget and overlays
//       body: Stack(
//         children: [
//           // The main game view
//           GameWidget(game: _game),
//           // Top overlay for score and round info
//           Positioned(
//             top: 40, // Position from the top
//             left: 0,
//             right: 0,
//             child: GameInfoOverlay(game: _game), // Pass the game instance
//           ),
//           // Conditional overlay for Start/Game Over/Win menus
//           ValueListenableBuilder<GameState>(
//             valueListenable: _game.gameStateNotifier, // Listen to game state changes
//             builder: (context, gameState, _) {
//               // Show the menu overlay only in idle, game over, or game won states
//               if (gameState == GameState.idle ||
//                   gameState == GameState.gameOver ||
//                   gameState == GameState.gameWon) {
//                 return Positioned.fill(
//                   child: GameMenuOverlay(game: _game), // Pass the game instance
//                 );
//               } else {
//                 // Otherwise, show nothing (an empty box)
//                 return SizedBox.shrink();
//               }
//             },
//           ),
//         ],
//       ),
//     );
//   }
// }

// // --- Top Overlay for Score and Round Information ---
// class GameInfoOverlay extends StatelessWidget {
//   final SpiritSimonGame game;

//   // Use const constructor for stateless widgets
//   const GameInfoOverlay({required this.game, Key? key}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     // Use ValueListenableBuilder to react to game state changes
//     return ValueListenableBuilder<GameState>(
//       valueListenable: game.gameStateNotifier,
//       builder: (context, gameState, _) {
//         // Hide the info overlay during idle, game over, or win states (menu handles that)
//         if (gameState == GameState.idle || gameState == GameState.gameOver || gameState == GameState.gameWon) {
//           return SizedBox.shrink();
//         }

//         // Display score, round, and turn information
//         return Column(
//           children: [
//             Text(
//               'Score: ${game.score}',
//               style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
//             ),
//             SizedBox(height: 8),
//             Text(
//               'Round: ${game.round} of ${SpiritSimonGame.MAX_ROUNDS}',
//               style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
//             ),
//             SizedBox(height: 12), // More spacing
//             // Show player turn instructions
//             if (gameState == GameState.playerTurn)
//               Padding(
//                 padding: const EdgeInsets.symmetric(horizontal: 20.0),
//                 child: Text(
//                   'Your turn: Repeat the sequence! (${game.currentPosition}/${game.sequence.length})',
//                   style: TextStyle(color: Colors.lightBlueAccent, fontSize: 16), // Highlight color
//                   textAlign: TextAlign.center,
//                 ),
//               ),
//             // Show message while computer is playing
//             if (gameState == GameState.playing && game.sequence.isNotEmpty)
//               Padding(
//                 padding: const EdgeInsets.symmetric(horizontal: 20.0),
//                 child: Text(
//                   'Watch the spirits...',
//                   style: TextStyle(color: Colors.yellowAccent, fontSize: 16), // Highlight color
//                   textAlign: TextAlign.center,
//                 ),
//               ),
//           ],
//         );
//       },
//     );
//   }
// }

// // --- Overlay for Start Menu, Game Over, and Game Won Screens ---
// class GameMenuOverlay extends StatelessWidget {
//   final SpiritSimonGame game;

//   // Use const constructor
//   const GameMenuOverlay({required this.game, Key? key}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     // Get the current game state directly (visibility controlled by GameScreen)
//     final gameState = game.gameStateNotifier.value;

//     return Container(
//       // Semi-transparent background
//       color: Colors.black.withOpacity(0.8),
//       child: Center(
//         child: Container(
//           width: 320, // Menu width
//           padding: EdgeInsets.all(30), // Menu padding
//           decoration: BoxDecoration(
//             color: Color(0xFF1A1A2E), // Dark blue background
//             borderRadius: BorderRadius.circular(20),
//             boxShadow: [ // Subtle shadow for depth
//               BoxShadow(
//                 color: Colors.black.withOpacity(0.5),
//                 blurRadius: 15,
//                 offset: Offset(0, 5),
//               )
//             ],
//             border: Border.all(color: Colors.lightBlue.withOpacity(0.5), width: 1), // Border
//           ),
//           child: Column(
//             mainAxisSize: MainAxisSize.min, // Fit content height
//             children: [
//               // --- Content based on Game State ---
//               if (gameState == GameState.gameWon) ...[
//                 Icon(Icons.star, color: Colors.yellowAccent, size: 50),
//                 SizedBox(height: 16),
//                 Text(
//                   'Congratulations!',
//                   style: TextStyle(color: Colors.yellowAccent, fontSize: 28, fontWeight: FontWeight.bold),
//                 ),
//                 SizedBox(height: 16),
//                 Text(
//                   'You freed all the spirits!',
//                   style: TextStyle(color: Colors.white, fontSize: 18),
//                   textAlign: TextAlign.center,
//                 ),
//                 SizedBox(height: 8),
//                 Text(
//                   'Final Score: ${game.score}',
//                   style: TextStyle(color: Colors.white, fontSize: 20),
//                 ),
//               ] else if (gameState == GameState.gameOver) ...[
//                 Icon(Icons.sentiment_dissatisfied, color: Colors.redAccent, size: 50),
//                 SizedBox(height: 16),
//                 Text(
//                   'Game Over!',
//                   style: TextStyle(color: Colors.redAccent, fontSize: 28, fontWeight: FontWeight.bold),
//                 ),
//                 SizedBox(height: 16),
//                 Text(
//                   'The spirits remain trapped...',
//                   style: TextStyle(color: Colors.white70, fontSize: 16),
//                   textAlign: TextAlign.center,
//                 ),
//                 SizedBox(height: 12),
//                 Text(
//                   'Score: ${game.score}',
//                   style: TextStyle(color: Colors.white, fontSize: 20),
//                 ),
//                 SizedBox(height: 8),
//                 Text(
//                   'Round: ${game.round}',
//                   style: TextStyle(color: Colors.white, fontSize: 20),
//                 ),
//               ] else ...[ // Idle state (Start Menu)
//                 Icon(Icons.auto_awesome, color: Colors.lightBlueAccent, size: 50), // Magic icon
//                 SizedBox(height: 16),
//                 Text(
//                   'Spirit Simon', // Game Title
//                   style: TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.bold),
//                   textAlign: TextAlign.center,
//                 ),
//                 SizedBox(height: 12),
//                 Text(
//                   'Free the trapped spirits by repeating their mystical patterns!',
//                   style: TextStyle(color: Colors.white70, fontSize: 16),
//                   textAlign: TextAlign.center,
//                 ),
//               ],
//               SizedBox(height: 30), // Spacing before button

//               // --- Start/Play Again Button ---
//               ElevatedButton(
//                 onPressed: () {
//                   // Call the game's start method
//                   game.startGame();
//                 },
//                 style: ElevatedButton.styleFrom(
//                   // Different colors for Start vs Play Again
//                   backgroundColor: gameState == GameState.gameOver || gameState == GameState.gameWon
//                       ? Colors.orangeAccent
//                       : Colors.greenAccent,
//                   padding: EdgeInsets.symmetric(horizontal: 40, vertical: 18),
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(30), // Rounded shape
//                   ),
//                   textStyle: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
//                 ),
//                 child: Text(
//                   // Different text for Start vs Play Again
//                   gameState == GameState.gameOver || gameState == GameState.gameWon
//                       ? 'Play Again'
//                       : 'Start Game',
//                 ),
//               ),
//               SizedBox(height: 24), // Spacing before dropdown

//               // --- Instrument Selection Dropdown ---
//               Text(
//                 'Spirit Sound:',
//                 style: TextStyle(color: Colors.white, fontSize: 16),
//               ),
//               SizedBox(height: 8),
//               Container(
//                 padding: EdgeInsets.symmetric(horizontal: 12),
//                 decoration: BoxDecoration(
//                   color: Colors.white.withOpacity(0.1),
//                   borderRadius: BorderRadius.circular(8),
//                   border: Border.all(color: Colors.lightBlue.withOpacity(0.3)),
//                 ),
//                 child: DropdownButtonHideUnderline( // Remove default line
//                   child: DropdownButton<String>(
//                     value: game.selectedInstrument, // Current selection
//                     dropdownColor: Color(0xFF1A1A2E), // Match menu background
//                     style: TextStyle(color: Colors.white, fontSize: 16),
//                     icon: Icon(Icons.arrow_drop_down, color: Colors.lightBlueAccent), // Custom icon
//                     isExpanded: true, // Fill width
//                     items: [ // Dropdown options
//                       DropdownMenuItem(value: 'piano', child: Text('Gentle Piano')),
//                       DropdownMenuItem(value: 'marimba', child: Text('Marimba Spirits')),
//                       DropdownMenuItem(value: 'synth', child: Text('Magic Synth')),
//                     ],
//                     onChanged: (value) {
//                       // Update game's instrument selection
//                       if (value != null) {
//                         game.setInstrument(value);
//                       }
//                     },
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

// // --- Enum Defining the Possible Game States ---
// enum GameState {
//   idle, // Before start or after game end, showing menu
//   playing, // Computer showing sequence
//   playerTurn, // Waiting for player input
//   gameOver, // Player made mistake, showing menu
//   gameWon, // Player completed all rounds, showing menu
// }

// // --- Main Game Logic Class (FlameGame) ---
// class SpiritSimonGame extends FlameGame with TapCallbacks { // Use TapCallbacks mixin
//   // --- Game Constants ---
//   static const int MAX_ROUNDS = 7;
//   static const double TILE_SIZE = 100.0;
//   static const double TILE_GAP = 20.0;

//   // --- Game Assets and Configuration ---
//   final List<Color> tileColors = [ // Colors for the 9 tiles
//     Color(0xFFFF6B6B), Color(0xFF4ECDC4), Color(0xFF45B7D1), // Row 1
//     Color(0xFF96CEB4), Color(0xFFFFEEAD), Color(0xFFD4A5A5), // Row 2
//     Color(0xFF9B59B6), Color(0xFF3498DB), Color(0xFFE74C3C), // Row 3
//   ];
//   String selectedInstrument = 'piano'; // Default instrument sound

//   // --- Game State Variables ---
//   List<SpiritTile> tiles = []; // List of tile components
//   List<int> sequence = []; // The sequence generated by the computer
//   List<int> playerSequence = []; // Player's correct inputs this round

//   int currentPosition = 0; // Index the player needs to press next
//   int score = 0;
//   int round = 1;
//   int? highlightedTile; // ID of tile being shown by the computer

//   // Single source of truth for game state changes, notifies listeners (like overlays)
//   final ValueNotifier<GameState> gameStateNotifier = ValueNotifier(GameState.idle);

//   // --- Audio Players ---
//   // One player for each potential sound type
//   late AudioPlayer pianoPlayer;
//   late AudioPlayer marimbaPlayer;
//   late AudioPlayer synthPlayer;
//   late AudioPlayer successPlayer;
//   late AudioPlayer failurePlayer;
//   late AudioPlayer spiritReleasePlayer;

//   // Random number generator for sequences
//   final Random random = Random();

//   // --- Initialization and Cleanup ---
//   @override
//   Future<void> onLoad() async {
//     await super.onLoad();

//     // Initialize audio players
//     pianoPlayer = AudioPlayer();
//     marimbaPlayer = AudioPlayer();
//     synthPlayer = AudioPlayer();
//     successPlayer = AudioPlayer();
//     failurePlayer = AudioPlayer();
//     spiritReleasePlayer = AudioPlayer();

//     // Load audio files (placeholder)
//     await _initAudio();
//     // Create the visual tile components
//     _createTiles();

//     // Set the initial game state
//     gameStateNotifier.value = GameState.idle;
//   }

//   @override
//   void onRemove() {
//     // Dispose audio players when the game is removed to free resources
//     pianoPlayer.dispose();
//     marimbaPlayer.dispose();
//     synthPlayer.dispose();
//     successPlayer.dispose();
//     failurePlayer.dispose();
//     spiritReleasePlayer.dispose();
//     super.onRemove();
//   }

//   // Placeholder for loading actual audio assets
//   Future<void> _initAudio() async {
//     // TODO: Implement audio loading from assets folder
//     // Example: await successPlayer.setAsset('assets/audio/success.mp3');
//     // Example: await failurePlayer.setAsset('assets/audio/failure.mp3');
//     // Example: await spiritReleasePlayer.setAsset('assets/audio/spirit_release.mp3');
//     // You'll also need to load the instrument note sounds, potentially into a map or list
//     // keyed by tile ID or note name.
//     print("Audio init: Placeholder - Load actual files.");
//   }

//   // Creates and adds the SpiritTile components to the game
//   void _createTiles() {
//     // Clear any existing tiles if the game is restarting
//     children.whereType<SpiritTile>().forEach(remove);
//     tiles.clear();

//     final gridSize = 3; // 3x3 grid
//     final totalWidth = gridSize * TILE_SIZE + (gridSize - 1) * TILE_GAP;
//     // Calculate starting position to center the grid
//     final startX = (size.x - totalWidth) / 2;
//     final startY = (size.y - totalWidth) / 2; // Adjust as needed for vertical centering

//     // Create each tile and add it to the game
//     for (int i = 0; i < gridSize; i++) { // Rows
//       for (int j = 0; j < gridSize; j++) { // Columns
//         final index = i * gridSize + j;
//         final tile = SpiritTile(
//           position: Vector2(
//             startX + j * (TILE_SIZE + TILE_GAP), // X position
//             startY + i * (TILE_SIZE + TILE_GAP), // Y position
//           ),
//           size: Vector2(TILE_SIZE, TILE_SIZE),
//           color: tileColors[index], // Assign color based on index
//           id: index, // Assign ID based on index
//           game: this, // Pass game reference
//         );
//         tiles.add(tile); // Add to list for easy access
//         add(tile); // Add component to the game world
//       }
//     }
//   }

//   // --- Game Flow Methods ---

//   // Starts a new game or restarts after game over/win
//   void startGame() {
//     // Reset game variables
//     score = 0;
//     round = 1;
//     sequence.clear();
//     playerSequence.clear();
//     currentPosition = 0;
//     highlightedTile = null;

//     // Reset the visual state of all tiles and their spirits
//     for (final tile in tiles) {
//       tile.resetState();
//     }

//     // Add the first step to the sequence
//     _addToSequence();

//     // Delay slightly before starting the first sequence playback
//     Future.delayed(Duration(milliseconds: 500), () {
//       // Change state to playing, which triggers overlays to hide/show
//       gameStateNotifier.value = GameState.playing;
//       // Begin showing the sequence to the player
//       playSequence();
//     });
//   }

//   // Adds one new random step to the current sequence
//   void _addToSequence() {
//     int newTileId;
//     if (tiles.isEmpty) return; // Safety check
//     final availableTiles = tileColors.length; // Use number of colors/tiles
//     do {
//       // Pick a random tile index
//       newTileId = random.nextInt(availableTiles);
//       // Avoid immediate repetition if possible and if there's more than one tile
//     } while (sequence.isNotEmpty &&
//              newTileId == sequence.last &&
//              availableTiles > 1);
//     sequence.add(newTileId); // Add the new step
//   }

//   // Plays the current sequence visually to the player
//   Future<void> playSequence() async {
//     // Double-check we are still in the playing state
//     if (gameStateNotifier.value != GameState.playing) {
//       print("Warning: Tried to play sequence when not in 'playing' state.");
//       return; // Exit if state changed unexpectedly
//     }

//     // Reset player input tracking for this round
//     playerSequence.clear();
//     currentPosition = 0;

//     // Ensure no tiles are highlighted or active initially
//     highlightedTile = null;
//     for (final tile in tiles) {
//       tile.isHighlighted = false;
//       tile.setActive(false); // Ensure player glow is off
//     }

//     // Brief pause before starting the sequence display
//     await Future.delayed(Duration(milliseconds: 500));

//     // Iterate through the sequence and highlight each tile
//     for (int i = 0; i < sequence.length; i++) {
//       // Check state again in case game ended during playback
//       if (gameStateNotifier.value != GameState.playing) break;

//       final tileId = sequence[i];
//       highlightedTile = tileId; // Track which tile is globally highlighted

//       // Find the corresponding tile component and set its highlight state
//       final tileComponent = tiles.firstWhere((t) => t.id == tileId);
//       tileComponent.isHighlighted = true;

//       _playTileSound(tileId); // Play sound for this tile

//       // Duration the tile stays highlighted
//       await Future.delayed(Duration(milliseconds: 600));
//       if (gameStateNotifier.value != GameState.playing) break; // Check state after delay

//       // Turn off highlight for the current tile
//       tileComponent.isHighlighted = false;
//       highlightedTile = null; // Clear global highlight tracker

//       // Pause between tile highlights
//       if (i < sequence.length - 1) {
//         await Future.delayed(Duration(milliseconds: 300));
//       }
//     }

//     // If the game is still in the 'playing' state after showing the sequence
//     if (gameStateNotifier.value == GameState.playing) {
//       // Switch to player's turn
//       gameStateNotifier.value = GameState.playerTurn;
//     }
//   }

//   // Placeholder for playing the sound associated with a tile
//   void _playTileSound(int tileId) {
//     // TODO: Implement actual sound playback based on selectedInstrument and tileId
//     // You might need a map or function to get the correct AudioPlayer/sound asset.
//     // Example: getAudioPlayer(selectedInstrument, tileId).seek(Duration.zero);
//     // Example: getAudioPlayer(selectedInstrument, tileId).play();
//     print("Playing sound for tile $tileId (Instrument: $selectedInstrument - Placeholder)");
//   }

//   // Handles the logic when a player taps on a tile
//   void handleTileClick(int tileId) {
//     // Ignore taps if it's not the player's turn
//     if (gameStateNotifier.value != GameState.playerTurn) return;

//     // Find the component for the clicked tile
//     final tileComponent = tiles.firstWhere((t) => t.id == tileId);
//     _playTileSound(tileId); // Play sound feedback for the tap

//     // Check if the clicked tile matches the expected tile in the sequence
//     if (tileId == sequence[currentPosition]) {
//       // --- CORRECT CLICK ---
//       playerSequence.add(tileId); // Record the correct tap
//       currentPosition++; // Move to the next expected position

//       // Provide visual feedback on the tile
//       tileComponent.setActive(true); // Activate the player's glow
//       tileComponent.triggerSpiritRelease(); // Start the spirit release animation
//       // TODO: Play spirit release sound if it's distinct from the tile sound
//       // spiritReleasePlayer.play();

//       // Check if the player has completed the sequence for this round
//       if (currentPosition == sequence.length) {
//         // --- ROUND COMPLETE ---
//         gameStateNotifier.value = GameState.playing; // Temporarily switch state back
//         score++; // Increase score

//         // Check if this was the final round (Game Won)
//         if (round == MAX_ROUNDS) {
//           // Delay slightly before showing the win screen
//           Future.delayed(Duration(milliseconds: 500), () {
//             // TODO: Play game win sound
//             gameStateNotifier.value = GameState.gameWon;
//           });
//           return; // End the turn processing
//         }

//         // --- PREPARE FOR NEXT ROUND ---
//         round++; // Advance to the next round number
//         _addToSequence(); // Add the next step for the upcoming sequence

//         // Schedule the next sequence playback after a delay
//         Future.delayed(Duration(milliseconds: 1200), () {
//           // Only play if the game hasn't ended in the meantime
//           if (gameStateNotifier.value == GameState.playing) {
//             playSequence();
//           }
//         });
//       }
//       // If sequence not yet complete, simply wait for the player's next tap.

//     } else {
//       // --- INCORRECT CLICK ---
//       // TODO: Play failure sound
//       // failurePlayer.play();
//       print("Game Over! Wrong tile: clicked $tileId, expected ${sequence[currentPosition]}");
//       tileComponent.showError(); // Show error visual feedback on the tile
//       // Set the game state to Game Over
//       gameStateNotifier.value = GameState.gameOver;
//     }
//   }

//   // Updates the selected instrument sound pack
//   void setInstrument(String instrument) {
//     selectedInstrument = instrument;
//     // Notify listeners (mainly the GameMenuOverlay dropdown) to update the display
//     // This is a slight workaround; ideally, the overlay listens to a dedicated notifier.
//     gameStateNotifier.notifyListeners();
//   }

//   // --- Input Handling ---

//   // Override onTapUp from TapCallbacks mixin
//   @override
//   void onTapUp(TapUpInfo info) {
//     super.onTapUp(info); // Call superclass method

//     // Only process taps during the player's turn
//     if (gameStateNotifier.value == GameState.playerTurn) {
//       // Check which tile contains the tap position (using global coordinates)
//       for (final tile in tiles) {
//         if (tile.containsPoint(info.eventPosition.global)) {
//           // If a tile is hit, handle the click and stop checking other tiles
//           handleTileClick(tile.id);
//           break;
//         }
//       }
//     }
//   }

//   // --- Game Loop Update ---
//   // Components now handle their own visual state based on flags set by game logic
//   @override
//   void update(double dt) {
//     super.update(dt);
//     // Main update loop - can be used for continuous game logic if needed,
//     // but most logic here is event-driven (taps, sequence completion).
//   }
// }


// // --- Spirit Tile Component (Visual Representation of a Tappable Tile) ---
// class SpiritTile extends PositionComponent with HasGameRef<SpiritSimonGame> {
//   final Color color; // Base color of the tile
//   final int id;      // Unique identifier (0-8)
//   final SpiritSimonGame game; // Reference to the main game logic

//   // --- State Flags (controlled by SpiritSimonGame calling methods) ---
//   bool isHighlighted = false; // Is the computer currently highlighting this tile?
//   bool isActive = false;      // Did the player correctly click this tile in the sequence?
//   bool _showError = false;    // Should the error glow be shown briefly?

//   // Child component representing the spirit inside
//   Spirit? _spirit;

//   // --- Cached Paint Objects for Performance ---
//   late final Paint _basePaint;
//   late final Paint _highlightPaint;
//   late final Paint _borderPaint;
//   late final Paint _innerGlowPaint;
//   late final Paint _errorPaint;
//   late final RRect _rrect; // Cache the tile's rounded rectangle shape

//   SpiritTile({
//     required Vector2 position,
//     required Vector2 size,
//     required this.color,
//     required this.id,
//     required this.game,
//   }) : super(position: position, size: size, anchor: Anchor.topLeft) { // Anchor at top-left
//     // Initialize paints (colors/properties set dynamically in render)
//     _basePaint = Paint()..style = PaintingStyle.fill;
//     _highlightPaint = Paint() // For the highlight glow effect
//       ..color = color.withOpacity(0.5) // Semi-transparent base color for glow
//       ..maskFilter = MaskFilter.blur(BlurStyle.normal, 25); // Blur effect
//     _borderPaint = Paint()..style = PaintingStyle.stroke;
//     _innerGlowPaint = Paint() // Inner glow for player activation
//       ..color = Colors.white.withOpacity(0.6)
//       ..style = PaintingStyle.fill
//       ..maskFilter = MaskFilter.blur(BlurStyle.normal, 15);
//     _errorPaint = Paint() // Red glow for incorrect taps
//       ..color = Colors.redAccent.withOpacity(0.7)
//       ..style = PaintingStyle.fill
//       ..maskFilter = MaskFilter.blur(BlurStyle.outer, 10); // Outer blur

//     // Pre-calculate the rounded rectangle shape
//     _rrect = RRect.fromRectAndRadius(
//         Rect.fromLTWH(0, 0, size.x, size.y), Radius.circular(10));
//   }

//   @override
//   Future<void> onLoad() async {
//     await super.onLoad();
//     // Ensure the tile starts in its default visual state with a spirit
//     resetState();
//   }

//   // --- Methods Called by Game Logic ---

//   // Resets the tile to its default appearance and adds/resets its spirit
//   void resetState() {
//     isHighlighted = false;
//     isActive = false;
//     _showError = false;

//     // Remove any existing spirit and create a new one
//     _spirit?.removeFromParent(); // Remove previous if exists
//     _spirit = Spirit(color: color, id: id);
//     // Add the spirit centered within the tile
//     add(_spirit!..position = size / 2); // Set position after adding
//   }

//   // Sets the 'active' state (player's correct click glow)
//   void setActive(bool active) {
//     isActive = active;
//   }

//   // Initiates the spirit's release animation
//   void triggerSpiritRelease() {
//     _spirit?.release();
//   }

//   // Shows the error glow temporarily
//   void showError() {
//     _showError = true;
//     // Add a timer component to automatically turn off the error state
//     add(TimerComponent(
//       period: 0.6, // How long the error glow lasts
//       removeOnFinish: true, // Remove the timer itself when done
//       onTick: () => _showError = false, // Action to perform when timer finishes
//     ));
//   }

//   // --- Rendering Logic ---
//   @override
//   void render(Canvas canvas) {
//     // --- Determine Paint Properties Based on State ---
//     // Base color changes when highlighted
//     _basePaint.color = isHighlighted ? color : color.withOpacity(0.7);
//     // Border changes when highlighted
//     _borderPaint.color = isHighlighted ? Colors.white.withOpacity(0.8) : Colors.white.withOpacity(0.3);
//     _borderPaint.strokeWidth = isHighlighted ? 3 : 2;

//     // --- Draw Tile Layers ---
//     // 1. Base tile color
//     canvas.drawRRect(_rrect, _basePaint);

//     // 2. Highlight outer glow (if highlighted)
//     if (isHighlighted) {
//       // Note: _highlightPaint color could also be adjusted here if needed
//       canvas.drawRRect(_rrect, _highlightPaint);
//     }

//     // 3. Inner glow (if active from player click)
//     if (isActive) {
//       // Define the inner rectangle shape for the glow
//       final innerRect = Rect.fromLTWH(size.x * 0.15, size.y * 0.15, size.x * 0.7, size.y * 0.7);
//       final innerRRect = RRect.fromRectAndRadius(innerRect, Radius.circular(8));
//       canvas.drawRRect(innerRRect, _innerGlowPaint);
//     }

//     // 4. Error glow (if showing error)
//     if (_showError) {
//       canvas.drawRRect(_rrect, _errorPaint);
//     }

//     // 5. Border (drawn last to be on top)
//     canvas.drawRRect(_rrect, _borderPaint);

//     // The Spirit child component renders itself automatically.
//   }
// }


// // --- Spirit Component (Visual Element Inside the Tile) ---
// // Uses HasPaint mixin to allow OpacityEffect to work correctly.
// class Spirit extends PositionComponent with HasPaint {
//   final Color color; // Spirit's base color
//   final int id;      // Identifier (can be used for animation variations)

//   bool isReleased = false; // Has the release animation been triggered?

//   // --- Cached Paint Objects ---
//   late final Paint _spiritPaint;
//   late final Paint _innerGlowPaint;

//   Spirit({
//     required this.color,
//     required this.id,
//   }) : super(size: Vector2(30, 30), anchor: Anchor.center) { // Anchor at the center
//     // Initialize paints (opacity controlled by HasPaint/OpacityEffect)
//     _spiritPaint = Paint()
//       ..color = color // Base color
//       ..style = PaintingStyle.fill
//       ..maskFilter = MaskFilter.blur(BlurStyle.normal, 10); // Outer glow
//     _innerGlowPaint = Paint()
//       ..color = Colors.white // Inner core color
//       ..style = PaintingStyle.fill
//       ..maskFilter = MaskFilter.blur(BlurStyle.normal, 5); // Inner glow
//   }

//   @override
//   Future<void> onLoad() async {
//     await super.onLoad();
//     // Set initial visual opacity using the HasPaint mixin property
//     opacity = 0.9;
//     // Add the initial floating animation if not already released (e.g., on game restart)
//     if (!isReleased) {
//       _addFloatingEffect();
//     }
//   }

//   // Adds the continuous up-and-down floating animation
//   void _addFloatingEffect() {
//     // Create the effect
//     final floatingEffect = MoveEffect.by(
//       Vector2(0, 5), // Move down 5 pixels
//       EffectController(
//         duration: 1.5, // Time for one direction
//         reverseDuration: 1.5, // Time to reverse
//         infinite: true, // Loop forever
//         curve: Curves.easeInOut, // Smooth motion
//       ),
//     )..key = ComponentKey.named('float_effect'); // Assign a key for later removal
//     // Add the effect to this component
//     add(floatingEffect);
//   }

//   // Starts the release animation sequence
//   void release() {
//     // Prevent triggering the animation multiple times
//     if (isReleased) return;
//     isReleased = true;

//     // --- Remove the Floating Effect ---
//     // Find the effect by its key and remove it
//     findByKeyName<MoveEffect>('float_effect')?.removeFromParent();

//     // --- Add Release Animation Effects ---
//     // Create a controller for synchronized animation timing
//     final effectController = EffectController(
//       duration: 1.8, // Duration of the release animation
//       curve: Curves.easeOutCubic, // Animation curve
//     );

//     // 1. Movement: Move upward and drift horizontally
//     final random = Random();
//     final driftX = (random.nextDouble() - 0.5) * 60; // Random horizontal amount
//     add(MoveEffect.by(Vector2(driftX, -120), effectController)); // Add move effect

//     // 2. Scaling: Grow larger
//     add(ScaleEffect.to(Vector2.all(2.5), effectController)); // Add scale effect

//     // 3. Fading: Fade out completely
//     add(OpacityEffect.fadeOut(
//       EffectController(duration: 1.8, curve: Curves.easeIn), // Use a slightly different curve for fade
//       onComplete: removeFromParent, // Remove the spirit component once faded
//     ));

//     // 4. Rotation: Add a slight random rotation (optional)
//     add(RotateEffect.by(random.nextDouble() * 0.6 - 0.3, effectController));
//   }

//   // --- Rendering Logic ---
//   @override
//   void render(Canvas canvas) {
//     // The HasPaint mixin and added Effects handle opacity and transformations (position, scale, rotation).
//     // We just need to draw the basic shapes. The drawing will be affected by the component's current state.

//     // Calculate radius based on the component's base size
//     final baseRadius = size.x / 2;

//     // Apply the current component opacity (controlled by OpacityEffect) to the paints
//     _spiritPaint.color = color.withOpacity(paint.color.opacity);
//     _innerGlowPaint.color = Colors.white.withOpacity(paint.color.opacity * 0.7); // Inner glow fades too

//     // Draw the spirit shapes (centered because anchor is center)
//     canvas.drawCircle(Offset.zero, baseRadius * 0.8, _spiritPaint); // Outer part
//     canvas.drawCircle(Offset.zero, baseRadius * 0.3, _innerGlowPaint); // Inner core
//   }

//   // update() method is not needed here because all animation is handled by Effects.
// }

//--------------____________________________________________________________________________________________________________________________________
import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'dart:async';
import 'layout_service.dart';
import 'sequence_generator.dart';
import 'corsi_game_state.dart';

void main() {
  // Initialize sequence generator with optional seed for debugging
  SequenceGenerator.initialize(seed: null); // Use null for random, or provide a seed
  runApp(MyApp());
}

// Custom clipper for cropping edges of the photo
class EdgeCropper extends CustomClipper<Rect> {
  final double cropAmount;
  EdgeCropper({required this.cropAmount});

  @override
  Rect getClip(Size size) {
    return Rect.fromLTRB(
      cropAmount,
      cropAmount,
      size.width - cropAmount,
      size.height - cropAmount,
    );
  }

  @override
  bool shouldReclip(CustomClipper<Rect> oldClipper) => false;
}

// Spirit particle class
class Spirit {
  late AnimationController controller;
  late Animation<double> progress;
  late Animation<double> opacity;
  late Animation<double> scale;

  final double startX;
  final double startY;
  final double endX;
  final double endY;

  bool isCompleted = false;
  List<Offset> trailPositions = [];
  final int maxTrailLength = 50;

  Spirit({
    required this.startX,
    required this.startY,
    required this.endX,
    required this.endY,
    required TickerProvider vsync,
    required VoidCallback onComplete,
  }) {
    controller = AnimationController(
      duration: Duration(milliseconds: 800 + math.Random().nextInt(400)),
      vsync: vsync,
    );

    progress = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: controller, curve: Curves.easeInOut));

    opacity = Tween<double>(begin: 1.0, end: 0.0).animate(CurvedAnimation(
        parent: controller, curve: Interval(0.7, 1.0, curve: Curves.easeOut)));

    scale = Tween<double>(begin: 0.5, end: 1.2).animate(CurvedAnimation(
        parent: controller, curve: Interval(0.0, 0.3, curve: Curves.easeOut)));

    controller.addListener(() {
      final currentPos = _calculateLinearPosition(progress.value);
      trailPositions.add(currentPos);
      if (trailPositions.length > maxTrailLength) {
        trailPositions.removeAt(0);
      }
    });

    controller.addStatusListener((status) {
      if (status == AnimationStatus.completed && !isCompleted) {
        isCompleted = true;
        onComplete();
      }
    });

    controller.forward();
  }

  Offset _calculateLinearPosition(double t) {
    final x = startX + (endX - startX) * t;
    final y = startY + (endY - startY) * t;
    return Offset(x, y);
  }

  Offset get currentPosition => _calculateLinearPosition(progress.value);

  void dispose() {
    controller.dispose();
  }
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Corsi Block Test',
      theme: ThemeData(primarySwatch: Colors.amber),
      home: FutureBuilder(
        future: LayoutService.initialize(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Scaffold(
              backgroundColor: Color(0xFF1A1A0D),
              body: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(color: Color(0xFFD4A574)),
                    SizedBox(height: 20),
                    Text(
                      'Loading Corsi Layouts...',
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  ],
                ),
              ),
            );
          }

          if (snapshot.hasError) {
            return Scaffold(
              backgroundColor: Color(0xFF1A1A0D),
              body: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error, color: Colors.red, size: 48),
                    SizedBox(height: 20),
                    Text(
                      'Error loading layouts',
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                    SizedBox(height: 10),
                    Text(
                      '${snapshot.error}',
                      style: TextStyle(color: Colors.grey, fontSize: 12),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            );
          }

          return CorsiTestScreen();
        },
      ),
      debugShowCheckedModeBanner: false,
    );
  }
}

class CorsiTestScreen extends StatefulWidget {
  @override
  _CorsiTestScreenState createState() => _CorsiTestScreenState();
}

// Add this to your existing main.dart file, replacing the current _CorsiTestScreenState class

class _CorsiTestScreenState extends State<CorsiTestScreen>
    with TickerProviderStateMixin {

  // Game state
  final CorsiGameState gameState = CorsiGameState();

  // UI state
  List<Spirit> activeSpirits = [];
  AnimationController? _floatingController;
  AnimationController? _backgroundController; // Add this for background animation
  CorsiLayout? currentLayout;
  List<Offset> squarePositions = [];
  int spiritCounter = 0; // Add spirit counter

  // Presentation timing
  Timer? _presentationTimer;
  Timer? _dehighlightTimer;

  // Highlight state
  Set<int> highlightedBlocks = {};

  @override
  void initState() {
    super.initState();
    _floatingController = AnimationController(
      duration: Duration(seconds: 8),
      vsync: this,
    );
    _floatingController?.repeat();

    // Initialize background animation controller - Made much slower
    _backgroundController = AnimationController(
      duration: Duration(seconds: 60), // Changed from 20 to 60 seconds for slower sparkles
      vsync: this,
    );
    _backgroundController?.repeat();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadRandomLayout();
      _startNewGame();
    });
  }

  @override
  void dispose() {
    _floatingController?.dispose();
    _backgroundController?.dispose();
    _presentationTimer?.cancel();
    _dehighlightTimer?.cancel();
    for (var spirit in activeSpirits) {
      spirit.dispose();
    }
    super.dispose();
  }

  void _loadRandomLayout() {
    try {
      final layout = LayoutService.getRandomLayout(context);
      setState(() {
        currentLayout = layout;
        squarePositions = layout.positions.map((pos) => Offset(pos.x, pos.y)).toList();
      });
    } catch (e) {
      print('Error loading layout: $e');
      _useFallbackPositions();
    }
  }

  void _useFallbackPositions() {
    final screenSize = MediaQuery.of(context).size;
    final isWideScreen = screenSize.width > 600;

    setState(() {
      squarePositions = isWideScreen ? [
        Offset(screenSize.width * 0.15, screenSize.height * 0.25),
        Offset(screenSize.width * 0.4, screenSize.height * 0.2),
        Offset(screenSize.width * 0.65, screenSize.height * 0.25),
        Offset(screenSize.width * 0.25, screenSize.height * 0.45),
        Offset(screenSize.width * 0.5, screenSize.height * 0.4),
        Offset(screenSize.width * 0.75, screenSize.height * 0.45),
        Offset(screenSize.width * 0.2, screenSize.height * 0.65),
        Offset(screenSize.width * 0.45, screenSize.height * 0.7),
        Offset(screenSize.width * 0.7, screenSize.height * 0.65),
      ] : [
        Offset(100, 180),
        Offset(250, 150),
        Offset(180, 300),
        Offset(320, 280),
        Offset(120, 420),
        Offset(260, 450),
        Offset(380, 400),
        Offset(80, 570),
        Offset(300, 580),
      ];
    });
  }

  void _startNewGame() {
    setState(() {
      gameState.reset();
      spiritCounter = 0; // Reset spirit counter
    });
    _startNewTrial();
  }

  void _startNewTrial() {
    _loadRandomLayout(); // Get new positions for each trial
    setState(() {
      gameState.startNewTrial();
      highlightedBlocks.clear();
    });

    // Start presentation after a brief delay
    Future.delayed(Duration(milliseconds: 1000), () {
      _startPresentation();
    });
  }

  void _startPresentation() {
    setState(() {
      gameState.startPresentation();
    });
    _showNextInSequence();
  }

  void _showNextInSequence() {
    if (gameState.currentPhase != GamePhase.PRESENTING) return;

    final blockToHighlight = gameState.getCurrentlyHighlightedBlock();
    if (blockToHighlight != null) {
      setState(() {
        highlightedBlocks.clear();
        highlightedBlocks.add(blockToHighlight);
      });

      // Auto-dehighlight after presentation delay
      _dehighlightTimer?.cancel();
      _dehighlightTimer = Timer(Duration(milliseconds: 800), () {
        setState(() {
          highlightedBlocks.remove(blockToHighlight);
        });
      });

      // Move to next in sequence
      gameState.advancePresentation();

      if (gameState.currentPhase == GamePhase.PRESENTING) {
        // Continue with next block
        _presentationTimer?.cancel();
        _presentationTimer = Timer(Duration(milliseconds: CorsiGameState.PRESENTATION_DELAY_MS), () {
          _showNextInSequence();
        });
      } else {
        // Presentation completed
        setState(() {});
      }
    }
  }

  void _handleBlockTap(int blockIndex) {
    if (gameState.currentPhase == GamePhase.PRESENTING) {
      // Show message to wait
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please wait for the sequence to finish!'),
          duration: Duration(seconds: 1),
          backgroundColor: Color(0xFFB8860B),
        ),
      );
      return;
    }

    if (!gameState.canAcceptInput()) return;

    bool accepted = gameState.addPlayerResponse(blockIndex);
    if (accepted) {
      setState(() {
        highlightedBlocks.add(blockIndex);
      });

      // Auto-dehighlight player's tap
      Timer(Duration(milliseconds: 300), () {
        setState(() {
          highlightedBlocks.remove(blockIndex);
        });
      });

      // Check if trial completed
      if (gameState.currentPhase == GamePhase.FEEDBACK) {
        _handleTrialComplete();
      }
    }
  }

  void _handleTrialComplete() {
    if (gameState.shouldShowSparkles()) {
      _showSparkles();
    }

    // Move to next trial after feedback delay
    Future.delayed(Duration(milliseconds: 2000), () {
      setState(() {
        gameState.moveToNextTrial();
      });

      if (gameState.currentPhase == GamePhase.COMPLETED) {
        _showGameComplete();
      } else {
        Future.delayed(Duration(milliseconds: 500), () {
          _startNewTrial();
        });
      }
    });
  }

  void _showSparkles() {
    final sparkleSequence = gameState.getSparkleSequence();
    final counterPosition = LayoutService.getCounterPosition(context);

    for (int blockId in sparkleSequence) {
      if (blockId < squarePositions.length) {
        final blockPosition = squarePositions[blockId];
        _spawnSpirits(Offset(blockPosition.dx + 50, blockPosition.dy + 50), counterPosition);
      }
    }
  }

  void _spawnSpirits(Offset start, Offset counterPosition) {
    for (int i = 0; i < 3; i++) {
      final spirit = Spirit(
        startX: start.dx + (math.Random().nextDouble() - 0.5) * 30,
        startY: start.dy + (math.Random().nextDouble() - 0.5) * 30,
        endX: counterPosition.dx + math.Random().nextDouble() * 40 - 20,
        endY: counterPosition.dy + math.Random().nextDouble() * 40 - 20,
        vsync: this,
        onComplete: () {
          setState(() {
            activeSpirits.removeWhere((spirit) => spirit.isCompleted);
            spiritCounter++; // Increment counter when spirit reaches destination
          });
        },
      );
      activeSpirits.add(spirit);
    }
  }

  void _showGameComplete() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: Color(0xFF2D2416),
        title: Text('Test Complete!', style: TextStyle(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Your longest span: ${gameState.longestCorrectSpan}',
              style: TextStyle(color: Color(0xFFD4A574), fontSize: 18),
            ),
            SizedBox(height: 10),
            Text(
              'Total trials completed: ${gameState.allResults.length}',
              style: TextStyle(color: Colors.white70),
            ),
            Text(
              'Spirits collected: $spiritCounter',
              style: TextStyle(color: Color(0xFFDAA520), fontSize: 16),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _startNewGame();
            },
            child: Text('Start New Test', style: TextStyle(color: Color(0xFFD4A574))),
          ),
        ],
      ),
    );
  }

  Widget _buildSpirit(Spirit spirit) {
    return AnimatedBuilder(
      animation: spirit.controller,
      builder: (context, child) {
        final currentPos = spirit.currentPosition;
        return Stack(
          children: [
            ...spirit.trailPositions.asMap().entries.map((entry) {
              final index = entry.key;
              final position = entry.value;
              final trailOpacity = (index / spirit.trailPositions.length) * spirit.opacity.value * 0.6;
              final trailSize = 12.0 + (index / spirit.trailPositions.length) * 8.0;
              return Positioned(
                left: position.dx - trailSize / 2,
                top: position.dy - trailSize / 2,
                child: Opacity(
                  opacity: trailOpacity,
                  child: Container(
                    width: trailSize,
                    height: trailSize,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          Color(0xFFFFD700).withOpacity(0.8),
                          Color(0xFFDAA520).withOpacity(0.8),
                          Color(0xFFB8860B).withOpacity(0.2),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
            Positioned(
              left: currentPos.dx - 9,
              top: currentPos.dy - 9,
              child: Opacity(
                opacity: spirit.opacity.value,
                child: Transform.scale(
                  scale: spirit.scale.value,
                  child: Container(
                    width: 18,
                    height: 18,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          Color(0xFFFFD700).withOpacity(1),
                          Color(0xFFDAA520).withOpacity(0.7),
                          Color(0xFFB8860B).withOpacity(0.5),
                        ],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Color(0xFFDAA520).withOpacity(0.5),
                          blurRadius: 8,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: Icon(Icons.auto_awesome, size: 12, color: Colors.white),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  // New method to build animated background
  Widget _buildAnimatedBackground() {
    return AnimatedBuilder(
      animation: _backgroundController!,
      builder: (context, child) {
        return Container(
          width: double.infinity,
          height: double.infinity,
          child: CustomPaint(
            painter: SparklyBackgroundPainter(_backgroundController!.value),
          ),
        );
      },
    );
  }

  // New method to build spirit counter display
  Widget _buildSpiritCounter() {
    final counterPosition = LayoutService.getCounterPosition(context);

    return Positioned(
      left: counterPosition.dx - 80,
      top: counterPosition.dy - 30,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: Color(0xFFDAA520).withOpacity(0.8),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Color(0xFFDAA520).withOpacity(0.3),
              blurRadius: 10,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.auto_awesome, color: Colors.white, size: 20),
            SizedBox(width: 8),
            Text(
              'Spirits: $spiritCounter',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF1A1A0D),
      body: _floatingController == null || squarePositions.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: Color(0xFFD4A574)),
                  SizedBox(height: 20),
                  Text(
                    'Preparing Corsi Test...',
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ],
              ),
            )
          : Stack(
              children: [
                // Animated sparkly background
                _buildAnimatedBackground(),

                // Title and instructions (simplified - removed sequence length)
                Positioned(
                  top: 50,
                  left: 20,
                  right: 20,
                  child: Column(
                    children: [
                      Text(
                        'Your Turn! Tap the squares',
                        style: TextStyle(
                          color: Color(0xFFD4A574),
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 8),
                      Text(
                        gameState.getInstructions(),
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 16,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),

                // Spirit counter display
                _buildSpiritCounter(),

                // 9 floating squares from CSV layout
                ...List.generate(9, (i) {
                  if (i >= squarePositions.length) return SizedBox.shrink();

                  return Positioned(
                    left: squarePositions[i].dx,
                    top: squarePositions[i].dy,
                    child: CorsiBlockTile(
                      imagePath: 'assets/images/square${i + 1}.png',
                      onTap: () => _handleBlockTap(i),
                      index: i,
                      animationController: _floatingController!,
                      isHighlighted: highlightedBlocks.contains(i),
                    ),
                  );
                }),

                // Spirit particles
                ...activeSpirits.map((spirit) => _buildSpirit(spirit)).toList(),

                // Bottom stats (moved sequence length info here)
                Positioned(
                  bottom: 80,
                  left: 20,
                  child: Container(
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Color(0xFF1A1A0D).withOpacity(0.7),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Color(0xFFD4A574).withOpacity(0.3)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Sequence Length: ${gameState.currentSpan}',
                          style: TextStyle(color: Color(0xFFD4A574), fontSize: 14, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          'Correct at span: ${gameState.correctTrialsAtCurrentSpan}/2',
                          style: TextStyle(color: Colors.white70, fontSize: 12),
                        ),
                        Text(
                          'Longest span: ${gameState.longestCorrectSpan}',
                          style: TextStyle(color: Colors.white70, fontSize: 12),
                        ),
                        if (currentLayout != null)
                          Text(
                            'Layout: ${currentLayout!.layoutId}',
                            style: TextStyle(color: Colors.white70, fontSize: 12),
                          ),
                      ],
                    ),
                  ),
                ),

                // Reset button
                Positioned(
                  bottom: 20,
                  right: 20,
                  child: FloatingActionButton(
                    mini: true,
                    backgroundColor: Color(0xFFD4A574),
                    onPressed: _startNewGame,
                    child: Icon(Icons.refresh, color: Colors.white),
                  ),
                ),

                // Start button for ready phase
                // if (gameState.currentPhase == GamePhase.READY)
                //   Positioned(
                //     bottom: 100,
                //     left: 0,
                //     right: 0,
                //     child: Center(
                //       child: ElevatedButton(
                //         style: ElevatedButton.styleFrom(
                //           backgroundColor: Color(0xFFD4A574),
                //           padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                //         ),
                //         onPressed: _startPresentation,
                //         child: Text(
                //           'Start Trial',
                //           style: TextStyle(color: Colors.white, fontSize: 18),
                //         ),
                //       ),
                //     ),
                //   ),
              ],
            ),
    );
  }
}

// Custom painter for sparkly animated background
class SparklyBackgroundPainter extends CustomPainter {
  final double animationValue;
  final List<Star> stars;

  SparklyBackgroundPainter(this.animationValue) : stars = _generateStars();

  static List<Star> _generateStars() {
    final random = math.Random();
    final stars = <Star>[];

    for (int i = 0; i < 150; i++) {
      stars.add(Star(
        x: random.nextDouble() * 2000, // Make it wider than screen
        y: random.nextDouble() * 2000, // Make it taller than screen
        size: random.nextDouble() * 3 + 1,
        speed: random.nextDouble() * 0.1 + 0.01, // Made slower: reduced from 0.5+0.2 to 0.2+0.1
        color: [
          Color(0xFF0B0C2A), // Deep Indigo
          Color(0xFF1B1F3B), // Midnight Blue
          Color(0xFF2C2F54), // Slate Indigo
          Color(0xFF3B3F5C), // Muted Navy
          Color(0xFF4A4F70), // Steel Indigo
          Color(0xFF5C6285), // Dusty Purple-Blue
        ][random.nextInt(6)], // Fixed: was 7 but only 6 colors in array
        phase: random.nextDouble() * 2 * math.pi,
      ));
    }

    return stars;
  }

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();

    // Draw solid dark background
    paint.color = Color(0xFF050614); // Very dark indigo/black
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), paint);

    // Draw animated stars
    for (final star in stars) {
      final phase = star.phase + animationValue * star.speed * 2 * math.pi;
      final opacity = (math.sin(phase) * 0.5 + 0.5);
      final twinkleSize = star.size * (0.8 + opacity * 0.4);

      paint.shader = RadialGradient(
        colors: [
          star.color.withOpacity(opacity * 0.8),
          star.color.withOpacity(opacity * 0.4),
          Colors.transparent,
        ],
      ).createShader(Rect.fromCircle(
        center: Offset(star.x % size.width, star.y % size.height),
        radius: twinkleSize * 2,
      ));

      canvas.drawCircle(
        Offset(star.x % size.width, star.y % size.height),
        twinkleSize,
        paint,
      );

      // Add extra sparkle effect
      if (opacity > 0.7) {
        paint.shader = null;
        paint.color = Color(0xFFFFE55C).withOpacity(opacity * 0.5); // Warm golden white
        canvas.drawCircle(
          Offset(star.x % size.width, star.y % size.height),
          twinkleSize * 0.3,
          paint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}
// Helper class for background stars
class Star {
  final double x;
  final double y;
  final double size;
  final double speed;
  final Color color;
  final double phase;

  Star({
    required this.x,
    required this.y,
    required this.size,
    required this.speed,
    required this.color,
    required this.phase,
  });
}

class CorsiBlockTile extends StatefulWidget {
  final String imagePath;
  final VoidCallback onTap;
  final int index;
  final AnimationController animationController;
  final bool isHighlighted;

  const CorsiBlockTile({
    required this.imagePath,
    required this.onTap,
    required this.index,
    required this.animationController,
    required this.isHighlighted,
  });

  @override
  _CorsiBlockTileState createState() => _CorsiBlockTileState();
}

class _CorsiBlockTileState extends State<CorsiBlockTile>
    with TickerProviderStateMixin {
  AnimationController? _floatController;
  Animation<double>? _scaleAnimation;
  Animation<Offset>? _floatAnimation;

  final double imageSize = 100.0;

  @override
  void initState() {
    super.initState();

    // Create individual float controller for each tile
    _floatController = AnimationController(
      duration: Duration(milliseconds: 2000 + widget.index * 300),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
        CurvedAnimation(parent: _floatController!, curve: Curves.easeInOut));

    // Enhanced floating animation
    _floatAnimation = Tween<Offset>(
      begin: Offset.zero,
      end: Offset(
        (math.Random().nextDouble() - 0.5) * 20,
        (math.Random().nextDouble() - 0.5) * 15,
      ),
    ).animate(CurvedAnimation(
      parent: _floatController!,
      curve: Curves.easeInOut,
    ));

    _floatController!.repeat(reverse: true);
  }

  @override
  void dispose() {
    _floatController?.dispose();
    super.dispose();
  }

  // @override
  // Widget build(BuildContext context) {
  //   return AnimatedBuilder(
  //     animation: Listenable.merge([
  //       if (_floatController != null) _floatController!,
  //     ]),
  //     builder: (context, child) {
  //       final scaleValue = widget.isHighlighted ? 1.2 : (_scaleAnimation?.value ?? 1.0);
  //       final floatOffset = _floatAnimation?.value ?? Offset.zero;

  //       return Transform.translate(
  //         offset: floatOffset,
  //         child: Transform.scale(
  //           scale: scaleValue,
  //           child: GestureDetector(
  //             onTap: widget.onTap,
  //             child: Container(
  //               width

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([
        if (_floatController != null) _floatController!,
      ]),
      builder: (context, child) {
        final scaleValue = widget.isHighlighted ? 1.2 : (_scaleAnimation?.value ?? 1.0);
        final floatOffset = _floatAnimation?.value ?? Offset.zero;

        return Transform.translate(
          offset: floatOffset,
          child: Transform.scale(
            scale: scaleValue,
            child: GestureDetector(
              onTap: widget.onTap,
              child: Container(
                width: imageSize,
                height: imageSize,
                decoration: BoxDecoration(
                  boxShadow: widget.isHighlighted
                      ? [
                          BoxShadow(
                            color: Color(0xFFDAA520).withOpacity(0.8),
                            blurRadius: 40,
                            spreadRadius: 10,
                          ),
                          BoxShadow(
                            color: Color(0xFFD4A574).withOpacity(0.4),
                            blurRadius: 60,
                            spreadRadius: 20,
                          ),
                        ]
                      : [
                          BoxShadow(
                            color: Color(0xFFB8860B).withOpacity(0.3),
                            blurRadius: 15,
                            spreadRadius: 3,
                          ),
                        ],
                ),
                child: Stack(
                  children: [
                    if (widget.isHighlighted)
                      Container(
                        width: imageSize,
                        height: imageSize,
                        decoration: BoxDecoration(
                          border: Border.all(color: Color(0xFFDAA520), width: 4),
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    Opacity(
                      opacity: 0.85,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: ClipRect(
                          clipper: EdgeCropper(cropAmount: 10),
                          child: Image.asset(
                            widget.imagePath,
                            width: imageSize,
                            height: imageSize,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              // Fallback to colored container if image not found
                              return Container(
                                width: imageSize,
                                height: imageSize,
                                decoration: BoxDecoration(
                                  color: Colors.primaries[widget.index % Colors.primaries.length],
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Center(
                                  child: Text(
                                    '${widget.index + 1}',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}