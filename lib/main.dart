import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart'; // Import the just_audio package

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: HalloweenGame(),
    );
  }
}

class HalloweenGame extends StatefulWidget {
  @override
  _HalloweenGameState createState() => _HalloweenGameState();
}

class _HalloweenGameState extends State<HalloweenGame> {
  final AudioPlayer _audioPlayer = AudioPlayer(); // For sound effects
  final AudioPlayer _backgroundPlayer = AudioPlayer(); // For background music

  bool gameOver = false;
  bool isWinner = false;
  bool _isPlaying = false; // Tracks if the play button has been hit

  // List to hold the positions of each character
  List<Offset> _characterPositions = [];

  // List of Halloween characters
  final List<_SpookyCharacter> _characters = [
    _SpookyCharacter(name: 'Ghost', imagePath: 'assets/SpookyGhost.png', isCorrect: false),
    _SpookyCharacter(name: 'Skeleton', imagePath: 'assets/GhostSkeleton.png', isCorrect: true),
    _SpookyCharacter(name: 'Dog', imagePath: 'assets/scarydog.png', isCorrect: false),
  ];

  // Timer to move characters continuously
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    // Initialize music and game logic, but avoid MediaQuery-related code
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Move character position initialization here
    _initializePositions();
  }

  // Initialize character positions based on screen size using MediaQuery
  void _initializePositions() {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    _characterPositions = List.generate(_characters.length, (index) {
      return Offset(
        Random().nextDouble() * (screenWidth - 100), // Adjust based on screen width
        Random().nextDouble() * (screenHeight - 200), // Adjust based on screen height
      );
    });
  }

  // Function to handle item selection and play sound effects
  void handleItemSelected(bool isCorrect) async {
    if (isCorrect) {
      await _audioPlayer.setAsset('assets/success_sound.wav');
      _audioPlayer.play();
      setState(() {
        isWinner = true;
        gameOver = true;
      });
    } else {
      await _audioPlayer.setAsset('assets/spooky_sound.wav');
      _audioPlayer.play();
      setState(() {
        gameOver = true;
      });
    }
  }

  // Play looping background music
  Future<void> _playBackgroundMusic() async {
    try {
      await _backgroundPlayer.setAsset('assets/bg.mp3');
      _backgroundPlayer.setLoopMode(LoopMode.one); // Loop the background music
      _backgroundPlayer.setVolume(1.0); // Ensure volume is at max
      _backgroundPlayer.play();
    } catch (e) {
      print("Error playing background music: $e");
    }
  }

  // Start floating characters with continuous movement
  void _startFloatingCharacters() {
    if (_timer == null || !_timer!.isActive) {
      _timer = Timer.periodic(Duration(seconds: 3), (timer) {
        setState(() {
          // Update positions randomly for each character
          _initializePositions();
        });
      });
    }
  }

  // Function to handle the play button and start floating
  void toggleVisibility() {
    setState(() {
      _isPlaying = !_isPlaying; // Toggle play/pause state
    });

    if (_isPlaying) {
      _startFloatingCharacters(); // Start floating when play is pressed
      _playBackgroundMusic(); // Play background music when play is pressed
    } else {
      _timer?.cancel(); // Stop floating when play is pressed again
      _backgroundPlayer.stop(); // Stop background music
    }
  }

  @override
  void dispose() {
    _audioPlayer.dispose(); // Dispose the audio player for sound effects
    _backgroundPlayer.dispose(); // Dispose the background music player
    _timer?.cancel(); // Stop the timer when the widget is disposed
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Set the background color to black
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text('Halloween Game'),
        // Set the AppBar color to orange
        backgroundColor: Colors.orange,
      ),
      body: Stack(
        children: [
          // Iterate through spooky characters and display them at their floating positions
          for (int i = 0; i < _characters.length; i++)
            AnimatedPositioned(
              duration: Duration(seconds: 2), // Movement animation duration
              left: _characterPositions[i].dx,
              top: _characterPositions[i].dy,
              child: GestureDetector(
                onTap: () => handleItemSelected(_characters[i].isCorrect),
                child: Image.asset(
                  _characters[i].imagePath,
                  width: 100,
                  height: 100,
                ),
              ),
            ),
          // Show the game result
          if (gameOver)
            Center(
              child: isWinner
                  ? Text('Congratulations! You found the correct item!',
                      style: TextStyle(fontSize: 24, color: Colors.green))
                  : Text('Spooky! You selected the wrong item!',
                      style: TextStyle(fontSize: 24, color: Colors.red)),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: toggleVisibility,
        // Set the FloatingActionButton color to orange
        backgroundColor: Colors.orange,
        child: Icon(_isPlaying ? Icons.pause : Icons.play_arrow), // Toggle play/pause icon
      ),
    );
  }
}

// Helper class to represent a spooky character
class _SpookyCharacter {
  final String name;
  final String imagePath;
  final bool isCorrect;

  _SpookyCharacter({required this.name, required this.imagePath, required this.isCorrect});
}
