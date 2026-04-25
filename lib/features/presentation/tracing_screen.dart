import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:confetti/confetti.dart';
import 'widgets/tracing_painter.dart';
import '../../../core/services/audio_players.dart';

class TracingScreen extends StatefulWidget {
  const TracingScreen({super.key});

  @override
  State<TracingScreen> createState() => _TracingScreenState();
}

class _TracingScreenState extends State<TracingScreen> {
  final List<TracingStroke> _strokes = [];
  String _currentTemplate = "1";
  final List<String> _numbers = [
    ...List.generate(30, (i) => (i + 1).toString()),
    "40", "50", "60", "70", "80", "90", "100"
  ];
  final List<String> _uppercase = List.generate(26, (i) => String.fromCharCode(65 + i));
  final List<String> _lowercase = List.generate(26, (i) => String.fromCharCode(97 + i));
  
  // 0: 123, 1: ABC, 2: abc
  int _activeMode = 0; 
  int _currentIndex = 0;
  late ConfettiController _confettiController;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(duration: const Duration(seconds: 2));
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  void _clear() {
    setState(() {
      _strokes.clear();
    });
  }

  Future<void> _onFinish() async {
    if (_strokes.isEmpty) return;

    // Show loading or processing if needed
    final bool isValid = await _validateTrace();

    if (!mounted) return;

    if (isValid) {
      _confettiController.play();
      AudioService.celebration();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Amazing! You traced $_currentTemplate perfectly! 🌟"),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 1),
        ),
      );
    } else {
       AudioService.wrong();
       ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Try to stay inside the lines! You can do it! 💪"),
          backgroundColor: Colors.orange,
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  Future<bool> _validateTrace() async {
    // 1. Create a 100x100 grid for validation
    const double gridSide = 100.0;
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    
    // Draw the template in black on the validation canvas
    final textPainter = TextPainter(
      text: TextSpan(
        text: _currentTemplate,
        style: const TextStyle(fontSize: 80, fontWeight: FontWeight.bold, color: Colors.black),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(canvas, Offset((gridSide - textPainter.width) / 2, (gridSide - textPainter.height) / 2));
    
    final picture = recorder.endRecording();
    final image = await picture.toImage(gridSide.toInt(), gridSide.toInt());
    final byteData = await image.toByteData(format: ui.ImageByteFormat.rawRgba);
    
    if (byteData == null) return false;

    // 2. Get the physical size of the tracing area
    // (We use a simple approximation for the prototype)
    // In a real app, we'd get the actual render size of the CustomPaint
    final RenderBox? renderBox = context.findRenderObject() as RenderBox?;
    if (renderBox == null) return false;
    final size = renderBox.size;
    
    int hits = 0;
    int totalStrokesPoints = 0;
    
    for (var stroke in _strokes) {
      for (var point in stroke.points) {
        totalStrokesPoints++;
        
        // 1. Shift point to be relative to screen center
        double screenCenterX = size.width / 2;
        double screenCenterY = size.height / 2;
        
        double relativeX = point.dx - screenCenterX;
        double relativeY = point.dy - screenCenterY;
        
        // 2. Scale to grid and shift back to grid center (50, 50)
        // Note: size.height * 0.8 was the font scale in the painter
        double screenScale = size.height * 0.8;
        double gridScale = 80.0; // matched to fontSize in validator
        
        int gx = (relativeX * (gridScale / screenScale) + (gridSide / 2)).toInt();
        int gy = (relativeY * (gridScale / screenScale) + (gridSide / 2)).toInt();
        
        // Neighborhood check (Check 3x3 area for fuzzy matching)
        bool isHit = false;
        for (int dy = -1; dy <= 1; dy++) {
          for (int dx = -1; dx <= 1; dx++) {
            int nx = gx + dx;
            int ny = gy + dy;
            if (nx >= 0 && nx < gridSide && ny >= 0 && ny < gridSide) {
              int index = (ny * gridSide.toInt() + nx) * 4;
              if (byteData.getUint8(index + 3) > 10) { // Very sensitive alpha
                isHit = true;
                break;
              }
            }
          }
          if (isHit) break;
        }

        if (isHit) hits++;
      }
    }

    if (totalStrokesPoints == 0) return false;
    
    double accuracy = hits / totalStrokesPoints;
    // Lower threshold to 0.2 (20%) - very flexible for kids!
    return accuracy > 0.2;
  }

  void _nextTemplate() {
    final list = _getCurrentList();
    if (_currentIndex < list.length - 1) {
      setState(() {
        _currentIndex++;
        _currentTemplate = list[_currentIndex];
        _strokes.clear();
      });
    }
  }

  void _prevTemplate() {
    if (_currentIndex > 0) {
      final list = _getCurrentList();
      setState(() {
        _currentIndex--;
        _currentTemplate = list[_currentIndex];
        _strokes.clear();
      });
    }
  }

  List<String> _getCurrentList() {
    if (_activeMode == 0) return _numbers;
    if (_activeMode == 1) return _uppercase;
    return _lowercase;
  }

  void _showNumberPicker() {
    final list = _getCurrentList();
    showModalBottomSheet(
      context: context,
       isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(20),
          height: MediaQuery.of(context).size.height * 0.6,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                _activeMode == 0 ? "Pick a Number" : (_activeMode == 1 ? "Pick Uppercase" : "Pick Lowercase"),
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 15),
              Expanded(
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 5,
                    mainAxisSpacing: 10,
                    crossAxisSpacing: 10,
                  ),
                  itemCount: list.length,
                  itemBuilder: (context, index) {
                    return ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _currentIndex = index;
                          _currentTemplate = list[index];
                          _strokes.clear();
                        });
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _currentIndex == index ? Colors.blue : Colors.blue.shade50,
                        padding: EdgeInsets.zero,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      child: Text(
                        list[index],
                        style: TextStyle(
                          fontSize: 18,
                          color: _currentIndex == index ? Colors.white : Colors.blue,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Trace & Draw ✍️"),
        backgroundColor: Colors.blue.shade100,
        actions: [
          IconButton(
            icon: const Icon(Icons.grid_view),
            onPressed: _showNumberPicker,
            tooltip: "Pick a Number",
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _clear,
            tooltip: "Clear",
          ),
        ],
      ),
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.blue.shade50, Colors.white],
              ),
            ),
            child: Column(
              children: [
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 20),
                  child: Text(
                    "Follow the lines!",
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.blueGrey),
                  ),
                ),
                
                // Mode Toggle
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: SegmentedButton<int>(
                    segments: const [
                      ButtonSegment(value: 0, label: Text("123"), icon: Icon(Icons.numbers)),
                      ButtonSegment(value: 1, label: Text("ABC"), icon: Icon(Icons.abc)),
                      ButtonSegment(value: 2, label: Text("abc"), icon: Icon(Icons.abc_outlined)),
                    ],
                    selected: {_activeMode},
                    onSelectionChanged: (newSelection) {
                      setState(() {
                        _activeMode = newSelection.first;
                        _currentIndex = 0;
                        _currentTemplate = _getCurrentList()[0];
                        _strokes.clear();
                      });
                    },
                  ),
                ),
                
                // Tracing Canvas
                Expanded(
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(30),
                      child: GestureDetector(
                        onPanStart: (details) {
                          setState(() {
                            _strokes.add(TracingStroke(
                              points: [details.localPosition],
                              color: Colors.blue,
                            ));
                          });
                        },
                        onPanUpdate: (details) {
                          setState(() {
                            if (_strokes.isNotEmpty) {
                              _strokes.last.points.add(details.localPosition);
                            }
                          });
                        },
                        child: CustomPaint(
                          painter: TracingPainter(
                            strokes: List.from(_strokes),
                            template: _currentTemplate,
                          ),
                          size: Size.infinite,
                        ),
                       ),
                    ),
                  ),
                ),
                
                // Controls
                Padding(
                  padding: const EdgeInsets.all(30.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      ElevatedButton(
                        onPressed: _currentIndex > 0 ? _prevTemplate : null,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.all(15),
                          shape: const CircleBorder(),
                        ),
                        child: const Icon(Icons.arrow_back),
                      ),
                      ElevatedButton.icon(
                        onPressed: _onFinish,
                        icon: const Icon(Icons.check, color: Colors.white),
                        label: const Text("Done!", style: TextStyle(color: Colors.white, fontSize: 18)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                        ),
                      ),
                      ElevatedButton(
                        onPressed: _currentIndex < _getCurrentList().length - 1 
                            ? _nextTemplate 
                            : null,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.all(15),
                          shape: const CircleBorder(),
                        ),
                        child: const Icon(Icons.arrow_forward),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          // Confetti
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _confettiController,
              blastDirectionality: BlastDirectionality.explosive,
              shouldLoop: false,
              colors: const [Colors.green, Colors.blue, Colors.pink, Colors.orange, Colors.purple],
            ),
          ),
        ],
      ),
    );
  }
}
