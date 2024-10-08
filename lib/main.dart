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

  bool _isVisible = true;
  bool gameOver = false;
  bool isWinner = false;

  // List of Halloween characters with their positions
  final List<_SpookyCharacter> _characters = [
    _SpookyCharacter(name: 'Ghost', imagePath: 'assets/SpookyGhost.jpeg', isCorrect: false),
    _SpookyCharacter(name: 'Skeleton', imagePath: 'assets/GhostSkeleton.jpg', isCorrect: true), // This is the correct item
    _SpookyCharacter(name: 'Dog', imagePath: 'assets/scarydog.png', isCorrect: false),
  ];

  @override
  void initState() {
    super.initState();
    _playBackgroundMusic(); // Play background music when the game starts
  }

  // Function to handle item selection and play sound effects
  void handleItemSelected(bool isCorrect) async {
    if (isCorrect) {
      // Play success sound
      await _audioPlayer.setAsset('assets/success_sound.wav');
      _audioPlayer.play();
      setState(() {
        isWinner = true;
        gameOver = true;
      });
    } else {
      // Play spooky sound
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

  @override
  void dispose() {
    _audioPlayer.dispose(); // Dispose the audio player for sound effects
    _backgroundPlayer.dispose(); // Dispose the background music player
    super.dispose();
  }

  // Function to randomly toggle visibility
  void toggleVisibility() {
    setState(() {
      _isVisible = !_isVisible;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Halloween Game'),
      ),
      body: Stack(
        children: [
          // Iterate through spooky characters and display them
          for (var character in _characters)
            AnimatedPositioned(
              duration: Duration(seconds: 3),
              left: Random().nextDouble() * MediaQuery.of(context).size.width,
              top: Random().nextDouble() * MediaQuery.of(context).size.height,
              child: GestureDetector(
                onTap: () => handleItemSelected(character.isCorrect),
                child: AnimatedOpacity(
                  opacity: _isVisible ? 1.0 : 0.0,
                  duration: Duration(seconds: 1),
                  child: Image.asset(
                    character.imagePath,
                    width: 100,
                    height: 100,
                  ),
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
        child: Icon(Icons.play_arrow),
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
