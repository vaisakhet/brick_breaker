library;

import 'package:block_break/brick_breaker.dart';
import 'package:block_break/shared_prefrance.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:simple_gradient_text/simple_gradient_text.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SharedPrefResponse.initialize();

  runApp(const GameApp());
}

class GameApp extends StatefulWidget {
  const GameApp({super.key});

  @override
  State<GameApp> createState() => _GameAppState();
}

class _GameAppState extends State<GameApp> {
  late final BrickBreaker game;

  @override
  void initState() {
    super.initState();
    game = BrickBreaker();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: FirstScreen(game: game),
    );
  }
}

class FirstScreen extends StatelessWidget {
  FirstScreen({
    super.key,
    required this.game,
  });

  final BrickBreaker game;
  final _prefns = SharedPrefResponse.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Positioned(
            bottom: MediaQuery.of(context).size.height / 2 + 20,
            left: MediaQuery.of(context).size.width / 4 - 20,
            child: GradientText(
              'Block \nBreak',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 40.0, fontFamily: "SuperPixel"),
              colors: const [
                Colors.blue,
                Colors.red,
                Colors.teal,
              ],
            ),
          ),
          const SizedBox(height: 20),
          Center(
            child: ElevatedButton(
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.resolveWith((states) {
                  if (states.contains(MaterialState.pressed)) {
                    return Colors.black12;
                  }
                  return Colors.black12;
                }),
                textStyle: MaterialStateProperty.resolveWith((states) {
                  if (states.contains(MaterialState.pressed)) {
                    return const TextStyle(fontSize: 40);
                  }
                  return const TextStyle(fontSize: 20);
                }),
              ),
              child: GradientText(
                'Start you\'r game',
                textAlign: TextAlign.center,
                style:
                    const TextStyle(fontSize: 15.0, fontFamily: "SuperPixel"),
                colors: const [
                  Color(0xfff94144),
                  Color(0xfff3722c),
                  Color(0xfff8961e),
                  Color(0xfff9844a),
                  Color(0xfff9c74f),
                  Color(0xff90be6d),
                  Color(0xff43aa8b),
                  Color(0xff4d908e),
                  Color(0xff277da1),
                ],
              ),
              onPressed: () {
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => GameScreen(game: game),
                ));
              },
            ),
          ),
          const SizedBox(height: 20),
          GradientText(
            'High Score : ${_prefns.getHighScore}',
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 15.0, fontFamily: "SuperPixel"),
            colors: const [
              Color(0xfff94144),
              Color(0xfff3722c),
              Color(0xfff8961e),
              Color(0xfff9844a),
              Color(0xfff9c74f),
              Color(0xff90be6d),
              Color(0xff43aa8b),
              Color(0xff4d908e),
              Color(0xff277da1),
            ],
          )
        ],
      ),
    );
  }
}

// ignore: must_be_immutable
class GameScreen extends StatelessWidget {
  GameScreen({
    super.key,
    required this.game,
  });

  final BrickBreaker game;
  var text = "0";
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(color: Colors.black
            // gradient: LinearGradient(
            //   begin: Alignment.topCenter,
            //   end: Alignment.bottomCenter,
            //   colors: [
            //     Color(0xffa9d6e5),
            //     Color(0xfff2e8cf),
            //   ],
            // ),
            ),
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8),
                child: Center(
                  child: FittedBox(
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      width: gameWidth,
                      height: gameHeight,
                      child: GameWidget(
                        game: game,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
