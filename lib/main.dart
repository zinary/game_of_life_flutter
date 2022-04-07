import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_processing/flutter_processing.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Conway\'s Game of Life',
      theme: ThemeData(
        primarySwatch: Colors.yellow,
      ),
      home: const MyHomePage(title: 'Conway\'s Game of Life'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  final String title;

  const MyHomePage({Key? key, required this.title}) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final pixelsPerCell = 10.0;
  late int rowCount;
  late int colCount;
  late List<List<bool>> _grid;
  @override
  Widget build(BuildContext context) {
    var mediaQuery = MediaQuery.of(context);

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        centerTitle: true,
        title: Text(widget.title),
      ),
      body: Padding(
        padding: const EdgeInsets.all(18.0),
        child: SafeArea(
          child: Processing(
            sketch: Sketch.simple(
              setup: (sketch) async {
                sketch.frameRate = 24;
                sketch.size(
                  width: mediaQuery.size.width.floor(),
                  height: mediaQuery.size.height.floor(),
                );
                colCount = (sketch.width / pixelsPerCell).floor();
                rowCount = (sketch.height / pixelsPerCell).floor();
                _grid = generateGrid();
              },
              draw: (sketch) async {
                sketch.background(color: Colors.black);
                sketch.fill(color: Colors.white);

                for (int col = 0; col < colCount; col++) {
                  for (int row = 0; row < rowCount; row++) {
                    if (_grid[col][row]) {
                      final block =
                          Offset(col * pixelsPerCell, row * pixelsPerCell);
                      sketch.rect(
                          rect: Rect.fromLTWH(block.dx, block.dy, pixelsPerCell,
                              pixelsPerCell));
                    }
                  }
                }

                createNextGeneration();
              },
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          setState(() {
            _grid = generateGrid();
          });
        },
        backgroundColor: Colors.yellow,
        tooltip: 'Reset',
        child: const Icon(
          Icons.replay_rounded,
          color: Colors.black,
        ),
      ),
    );
  }

  List<List<bool>> generateGrid() {
    return List.generate(
      colCount,
      (index) => List.generate(
        rowCount,
        (index) => Random().nextBool(),
      ),
    );
  }

  void createNextGeneration() {
    var newGrid = List.generate(
      colCount,
      (index) => List.generate(
        rowCount,
        (index) => Random().nextBool(),
      ),
    );

    for (int col = 0; col < colCount; col++) {
      for (int row = 0; row < rowCount; row++) {
        newGrid[col][row] = calculateNextCellValue(col, row);
      }
    }

    _grid = newGrid;
  }

  bool calculateNextCellValue(int col, int row) {
    int liveNeighboursCount = 0;

    // top left
    liveNeighboursCount += (col > 0) && row > 0 && _grid[col][row] ? 1 : 0;

    // top
    liveNeighboursCount += (row > 0) && _grid[col][row - 1] ? 1 : 0;

    // top right
    liveNeighboursCount +=
        (col < colCount - 1) && (row > 0) && _grid[col + 1][row - 1] ? 1 : 0;

    // right
    liveNeighboursCount += (col < colCount - 1) && _grid[col + 1][row] ? 1 : 0;

    // bottom right
    liveNeighboursCount +=
        (col < colCount - 1) && (row < rowCount - 1) && _grid[col + 1][row + 1]
            ? 1
            : 0;

    // bottom
    liveNeighboursCount += (row < rowCount - 1) && _grid[col][row + 1] ? 1 : 0;

    // bottom left
    liveNeighboursCount +=
        (col > 0) && (row < rowCount - 1) && _grid[col - 1][row + 1] ? 1 : 0;

    // left
    liveNeighboursCount += (col > 0) && _grid[col - 1][row] ? 1 : 0;

    if (_grid[col][row] &&
        liveNeighboursCount >= 2 &&
        liveNeighboursCount <= 3) {
      // cell survives
      return true;
    } else if (!_grid[col][row] && liveNeighboursCount == 3) {
      // new cell is born
      return true;
    } else if (_grid[col][row] && liveNeighboursCount > 3) {
      // cell dies due to over population
      return false;
    } else {
      // cell remains dead
      return false;
    }
  }
}
